--Connecting to user
CONNECT system/oracle;

--PL/SQL code for removing schema
BEGIN
  EXECUTE IMMEDIATE 'DROP USER carinsure CASCADE';
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('');
END;
/ 

--Creating the schema
CREATE USER carinsure IDENTIFIED BY password DEFAULT TABLESPACE USERS;
GRANT ALL PRIVILEGES TO carinsure;

--Connecting to schema
CONNECT carinsure/password;

--PL/SQL block for removing tables
BEGIN
    EXECUTE IMMEDIATE 'drop table payments';
    EXECUTE IMMEDIATE 'drop table vehicles';
    EXECUTE IMMEDIATE 'drop table customers';
    EXECUTE IMMEDIATE 'drop table policies';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('');
END;
/

--Creating tables
CREATE TABLE policies
(
    policy_number NUMBER(15) PRIMARY KEY,
    policy_type VARCHAR2(20) NOT NULL CHECK (policy_type IN ('FULL COVERAGE','LIABILITY COVERAGE')),
    deductible NUMBER(10) NOT NULL CHECK (deductible IN (500, 750, 1000)),
    discount NUMBER(10) CHECK (discount IN (5, 10, 15))
);

CREATE TABLE customers
(
    customer_id NUMBER(10) PRIMARY KEY,
    first_name VARCHAR2(25) NOT NULL,
    last_name VARCHAR2(25) NOT NULL,
    gender VARCHAR2(10),
    date_of_birth DATE,
    license_id VARCHAR2(30) UNIQUE,
    address VARCHAR2(30),
    city VARCHAR2(20), 
    state VARCHAR2(15),
    zip_code NUMBER(10),
    phone_number NUMBER(15)
);

CREATE TABLE vehicles
(
    vehicle_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10) REFERENCES customers(customer_id), 
    policy_number NUMBER(15) REFERENCES policies(policy_number), 
    vin_number VARCHAR2(20) UNIQUE,
    year NUMBER(10),
    make VARCHAR2(15) NOT NULL,
    model VARCHAR2(20) NOT NULL,
    mileage VARCHAR2(15)
);

CREATE TABLE payments
( 
    payment_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10)REFERENCES customers(customer_id),
    policy_number NUMBER(15) REFERENCES policies(policy_number), 
    amount NUMBER(10) NOT NULL,
    payment_method VARCHAR2(15) CHECK (payment_method IN ('CHECKING', 'CREDIT CARD'))
);   

--Inserting data into tables 

INSERT INTO policies VALUES (84650,'FULL COVERAGE',500,5);
INSERT INTO policies VALUES (84651,'FULL COVERAGE',750,10);
INSERT INTO policies VALUES (84652,'LIABILITY COVERAGE',750,10);
INSERT INTO policies VALUES (84653,'FULL COVERAGE',1000,15);
INSERT INTO policies VALUES (84654,'LIABILITY COVERAGE',500,5);
INSERT INTO policies VALUES (84655,'LIABILITY COVERAGE',1000,15);

INSERT INTO customers VALUES (9961,'JACKSON','HYPER','MALE','15-NOV-1989','D400-7836-0001','69821 SOUTH AVENUE','BOISE','ID',8370,2087778976);
INSERT INTO customers VALUES (9962,'ELLA','CANDY','FEMALE','4-FEB-1998','T273-9836-9965','114 EAST SAVVANNAH','ATLANTA','GA',30314,4046317877);
INSERT INTO customers VALUES (9963,'ELIZABETH','BROWN','FEMALE','03-APR-1998','T654-8875-9845','1008 GRAND AVENUE','MACON','GA',31206,4789986793);
INSERT INTO customers VALUES (9964,'JOHNSON','PATEL','MALE','20-SEP-1990','S546-7685-2245','P.O. BOX 2947','CODY','WY',82424,3071984988);
INSERT INTO customers VALUES (9965,'THOMAS','MOORE','MALE','27-FEB-1991','Y659-6211-9999','9153 MAIN STREET','AUNTIN','TX',7810,2145554671);

