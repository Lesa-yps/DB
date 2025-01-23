import psycopg2

# подключиться к базе данных
connection = psycopg2.connect(
    dbname='cosmos',
    user='olesya',
    password='280904',
    host='localhost',
    port=5432
)
cursor = connection.cursor()

# 1. Найти самый древний спутник в России
cursor.execute("""
    SELECT *
    FROM satellite
    WHERE country = 'Россия'
    ORDER BY manufacture_date
    LIMIT 1;
""")
print("Самый древний спутник в России:", cursor.fetchall())

# 2. Найти спутник, который в этом году был отправлен раньше всех
cursor.execute("""
    SELECT s.id, s.name, f.launch_date, f.launch_time
    FROM flight f
    JOIN satellite s ON f.satellite_id = s.id
    WHERE EXTRACT(YEAR FROM f.launch_date) = EXTRACT(YEAR FROM CURRENT_DATE)
      AND f.type_flight = 1
    ORDER BY f.launch_date, f.launch_time
    LIMIT 1;
""")
print("Спутник, который в этом году был отправлен раньше всех:", cursor.fetchall())

# 3. Найти спутник, который в прошлом календарном году вернулся последним
cursor.execute("""
    SELECT s.id, s.name, f.launch_date, f.launch_time
    FROM flight f
    JOIN satellite s ON f.satellite_id = s.id
    WHERE EXTRACT(YEAR FROM f.launch_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
      AND f.type_flight = 0
    ORDER BY f.launch_date DESC, f.launch_time DESC
    LIMIT 1;
""")
print("Спутник, который в прошлом календарном году вернулся последним:", cursor.fetchall())

# завершить подключение
cursor.close()
connection.close()
