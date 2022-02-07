import psycopg2
from tabulate import tabulate


class DB:
    HOST = '127.0.0.1'
    PORT = 5432
    user = 'postgres'
    database = 'db_project'
    password = 'postgrespass'

    def __init__(self):
        self.connection = psycopg2.connect(database=DB.database, user=DB.user, host=DB.HOST, port=DB.PORT,
                                           password=DB.password)
        self.cursor = self.connection.cursor()

    def get_output(self, query):
        self.cursor.execute(query)
        return self.cursor.fetchall(), [desc[0] for desc in self.cursor.description]

    def see_all_bank_account(self, is_sort='FALSE'):
        is_sort = True if is_sort.capitalize() == 'TRUE' else 'FALSE'
        if is_sort:
            query = 'SELECT * FROM bank_account NATURAL JOIN saving_data ORDER BY balance DESC;'
        else:
            query = 'SELECT * FROM NATURAL JOIN saving_data bank_account;'
        data, header = self.get_output(query)
        print(tabulate(data, headers=header))

