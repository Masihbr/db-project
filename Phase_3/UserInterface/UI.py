from DB import DB


class View:
    def __init__(self, name, sub_views=None, function=None, father=None, explanation='', next_menu=None):
        self.name = name
        self.sub_views = sub_views if sub_views else []
        self.function = function
        self.father = father
        self.explanation = explanation
        self.next_menu = next_menu

    def show(self):
        if self.function:
            print(self.explanation)
            command = input()
            out = self.function(command)
            if out:
                self.next_menu.show()
            elif self.father:
                self.father.show()
        else:
            print(f'current: {self.name}')
            print('------------------------')
            i = 0
            for i, subview in enumerate(self.sub_views):
                print(f'{i}. {subview.name}.')
            print(f'{i+1}. Exit.')
            print('------------------------')
            command = input()
            if command != f'{i+1}':
                self.execute(int(command))
            else:
                if self.father:
                    self.father.show()

    def execute(self, command):
        view_to_show = self.sub_views[command]
        view_to_show.show()

    def add_view(self, view):
        self.sub_views.append(view)


if __name__ == '__main__':
    db = DB()

    first_view = View('Main Menu')
    user_view = View('User Menu', father=first_view)
    employee_view = View('Employee Menu', father=first_view)
    manager_view = View('Manager', father=first_view)

    # --------------------- User View ------------------------
    user_bank_accounts_view = View('My Bank Accounts', function=db.see_user_bank_accounts,
                                   explanation='press enter', father=user_view)
    last_transactions_view = View('Last Transactions', function=db.last_five_transactions,
                                  explanation='Enter [account], [limit]', father=user_view)
    user_withdraw = View('Withdraw', function=db.withdraw_transition,
                         explanation='Enter [amount(int)], [description(just letters)], [account_id(int)]',
                         father=user_view)
    user_deposit = View('Deposit', function=db.deposit_transition,
                        explanation='Enter [amount(int)], [description(just letters)], [account_id(int)]',
                        father=user_view)
    user_transfer = View('Transfer', function=db.transfer,
                         explanation='Enter [amount(int)], [description(just letters)], [account_id(int)], [destination_id(int)]',
                         father=user_view)

    user_view.add_view(user_bank_accounts_view)
    user_view.add_view(user_deposit)
    user_view.add_view(user_withdraw)
    user_view.add_view(user_transfer)
    user_view.add_view(last_transactions_view)
    # --------------------- Manager View ---------------------
    login_costumers_view = View('Login (Costumers)', function=db.login_user,
                                explanation='Enter your id', father=first_view, next_menu=user_view)
    login_employee_view = View('Login (Employee)', function=db.login_employee,
                               explanation='Enter your id', father=first_view)

    first_view.add_view(login_costumers_view)
    first_view.add_view(login_employee_view)
    first_view.add_view(manager_view)

    bank_account_view = View('Bank Accounts', function=db.see_all_bank_account,
                             explanation='type TRUE to sort ordered by balance', father=manager_view)
    transaction_view = View('Transactions', function=db.see_all_transaction,
                            explanation='type None to get all or like YYYY/MM/DD, YYYY/MM/DD', father=manager_view)
    loan_request_view = View('All loan requests', function=db.see_all_loan_request,
                             explanation='press enter.', father=manager_view)
    all_loans = View('All loans', function=db.see_all_loans,
                     explanation='press enter.', father=manager_view)
    accept_request_view = View('Accept loan request', function=db.accept_loan,
                               explanation='enter [user_id], [YYYY/MM/DD], [YYYY/MM/DD].', father=manager_view)

    manager_view.add_view(bank_account_view)
    manager_view.add_view(transaction_view)
    manager_view.add_view(loan_request_view)
    manager_view.add_view(all_loans)
    manager_view.add_view(accept_request_view)

    first_view.show()


