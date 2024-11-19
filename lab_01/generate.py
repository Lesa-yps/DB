from faker import Faker
import names
import random
import datetime

# количество данных в каждой таблице для генерации
COUNT_DATES = 1000
# наиболее популярные жанры
GENRES = ['detective', 'romance novel', 'fantasy', 'science fiction', 'historical novel', 'adventure', 'mystery', 'humorous prose', 'drama', 'biography']
# Текущий год
THIS_YEAR = int(Faker().year())
# адреса файлов для генерации по умолчанию
DEF_FILENAMES = {"authors": "L:\sem_5\DB\DB\lab_01\\test_data\\authors.csv", "books": "L:\sem_5\DB\DB\lab_01\\test_data\\books.csv",\
                  "readers": "L:\sem_5\DB\DB\lab_01\\test_data\\readers.csv", "rentals": "L:\sem_5\DB\DB\lab_01\\test_data\\rentals.csv"}

# генерация рандомных данных для таблицы с книгами
def generate_random_books(count = COUNT_DATES):
    rand_books = []
    for i in range(count):
        rand_books.append({
            'book_id': i + 1,
            'title': Faker().catch_phrase(),
            'genre': random.choice(GENRES),
            'author_id': random.randint(1, COUNT_DATES),
            # Генерируем случайное число за последние 100 лет
            'publish_year': random.randint(THIS_YEAR - 100, THIS_YEAR)
            })
    return rand_books

# генерация рандомных данных для таблицы с авторами
def generate_random_authors(count = COUNT_DATES):
    rand_authors = []
    for i in range(count):
        rand_authors.append({
            'author_id': i + 1,
            'first_name': names.get_first_name(),
            'last_name': names.get_last_name(),
            'pseudonym': Faker().catch_phrase(),
            'birthday': Faker().date_of_birth(minimum_age=18, maximum_age=100),
            })
    return rand_authors

# генерация рандомных данных для таблицы с читателями
def generate_random_readers(count = COUNT_DATES):
    rand_readers = []
    for i in range(count):
        rand_readers.append({
            'reader_id': i + 1,
            'first_name': names.get_first_name(),
            'last_name': names.get_last_name(),
            'email': str(i) + "_" + Faker().email(),
            'registration_date': Faker().date_this_decade(),
            })
    return rand_readers

# генерация рандомных данных для таблицы с арендами книг
def generate_random_rentals(count = COUNT_DATES):
    rand_rentals = []
    for i in range(count):
        take_date = Faker().date_this_year()
        return_date = take_date + datetime.timedelta(days=21)
        rand_rentals.append({
            'rental_id': i + 1,
            'book_id': random.randint(1, COUNT_DATES),
            'reader_id': random.randint(1, COUNT_DATES),
            'take_date': take_date,
            'return_date': return_date,
            })
    return rand_rentals
        

def clear_files(filenames):
    for filename in filenames:
        # Открываем файл в режиме записи, что автоматически очистит его содержимое
        with open(filename, 'w'):
            pass  # Ничего не делаем, просто открываем и закрываем файл


# Запись сгенерированных данных в *.CSV файлы
def generate_write_random_books(filename = DEF_FILENAMES['books'], count = COUNT_DATES):
    rand_books = generate_random_books(count)
    with open(filename, 'a') as file:
        for book in rand_books:
            file.write(f"{book['book_id']}, {book['title']},\
                        {book['genre']}, {book['author_id']}, {book['publish_year']}\n")

def generate_write_random_authors(filename = DEF_FILENAMES['authors'], count = COUNT_DATES):
    rand_authors = generate_random_authors(count)
    with open(filename, 'a') as file:
        for author in rand_authors:
            file.write(f"{author['author_id']}, {author['first_name']},\
                        {author['last_name']}, {author['pseudonym']}, {author['birthday']}\n")

def generate_write_random_readers(filename = DEF_FILENAMES['readers'], count = COUNT_DATES):
    rand_readers = generate_random_readers(count)
    with open(filename, 'a') as file:
        for reader in rand_readers:
            file.write(f"{reader['reader_id']}, {reader['first_name']},\
                        {reader['last_name']}, {reader['email']}, {reader['registration_date']}\n")
        
def generate_write_random_rentals(filename = DEF_FILENAMES['rentals'], count = COUNT_DATES):
    rand_rentals = generate_random_rentals(count)
    with open(filename, 'a') as file:
        for rental in rand_rentals:
            file.write(f"{rental['rental_id']}, {rental['book_id']},\
                       {rental['reader_id']}, {rental['take_date']}, {rental['return_date']}\n")


def generate_write_random_all(filenames = DEF_FILENAMES, count = COUNT_DATES):
    generate_write_random_authors(filenames['authors'], count)
    generate_write_random_books(filenames['books'], count)
    generate_write_random_readers(filenames['readers'], count)
    generate_write_random_rentals(filenames['rentals'], count)


def regenerate_write_random_all(filenames = DEF_FILENAMES, count = COUNT_DATES):
    clear_files(list(filenames.values()))
    generate_write_random_all(filenames, count)

if __name__ == "__main__":
    regenerate_write_random_all()