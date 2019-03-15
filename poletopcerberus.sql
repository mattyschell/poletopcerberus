SET ECHO OFF
SET FEEDBACK ON
SET VERIFY ON
SET HEADING ON
SET SERVEROUTPUT ON
SPOOL poletopcerberus_output.txt REPLACE
COLUMN WORKINGSCHEMA FORMAT A32
COLUMN WORKINGDATABASE FORMAT A32
COLUMN report FORMAT A9999
-- part 1: logging clues
SELECT TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MON-DD HH:MM:SS AM') AS CURRENT_TIME FROM DUAL;
SELECT user AS WORKINGSCHEMA, global_name AS WORKINGDATABASE FROM global_name;
DELETE FROM reservationreport;
COMMIT;
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
-- these will be frozen in their current state - pending or whatever
-- the data that gets to reservationsnapshot at this point should not ever 
-- change
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
   ackiez           NUMBERARRAY;
   psql             VARCHAR2(4000);
   asql             VARCHAR2(4000);    
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
         || 'OR (c.reservation_id IS NOT NULL AND c.company_id <> a.company_id) '
         || 'ORDER BY a.reservation_id ';
    asql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationack a '
         || 'INNER JOIN '
         || '   reservationsnapshot b '
         || 'ON a.reservation_id = b.reservation_id '
         || 'WHERE '
         || '    a.company_id <> b.company_id '
         || 'ORDER BY a.reservation_id ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez;
    FORALL ii IN 1 .. baddiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING baddiez(ii)
                                                      ,'POLETOPERROR'
                                                      ,'changed franchisees';                
    COMMIT; 
    baddiez.DELETE;
    EXECUTE IMMEDIATE asql BULK COLLECT INTO ackiez;
    FORALL ii IN 1 .. ackiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING ackiez(ii)
                                                      ,'POLETOPACKNOWLEDGED'
                                                      ,'changed franchisees';                
    COMMIT; 
    ackiez.DELETE;
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
         || '   ((ROUND(a.shape_x) <> ROUND(b.shape_x) OR ROUND(a.shape_y) <> ROUND(b.shape_y)) AND c.reservation_id IS NULL) '
         || 'OR (c.reservation_id IS NOT NULL AND (ROUND(c.shape_x) <> ROUND(a.shape_x) OR ROUND(c.shape_y) <> ROUND(a.shape_y))) '
         || 'ORDER BY a.reservation_id ';
    asql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationack a '
         || 'INNER JOIN '
         || '   reservationsnapshot b '
         || 'ON a.reservation_id = b.reservation_id '
         || 'WHERE '
         || '   ROUND(a.shape_x) <> ROUND(b.shape_x) OR ROUND(a.shape_y) <> ROUND(b.shape_y) '
         || 'ORDER BY a.reservation_id ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez;
    FORALL ii IN 1 .. baddiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING baddiez(ii)
                                                      ,'POLETOPERROR'
                                                      ,'moved x and/or y (geometry)';                
    COMMIT; 
    baddiez.DELETE;
    EXECUTE IMMEDIATE asql BULK COLLECT INTO ackiez;
    FORALL ii IN 1 .. ackiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING ackiez(ii)
                                                      ,'POLETOPACKNOWLEDGED'
                                                      ,'moved x and/or y (geometry)';                
    COMMIT;
    ackiez.DELETE;
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
    asql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationack a '
         || 'INNER JOIN '
         || '   reservationsnapshot b '
         || 'ON a.reservation_id = b.reservation_id '
         || 'WHERE '
         || '   ROUND(a.x_coord) <> ROUND(b.x_coord) OR ROUND(a.y_coord) <> ROUND(b.y_coord) '
         || 'ORDER BY a.reservation_id ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez;
    FORALL ii IN 1 .. baddiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING baddiez(ii)
                                                      ,'POLETOPERROR'
                                                      ,'moved x and/or y (data)';                
    COMMIT; 
    baddiez.DELETE;
    EXECUTE IMMEDIATE asql BULK COLLECT INTO ackiez;
    FORALL ii IN 1 .. ackiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING ackiez(ii)
                                                      ,'POLETOPACKNOWLEDGED'
                                                      ,'moved x and/or y (data)';                
    COMMIT;
    ackiez.DELETE;
    -- zombie inactive to active - inactive should only be at end of reservation life
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
    asql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationack a '
         || 'INNER JOIN '
         || '   reservationsnapshot b '
         || 'ON a.reservation_id = b.reservation_id '
         || 'WHERE  '
         || '    a.active = :p1 '
         || 'AND b.active = :p2 '
         || 'ORDER BY a.reservation_id ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez USING 'Y','N','N';
    FORALL ii IN 1 .. baddiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING baddiez(ii)
                                                      ,'POLETOPERROR'
                                                      ,'zombiefied and became active again';                
    COMMIT; 
    baddiez.DELETE;
    EXECUTE IMMEDIATE asql BULK COLLECT INTO ackiez USING 'Y','N';
    FORALL ii IN 1 .. ackiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING ackiez(ii)
                                                      ,'POLETOPACKNOWLEDGED'
                                                      ,'zombiefied and became active again';                
    COMMIT;
    ackiez.DELETE;     
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
    --not gonna mess with acknowledged version of this 
    FORALL ii IN 1 .. baddiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING baddiez(ii)
                                                      ,'POLETOPERROR'
                                                      ,'is suspect with lower ID than we have seen';                
    COMMIT; 
    baddiez.DELETE;
    -- status preinsp_req with no pre_install_inspection_id
    -- only check reservationnow, initial inserts into reservationsnapshot
    -- are at whatever status they had at that time
    psql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationnow a '
         || 'LEFT JOIN '
         || '   reservationack c '
         || 'ON a.reservation_id = c.reservation_id '
         || 'WHERE '
         || '   a.status = :p1 AND a.pre_install_inspection_id IS NULL '
         || 'AND ( (c.reservation_id IS NULL) '
         || '      OR (c.reservation_id IS NOT NULL and c.pre_install_inspection_id IS NOT NULL) '
         || '    ) '
         || 'ORDER by a.reservation_id ';
    asql := 'SELECT a.reservation_id '
         || 'FROM '
         || '   reservationack a '
         || 'WHERE '
         || '   a.status = :p1 AND a.pre_install_inspection_id IS NULL '
         || 'ORDER by a.reservation_id ';
    EXECUTE IMMEDIATE psql BULK COLLECT INTO baddiez USING 'PREINSP_REQ'; 
    FORALL ii IN 1 .. baddiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING baddiez(ii)
                                                      ,'POLETOPERROR'
                                                      ,'is missing a pre_install_inspection_id';                
    COMMIT; 
    baddiez.DELETE;
    EXECUTE IMMEDIATE asql BULK COLLECT INTO ackiez USING 'PREINSP_REQ';
    FORALL ii IN 1 .. ackiez.COUNT
        EXECUTE IMMEDIATE 'INSERT INTO reservationreport '
                       || '(reservation_id, qatype, message) '
                       || 'VALUES(:p1,:p2,:p3) ' USING ackiez(ii)
                                                      ,'POLETOPACKNOWLEDGED'
                                                      ,'is missing a pre_install_inspection_id';                
    COMMIT;
    ackiez.DELETE;   
END;
/
SELECT
   a.qatype || ': reservation ' || TO_CHAR(a.reservation_id) || ' ' || a.message 
AS report
FROM 
    reservationreport a 
WHERE a.qatype = 'POLETOPERROR'
ORDER BY a.reservation_id;
SELECT
   a.qatype || ': reservation ' || TO_CHAR(a.reservation_id) || ' ' || a.message 
AS report
FROM 
    reservationreport a 
WHERE a.qatype = 'POLETOPACKNOWLEDGED'
ORDER BY a.reservation_id;
SPOOL OFF
EXIT