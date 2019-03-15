CREATE TABLE LAST_UPDATE (
    job_name             VARCHAR2(100) NOT NULL
   ,table_name           VARCHAR2(100) NOT NULL
   ,last_update          TIMESTAMP NOT NULL
   ,CONSTRAINT last_updatepkc PRIMARY KEY (job_name, table_name)
);
CREATE TABLE RESERVATIONSNAPSHOT (
    reservation_id               NUMBER
   ,company_id                   NUMBER
   ,shape_x                      NUMBER
   ,shape_y                      NUMBER
   ,x_coord                      NUMBER
   ,y_coord                      NUMBER
   ,active                       VARCHAR2(1)
   ,status                       VARCHAR2(50)
   ,pre_install_inspection_id    NUMBER
   ,CONSTRAINT reservationsnapshotpkc PRIMARY KEY (reservation_id)
);
CREATE TABLE RESERVATIONNOW (
    reservation_id               NUMBER
   ,company_id                   NUMBER
   ,shape_x                      NUMBER
   ,shape_y                      NUMBER
   ,x_coord                      NUMBER
   ,y_coord                      NUMBER
   ,active                       VARCHAR2(1)
   ,status                       VARCHAR2(50)
   ,pre_install_inspection_id    NUMBER
   ,CONSTRAINT reservationnowpkc PRIMARY KEY (reservation_id)
); 
CREATE TABLE RESERVATIONACK (
    reservation_id               NUMBER
   ,company_id                   NUMBER
   ,shape_x                      NUMBER
   ,shape_y                      NUMBER
   ,x_coord                      NUMBER
   ,y_coord                      NUMBER
   ,active                       VARCHAR2(1)
   ,status                       VARCHAR2(50)
   ,pre_install_inspection_id    NUMBER
   ,CONSTRAINT reservationackpkc PRIMARY KEY (reservation_id)
); 
CREATE TABLE RESERVATIONREPORT (
     reservation_id              NUMBER
    ,qatype                      VARCHAR2(32)
    ,message                     VARCHAR2(4000)
);