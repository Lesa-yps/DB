import psycopg2

# Подключение к базе данных
connection = psycopg2.connect(
    dbname='cosmos',
    user='olesya',
    password='280904',
    host='localhost',
    port=5432
)
cursor = connection.cursor()

# 1. Найти страны с наибольшим числом аппаратов в октябре
cursor.execute("""
    SELECT country, COUNT(*) AS total_satellites
    FROM satellite
    WHERE EXTRACT(MONTH FROM manufacture_date) = 10
    GROUP BY country
    ORDER BY total_satellites DESC;
""")
print("Страны с наибольшим числом аппаратов в октябре:", cursor.fetchall())

# 2. Найти спутник с самым поздним вылетом в этом году
cursor.execute("""
    SELECT s.name, f.launch_date, f.launch_time
    FROM flight f
    JOIN satellite s ON f.satellite_id = s.id
    WHERE EXTRACT(YEAR FROM f.launch_date) = EXTRACT(YEAR FROM CURRENT_DATE)
      AND f.type_flight = 1
    ORDER BY f.launch_date DESC, f.launch_time DESC
    LIMIT 1;
""")
print("Спутник с самым поздним вылетом в этом году:", cursor.fetchall())

# 3. Найти российские спутники с вылетом до 1 сентября 2024
cursor.execute("""
    SELECT s.name, f.launch_date, f.launch_time
    FROM flight f
    JOIN satellite s ON f.satellite_id = s.id
    WHERE s.country = 'Россия'
      AND f.type_flight = 1
      AND f.launch_date <= '2024-09-01';
""")
print("Российские спутники с вылетом до 1 сентября 2024:", cursor.fetchall())

# Завершаем подключение
cursor.close()
connection.close()
