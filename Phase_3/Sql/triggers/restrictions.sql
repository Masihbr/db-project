-- no bank account if not active

-- bank_account_req
CREATE OR REPLACE FUNCTION bank_acc_req_valid_func() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
    IF ((SELECT "is_active" FROM user_account WHERE user_id = NEW."user_id")) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Can not request for a new account before user activation';
    END IF; 
END;
$$;

CREATE TRIGGER bank_acc_req_valid
    BEFORE INSERT
    ON bank_account_req
    FOR EACH ROW
    EXECUTE PROCEDURE bank_acc_req_valid_func();

-- loan_req

CREATE OR REPLACE FUNCTION loan_req_valid_func() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
    IF ((SELECT "is_active" FROM user_account WHERE user_id = NEW."user_id")) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Can not request for a loan before user activation';
    END IF; 
END;
$$;

CREATE TRIGGER loan_req_valid
    BEFORE INSERT
    ON loan_req
    FOR EACH ROW
    EXECUTE PROCEDURE loan_req_valid_func();


-- req limitations

-- bank account req 
CREATE OR REPLACE FUNCTION bank_acc_req_limit_func() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
    IF (CURRENT_TIMESTAMP - (SELECT "req_date" FROM bank_account_req WHERE "user_id" = NEW."user_id" ORDER BY "req_date" DESC LIMIT 1) < interval '24 hours') THEN
        RAISE EXCEPTION 'One request every 24 hours';
    ELSE
        RETURN NEW;
    END IF;
END;
$$;
CREATE TRIGGER bank_acc_req_limit
    BEFORE INSERT
    ON bank_account_req
    FOR EACH ROW
    EXECUTE PROCEDURE bank_acc_req_limit_func();

-- loan_req

CREATE OR REPLACE FUNCTION loan_req_limit_func() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
    IF (CURRENT_TIMESTAMP - (SELECT "req_date" FROM loan_req WHERE "user_id" = NEW."user_id" ORDER BY "req_date" DESC LIMIT 1) < interval '24 hours') THEN
        RAISE EXCEPTION 'One request every 24 hours';
    ELSE
        RETURN NEW;
    END IF;
END;
$$;
CREATE TRIGGER loan_req_limit
    BEFORE INSERT
    ON loan_req
    FOR EACH ROW
    EXECUTE PROCEDURE loan_req_limit_func();
