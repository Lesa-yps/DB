import json

JSON_FILENAME = 'authors.json'

# Создать JSON документ, извлекая его из таблиц базы данных с помощью инструкции SELECT
def make_JSON_Authors_file(Authors):
    # SELECT - запрос на извлечение данных из таблицы Authors
    authors_data = [{"author_id": author.author_id, 
                     "first_name": author.first_name, 
                     "last_name": author.last_name,
                     "pseudonym": author.pseudonym, 
                     "birthday": str(author.birthday)} 
                    for author in Authors.select()]
    # сохранение данных в JSON-файл 'authors.json'
    with open(JSON_FILENAME, 'w', encoding='utf-8') as file:
        json.dump(authors_data, file, indent=4, ensure_ascii=False)
    print("\nJSON-документ создан на основе таблицы Authors!")


# LINQ to JSON
def main_JSON_menu(db, Authors, Books, Readers, Rentals):
    # Создать JSON документ, извлекая его из таблиц базы данных с помощью инструкции SELECT
    make_JSON_Authors_file(Authors)
    while True:
        print("\nМеню:\n"\
                "1. Чтение из JSON документа\n"\
                "2. Обновление JSON документа\n"\
                "3. Запись (Добавление) в JSON документ\n"\
                "0. Выйти из программы")
        choice = input("Выберите действие: ")

        # 1. Чтение из JSON документа
        if choice == '1':
            with open(JSON_FILENAME, 'r', encoding='utf-8') as file:
                authors_data = json.load(file)
            print("Данные из JSON-файла:", authors_data)
        # 2. Обновление JSON документа
        elif choice == '2':
            with open(JSON_FILENAME, 'r', encoding='utf-8') as file:
                authors_data = json.load(file)
            for author in authors_data:
                if author["first_name"].strip() == "Daniel":
                    author["pseudonym"] = "Today I don't think like doing anything!"
            with open(JSON_FILENAME, 'w', encoding='utf-8') as file:
                json.dump(authors_data, file, indent=4, ensure_ascii=False)
            print("Данные в JSON документе обновлены!")
        # 3. Запись (Добавление) в JSON документ
        elif choice == '3':
            with open(JSON_FILENAME, 'r', encoding='utf-8') as file:
                authors_data = json.load(file)
            new_author = {
                "author_id": 10101,
                "first_name": "New_Author",
                "last_name": "Lab_07_JSON",
                "pseudonym": "Some_pseudonym",
                "birthday": "2004-07-17"
            }
            authors_data.append(new_author)
            with open(JSON_FILENAME, 'w', encoding='utf-8') as file:
                json.dump(authors_data, file, indent=4, ensure_ascii=False)
            print("Новая запись добавлена в JSON документ!")
        # 0. Выйти из программы
        elif choice == '0':
            print("Выход из программы.")
            break
        else:
            print("Неверный выбор, попробуйте снова.")