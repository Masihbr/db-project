in UserInterface folder run following commands:

```
python3 -m venv ./venv
source venv/bin/activate
pip install -r requirements.txt
python UI.py
```

Add a .env file in UserInterface folder to configure database in this format:
```
HOST = 127.0.0.1
PORT = 5432
user = postgres
database = db_project
password = postgrespass
```