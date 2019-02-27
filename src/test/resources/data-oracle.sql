-- Test cases
-- nothing changes 
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (10,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (10,10,1034199.1,159270.9,1034199,159271,'Y');
-- reservation that has changed franchisees
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (15,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (15,11,1034199.1,159270.9,1034199,159271,'Y');
-- changed x
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (20,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (20,10,1034199,159270.9,1034199,159271,'Y');
-- changed y
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (25,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (25,10,1034199.1,159271.0,1034199,159271,'Y');
-- changed super special x coord col
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (30,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (30,10,1034199.1,159270.9,1034198,159271,'Y');
-- changed super special y coord col
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (35,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (35,10,1034199.1,159270.9,1034199,159271.1,'Y');
-- gone from inactive to active
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (40,10,1034199.1,159270.9,1034199,159271,'N');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (40,10,1034199.1,159270.9,1034199,159271,'Y');
-- an ackowledged change: company
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (45,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (45,12,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (45,12,1034199.1,159270.9,1034199,159271,'Y');
-- an ackowledged change: X coord 
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (50,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (50,10,1034201,159270.9,1034201,159271,'Y');
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (50,10,1034201,159270.9,1034201,159271,'Y');
-- an ackowledged change that has not changed as acknowledged (ie changed again)
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (55,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (55,10,1034199.1,159999,1034201,159999,'Y');
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (55,10,1034199.1,159888,1034201,159888,'Y');
-- an acknowledged zombie, inactive to active
INSERT INTO RESERVATIONSNAPSHOT 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (60,10,1034199.1,159270.9,1034199,159271,'N');
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (60,10,1034199.1,159270.9,1034199,159271,'Y');
INSERT INTO RESERVATIONACK 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (60,10,1034199.1,159270.9,1034199,159271,'Y');
-- a perfectly cromulent new reservation
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (100,10,1034000,159000,1034000,159000,'Y');
-- a suspect new reservation with a reservation id less than previously seen
INSERT INTO RESERVATIONNOW 
    (reservation_id, company_id, shape_x, shape_y, x_coord, y_coord, active) 
    VALUES 
    (2,10,1035000,158000,1035000,158000,'Y');
COMMIT;
EXIT