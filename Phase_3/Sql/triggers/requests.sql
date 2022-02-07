
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
   IF (NEW.is_accepted = "accepted") THEN
      UPDATE UserAccount SET is_accepted = "accepted" WHERE UserAccount.user_id = NEW.user_id;
END;
$$

CREATE TRIGGER activate_account_f
   AFTER OF update ON PhysicalAccount
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
   IF (NEW.is_active = TRUE) THEN
      INSERT INTO BankAccount VALUES(DEFAULT, NEW.user_id, NEW.balace, CURRENT_TIMESTAMP, true) RETURNING account_number INTO account_num;
      INSERT INTO SavingData VALUES(account_num, NEW.profit_percentage, NEW.type);
END;
$$

CREATE TRIGGER create_bank_account_f
   AFTER OF UPDATE ON bank_account_req
   FOR EACH ROW
       EXECUTE PROCEDURE create_bank_account() 
-----------------------------------------------------------