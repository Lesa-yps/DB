import psycopg2
import redis
import json
from datetime import date
import config_Linux as conf

class DB_To_Redis:

    def __init__(self):
        try:
            # Подключение к PostgreSQL
            self.__connection = psycopg2.connect(
                host=conf.host,
                user=conf.user,
                port=conf.port,
                password=conf.password,
                database=conf.db_name
            )
            self.__connection.autocommit = True
            self.__cursor = self.__connection.cursor()
            print("[INFO] Успешно подключено к PostgreSQL.")
        
        except Exception as exc:
            self.__connection = None
            print(f"[INFO] Ошибка при подключении к PostgreSQL: {exc}.")

        try:
            # Подключение к Redis
            self.redis_client = redis.StrictRedis(host='localhost', port=6379, decode_responses=True)
            self.redis_client.ping()
            print("[INFO] Успешно подключено к Redis.")
        
        except Exception as exc:
            self.redis_client = None
            print(f"[INFO] Ошибка при подключении к Redis: {exc}.")


    # Функция преобразования данных в сериализуемый вид
    def __serialize_row(self, row):
        serialized = []
        for item in row:
            if isinstance(item, date):
                # Преобразование DATE в строку
                serialized.append(item.strftime('%Y-%m-%d'))
            else:
                serialized.append(item)
        return serialized

    # Функция сохраняет данные из PostgreSQL в Redis
    def save_to_redis(self, query, redis_key_prefix):
        if not self.redis_client:
            print("[INFO] Подключение к Redis отсутствует.")
            return

        try:
            self.__cursor.execute(query)
            rows = self.__cursor.fetchall()
            
            # Сохранение данных в Redis
            for row in rows:
                # Используем первый столбец как ключ
                redis_key = f"{redis_key_prefix}:{row[0]}"  
                # Преобразование строки в сериализуемый вид
                redis_value = json.dumps(self.__serialize_row(row[1:]))  
                self.redis_client.set(redis_key, redis_value)

            print(f"[INFO] Данные успешно сохранены в Redis с префиксом '{redis_key_prefix}'.")
        
        except Exception as exc:
            print(f"[INFO] Ошибка при сохранении данных в Redis: {exc}")


    def __del__(self):
        if self.__connection:
            self.__cursor.close()
            self.__connection.close()
            print("[INFO] Работа с PostgreSQL завершена.")


if __name__ == "__main__":
    db_to_redis = DB_To_Redis()

    # SQL-запрос для выборки данных
    query = "SELECT * FROM Rentals;"
    redis_prefix = "rental"

    # Загрузка данных в Redis
    db_to_redis.save_to_redis(query, redis_prefix)
