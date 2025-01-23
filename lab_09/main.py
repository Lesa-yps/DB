import psycopg2
import redis
import time
import matplotlib.pyplot as plt
import config_Linux as conf
import json
import base64
from copy import deepcopy

NO_CHANGES = "Без изменений БД"
ADD_ROWS = "Добавление строк в БД"
DELETE_ROWS = "Удаление строк в БД"
UPDATE_ROWS = "Обновление строк в БД"


# хэширование запроса кодировкой base64
def encode_query(query):
    return base64.urlsafe_b64encode(query.encode()).decode()

# расхэширование запроса из кодировки base64
def decode_query(encoded_query):
    return base64.urlsafe_b64decode(encoded_query.encode()).decode()


# класс для работы с PostgreSQL и Redis, а также замеров в них
class Analyzer_query_performance:

    # конструктор
    def __init__(self):
        # Подключение к PostgreSQL
        try:
            self.pg_conn = psycopg2.connect(
                host=conf.host,
                user=conf.user,
                port=conf.port,
                password=conf.password,
                database=conf.db_name
            )
            self.pg_conn.autocommit = True
            self.pg_cursor = self.pg_conn.cursor()
            print("[INFO] Успешно подключено к PostgreSQL.")
        except Exception as exc:
            self.pg_conn = None
            print(f"[ERROR] Ошибка подключения к PostgreSQL: {exc}")

        # Подключение к Redis
        try:
            self.redis_client = redis.StrictRedis(host='localhost', port=6379, decode_responses=True)
            self.redis_client.ping()
            print("[INFO] Успешно подключено к Redis.")
        except Exception as exc:
            self.redis_client = None
            print(f"[ERROR] Ошибка подключения к Redis: {exc}")

        # хранилища времён выполнения
        self.pg_times = []
        self.redis_times = []

    # очистка кэша редиса (если ключ передан, то очистка ключа, иначе всего кэша)
    def clear_redis_cache(self, query_key=None):
        if self.redis_client:
            try:
                if query_key:
                    self.redis_client.delete(query_key)
                    print(f"[INFO] Кэш для ключа '{query_key}' успешно очищен.")
                else:
                    self.redis_client.flushdb()
                    print("[INFO] Все данные в Redis успешно очищены.")
            except Exception as exc:
                print(f"[ERROR] Ошибка при очистке кэша Redis: {exc}")
        else:
            print("[INFO] Подключение к Redis отсутствует.")

    # выборка данных из postgres по запросу (с замером времени запроса)
    def fetch_from_postgres(self, query, to_redis=False):
        start_time = time.time()
        self.pg_cursor.execute(query)
        rows = self.pg_cursor.fetchall()
        end_time = time.time()
        execution_time = end_time - start_time
        if not to_redis:
            self.pg_times.append(execution_time)
        return rows

    # выборка данных из кэша redis по запросу (с замером времени запроса)
    # если данных нет в кэше (или они были изменены), идёт запрос в postgres и результат сохраняется в redis
    def fetch_from_redis(self, query_key, is_modify=False):
        if self.redis_client is None:
            print("Ошибка: Redis не подключён!")
            exit(1)
        start_time = time.time()
        if not is_modify:
            cached_data = self.redis_client.get(query_key)
        if not is_modify and cached_data is not None:
            rows = json.loads(cached_data)
        else:
            query = decode_query(query_key)
            rows = self.fetch_from_postgres(query, to_redis=True)
            self.redis_client.set(query_key, json.dumps(rows), ex=300)
        end_time = time.time()
        execution_time = end_time - start_time
        self.redis_times.append(execution_time)
        return rows

    # выполнение преобразований с базой (добавление / удаление / изменение строк через интервалы времени)
    def perform_modifications(self, mode):
        if mode == NO_CHANGES:
            pass
        elif mode == ADD_ROWS:
            self.pg_cursor.execute(
                "INSERT INTO Rentals (rental_id, book_id, reader_id, take_date, return_date) "
                "VALUES ((SELECT COALESCE(MAX(rental_id), 0) + 1 FROM Rentals), 3, 2, NOW(), NOW())"
            )
        elif mode == DELETE_ROWS:
            self.pg_cursor.execute("DELETE FROM Rentals WHERE book_id = (SELECT COALESCE(MAX(rental_id), 0) FROM Rentals)")
        elif mode == UPDATE_ROWS:
            self.pg_cursor.execute(
                "UPDATE Rentals SET return_date = NOW() WHERE book_id = (SELECT COALESCE(MAX(rental_id), 0) FROM Rentals)"
            )

    # построение результирующих графиков (4)
    def plot_results(self, titles, all_pg_times, all_rd_times):
        _, axs = plt.subplots(2, 2, figsize=(15, 10))
        for i, (ax, title) in enumerate(zip(axs.flat, titles)):
            times_pg_i = all_pg_times[i]
            times_rd_i = all_rd_times[i]
            ax.plot(range(len(times_pg_i)), times_pg_i, label="PostgreSQL")
            ax.plot(range(len(times_rd_i)), times_rd_i, label="Redis")
            ax.set_title(title)
            ax.set_xlabel("Номер замера")
            ax.set_ylabel("Время выполнения (сек.)")
            ax.legend()
            ax.grid()
        plt.tight_layout()
        plt.show()

    # деструктор
    def __del__(self):
        if self.pg_conn:
            self.pg_cursor.close()
            self.pg_conn.close()
            print("[INFO] Работа с PostgreSQL завершена.")



if __name__ == "__main__":
    analyzer = Analyzer_query_performance()
    # выборка топ-10 читаемых книг
    query = """SELECT book_id, count(*) AS count_readers
                   FROM Rentals
                   GROUP BY book_id
                   ORDER BY count_readers DESC
                   LIMIT 10;"""
    # получение хэша запроса для ключа Redis
    query_key = encode_query(query)
    # сценарии
    scenarios = [NO_CHANGES, ADD_ROWS, DELETE_ROWS, UPDATE_ROWS]
    # массивы для хранения времён - замеров
    all_pg_times, all_rd_times = [], []
    # проведение замеров для всех сценариев
    for scenario in scenarios:
        print(f"[INFO] Сценарий: {scenario}")
        # очистка данных из Redis
        analyzer.clear_redis_cache(query_key)
        # делаем 10 замеров (с таймаутом = 5 секунд)
        for i in range(10):
            # переменная означает были ли данные изменены (актуальны ли старые из кэша?)
            is_modify = scenario != NO_CHANGES and i % 2 != 0
            analyzer.fetch_from_postgres(query)
            analyzer.fetch_from_redis(query_key, is_modify)
            # модификация данных
            if i % 2 == 0:
                analyzer.perform_modifications(scenario)
            time.sleep(5)
        # запоминаем массивы времён и очищаем их
        all_pg_times.append(deepcopy(analyzer.pg_times))
        all_rd_times.append(deepcopy(analyzer.redis_times))
        analyzer.pg_times.clear()
        analyzer.redis_times.clear()
    # построение итоговых графиков
    analyzer.plot_results(scenarios, all_pg_times, all_rd_times)
