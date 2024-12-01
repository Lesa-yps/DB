from peewee import *
from peewee import fn
from datetime import date

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
    # устанавливаем соединение с базой данных и создаём таблицы, если их нет
    db.connect()  
    db.create_tables([Authors, Books, Readers, Rentals], safe = True)
    print("Инициализация с PostgreSQL прошла успешно!")

    # 1. LINQ to Object.

    # SELECT - запрос вывода всех Авторов
    #result = [{"Name": f"{author.first_name} {author.last_name}", "Pseudonym": author.pseudonym} for author in Authors.select()]
    #print(result)

    # 2. WHERE - поиск авторов с датой рождения после 1980
    #result = [{"Name": f"{author.first_name} {author.last_name}", "Birthday": author.birthday} for author in Authors.select().where(Authors.birthday > '1980-01-01')]
    #print(result)

    # 3. ORDER BY — сортировка книг по году публикации
    #result = [{"Title": book.title, "Publish Year": book.publish_year} for book in Books.select().order_by(Books.publish_year.desc())]
    #print(result)

    # 4. JOIN — выборка книг с их авторами
    #result = [{"Book Title": book.title, "Author": f"{book.author.first_name} {book.author.last_name}"} for book in Books.select().join(Authors)]
    #print(result)

    # 5. GROUP BY — группировка книг по жанру с подсчётом количества
    #result = [{"Genre": row.genre, "Count": row.count} for row in Books.select(Books.genre, fn.COUNT(Books.book_id).alias('count')).group_by(Books.genre)]
    #print(result)

    # 6. LIMIT — ограничение вывода до 5 книг
    #result = [{"Title": book.title, "Publish Year": book.publish_year} for book in Books.select().limit(5)]
    print(result)


    # закрываем соединение
    db.close()    