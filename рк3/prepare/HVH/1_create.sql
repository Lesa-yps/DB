CREATE DATABASE Cosmos;

-- Таблица Космических аппаратов
CREATE TABLE IF NOT EXISTS satellite (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    manufacture_date DATE NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- Таблица Космических полетов
CREATE TABLE IF NOT EXISTS flight (
    id SERIAL PRIMARY KEY,
    satellite_id INT REFERENCES satellite(id),
    launch_date DATE NOT NULL,
    launch_time TIME NOT NULL,
    day_of_week VARCHAR(15),
    type_flight INT CHECK (type_flight IN (0, 1)) -- 1 - вылет, 0 - прилет
);

-- Вставка данных в таблицу "Космические аппараты"
INSERT INTO satellite (id, name, manufacture_date, country)
VALUES 
(1, 'SIT-2068', '2050-05-11', 'Россия'),
(2, 'Шинджи-12', '2049-12-01', 'Китай')
(3, 'Победа', '2039-11-17', 'Россия');

-- Вставка данных в таблицу "Космических полетов"
INSERT INTO flight (satellite_id, launch_date, launch_time, day_of_week, type_flight)
VALUES
(1, '2050-05-11', '13:00', 'Среда', 1),
(1, '2051-06-13', '23:00', 'Вторник', 0),
(2, '2050-06-12', '19:00', 'Понедельник', 1),
(2, '2052-06-15', '12:15', 'Четверг', 0);

-- drop table satellite;
-- drop table flight;
