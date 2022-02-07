UPDATE loan_req SET status='accepted' WHERE {condition};

INSERT INTO loan
VALUES(DEFAULT, {user_id}, {amount}, 'active', {start_date}, {end_date}, {remaining_number}, {profit_percentage}, {supervisor});