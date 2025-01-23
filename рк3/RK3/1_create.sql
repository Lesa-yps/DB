CREATE DATABASE Cosmos;

-- drop table flight;
-- drop table satellite;

-- таблица Космических аппаратов
CREATE TABLE IF NOT EXISTS satellite (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    manufacture_date DATE NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- таблица Космических полетов
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
(2, 'Шинджи-12', '2049-12-01', 'Китай'),
(3, 'Победа', '2024-08-17', 'Россия'),
(4, 'Amerinan_boy', '2024-11-13', 'США'),
(5, 'Sergey', '2022-01-14', 'Россия'),
(6, 'Some-2', '2023-12-01', 'Китай');

-- Вставка данных в таблицу "Космических полетов"
INSERT INTO flight (satellite_id, launch_date, launch_time, day_of_week, type_flight)
values
(1, '2050-05-11', '9:00', 'Среда', 1),
(1, '2051-06-14', '23:05', 'Среда', 0),
(1, '2051-10-10', '23:50', 'Вторник', 1),
(2, '2050-05-11', '15:15', 'Среда', 1),
(2, '2052-01-01', '12:15', 'Понедельник', 0),
(3, '2024-11-10', '11:01', 'Суббота', 1),
(4, '2024-02-17', '10:00', 'Пятница', 1),
(5, '2023-06-14', '23:05', 'Среда', 0),
(6, '2023-05-11', '9:00', 'Понедельник', 0);

