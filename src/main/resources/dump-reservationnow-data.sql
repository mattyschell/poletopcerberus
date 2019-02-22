SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET TERMOUT OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET WRAP OFF
SET LINESIZE 32000
SET LONG 32000
SET LONGCHUNKSIZE 32000
SET SERVEROUT OFF
SET RECSEP OFF
SET PAGES 0
SPOOL reservationnow-data-oracle.sql REPLACE
COLUMN SQLSTMTS FORMAT A32000
SELECT 'SET DEFINE OFF' as SQLSTMTS from dual;
SELECT '-- In matters of style swim with the current.' AS SQLSTMTS from dual;
SELECT '-- In matters of principle stand like a rock.' AS SQLSTMTS from dual;
SELECT 'DELETE FROM DOITT_PT_MTF.RESERVATIONNOW;' AS SQLSTMTS from dual;
SELECT q'^INSERT INTO DOITT_PT_MTF.RESERVATIONNOW ^'
       || q'^(reservation_id, company_id, shape_x, shape_y, x_coord, y_coord ^'
       || q'^VALUES (^'
       || a.reservation_id 
       || q'^,^'
       || a.company_id 
       || q'^,^'
       || a.shape.sdo_point.x 
       || q'^,^'
       || a.shape.sdo_point.y
       || q'^,^'
       || a.x_coord
       || q'^,^'
       || a.y_coord 
       || q'^);^' as SQLSTMTS
  FROM doitt_pt.reservation a
  ORDER BY reservation_id;
SELECT 'COMMIT;' AS SQLSTMTS from dual;
SPOOL OFF
EXIT       