CREATE VIEW top_transactions AS
    SELECT *
    FROM transaction 
    WHERE amount >= 1000000000;

    select *
    from top_transactions;
    --------------------------------------------
CREATE OR REPLACE VIEW top_customers AS
    SELECT bank_account.user_id, user_account.name
    FROM bank_account
    inner join user_account
    on user_account.user_id = bank_account.user_id
	GROUP BY bank_account.user_id, user_account.name
    HAVING sum(balance)>= 1000000000;
    
    select *
    from top_customers;
    --------------------------------------------
CREATE OR REPLACE VIEW COMPANY_FULL_INFO AS
    SELECT user_account.user_id, "name", company_id
    FROM legal_account
    inner JOIN user_account
    on user_account.user_id = legal_account.user_id;
    
    select *
    from COMPANY_FULL_INFO;
    --------------------------------------------
CREATE OR REPLACE VIEW HUMAN_FULL_INFO AS
    SELECT national_id, user_account.user_id, user_account.name, family_name
    FROM physical_account
    inner JOIN user_account
    on user_account.user_id = physical_account.user_id;
    
    select *
    from HUMAN_FULL_INFO;