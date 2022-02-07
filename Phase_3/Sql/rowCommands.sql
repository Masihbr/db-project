-- add physical account
INSERT INTO user_account
VALUES (1, 'masih', DEFAULT);
INSERT INTO physical_account
VALUES ('0024808629', 1, NULL, NULL, 'beigi');

-- add logical account
INSERT INTO user_account
VALUES (10, 'bmw');
INSERT INTO legal_account
VALUES ('43221', 1);

-- add employee
INSERT INTO employee
VALUES (1, 'ali Lee', 'staff');

-- add manager (???)
INSERT INTO employee
VALUES (2, 'Lee Te Pong', 'manager');
INSERT INTO manager
VALUES (2);

-- add banck_account_req

INSERT INTO bank_account_req
VALUES (1, CURRENT_TIMESTAMP, DEFAULT, 100000, false, 10, 'deposit_account', 1);

-- edit banck_account_req 
-- need trigger to check no more than one req each 24 hours
UPDATE bank_account_req
SET "status" = 'accepted' 
WHERE user_id = 1 AND req_date <= '2022-02-06 13:57:52.275892' AND req_date >= '2022-02-06 11:57:52.275892';
-- trigger to create bank_acc (?)

-- add bank_account

INSERT INTO bank_account
VALUES (1, 1, 100000, CURRENT_TIMESTAMP, true, 10, 'deposit_account');
-- INSERT INTO saving_data
-- VALUES (1, 10, 'deposit_account');

-- get bank_account data (???)

-- SELECT * FROM bank_account NATURAL JOIN saving_data;

-- add transaction

INSERT INTO "transaction"
VALUES (DEFAULT, 10000, 'withdraw', CURRENT_TIMESTAMP, NULL, 1, NULL);
-- trigger to check deposit has destination and withdraw has origin

-- add activation_req

INSERT INTO activation_req
VALUES (1, CURRENT_TIMESTAMP, 'declined', 1);

-- add loan_req

INSERT INTO loan_req
VALUES (1, CURRENT_TIMESTAMP, DEFAULT, 1000000, '2022-02-06', '2022-10-06', 8, 50, 2);

-- add loan 

INSERT INTO loan
VALUES(DEFAULT, 1, 1000000, 'requested', '2022-02-06', '2022-10-06', 8, 50, 2);

-- have number of total instalments
-- have another field remaining instalments which is updated with a trigger based on piad instalments

-- add instalment
INSERT INTO instalment
VALUES(1, 1, CURRENT_TIMESTAMP, 20000, 'unpaid', null);

-- edit instalment

UPDATE instalment
SET "status" = 'paid', transaction_number = 1
WHERE instalment.loan_number = 1 AND instalment.number = 1

-- trigger to check transaction_number belongs to type deposit ?
