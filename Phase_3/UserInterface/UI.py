from DB import DB


class View:
    def __init__(self, name, sub_views=[], function=None, father=None, explanation=''):
        self.name = name
        self.sub_views = sub_views
        self.function = function
        self.father = father
        self.explanation = explanation

    def show(self):
        if self.function:
            print(self.explanation)
            command = input()
            self.function(command)
            if self.father:
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
    manager_view = View('Manager')

    bank_account_view = View('Bank Accounts', function=db.see_all_bank_account,
                             explanation='type TRUE to sort ordered by balance', father=manager_view)
    transaction_view = View('Transactions', function=db.see_all_transaction,
                            explanation='type None to get all or like YYYY/MM/DD, YYYY/MM/DD', father=manager_view)

    manager_view.add_view(bank_account_view)
    manager_view.add_view(transaction_view)

    manager_view.show()

