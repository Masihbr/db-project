-- add employee
INSERT INTO employee
VALUES (1, 'emp1', 'staff');
INSERT INTO employee
VALUES (2, 'emp1', 'staff');
INSERT INTO employee
VALUES (3, 'emp1', 'staff');
INSERT INTO employee
VALUES (4, 'emp1', 'staff');

-- add manager (???)
INSERT INTO employee
VALUES (5, 'mngr', 'manager');
INSERT INTO manager
VALUES (5);

-- add physical account
INSERT INTO user_account
VALUES (1, 'user1', DEFAULT);
INSERT INTO user_account
VALUES (2, 'user2', DEFAULT);
INSERT INTO user_account
VALUES (3, 'user3', DEFAULT);
INSERT INTO user_account
VALUES (4, 'user4', DEFAULT);
INSERT INTO physical_account
VALUES ('0024808631', 1, NULL, NULL, 'USER1');

INSERT INTO physical_account
VALUES ('0024808632', 2, NULL, NULL, 'USER2');
INSERT INTO physical_account
VALUES ('0024808633', 3, NULL, NULL, 'USER3');
INSERT INTO physical_account
VALUES ('0024808634', 4, NULL, NULL, 'USER4');
-- add logical account
INSERT INTO user_account
VALUES (5, 'com1', DEFAULT);
INSERT INTO legal_account
VALUES ('101015', 5);

-- add banck_account_req

INSERT INTO bank_account_req
VALUES (1, CURRENT_TIMESTAMP, DEFAULT, 100000, 10, 'deposit_account', 1);

INSERT INTO bank_account_req
VALUES (2, CURRENT_TIMESTAMP, DEFAULT, 900000, 5, 'deposit_account', 2);

INSERT INTO bank_account_req
VALUES (3, CURRENT_TIMESTAMP, DEFAULT, 5000, 20, 'deposit_account', 3);
-- edit banck_account_req 

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
VALUES (DEFAULT, 777, 'withdraw', CURRENT_TIMESTAMP, NULL, 1, NULL);
INSERT INTO "transaction"
VALUES (DEFAULT, 777, 'transfer', CURRENT_TIMESTAMP, "Buying a Broken toy car.", 1, 2);
INSERT INTO "transaction"
VALUES (DEFAULT, 777, 'deposit', CURRENT_TIMESTAMP, NULL, NULL, 3);

-- trigger to check deposit has destination and withdraw has origin

-- add activation_req

INSERT INTO activation_req
VALUES (1, CURRENT_TIMESTAMP, 'declined', 1);

UPDATE activation_req
SET "status" = 'accepted'
WHERE user_id = 1;

-- add loan_req

INSERT INTO loan_req
VALUES (1, CURRENT_TIMESTAMP, DEFAULT, 1000000, '2022-02-06', '2022-10-06', 8, 50, 2);

-- add loan 

INSERT INTO loan
VALUES(DEFAULT, 1, 1000000, 'requested', '2022-02-06', '2022-10-06', 8, 50, 5);

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
