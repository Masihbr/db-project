CREATE FUNCTION trigger_function() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   -- trigger logic
END;
$$

CREATE TRIGGER trigger_name 
   {BEFORE | AFTER | INSTEAD OF} { event }
   ON table_name
   [FOR [EACH] { ROW | STATEMENT }]
       EXECUTE PROCEDURE trigger_function


CREATE OR REPLACE FUNCTION transaction_valid_func() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
    IF (NEW."origin" = NEW."destination") THEN
        RAISE EXCEPTION 'Can not transfer money to your own account';
    END IF;
    IF (NEW."type" = 'withdraw' AND NEW."origin" IS NOT NULL AND NEW."destination" IS NULL)
    OR (NEW."type" = 'transfer' AND  NEW."origin" IS NOT NULL AND NEW."destination" IS NOT NULL) THEN
        IF ((SELECT "balance" FROM bank_account WHERE "account_number"=NEW."origin") > NEW."amount") THEN
            RETURN NEW;
        ELSE
            RAISE EXCEPTION 'Not enough balance to commit the transaction';   
        END IF;
    END IF;
    IF ((NEW."type" = 'deposit' OR NEW."type" = 'profit') AND  NEW."origin" IS NULL AND NEW."destination" IS NOT NULL) THEN
        RETURN NEW;
    END IF;
    RAISE EXCEPTION 'Wrong operation due to transaction type requirements'; 
END;
$$;

CREATE TRIGGER transaction_valid
    BEFORE INSERT
    ON "transaction"
    FOR EACH ROW
    EXECUTE PROCEDURE transaction_valid_func();

CREATE TRIGGER trigger_name 
   {BEFORE | AFTER | INSTEAD OF} { event }
   ON table_name
   [FOR [EACH] { ROW | STATEMENT }]
       EXECUTE PROCEDURE trigger_function


CREATE OR REPLACE FUNCTION transaction_success_func() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
    IF (NEW."type" = 'withdraw') THEN
        UPDATE bank_account
        SET "balance" = "balance" - NEW."amount"
        WHERE "account_number" = NEW."origin";
    END IF;

    IF (NEW."type" = 'transfer') THEN
        UPDATE bank_account
        SET "balance" = "balance" - NEW."amount"
        WHERE "account_number" = NEW."origin";
        UPDATE bank_account
        SET "balance" = "balance" + NEW."amount"
        WHERE "account_number" = NEW."destination";
    END IF;
    
    IF (NEW."type" = 'deposit' OR NEW."type" = 'profit') THEN
        UPDATE bank_account
        SET "balance" = "balance" + NEW."amount"
        WHERE "account_number" = NEW."destination";
    END IF;

    RETURN NEW; 
END;
$$;
CREATE TRIGGER transaction_success
    AFTER INSERT
    ON "transaction"
    FOR EACH ROW
    EXECUTE PROCEDURE transaction_success_func();