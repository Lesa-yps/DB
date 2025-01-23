from peewee import *
from datetime import date

# Подключение к БД PostgreSQL
db = PostgresqlDatabase(
    'cosmos',
    user='olesya',
    password='280904',
    host='localhost',
    port=5432
)

# Базовая модель
class BaseModel(Model):
    class Meta:
        database = db

# Модель для таблицы Космических аппаратов (satellite)
class Satellite(BaseModel):
    id = AutoField()
    name = CharField(max_length=50, null=False)
    manufacture_date = DateField(null=False)
    country = CharField(max_length=50, null=False)

# Модель для таблицы Космических полетов (flight)
class Flight(BaseModel):
    id = AutoField()
    satellite = ForeignKeyField(Satellite, backref='flights', on_delete='CASCADE')
    launch_date = DateField(null=False)
    launch_time = TimeField(null=False)
    day_of_week = CharField(max_length=15, null=True)
    type_flight = IntegerField(constraints=[Check("type_flight IN (1, 0)")])  # 1 - вылет, 0 - прилет

# Создание таблиц
def create_tables():
    db.connect()
    db.create_tables([Satellite, Flight], safe=True)
    print("Таблицы созданы!")

# Заполнение тестовыми данными
def populate_data():

    # Очистка таблиц
    Flight.delete().execute()
    Satellite.delete().execute()

    # Вставка новых данных
    russia = Satellite.create(name="Спутник-1", manufacture_date="2023-10-05", country="Россия")
    usa = Satellite.create(name="Satellite-X", manufacture_date="2023-09-15", country="США")
    china = Satellite.create(name="Satellite-Y", manufacture_date="2023-10-10", country="Китай")

    Flight.create(satellite=russia, launch_date="2023-08-15", launch_time="08:00:00", day_of_week="Четверг", type_flight=1)
    Flight.create(satellite=russia, launch_date="2024-09-01", launch_time="10:00:00", day_of_week="Воскресенье", type_flight=1)
    Flight.create(satellite=usa, launch_date="2024-11-05", launch_time="12:00:00", day_of_week="Вторник", type_flight=1)
    Flight.create(satellite=china, launch_date="2024-07-20", launch_time="15:30:00", day_of_week="Суббота", type_flight=0)

    print("Данные добавлены!")

# 1. Найти страны, которые производили больше всего аппаратов в октябре
def query_most_produced_in_october():
    query = (Satellite
             .select(Satellite.country, fn.COUNT(Satellite.id).alias('count'))
             .where(fn.date_part('month', Satellite.manufacture_date) == 10)
             .group_by(Satellite.country)
             .order_by(fn.COUNT(Satellite.id).desc()))
    
    print("\nСтраны, которые произвели больше всего аппаратов в октябре:")
    for row in query.dicts():
        print(f"Страна: {row['country']}, Количество: {row['count']}")


# 2. Найти спутник, который в этом году отправлен позже всех
def query_latest_satellite_this_year():
    query = (Flight
             .select(Flight, Satellite)
             .join(Satellite)
             .where(fn.date_part('year', Flight.launch_date) == date.today().year)
             .order_by(Flight.launch_date.desc(), Flight.launch_time.desc())
             .limit(1))
    # что получилось (отладка)
    print(query.sql())
    
    print("\nСпутник, отправленный позже всех в этом году:")
    for flight in query:
        print(f"Название: {flight.satellite.name}, Дата запуска: {flight.launch_date}, Время: {flight.launch_time}")


# 3. Найти все российские спутники, у которых состоялся вылет в 2024 году не позднее 1 сентября
def query_russian_satellites_before_september():
    query = (Flight
             .select(Flight, Satellite)
             .join(Satellite)
             .where(
                 (Satellite.country == "Россия") &
                 (fn.date_part('year', Flight.launch_date) == 2024) &
                 (Flight.launch_date <= date(2024, 9, 1)) &
                 (Flight.type_flight == 1)
             ))
    
    print("\nРоссийские спутники, вылетевшие в 2024 году не позднее 1 сентября:")
    for flight in query:
        print(f"Название: {flight.satellite.name}, Дата запуска: {flight.launch_date}, Время: {flight.launch_time}")

# Главная функция
if __name__ == '__main__':
    create_tables()
    populate_data()
    query_most_produced_in_october()
    query_latest_satellite_this_year()
    query_russian_satellites_before_september()
