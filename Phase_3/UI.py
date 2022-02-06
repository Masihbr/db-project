import psycopg2

HOST = '127.0.0.1'
PORT = 5432
user = 'admin'
database = 'db'
password = 'db-course'

with psycopg2.connect(database=database, user=user, host=HOST, port=PORT, password=password) as connection:
    cursor = connection.cursor()
    cursor.execute("select * from test;")
    data = cursor.fetchone()
    print("query_result: ", data)