import psycopg2
from psycopg2 import sql
import config as conf

from generate import regenerate_write_random_all, COUNT_DATES, DEF_FILENAMES

class DB_Library:

    def __init__(self):
        try:
            # Подключение к серверу без указания базы данных
            connection = psycopg2.connect(
                host = conf.def_host, 
                user = conf.def_user, 
                password = conf.def_password,
                port = conf.def_port,
                database = conf.def_database,  # Подключаемся к системной базе данных postgres
            )
            connection.autocommit = True
            cursor = connection.cursor()

            # Проверяем, существует ли база данных
            cursor.execute(f"SELECT 1 FROM pg_database WHERE datname = '{conf.db_name}'")
            if not cursor.fetchone():
                # Если базы данных не существует, создаем её
                cursor.execute(sql.SQL("CREATE DATABASE {}").format(
                    sql.Identifier(conf.db_name)
                ))
                print(f"[INFO] База данных '{conf.db_name}' успешно создана.")
            else:
                print(f"[INFO] База данных '{conf.db_name}' уже существует.")

            cursor.close()
            connection.close()

            # Подключаемся к только что созданной базе данных
            self.__connection = psycopg2.connect(
                host = conf.host,
                user = conf.user,
                port = conf.port,
                password = conf.password,
                database = conf.db_name  # Теперь подключаемся к созданной базе данных
            )
            self.__connection.autocommit = True
            self.__cursor = self.__connection.cursor()

            print("[INFO] Успешно начата работа с PostgreSQL. БД готова к работе.")
        
        except Exception as exc:
            self.__connection = None
            print(f"[INFO] Error while working with PostgreSQL: {exc}.")

    def __execute__(self, sql_file):
        try:
            with open(sql_file, 'r') as file:
                sql_script = file.read()
            # Выполнение SQL-скрипта
            self.__cursor.execute(sql_script)
            print(f"[INFO] Файл {sql_file} успешно выполнен.")
        
        except Exception as exc:
            self.__connection.rollback() # откат
            print(f"[INFO] Ошибка при выполнении файла {sql_file}: {exc}.")
    
    def delete_all(self, filename = "delete_all.sql"):
        self.__execute__(filename)

    def create_bd(self, create_filename = "create.sql", constraint_filename = "constraint.sql"):
        self.__execute__(create_filename)
        self.__execute__(constraint_filename)
    
    def test_data_copy(self, filename = "copy.sql"):
        self.__execute__(filename)
    
    def generate_data(self, filenames = DEF_FILENAMES, count = COUNT_DATES):
        regenerate_write_random_all(filenames=filenames, count=count)
        self.test_data_copy()

    def __del__(self):
        if self.__connection:
            self.__cursor.close()
            self.__connection.close()
            print("[INFO] PostgreSQL connection closed.")


if __name__ == "__main__":
    db_lib = DB_Library()
    user = -1
    print("Начинается работа с базой данных DB_Litres...\n")
    while (user != 0):
        print("Меню:\n"
              "1 - пересоздать БД;\n"
              "2 - удалить БД;\n"
              "3 - скопировать данные в БД из файлов из папки test_data;\n"
              "4 - сгенерировать 1000 записей в таблицы;\n"
              "0 - выйти из программы, завершив работу с БД.")
        user = int(input("Введите выбранный пункт меню: "))
        if (user == 1):
            db_lib.create_bd()
        elif (user == 2):
            db_lib.delete_all()
        elif (user == 3):
            db_lib.test_data_copy()
        elif (user == 4):
            db_lib.generate_data()
        elif (user == 0):
            print("Завершение работы ^-^")
        else:
            user = -1
            print("Ошибка в выборе пункта меню. Повторите попытку.\n")