INSERT INTO vehicles VALUES (101,9961,84650,'4Y1SL65848Z411439',2009,'FORD','FUSION','30MPH');
INSERT INTO vehicles VALUES (102,9962,84654,'5Q5SR682972972303',2000,'TAYOTA','CAMRY','28MPH');
INSERT INTO vehicles VALUES (103,9963,84653,'7Z8BK0983716837290',2003,'BENZ','GLD','22MPH');
INSERT INTO vehicles VALUES (104,9964,84651,'9K0RM092834689270',2006,'BMW','M4','15MPH');
INSERT INTO vehicles VALUES (105,9965,84652,'1S9KP7365292975362',2010,'JEEP','WARANGLER','20MPH');
INSERT INTO vehicles VALUES (106,9962,84653,'2B7DR983732001937',2011,'HONDA','CIVIC','23MPH');
INSERT INTO vehicles VALUES (107,9965,84652,'8P8MK827649238107',2015,'AUDI','Q4','18MPH');
INSERT INTO vehicles VALUES (108,9964,84655,'4M2EE987684029263',2020,'BENTLY','CONTINENTAL GT','18MPH');
INSERT INTO vehicles VALUES (109,9962,84651,'6T5ST9873463240798',2021,'JEEP','COMPASS','29MPH');

INSERT INTO payments VALUES (201,9961,84650,125,'CHECKING');
INSERT INTO payments VALUES (202,9962,84654,125,'CREDIT CARD'); 
INSERT INTO payments VALUES (203,9963,84653,75,'CREDIT CARD'); 
INSERT INTO payments VALUES (204,9964,84651,100,'CHECKING');
INSERT INTO payments VALUES (205,9965,84652,100,'CREDIT CARD');
INSERT INTO payments VALUES (206,9962,84653,75,'CHECKING'); 
INSERT INTO payments VALUES (207,9965,84652,100,'CHECKING'); 
INSERT INTO payments VALUES (208,9964,84655,75,'CREDIT CARD');
INSERT INTO payments VALUES (209,9962,84651,100,'CHECKING');

--PL/SQL code for removing roles 
BEGIN 
    EXECUTE IMMEDIATE ' drop role agent';
    EXECUTE IMMEDIATE ' drop role users';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('');
END;
/

--Creating roles
CREATE ROLE agent; 
GRANT INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO agent;

CREATE ROLE users;
GRANT SELECT ANY TABLE TO users;
GRANT UPDATE ON customers TO users;
GRANT UPDATE ON vehicles TO users;

--PL.SQL for removing users
BEGIN
    EXECUTE IMMEDIATE 'drop user mabbu';
    EXECUTE IMMEDIATE 'drop user cloud';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('');
END;
/

--Creating users 
CREATE USER mabbu IDENTIFIED BY password DEFAULT TABLESPACE USERS;
CREATE USER cloud IDENTIFIED BY password DEFAULT TABLESPACE USERS;

--Granting roles to users
GRANT agent TO mabbu;
GRANT users TO cloud;

--Using joins and group functions

--Determining the which policies are using the customers? 
SELECT customers.customer_id, first_name||' '||last_name  "Customer Name", gender, policies.policy_number, policy_type 
FROM customers, vehicles, policies
WHERE customers.customer_id = vehicles.customer_id
AND vehicles.policy_number = policies.policy_number
ORDER BY customers.customer_id;

--Determining the customers payment method 
SELECT payments.payment_id,first_name||' '||last_name  "Customer Name", payment_method
FROM customers JOIN payments
ON customers.customer_id = payments.customer_id;

--Determining the total amount recived from checking payment method 
SELECT SUM(amount) FROM payments WHERE payment_method = 'CHECKING';

--PL/SQL code for remove stored procedures
BEGIN 
    EXECUTE IMMEDIATE ' drop procedure delete_customers';
    EXECUTE IMMEDIATE ' drop procedure update_customers';
    EXECUTE IMMEDIATE ' drop procedure insert_customers';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('');
