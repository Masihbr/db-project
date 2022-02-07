
-- create user account
CREATE FUNCTION create_user_account() 
   RETURNS TRIGGER 
   LANGUAGE PLPGSQL
AS $$
BEGIN
   INSERT INTO Activation_req VALUES(NEW.user_id, CURRENT_TIMESTAMP, "pending", null);
END;
$$

CREATE TRIGGER create_user_account_f
   AFTER OF INSERT ON UserAccount
   FOR EACH ROW
       EXECUTE PROCEDURE create_user_account() 
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