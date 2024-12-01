from peewee import RawQuery

# LINQ to SQL
def main_SQL_menu(db, Authors, Books, Readers, Rentals):
    while True:
        print("\nМеню:\n"\
                "1. Однотабличный запрос на выборку\n"\
                "2. Многотабличный запрос на выборку\n"\
                "3. Три запроса на добавление, изменение и удаление данных в базе данных\n"\
                "4. Получение доступа к данным, выполняя только хранимую процедуру\n"\
                "0. Выйти из программы")
        choice = input("Выберите действие: ")

        # 1. Однотабличный запрос на выборку
        if choice == '1':
            # Найти авторов, родившихся после 1980
            result = [{"Name": f"{author.first_name} {author.last_name}", "Birthday": author.birthday} 
                      for author in Authors.select().where(Authors.birthday > '1980-01-01')]
            print(result)
        # 2. Многотабличный запрос на выборку
        elif choice == '2':
            # Вывести книги с их авторами
            result = [{"Book Title": book.title, "Author": f"{book.author.first_name} {book.author.last_name}"} 
                      for book in Books.select().join(Authors, on=(Books.author == Authors.author_id))]
            print(result)
        # 3. Три запроса на добавление, изменение и удаление данных в базе данных
        elif choice == '3':
            # добавление
            new_author = Authors.create(
                author_id=11111,
                first_name="New_Author",
                last_name="Lab_07_SQL",
                pseudonym="Some_pseudonym",
                birthday="2004-07-17"
            )
            print(f"Добавленный автор: {new_author.first_name} {new_author.last_name}")

            # изменение
            updated_rows = (Authors
                .update({Authors.pseudonym: Authors.pseudonym + "U"})
                .where(Authors.birthday == "1985-08-27")
                .execute()
            )
            print(f"Обновлёно {updated_rows} строк.")

            # удаление
            deleted_rows = (Authors
                .delete()
                .where(Authors.last_name == "Lab_07_SQL")
                .execute()
            )
            print(f"Удалено {deleted_rows} строк.")
        # 4. Получение доступа к данным, выполняя только хранимую процедуру
        elif choice == '4':
            # Считает количество книг у автора с переданным id
            author_id = 10
            query = "SELECT calc_count_books_author(%s);"
            cursor = db.execute_sql(query, [author_id])
            result = cursor.fetchone()
            if result:
                print(f"Число книг автора с id = {author_id} -> {result[0]}")
            else:
                print("Нет данных для указанного автора.")
        # 0. Выйти из программы
        elif choice == '0':
            print("Выход из программы.")
            break
        else:
            print("Неверный выбор, попробуйте снова.")