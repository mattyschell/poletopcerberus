-- Test cases
-- nothing changes 
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (10,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',100);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (10,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',100);
-- reservation that has changed franchisees
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (15,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',101);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (15,11,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',101);
-- changed x
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (20,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',102);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (20,10,1034200.1,159270.9,1034199,159271,'Y','COMPLETE',102);
-- changed y
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (25,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',103);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (25,10,1034199.1,159271.9,1034199,159271,'Y','COMPLETE',103);
-- changed super special x coord col
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (30,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',104);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (30,10,1034199.1,159270.9,1034198,159271,'Y','COMPLETE',104);
-- changed super special y coord col
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (35,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',105);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (35,10,1034199.1,159270.9,1034199,159270,'Y','COMPLETE',105);
-- gone from inactive to active
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (40,10,1034199.1,159270.9,1034199,159271,'N','COMPLETE',106);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (40,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',106);
-- an ackowledged change: company
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (45,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',107);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (45,12,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',107);
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (45,12,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',107);
-- an ackowledged change: X coord 
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (50,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',108);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (50,10,1034201,159270.9,1034201,159271,'Y','COMPLETE',108);
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (50,10,1034201,159270.9,1034201,159271,'Y','COMPLETE',108);
-- an ackowledged change that has not changed as acknowledged (ie changed again)
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (55,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',109);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (55,10,1034199.1,159999,1034201,159999,'Y','COMPLETE',109);
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (55,10,1034199.1,159888,1034201,159888,'Y','COMPLETE',109);
-- an acknowledged zombie, inactive to active
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (60,10,1034199.1,159270.9,1034199,159271,'N','COMPLETE',110);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (60,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',110);
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (60,10,1034199.1,159270.9,1034199,159271,'Y','COMPLETE',110);
-- a new reservation with status preinsp_req with no pre_install_inspection_id
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (65,10,1034199.1,159270.9,1034199,159270,'Y','PREINSP_REQ',NULL);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (65,10,1034199.1,159270.9,1034199,159270,'Y','PREINSP_REQ',NULL);
-- an acknowledged reservation with status preinsp_req with no pre_install_inspection_id
-- should not be reported
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (70,10,1034199.1,159270.9,1034199,159271,'N','PREINSP_REQ',NULL);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (70,10,1034199.1,159270.9,1034199,159271,'Y','PREINSP_REQ',NULL);
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (70,10,1034199.1,159270.9,1034199,159271,'Y','PREINSP_REQ',NULL);
-- an acknowledged reservation with status preinsp_req with no pre_install_inspection_id
-- that has been acknowledged for some other reason
-- should be reported
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (75,10,1034199.1,159270.9,1034199,159271,'N','PREINSP_REQ',NULL);
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (75,10,1034199.1,159270.9,1034199,159271,'Y','PREINSP_REQ',NULL);
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (75,10,1034199.1,159270.9,1034199,159271,'Y','PREINSP_REQ',111);
-- a perfectly cromulent new reservation
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (100,10,1034000,159000,1034000,159000,'Y','COMPLETE',198);
-- a suspect new reservation with a reservation id less than previously seen
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active, status, pre_install_inspection_id) 
    VALUES 
    (2,10,1035000,158000,1035000,158000,'Y','COMPLETE',199);
COMMIT;
EXIT