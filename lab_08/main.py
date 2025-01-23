import os
import json
import time
from datetime import datetime
from peewee import *

OUTPUT_DIR = "./nifi/in_file/"
COUNT_MIN = 5


# создать объект подключения к базе данных
db = PostgresqlDatabase(
    'postgres',
    user='olesya',
    password='280904',
    host='localhost',
    port=5433
)


# базовый класс для всех моделей
class BaseModel(Model):
    class Meta:
        database = db


# модель для таблицы Authors_lab8
class Authors_lab8(BaseModel):
    author_id = AutoField()
    first_name = CharField(max_length=225, null=False)
    last_name = CharField(max_length=225, null=False)
    pseudonym = CharField(max_length=225, null=True)
    birthday = DateField(constraints=[Check('birthday <= CURRENT_DATE')])


# генерация имени файла с маской
def generate_filename(table_name: str, file_format: str) -> str:
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    return f"{OUTPUT_DIR}{table_name}_{timestamp}.{file_format}"


def main():
    db.connect()
    db.create_tables([Authors_lab8], safe=True)
    print("Инициализация с PostgreSQL прошла успешно!")

    try:
        while True:
            try:
                # определяется максимальный ID автора
                max_id = Authors_lab8.select(fn.MAX(Authors_lab8.author_id)).scalar() or 0

                # создаётся новая запись автора
                new_author = {
                    "first_name": f"Author_{max_id + 1}",
                    "last_name": f"LastName_{max_id + 1}",
                    "pseudonym": f"Pseudonym_{max_id + 1}",
                    "birthday": "2000-01-01"
                }

                # генерация имени файла
                filename = generate_filename("Authors", "json")

                # создаётся папка для выходного файла, если её нет
                if not os.path.exists(OUTPUT_DIR):
                    os.makedirs(OUTPUT_DIR)

                # сохраняются данные в формате JSON
                with open(filename, 'w', encoding='utf-8') as file:
                    json.dump(new_author, file, indent=4, ensure_ascii=False)

                print(f"Новая запись добавлена с ID {max_id + 1} в файле {filename}.")

            except Exception as e:
                print(f"Ошибка: {e}")

            # Ждем 5 минут
            time.sleep(COUNT_MIN * 60)

    except KeyboardInterrupt:
        print("Выход из программы...")
    finally:
        db.close()


if __name__ == '__main__':
    main()
