SET ECHO OFF
SET FEEDBACK ON
SET VERIFY ON
SET HEADING ON
SET SERVEROUTPUT ON
SPOOL poletopcerberus_output.txt REPLACE
COLUMN WORKINGSCHEMA FORMAT A32
COLUMN WORKINGDATABASE FORMAT A32
-- part 1: logging clues
SELECT TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MON-DD HH:MM:SS AM') AS CURRENT_TIME FROM DUAL;
SELECT user AS WORKINGSCHEMA, global_name AS WORKINGDATABASE FROM global_name;
-- part 2: total failures MAYDAY MAYDAY, plus last update record
DECLARE
   kountsnap    pls_integer;
   kountnow     pls_integer;
   kountack     pls_integer;
BEGIN
    BEGIN
        --snapshot 0 will be allowed on initialization
        SELECT count(*) INTO kountsnap FROM reservationsnapshot;
        SELECT count(*) INTO kountnow FROM reservationnow;
        IF  kountsnap = 0 
        AND kountnow > 0
        THEN
            dbms_output.put_line('WARN, no records in target reservationsnapshot table');
            dbms_output.put_line('This must be an initialization run on the target');
        END IF;
        IF  kountnow = 0
        AND kountsnap > 0
        THEN
           raise_application_error(-20001, 'FAIL, no records in target reservationnow table');
        END IF;
        SELECT count(*) INTO kountack FROM reservationack; -- must exist, could be empty
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
DECLARE
   kountsnap    pls_integer;
BEGIN
    --init check
    SELECT count(*) INTO kountsnap FROM reservationsnapshot;
    IF kountsnap > 0 
    THEN
        --SOP
        INSERT INTO reservationsnapshot 
            (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active)
        SELECT reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active
        FROM reservationnow b
        WHERE 
            b.reservation_id NOT IN (SELECT reservation_id FROM reservationsnapshot)
        AND b.reservation_id > (SELECT MAX(reservation_id) FROM reservationsnapshot);
    ELSE
        INSERT INTO reservationsnapshot 
            (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active)
        SELECT reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active
        FROM reservationnow b;
    END IF;
COMMIT;
END;
/
-- section 2: actual QA
DECLARE
   TYPE NUMBERARRAY IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
   baddiez          NUMBERARRAY;
   psql             VARCHAR2(4000);
   -- sqlplus cuts at 4k
   baddieput        VARCHAR2(12000);
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
         || '   ((ROUND(a.shape_x) <> ROUND(b.shape_x) OR  ROUND(a.shape_y) <> ROUND(b.shape_y)) AND c.reservation_id IS NULL) '
         || 'OR (c.reservation_id IS NOT NULL AND (ROUND(c.shape_x) <> ROUND(a.shape_x) OR ROUND(c.shape_y) <> ROUND(a.shape_y))) '
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
         || '   ((ROUND(a.x_coord) <> ROUND(b.x_coord) OR ROUND(a.y_coord) <> ROUND(b.y_coord)) AND c.reservation_id IS NULL) '
         || 'OR '
         || '   (c.reservation_id IS NOT NULL AND (ROUND(c.x_coord) <> ROUND(a.x_coord) OR ROUND(c.y_coord) <> ROUND(a.y_coord))) '
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
        IF LENGTH(baddieput) > 3900
        THEN
            dbms_output.put_line(baddieput);
        END IF;
        RAISE_APPLICATION_ERROR(-20001,SUBSTR(baddieput,1,3900));
    END IF;
END;
/
SPOOL OFF
EXIT