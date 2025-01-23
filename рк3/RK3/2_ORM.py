from peewee import *
from datetime import date

# подключиться к БД PostgreSQL
db = PostgresqlDatabase(
    'cosmos',
    user='olesya',
    password='280904',
    host='localhost',
    port=5432
)

# базовая модель
class BaseModel(Model):
    class Meta:
        database = db

# модель для таблицы Космических аппаратов (satellite)
class Satellite(BaseModel):
    id = AutoField()
    name = CharField(max_length=50, null=False)
    manufacture_date = DateField(null=False)
    country = CharField(max_length=50, null=False)

# модель для таблицы Космических полетов (flight)
class Flight(BaseModel):
    id = AutoField()
    satellite = ForeignKeyField(Satellite, backref='flights', on_delete='CASCADE')
    launch_date = DateField(null=False)
    launch_time = TimeField(null=False)
    day_of_week = CharField(max_length=15, null=True)
    type_flight = IntegerField(constraints=[Check("type_flight IN (1, 0)")])  # 1 - вылет, 0 - прилет

# создать таблиц
def create_tables():
    db.connect()
    db.create_tables([Satellite, Flight], safe=True)
    print("Таблицы созданы.")


# 1. Найти самый древний спутник в России
def query_older_Russian_satellite():
    query = (Satellite
             .select()
             .where(Satellite.country == 'Россия')
             .order_by(Satellite.manufacture_date)
             .limit(1))
    
    print("\nСамый древний спутник в России:")
    satel = query.get()
    print(f"    ID: {satel.id}, Название: {satel.name}, Дата производства: {satel.manufacture_date}, Страна: {satel.country}")


# 2. Найти спутник, который в этом году был отправлен раньше всех
def query_earliest_satellite_this_year():
    query = (Flight
             .select(Flight, Satellite)
             .join(Satellite)
             .where(fn.date_part('year', Flight.launch_date) == date.today().year)
             .order_by(Flight.launch_date, Flight.launch_time)
             .limit(1))
    
    print("\nСпутник, который в этом году был отправлен раньше всех:")
    satel = query.get()
    print(f"    ID: {satel.satellite.id}, Название: {satel.satellite.name}, Дата запуска: {satel.launch_date}, Время: {satel.launch_time}")


# 3. Найти спутник, который в прошлом календарном году вернулся последним
def query_lastest_return_satellite_last_year():
    query = (Flight
             .select(Flight, Satellite)
             .join(Satellite)
             .where((fn.date_part('year', Flight.launch_date) == date.today().year - 1) &
                 (Flight.type_flight == 0))
             .order_by(Flight.launch_date.desc(), Flight.launch_time.desc())
             .limit(1))
    
    print("\nСпутник, который в прошлом календарном году вернулся последним:")
    satel = query.get()
    print(f"    ID: {satel.satellite.id}, Название: {satel.satellite.name}, Дата запуска: {satel.launch_date}, Время: {satel.launch_time}")



if __name__ == '__main__':
    create_tables()
    query_older_Russian_satellite()
    query_earliest_satellite_this_year()
    query_lastest_return_satellite_last_year()
