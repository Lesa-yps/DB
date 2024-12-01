import psycopg2
import config_Linux as conf
import shutil

SQL_DIR = "sql_dir"
RES_DIR = "res_dir"

flag_was_9 = False


class DB_Library:

    def __init__(self):
        global flag_was_9
        try:
            # Подключаемся к базе данных
            self.__connection = psycopg2.connect(
                host = conf.host,
                user = conf.user,
                port = conf.port,
                password = conf.password,
                database = conf.db_name
            )
            self.__connection.autocommit = True
            self.__cursor = self.__connection.cursor()

            # Проверка на существование таблицы из пункта 9
            with open(SQL_DIR + "/check_9.sql", 'r') as file:
                sql_script = file.read()
            self.__cursor.execute(sql_script)
            flag_was_9 = self.__cursor.fetchone()[0]

            print("[INFO] Успешно начата работа с PostgreSQL. БД готова к работе.")
        
        except Exception as exc:
            self.__connection = None
            print(f"[INFO] Ошибка во время работы с PostgreSQL: {exc}.")

    def __execute__(self, file_number):
        try:
            sql_file = SQL_DIR + '/' + file_number + '.sql'
            res_file = RES_DIR + '/' + file_number + '.csv'
            tmp_res_file = '/tmp/' + file_number + '.csv'
            with open(sql_file, 'r') as file:
                sql_script = file.read()
            # Выполнение SQL-скрипта
            self.__cursor.execute(sql_script)
            print(f"[INFO] Файл {sql_file} успешно выполнен.")
            # Копирование файла
            shutil.copy(tmp_res_file, res_file)
            return 0
        
        except Exception as exc:
            self.__connection.rollback() # откат
            print(f"[INFO] Ошибка при выполнении файла {sql_file}: {exc}.")
            return 1

    def __del__(self):
        if self.__connection:
            self.__cursor.close()
            self.__connection.close()
            print("[INFO] Работа с PostgreSQL завершена.")


if __name__ == "__main__":
    db_lib = DB_Library()
    user = -1
    print("Начинается работа с базой данных DB_Litres...\n")
    while (user != 0):
        print("Меню:\n"
              "0. Выйти из программы, завершив работу с БД.\n"
              "1. Выполнить скалярный запрос;\n"
              "2. Выполнить запрос с несколькими соединениями (JOIN);\n"
              "3. Выполнить запрос с ОТВ(CTE) и оконными функциями;\n"
              "4. Выполнить запрос к метаданным;\n"
              "5. Вызвать скалярную функцию (написанную в третьей лабораторной работе);\n"
              "6. Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе);\n"
              "7. Вызвать хранимую процедуру (написанную в третьей лабораторной работе);\n"
              "8. Вызвать системную функцию или процедуру;\n"
              "9. Создать таблицу в базе данных, соответствующую тематике БД;\n"
              "10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.")
        user = int(input("Введите выбранный пункт меню: "))
        if (user <= 10 and user >= 1):
            if user == 10 and not flag_was_9:
                print("Ошибка! Таблица не была создана. Выполните пункт 9.")
                continue
            rc = db_lib.__execute__(str(user))
            if rc == 0 and user == 9:
                flag_was_9 = True
        elif (user == 0):
            print("Завершение работы ^-^")
        else:
            user = -1
            print("Ошибка в выборе пункта меню. Повторите попытку.\n")