from peewee import *
from main_object_menu import main_object_menu
from main_JSON_menu import main_JSON_menu
from main_SQL_menu import main_SQL_menu

# создаём объект подключения к базе данных
db = PostgresqlDatabase(
    'DB_Litres',
    user='olesya',
    password='280904',
    host='localhost',
    port=5432
)

# базовый класс для всех моделей
class BaseModel(Model):
    class Meta:
        database = db

# модель для таблицы Authors
class Authors(BaseModel):
    author_id = AutoField()
    first_name = CharField(max_length=225, null=False)
    last_name = CharField(max_length=225, null=False)
    pseudonym = CharField(max_length=225, null=True)
    birthday = DateField(constraints=[Check('birthday <= CURRENT_DATE')])

# модель для таблицы Books
class Books(BaseModel):
    book_id = AutoField()
    title = CharField(max_length=225, null=False)
    genre = CharField(max_length=225, null=True)
    author = ForeignKeyField(Authors, backref='books', on_delete='CASCADE', on_update='CASCADE')
    publish_year = IntegerField(constraints=[
        Check('publish_year >= 0 AND publish_year <= date_part(\'year\', CURRENT_DATE::date)')
    ])

# модель для таблицы Readers
class Readers(BaseModel):
    reader_id = AutoField()
    first_name = CharField(max_length=225, null=False)
    last_name = CharField(max_length=225, null=False)
    email = CharField(max_length=225, unique=True, constraints=[
        Check("email ~* '^[^@]+@[^@]+\\.[^@]+$'")
    ])
    registration_date = DateField(constraints=[Check('registration_date <= CURRENT_DATE')])

# модель для таблицы Rentals
class Rentals(BaseModel):
    rental_id = AutoField()
    book = ForeignKeyField(Books, backref='rentals', on_delete='CASCADE', on_update='CASCADE')
    reader = ForeignKeyField(Readers, backref='rentals', on_delete='CASCADE', on_update='CASCADE')
    take_date = DateField(constraints=[Check('take_date <= CURRENT_DATE')])
    return_date = DateField(null=True, constraints=[
        Check('return_date >= take_date')
    ])



if __name__ == '__main__':
    db.connect()
    db.create_tables([Authors, Books, Readers, Rentals], safe=True)
    print("Инициализация с PostgreSQL прошла успешно!")

    while True:
        print("\nГлавное меню:\n"\
                "1. LINQ to Object\n"\
                "2. LINQ to JSON\n"\
                "3. LINQ to SQL\n"\
                "0. Выйти из программы")
        choice = input("Выберите действие: ")
        # 1. LINQ to Object
        if choice == '1':
            main_object_menu(db, Authors, Books, Readers, Rentals)
        # 2. LINQ to JSON
        elif choice == '2':
            main_JSON_menu(db, Authors, Books, Readers, Rentals)
        # 3. LINQ to SQL
        elif choice == '3':
            main_SQL_menu(db, Authors, Books, Readers, Rentals)
        # 0. Выйти из программы
        elif choice == '0':
            print("Выход из программы.")
            break
        else:
            print("Неверный выбор, попробуйте снова.")
    db.close()  