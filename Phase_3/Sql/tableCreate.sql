DROP TYPE IF EXISTS saving_type;
CREATE TYPE saving_type AS ENUM (
  'deposit_account',
  'money_market_account',
  'certificate'
);

DROP TYPE IF EXISTS transaction_type;
CREATE TYPE transaction_type AS ENUM (
  'withdraw',
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

DROP TABLE IF EXISTS bank_account CASCADE;
CREATE TABLE bank_account (
  "account_number" SERIAL PRIMARY KEY,
  "user_id" INT,
  "balance" INT CHECK ("balance" >= 0),
  "activation_date" TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "is_active" BOOLEAN NOT NULL DEFAULT FALSE,
  "profit_percentage" INT NOT NULL DEFAULT 0 CHECK ("profit_percentage" >= 0 AND "profit_percentage" <= 100), 
  "type" saving_type NOT NULL
);

-- DROP TABLE IF EXISTS saving_data;
-- CREATE TABLE saving_data (
--   "account_number" int PRIMARY KEY,
--   "profit_percentage" int,
--   "type" saving_type
-- );

DROP TABLE IF EXISTS user_account;
CREATE TABLE user_account (
  "user_id" SERIAL PRIMARY KEY,
  "name" VARCHAR(50) NOT NULL, 
  "is_active" BOOLEAN NOT NULL DEFAULT FALSE
);

DROP TABLE IF EXISTS legal_account;
CREATE TABLE legal_account (
  "company_id" VARCHAR(20) PRIMARY KEY, -- may start with zero
  "user_id" INT NOT NULL
);

DROP TABLE IF EXISTS physical_account;
CREATE TABLE physical_account (
  "national_id" VARCHAR(20) PRIMARY KEY, -- may start with zero
  "user_id" INT NOT NULL,
  "signature" VARCHAR(200), -- address to file
  "finger_print" VARCHAR(200), -- address to file
  "family_name" VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS "transaction";
CREATE TABLE "transaction" (
  "transaction_number" SERIAL PRIMARY KEY,
  "amount" INT DEFAULT 0 CHECK ("amount" >= 0),
  "type" transaction_type NOT NULL,
  "date" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "description" VARCHAR(200),
  "origin" INT,
  "destination" INT CHECK ("destination" IS NOT NULL OR "origin" IS NOT NULL)
);

-- trigger to check not both origin and destination are null - check type and nullness of origin and dest

DROP TABLE IF EXISTS loan;
CREATE TABLE loan (
  "loan_number" SERIAL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "amount" INT NOT NULL CHECK ("amount" >= 0),
  "status" loan_status DEFAULT 'requested',
  "start_date" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "end_date" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "remaining_number" INT NOT NULL CHECK("remaining_number" >= 0),
  "profit_percentage" INT NOT NULL CHECK("profit_percentage" >= 0),
  "supervisor_id" INT
);

DROP TABLE IF EXISTS instalment;
CREATE TABLE instalment (
  "loan_number" INT NOT NULL,
  "number" SERIAL NOT NULL CHECK ("number" > 0),
  "date" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "amount" INT NOT NULL CHECK ("amount" >= 0),
  "status" instalment_status NOT NULL DEFAULT 'unpaid',
  "transaction_number" INT UNIQUE,
  PRIMARY KEY ("loan_number", "number")
);

DROP TABLE IF EXISTS employee CASCADE;
CREATE TABLE employee (
  "employee_number" SERIAL PRIMARY KEY,
  "full_name" VARCHAR(100) NOT NULL,
  "type" employee_type NOT NULL DEFAULT 'staff'
);

DROP TABLE IF EXISTS manager CASCADE;
CREATE TABLE manager (
  "employee_number" INT PRIMARY KEY
);

DROP TABLE IF EXISTS activation_req;
CREATE TABLE activation_req (
  "user_id" INT NOT NULL,
  "req_date" TIMESTAMP UNIQUE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "status" req_status NOT NULL DEFAULT 'pending',
  "employee_number" INT,
  PRIMARY KEY ("user_id", "req_date")
);

DROP TABLE IF EXISTS bank_account_req CASCADE;
CREATE TABLE bank_account_req (
  "user_id" INT NOT NULL,
  "req_date" TIMESTAMP NOT NULL UNIQUE DEFAULT CURRENT_TIMESTAMP,
  "status" req_status NOT NULL DEFAULT 'pending',
  "balance" INT NOT NULL DEFAULT 0 CHECK ("balance" >= 0),
  "is_saving" BOOLEAN DEFAULT false,
  "profit_percentage" INT NOT NULL DEFAULT 0 CHECK ("profit_percentage" >= 0 AND "profit_percentage" <= 100),
  "type" saving_type NOT NULL,
  "employee_number" INT,
  PRIMARY KEY ("user_id", "req_date")
);

DROP TABLE IF EXISTS loan_req;
CREATE TABLE loan_req (
  "user_id" INT NOT NULL,
  "req_date" TIMESTAMP NOT NULL UNIQUE DEFAULT CURRENT_TIMESTAMP,
  "status" req_status NOT NULL DEFAULT 'pending',
  "amount" INT NOT NULL DEFAULT 0 CHECK ("amount" >= 0),
  "start_date" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "end_date" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "instalment_number" INT NOT NULL DEFAULT 0 CHECK ("instalment_number" >= 0),
  "profit_percentage" INT NOT NULL DEFAULT 0 CHECK ("profit_percentage" >= 0 AND "profit_percentage" <= 100),
  "manager_number" INT,
  PRIMARY KEY ("user_id", "req_date")
);

-- trigger to check manager_number belongs to a manager ?

ALTER TABLE bank_account 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

-- ALTER TABLE saving_data 
-- ADD FOREIGN KEY ("account_number") 
-- REFERENCES bank_account ("account_number") 
-- ON DELETE CASCADE
-- ON UPDATE CASCADE;

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
REFERENCES manager ("employee_number")
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
ADD FOREIGN KEY ("employee_number") 
REFERENCES employee ("employee_number")
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE activation_req 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE activation_req 
ADD FOREIGN KEY ("employee_number") 
REFERENCES employee ("employee_number")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE bank_account_req 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE bank_account_req 
ADD FOREIGN KEY ("employee_number") 
REFERENCES employee ("employee_number")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE loan_req 
ADD FOREIGN KEY ("user_id") 
REFERENCES user_account ("user_id")
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE loan_req 
ADD FOREIGN KEY ("manager_number") 
REFERENCES manager ("employee_number")
ON DELETE RESTRICT
ON UPDATE RESTRICT;