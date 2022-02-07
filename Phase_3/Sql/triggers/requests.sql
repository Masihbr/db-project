-- create user account
CREATE OR REPLACE FUNCTION create_user_account() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   INSERT INTO activation_req 
   VALUES(NEW.user_id, CURRENT_TIMESTAMP, 'pending', 
   (SELECT employee_number
   FROM employee
   WHERE (SELECT COUNT(*) 
          FROM activation_req 
          WHERE activation_req."employee_number" = employee."employee_number") = 0 
   OR 
   (SELECT COUNT(*) 
          FROM activation_req 
          WHERE activation_req."employee_number" = employee."employee_number")
          = (
          SELECT MIN(myCount)
          FROM (SELECT "employee_number", COUNT(*) as myCount
                FROM activation_req
                GROUP BY "employee_number") AS emp_count
          )
   ORDER BY (
      CASE WHEN (SELECT COUNT(*) 
                 FROM activation_req 
                 WHERE activation_req."employee_number" = employee."employee_number") = 0 THEN 1 ELSE 2 END)
   LIMIT 1
   ));
   RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER create_user_account_f
   AFTER INSERT 
   ON user_account
   FOR EACH ROW
      EXECUTE PROCEDURE create_user_account(); 
-----------------------------------------------------------
-- activate account
CREATE FUNCTION activate_account() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   IF (NEW.status = "accepted" and NEW.employee_number IS NOT NULL) THEN
      UPDATE user_account SET is_active = TRUE WHERE user_account.user_id = NEW.user_id;
   END IF;
END;
$$;

CREATE TRIGGER activate_account_f
   AFTER update ON activation_req
   FOR EACH ROW
       EXECUTE PROCEDURE activate_account() 
-----------------------------------------------------------
-- create bank account
CREATE FUNCTION create_bank_account() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
DECLARE account_num INT;
BEGIN
   IF (NEW.status = "accepted" and NEW.employee_number IS NOT NULL) THEN
      INSERT INTO bank_account VALUES(DEFAULT, NEW.user_id, NEW.balance, CURRENT_TIMESTAMP, TRUE, NEW.profit_percentage, NEW.type);
   END IF;  
END;
$$;

CREATE TRIGGER create_bank_account_f
   AFTER UPDATE ON bank_account_req
   FOR EACH ROW
       EXECUTE PROCEDURE create_bank_account() 
-----------------------------------------------------------
--create loan
CREATE FUNCTION create_loan() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
DECLARE loan_num INT;
        AMOUNT_Instalment INT;
BEGIN
   IF (NEW.status = "accepted" and NEW.manager_number IS NOT NULL) THEN
      INSERT INTO loan VALUES(DEFAULT, NEW.user_id, NEW.amount, "accepted", new.start_date, new.end_date, NEW.instalment_number, NEW.profit_percentage, NEW.manager_number) RETURNING loan_number INTO loan_num;
      
      AMOUNT_Instalment = (NEW.amount * NEW.profit_percentage) / NEW.instalment_number;

      for r in 1..new.instalment_number loop
      INSERT INTO Instalment VALUES(loan_num, DEFAULT, NEW.start_date + interval '1 month' * (r - 1), AMOUNT_Instalment, "unpaid", NULL);
         end loop;
   END IF;

END;
$$;

CREATE TRIGGER create_loan_f
   AFTER UPDATE ON loan_req
   FOR EACH ROW
       EXECUTE PROCEDURE create_loan()
-----------------------------------------------------------
