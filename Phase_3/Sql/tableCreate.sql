DROP TYPE IF EXISTS saving_type;
CREATE TYPE saving_type AS ENUM (
  'deposit_account',
  'money_market_account',
  'certificate'
);

DROP TYPE IF EXISTS transaction_type;
CREATE TYPE transaction_type AS ENUM (
  'deposit',
  'transfer',
  'profit'
);

DROP TYPE IF EXISTS instalment_status;
CREATE TYPE instalment_status AS ENUM (
  'paid',
  'unpaid'
);

DROP TYPE IF EXISTS loan_status;
CREATE TYPE loan_status AS ENUM (
  'requested',
  'active',
  'paid'
);

DROP TYPE IF EXISTS employee_type;
CREATE TYPE employee_type AS ENUM (
  'manager',
  'staff'
);

DROP TYPE IF EXISTS req_status;
CREATE TYPE req_status AS ENUM (
  'pending',
  'accepted',
  'declined'
);

DROP TABLE IF EXISTS bank_account;
CREATE TABLE bank_account (
  "account_number" int PRIMARY KEY,
  "user_id" int,
  "balance" int,
  "activation_date" timestamp,
  "is_active" boolean
);

DROP TABLE IF EXISTS saving_data;
CREATE TABLE saving_data (
  "account_number" int PRIMARY KEY,
  "profit_percentage" int,
  "type" saving_type
);

DROP TABLE IF EXISTS user_account;
CREATE TABLE user_account (
  "user_id" SERIAL PRIMARY KEY,
  "name" varchar(50)
);

DROP TABLE IF EXISTS legal_account;
CREATE TABLE legal_account (
  "company_id" int PRIMARY KEY,
  "user_id" int
);

DROP TABLE IF EXISTS physical_account;
CREATE TABLE physical_account (
  "national_id" int PRIMARY KEY,
  "user_id" int,
  "signature" varchar(200), -- address to file
  "finger_print" varchar(200), -- address to file
  "family_name" varchar(50)
);

DROP TABLE IF EXISTS "transaction";
CREATE TABLE "transaction" (
  "transaction_number" int PRIMARY KEY,
  "amount" int,
  "type" transaction_type,
  "date" timestamp,
  "description" varchar(200),
  "origin" int,
  "destination" int
);

DROP TABLE IF EXISTS loan;
CREATE TABLE loan (
  "loan_number" SERIAL PRIMARY KEY,
  "user_id" int,
  "amount" int,
  "status" loan_status,
  "start_date" timestamp,
  "end_date" timestamp,
  "remaining_number" int,
  "profit_percentage" int,
  "supervisor_id" int
);

DROP TABLE IF EXISTS instalment;
CREATE TABLE instalment (
  "loan_number" int,
  "number" int,
  "data" timestamp,
  "amount" int,
  "status" instalment_status,
  "transaction_number" int UNIQUE,
  PRIMARY KEY ("loan_number", "number")
);

DROP TABLE IF EXISTS employee;
CREATE TABLE employee (
  "employee_num" int PRIMARY KEY,
  "full_name" varchar,
  "type" employee_type
);

DROP TABLE IF EXISTS manager;
CREATE TABLE manager (
  "employee_num" int PRIMARY KEY
);

DROP TABLE IF EXISTS activation_req;
CREATE TABLE activation_req (
  "user_id" int,
  "req_date" timestamp UNIQUE,
  "is_accepted" req_status,
  "employee_num" int,
  PRIMARY KEY ("user_id", "req_date")
);

DROP TABLE IF EXISTS bank_account_req;
CREATE TABLE bank_account_req (
  "user_id" int,
  "req_date" timestamp UNIQUE,
  "is_accepted" req_status,
  "balance" int,
  "is_saving" boolean,
  "profit_percentage" int,
  "type" saving_type,
  "employee_num" int,
  PRIMARY KEY ("user_id", "req_date")
);

DROP TABLE IF EXISTS loan_req;
CREATE TABLE loan_req (
  "user_id" int,
  "req_date" timestamp UNIQUE,
  "is_accepted" req_status,
  "amount" int,
  "start_date" timestamp,
  "end_date" timestamp,
  "instalment_number" int,
  "profit_percentage" int,
  "manager_num" int,
  PRIMARY KEY ("user_id", "req_date")
);

ALTER TABLE bank_account 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE saving_data 
ADD FOREIGN KEY ("account_number") 
REFERENCES bank_account ("account_number") 
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE physical_account 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE legal_account 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE "transaction" 
ADD FOREIGN KEY ("origin") 
REFERENCES bank_account ("account_number")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE "transaction" 
ADD FOREIGN KEY ("destination") 
REFERENCES bank_account ("account_number")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE loan 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE loan 
ADD FOREIGN KEY ("supervisor_id") 
REFERENCES manager ("employee_num")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE instalment 
ADD FOREIGN KEY ("loan_number") 
REFERENCES loan ("loan_number")
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE instalment 
ADD FOREIGN KEY ("transaction_number") 
REFERENCES "transaction" ("transaction_number")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE manager 
ADD FOREIGN KEY ("employee_num") 
REFERENCES employee ("employee_num")
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE activation_req 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE activation_req 
ADD FOREIGN KEY ("employee_num") 
REFERENCES employee ("employee_num")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE bank_account_req 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE bank_account_req 
ADD FOREIGN KEY ("employee_num") 
REFERENCES employee ("employee_num")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE loan_req 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE loan_req 
ADD FOREIGN KEY ("manager_num") 
REFERENCES manager ("employee_num")
ON DELETE RESTRICT
ON UPDATE RESTRICT;