END;
/

--Stored procedure
CREATE OR REPLACE PROCEDURE insert_customers
(
    
    customer_id_param NUMBER ,
    first_name_param VARCHAR2 DEFAULT NULL,
    last_name_param VARCHAR2 DEFAULT NULL,
    gender_param VARCHAR2 DEFAULT NULL,
    date_of_birth_param DATE DEFAULT sysdate,
    license_id_param VARCHAR2 DEFAULT NULL,
    address_param VARCHAR2 DEFAULT NULL,
    city_param VARCHAR2 DEFAULT NULL,
    state_param VARCHAR2 DEFAULT NULL,
    zip_code_param NUMBER DEFAULT NULL,
    phone_number_param NUMBER DEFAULT NULL
)
AS
    BEGIN
        INSERT INTO customers VALUES
        (
            customer_id_param,
            first_name_param,
            last_name_param,
            gender_param,
            date_of_birth_param,
            license_id_param,
            address_param,
            city_param,
            state_param,
            zip_code_param,
            phone_number_param
        );
COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END;
/
EXEC insert_customers(9966,'AVERY','SHON','FEMALE',NULL,NULL,NULL,NULL,NULL,NULL,NULL);

SELECT * FROM customers;

CREATE OR REPLACE PROCEDURE update_customers
(
    customer_id_param       customers.customer_id%TYPE DEFAULT NULL,
    first_name_param        customers.first_name%TYPE DEFAULT NULL,
    last_name_param         customers.last_name%TYPE DEFAULT NULL,
    gender_param            customers.gender%TYPE DEFAULT NULL,
    date_of_birth_param     customers.date_of_birth%TYPE DEFAULT SYSDATE,
    license_id_param        customers.license_id%TYPE DEFAULT NULL,
    address_param           customers.address%TYPE DEFAULT NULL,
    city_param              customers.city%TYPE DEFAULT NULL,
    state_param             customers.state%TYPE DEFAULT NULL,
    zip_code_param          customers.zip_code%TYPE DEFAULT NULL,
    phone_number_param      customers.phone_number%TYPE DEFAULT NULL
)
AS 
BEGIN
    UPDATE customers SET
        date_of_birth=date_of_birth_param,
        license_id=license_id_param,
        address=address_param,
        city=city_param,
        state = state_param,
        zip_code = zip_code_param,
        phone_number=phone_number_param
        WHERE customer_id=customer_id_param;
        COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
/

BEGIN 
    update_customers(
    date_of_birth_param=>'29-SEP-1998',
    license_id_param=>'Z876-9863-5647',
    address_param => 'P.O. BOX 651',
    city_param => 'EAST POINT',
    state_param => 'FLs',
    zip_code_param => 32328,
    phone_number_param=>3059845672,
    customer_id_param=>9966);
END;
/
SELECT * FROM customers;

CREATE OR REPLACE PROCEDURE delete_customers
(
    customer_id_param       customers.customer_id%TYPE
)
AS
BEGIN
    DELETE FROM customers WHERE customer_id = customer_id_param;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
END;
/

CALL delete_customers(9966);

SELECT * FROM customers;

--PL/SQL code for remove stored function
BEGIN 
    EXECUTE IMMEDIATE ' drop function get_payment_amount';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('');
END;
/
--Creating stored function
CREATE OR REPLACE FUNCTION get_payment_amount
(
    payment_id_param payments.payment_id%TYPE
)
RETURN NUMBER
AS
    amount_param NUMBER;
BEGIN
    SELECT amount INTO amount_param
    FROM payments 
    WHERE payment_id = payment_id_param;
RETURN
    amount_param;
END;
/

SELECT payment_id, policy_number, get_payment_amount(payment_id) amount
FROM payments WHERE payment_method = 'CHECKING'
ORDER BY amount;
