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
    OR ((NEW."type" = 'deposit' OR NEW."type" = 'profit') AND  NEW."origin" IS NULL AND NEW."destination" IS NOT NULL)
    OR (NEW."type" = 'transfer' AND  NEW."origin" IS NOT NULL AND NEW."destination" IS NOT NULL) THEN
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