
-- create user account
CREATE FUNCTION create_user_account() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   INSERT INTO activation_req VALUES(NEW.user_id, CURRENT_TIMESTAMP, "pending", null);
END;
$$

CREATE TRIGGER create_user_account_f
   AFTER OF INSERT ON user_account
   FOR EACH ROW
       EXECUTE PROCEDURE create_user_account() 
-----------------------------------------------------------
-- activate account
CREATE FUNCTION activate_account() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   IF (NEW.status = "accepted" and NEW.employee_number IS NOT NULL) THEN
      UPDATE user_account SET is_active = TRUE WHERE user_account.user_id = NEW.user_id;
END;
$$

CREATE TRIGGER activate_account_f
   AFTER OF update ON activation_req
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
   IF (NEW.status = "accepted" and NEW.Employee_num IS NOT NULL) THEN
      INSERT INTO BankAccount VALUES(DEFAULT, NEW.user_id, NEW.balace, CURRENT_TIMESTAMP, "accepted") RETURNING account_number INTO account_num;
      INSERT INTO SavingData VALUES(account_num, NEW.profit_percentage, NEW.type);
END;
$$

CREATE TRIGGER create_bank_account_f
   AFTER OF UPDATE ON bank_account_req
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
   IF (NEW.is_accepted = "accepted" and NEW.Manager_num IS NOT NULL) THEN
      INSERT INTO Loan VALUES(DEFAULT, NEW.user_id, NEW.amount, "accepted", new.start_date, new.end_date, installment_number, new.profit_percentage, new.supervisor_id) RETURNING loan_number INTO loan_num;
      
      AMOUNT_Instalment = (NEW.amount * NEW.profit_percentage) / NEW.installment_number

      for r in 1..new.installment_number loop
      INSERT INTO Instalment VALUES(DEFAULT, loan_num, NEW.start_date + interval '1 month' * (r - 1), AMOUNT_Instalment "UNPAID", NULL);
         end loop;

END;
$$

CREATE TRIGGER create_loan_f
   AFTER OF UPDATE ON loan_req
   FOR EACH ROW
       EXECUTE PROCEDURE create_loan()
-----------------------------------------------------------
