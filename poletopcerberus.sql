SET ECHO OFF
SET FEEDBACK ON
SET VERIFY ON
SET HEADING ON
SPOOL poletopcerberus_output.txt REPLACE
COLUMN WORKINGSCHEMA FORMAT A32
COLUMN WORKINGDATABASE FORMAT A32
-- part 1: logging clues
SELECT TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MON-DD HH:MM:SS AM') AS CURRENT_TIME FROM DUAL;
SELECT user AS WORKINGSCHEMA, global_name AS WORKINGDATABASE FROM global_name;
-- part 2: total failures MAYDAY MAYDAY, plus last update record
DECLARE
   kount pls_integer;
BEGIN
    BEGIN
        SELECT count(*) INTO kount FROM reservationsnapshot;
    IF kount = 0
    THEN
       raise_application_error(-20001, 'FAIL, no records in target reservationsnapshot table');
    END IF;
    SELECT count(*) INTO kount FROM reservationnow;
    IF kount = 0
    THEN
       raise_application_error(-20001, 'FAIL, no records in target reservationnow table');
    END IF;
    SELECT count(*) INTO kount FROM reservationack; -- must exist, could be empty
    EXCEPTION
    WHEN OTHERS 
    THEN
        raise_application_error(-20001, SQLERRM || ' before running QA checks');
    END;
    MERGE INTO last_update a
        USING (SELECT 'POLETOPCERBERUS' AS job_name,
                      'RESERVATIONNOW' AS table_name,
                      SYSTIMESTAMP AS last_update
               FROM DUAL) d
    ON (a.job_name = d.job_name AND a.table_name = d.table_name)
    WHEN MATCHED
    THEN
       UPDATE SET a.last_update = SYSTIMESTAMP
    WHEN NOT MATCHED
    THEN
        INSERT     (a.job_name, a.table_name, a.last_update)
            VALUES (d.job_name, d.table_name, d.last_update);
   COMMIT;
END;
/
-- insert newly created reservations from latest into snapshot
BEGIN
   INSERT INTO reservationsnapshot 
      (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active)
   SELECT reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active
   FROM reservationnow b
   WHERE 
       b.reservation_id NOT IN (SELECT reservation_id FROM reservationsnapshot)
   AND b.reservation_id > (SELECT MAX(reservation_id) FROM reservationsnapshot);
COMMIT;
END;
/
-- section 2: actual QA
DECLARE
   TYPE NUMBERARRAY IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
   baddiez          NUMBERARRAY;
   psql             VARCHAR2(4000);
   baddieput        VARCHAR2(4000);
BEGIN
    -- changed franchisees
    psql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationnow a '
         || 'INNER JOIN '
         || '   reservationsnapshot b '
         || 'ON a.reservation_id = b.reservation_id '
         || 'LEFT JOIN '
         || '   reservationack c '
         || 'ON a.reservation_id = c.reservation_id '
         || 'WHERE '
         || '    a.company_id <> b.company_id '
         || 'AND c.reservation_id IS NULL '
         || 'OR (c.reservation_id IS NOT NULL AND c.company_id <> a.company_id) ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez;
    FOR i IN 1 .. baddiez.COUNT
    LOOP
        baddieput := baddieput || CHR(10) || ' POLETOPERROR: reservation '
                               || baddiez(i) || ' changed franchisees ';  
    END LOOP;
    baddiez.DELETE;
    --changed x or changed y (from sdogeometry)
    psql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationnow a '
         || 'INNER JOIN '
         || '   reservationsnapshot b '
         || 'ON a.reservation_id = b.reservation_id '
         || 'LEFT JOIN '
         || 'reservationack c '
         || 'ON a.reservation_id = c.reservation_id '
         || 'WHERE '
         || '   ((a.shape_x <> b.shape_x OR  a.shape_y <> b.shape_y) AND c.reservation_id IS NULL) '
         || 'OR (c.reservation_id IS NOT NULL AND (c.shape_x <> a.shape_x OR c.shape_y <> a.shape_y)) '
         || 'ORDER BY a.reservation_id ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez;
    FOR i IN 1 .. baddiez.COUNT
    LOOP
        baddieput := baddieput || CHR(10) || ' POLETOPERROR: reservation '
                               || baddiez(i) || ' moved x and/or y (geometry) ';  
    END LOOP;
    baddiez.DELETE;
    -- the other x_coord and y_coord cols
    psql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationnow a '
         || 'INNER JOIN '
         || '   reservationsnapshot b '
         || 'ON a.reservation_id = b.reservation_id '
         || 'LEFT JOIN '
         || '   reservationack c '
         || 'ON  a.reservation_id = c.reservation_id '
         || 'WHERE '
         || '   ((a.x_coord <> b.x_coord OR  a.y_coord <> b.y_coord ) AND c.reservation_id IS NULL) '
         || 'OR '
         || '   (c.reservation_id IS NOT NULL AND (c.x_coord <> a.x_coord OR c.y_coord <> a.y_coord)) '
         || 'ORDER BY a.reservation_id ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez;
    FOR i IN 1 .. baddiez.COUNT
    LOOP
        baddieput := baddieput || CHR(10) || ' POLETOPERROR: reservation '
                               || baddiez(i) || ' moved x and/or y (data) ';  
    END LOOP; 
    baddiez.DELETE;
    -- zombie inactive to active
    psql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationnow a '
         || 'INNER JOIN '
         || '   reservationsnapshot b '
         || 'ON a.reservation_id = b.reservation_id '
         || 'LEFT JOIN '
         || '   reservationack c '
         || 'ON a.reservation_id = c.reservation_id '
         || 'WHERE  '
         || '    a.active = :p1 '
         || 'AND b.active = :p2 '
         || 'AND (c.reservation_id IS NULL OR (c.reservation_id IS NOT NULL AND c.active = :p3)) '
         || 'ORDER BY a.reservation_id ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez USING 'Y','N','N';
    FOR i IN 1 .. baddiez.COUNT
    LOOP
        baddieput := baddieput || CHR(10) || ' POLETOPERROR: reservation '
                               || baddiez(i) || ' zombiefied, became active again ';  
    END LOOP; 
    baddiez.DELETE;     
    -- a new reservation ID, never seen before, that is lower in the sequence 
    -- than previous snapshots. Depends on initial insert working correctly
    -- for new, higher sequence reservation ids
    psql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationnow a '
         || 'WHERE '
         || '   a.reservation_id NOT IN '
         || '   (SELECT reservation_id FROM reservationsnapshot) ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez; 
    FOR i IN 1 .. baddiez.COUNT
    LOOP
        baddieput := baddieput || CHR(10) || ' POLETOPERROR: reservation '
                               || baddiez(i) || ' is suspect, lower ID than we have seen in the past ';  
    END LOOP; 
    baddiez.DELETE;
    IF length(baddieput) > 0
    THEN
        RAISE_APPLICATION_ERROR(-20001,baddieput);
    END IF;
END;
/
SPOOL OFF
EXIT