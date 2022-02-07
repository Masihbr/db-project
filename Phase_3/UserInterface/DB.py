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
        self.current_user = None

    def get_output(self, query):
        self.cursor.execute(query)
        return self.cursor.fetchall(), [desc[0] for desc in self.cursor.description]

    def do_query(self, query):
        self.cursor.execute(query)
        try:
            self.connection.commit()
            print('Done Successful.')
        except psycopg2.OperationalError as e:
            print('Error: {0}').format(e)

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
            print('Invalid Input.')
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

    def see_all_loan_request(self, command):
        query_text = open('../Sql/queries/view_all_loan_request.sql').read()
        query = query_text.format(condition='true')
        data, header = self.get_output(query)
        print(tabulate(data, headers=header))

    def accept_loan(self, command):
        match_object = re.match('^(\d+), \d\d\d\d/\d\d/\d\d, \d\d\d\d/\d\d/\d\d$', command)
        if not match_object:
            print('Invalid Input.')
            return
        user_id, req_date, req_date_prime = match_object.group().split(', ')
        where_condition = f"user_id = {user_id} and req_date between '{req_date}' and '{req_date_prime}'"
        query_text = open('../Sql/queries/view_all_loan_request.sql').read()
        query = query_text.format(condition=where_condition)
        data, header = self.get_output(query)

        if data:
            query_text = open('../Sql/queries/accept_loan_req.sql').read()
            values = data[0]
            query = query_text.format(condition=where_condition, user_id=values[0], amount=values[3],
                                      start_date=f"'{values[4].strftime('%x')}'",
                                      end_date=f"'{values[5].strftime('%x')}'", remaining_number=values[6],
                                      profit_percentage=values[7], supervisor=values[8])
            self.do_query(query)

    def see_all_loans(self, command):
        query_text = open('../Sql/queries/view_all_loans.sql').read()
        query = query_text.format(condition='true')
        data, header = self.get_output(query)
        print(tabulate(data, headers=header))

    def login_user(self, command):
        query = open('../Sql/queries/view_all_user.sql').read()
        data, header = self.get_output(query)
        all_ids = [x[0] for x in data]
        try:
            id = int(command)
            if id in all_ids:
                self.current_user = id
                print('Login successful.')
                return True
            else:
                print('user does not exist.')
        except ValueError:
            print('Invalid Id.')

    def login_employee(self, command):
        query = open('../Sql/queries/view_all_employee.sql').read()
        data, header = self.get_output(query)
        all_ids = [x[0] for x in data]
        try:
            id = int(command)
            if id in all_ids:
                self.current_user = id
                print('Login successful.')
                return True
            else:
                print('user does not exist.')
        except ValueError:
            print('Invalid Id.')

    def see_user_bank_accounts(self, command):
        query_text = open('../Sql/queries/view_bank_accounts.sql').read()
        query = query_text.format(condition=f'user_id = {self.current_user}')
        data, header = self.get_output(query)
        print(tabulate(data, headers=header))

    def withdraw_transition(self, command):
        match = re.match('^(\d+), (\w*), (\d+)$', command)
        if match:
            amount, desc, origin = match.group().split(', ')
            if self.has_account(int(origin)):
                query_text = open('../Sql/queries/do_transaction.sql').read()
                query = query_text.format(amount=amount, type="'withdraw'",
                                          description=f"'{desc}'", origin=origin,
                                          destination='NULL')
                self.do_query(query)
            else:
                print('This account does not belong to you.')
        else:
            print('Invalid Command.')

    def deposit_transition(self, command):
        match = re.match('^(\d+), (\w+), (\d+)$', command)
        if match:
            amount, desc, destination = match.group().split(', ')
            if self.has_account(int(destination)):
                query_text = open('../Sql/queries/do_transaction.sql').read()
                query = query_text.format(amount=amount, type="'deposit'", description=f"'{desc}'",
                                          origin='NULL', destination=destination)
                self.do_query(query)
            else:
                print('This account does not belong to you.')
        else:
            print('Invalid Command.')

    def transfer(self, command):
        match = re.match('^(\d+), (\w+), (\d+), (\d+)$', command)
        if match:
            amount, desc, origin, destination = match.group().split(', ')
            if self.has_account(int(origin)):
                query_text = open('../Sql/queries/do_transaction.sql').read()
                query = query_text.format(amount=amount, type="'transfer'", description=f"'{desc}'",
                                          origin=origin, destination=destination)
                self.do_query(query)
            else:
                print('This account does not belong to you.')
        else:
            print('Invalid Command.')

    def last_five_transactions(self, command):
        match = re.match('^(\d+), (\d+)$', command)
        account, limit = match.group().split(', ')
        if match:
            if self.has_account(int(account)):
                query_text = open('../Sql/queries/view_last_transactions.sql').read()
                query = query_text.format(ID=account, limit=limit)
                data, header = self.get_output(query)
                print(tabulate(data, headers=header))
            else:
                print('This account does not belong to you.')
        else:
            print('Invalid Command.')

    def has_account(self, account):
        query_text = open('../Sql/queries/view_bank_accounts.sql').read()
        query = query_text.format(condition=f'user_id = {self.current_user}')
        data, _ = self.get_output(query)
        return account in [x[0] for x in data]



