from peewee import fn


# LINQ to Object
def main_object_menu(db, Authors, Books, Readers, Rentals):
    while True:
        print("\nМеню:\n"\
                "1. Вывести всех авторов\n"\
                "2. Найти авторов, родившихся после 1980\n"\
                "3. Сортировать книги по году публикации\n"\
                "4. Вывести книги с их авторами\n"\
                "5. Группировка книг по жанру с подсчётом\n"\
                "6. Показать 5 книг\n"\
                "0. Выйти из программы")
        choice = input("Выберите действие: ")

        # 1. Вывести всех авторов
        if choice == '1':
            result = [{"Name": f"{author.first_name} {author.last_name}", "Pseudonym": author.pseudonym} 
                      for author in Authors.select()]
            print(result)
        # 2. Найти авторов, родившихся после 1980
        elif choice == '2':
            result = [{"Name": f"{author.first_name} {author.last_name}", "Birthday": author.birthday} 
                      for author in Authors.select().where(Authors.birthday > '1980-01-01')]
            print(result)
        # 3. Сортировать книги по году публикации
        elif choice == '3':
            result = [{"Title": book.title, "Publish Year": book.publish_year} 
                      for book in Books.select().order_by(Books.publish_year.desc())]
            print(result)
        # 4. Вывести книги с их авторами
        elif choice == '4':
            result = [{"Book Title": book.title, "Author": f"{book.author.first_name} {book.author.last_name}"} 
                      for book in Books.select().join(Authors, on=(Books.author == Authors.author_id))]
            print(result)
        # 5. Группировка книг по жанру с подсчётом
        elif choice == '5':
            result = [{"Genre": row.genre, "Count": row.count} 
                      for row in Books.select(Books.genre, fn.COUNT(Books.book_id).alias('count')).group_by(Books.genre)]
            print(result)
        # 6. Показать 5 книг
        elif choice == '6':
            result = [{"Title": book.title, "Publish Year": book.publish_year} 
                      for book in Books.select().limit(5)]
            print(result)
        # 0. Выйти из программы
        elif choice == '0':
            print("Выход из программы.")
            break
        else:
            print("Неверный выбор, попробуйте снова.")