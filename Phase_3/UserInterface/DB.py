import re
import psycopg2
from tabulate import tabulate
from dotenv import load_dotenv
import os

load_dotenv()


class DB:
    HOST = os.getenv('HOST') or '127.0.0.1'
    PORT = os.getenv('PORT') or '5432'
    user = os.getenv('user') or 'postgres'
    database = os.getenv('database') or 'db_project'
    password = os.getenv('password') or 'postgrespass'

    def __init__(self):
        self.connection = psycopg2.connect(database=DB.database, user=DB.user, host=DB.HOST, port=DB.PORT,
                                           password=DB.password)
        self.cursor = self.connection.cursor()

    def get_output(self, query):
        self.cursor.execute(query)
        return self.cursor.fetchall(), [desc[0] for desc in self.cursor.description]

    def see_all_bank_account(self, is_sort='FALSE'):
        is_sort = is_sort.capitalize() == 'True'
        query_text = open('../Sql/queries/view_all_bank_accounts.sql').read()
        query = query_text.format(order_by=' ORDER BY balance DESC' if is_sort else '')
        data, header = self.get_output(query)
        print(tabulate(data, headers=header))

    def see_all_transaction(self, command):
        x = re.match('^\d\d\d\d/\d\d/\d\d, \d\d\d\d/\d\d/\d\d$', command)
        if command == 'None':
            condition = 'True'
        elif not x:
            return
        else:
            start_date, end_date = x.group().split(',')
            start_date = start_date.strip()
            end_date = end_date.strip()
            condition = f"date between '{start_date}' and '{end_date}'"
        query_text = open('../Sql/queries/view_all_transactions.sql').read()
        query = query_text.format(condition=condition)
        data, header = self.get_output(query)
        print(tabulate(data, headers=header))





