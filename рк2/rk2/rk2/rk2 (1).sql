-- РК2 ИУ7И-57Б ХУИНЬ_ВЬЕТ_ХЫНГ Вариант_2

-- MSSQL SERVER. T-SQL.

-- ЗАДАНИЕ 1

CREATE DATABASE RK2;
GO

USE RK2;
GO


CREATE TABLE ВидыКонфет (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Название NVARCHAR(100),
    Состав NVARCHAR(255),
    Описание NVARCHAR(MAX)
);
GO

CREATE TABLE Поставщики (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Название NVARCHAR(100),
    ИНН NVARCHAR(20),
    Адрес NVARCHAR(255)
);
GO

CREATE TABLE ТорговыеТочки (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Название NVARCHAR(100),
    Адрес NVARCHAR(255),
    ДатаРегистрации DATE,
    Рейтинг INT
);
GO


CREATE TABLE ВидыКонфет_Поставщики (
    ВидыКонфетID INT,
    ПоставщикиID INT,
	PRIMARY KEY (ВидыКонфетID, ПоставщикиID),
    FOREIGN KEY (ВидыКонфетID) REFERENCES ВидыКонфет(ID),
    FOREIGN KEY (ПоставщикиID) REFERENCES Поставщики(ID)
);
GO

CREATE TABLE Поставщики_ТорговыеТочки (
    ПоставщикиID INT,
    ТорговыеТочкиID INT,
	PRIMARY KEY (ПоставщикиID, ТорговыеТочкиID),
    FOREIGN KEY (ПоставщикиID) REFERENCES Поставщики(ID),
    FOREIGN KEY (ТорговыеТочкиID) REFERENCES ТорговыеТочки(ID)
);
GO

CREATE TABLE ВидыКонфет_ТорговыеТочки (
    ВидыКонфетID INT,
    ТорговыеТочкиID INT,
	PRIMARY KEY (ВидыКонфетID, ТорговыеТочкиID),
    FOREIGN KEY (ВидыКонфетID) REFERENCES ВидыКонфет(ID),
    FOREIGN KEY (ТорговыеТочкиID) REFERENCES ТорговыеТочки(ID)
);
GO


INSERT INTO ВидыКонфет (Название, Состав, Описание) VALUES 
('Шоколадные конфеты', 'Шоколад, сахар, молоко', 'Вкусные шоколадные конфеты'),
('Карамельки', 'Сахар, ароматизаторы', 'Карамель с разными вкусами'),
('Леденцы', 'Сахар, вода, лимонная кислота', 'Леденцы с фруктовым вкусом'),
('Трюфели', 'Шоколад, какао, масло', 'Трюфели с мягкой начинкой'),
('Мармелад', 'Желатин, фруктовый сок', 'Мармелад с натуральными соками'),
('Жевательные конфеты', 'Сахар, желатин', 'Жевательные конфеты с фруктовым вкусом'),
('Пралине', 'Шоколад, орехи, сахар', 'Конфеты с ореховой начинкой'),
('Ириски', 'Сахар, сливки', 'Сладкие ириски с молочным вкусом'),
('Сливочные конфеты', 'Сахар, молоко', 'Конфеты со сливочной начинкой'),
('Фруктовые батончики', 'Сухофрукты, орехи', 'Батончики с фруктовой начинкой');

INSERT INTO Поставщики (Название, ИНН, Адрес) VALUES 
('Конфетный Рай', '1234567890', 'ул. Сладкая, д. 1'),
('Сладкая Жизнь', '0987654321', 'ул. Ванильная, д. 2'),
('Шоколадная Фабрика', '1122334455', 'пр. Какао, д. 3'),
('Мир Леденцов', '2233445566', 'ул. Карамельная, д. 4'),
('Трюфельный Двор', '3344556677', 'ул. Шоколадная, д. 5'),
('Мармеладная Сказка', '4455667788', 'ул. Фруктовая, д. 6'),
('Жевательный Дом', '5566778899', 'ул. Сахарная, д. 7'),
('Пралине Премиум', '6677889900', 'пр. Ореховый, д. 8'),
('Сливочные Лакомства', '7788990011', 'ул. Сливочная, д. 9'),
('Фруктовый Микс', '8899001122', 'ул. Садовая, д. 10');

INSERT INTO ТорговыеТочки (Название, Адрес, ДатаРегистрации, Рейтинг) VALUES 
('Магазин №1', 'ул. Центральная, д. 1', '2024-01-15', 5),
('Магазин №2', 'ул. Лесная, д. 2', '2024-02-10', 4),
('Магазин №3', 'ул. Полевая, д. 3', '2024-03-05', 3),
('Магазин №4', 'ул. Городская, д. 4', '2024-04-20', 4),
('Магазин №5', 'ул. Морская, д. 5', '2024-05-25', 5),
('Магазин №6', 'ул. Цветочная, д. 6', '2024-06-30', 3),
('Магазин №7', 'ул. Солнечная, д. 7', '2024-07-15', 5),
('Магазин №8', 'ул. Лунная, д. 8', '2024-08-22', 4),
('Магазин №9', 'ул. Звездная, д. 9', '2024-09-10', 2),
('Магазин №10', 'ул. Набережная, д. 10', '2024-10-05', 5),
('Магазин №10', 'ул. Набережная, д. 10', '2024-10-05', 100);

INSERT INTO ВидыКонфет_Поставщики (ВидыКонфетID, ПоставщикиID) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

INSERT INTO Поставщики_ТорговыеТочки (ПоставщикиID, ТорговыеТочкиID) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

INSERT INTO ВидыКонфет_ТорговыеТочки (ВидыКонфетID, ТорговыеТочкиID) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);
GO


-- ЗАДАНИЕ 2

-- 1. Инструкция SELECT с использованием предиката сравнения:
-- Запрос выбирает торговые точки с рейтингом выше 3
SELECT ID, Название, Адрес, Рейтинг
FROM ТорговыеТочки
WHERE Рейтинг > 3;

-- 2. Инструкция, использующая оконную функцию:
-- Запрос подсчитывает среднего рейтинга по магазинам
SELECT DISTINCT Название,
    AVG(Рейтинг) OVER (PARTITION BY Название) AS СреднийРейтингПоМагазину
FROM ТорговыеТочки;

-- 3. Инструкция SELECT, использующая вложенные коррелированные подзапросы в FROM:
-- Запрос получает данные о конфетах и их поставщиках
SELECT vc.ID, vc.Название AS НазваниеКонфет, ps.ID, ps.Название AS НазваниеПоставщика
FROM ВидыКонфет vc
JOIN (SELECT ВидыКонфетID, ПоставщикиID
      FROM ВидыКонфет_Поставщики
      WHERE ВидыКонфетID IN (SELECT ID FROM ВидыКонфет)
     ) AS vcps ON vc.ID = vcps.ВидыКонфетID
JOIN Поставщики ps ON vcps.ПоставщикиID = ps.ID;
GO

-- ЗАДАНИЕ 3

-- Хранимая процедура для поиска ключевого слова в тексте хранимых процедур и функций
CREATE PROCEDURE FindFunctionsAndProcedures
    @Keyword NVARCHAR(100)
AS
BEGIN
    SELECT 
        SPECIFIC_NAME AS ИмяОбъекта,
        ROUTINE_TYPE AS ТипОбъекта,
        ROUTINE_DEFINITION AS ОпределениеОбъекта
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_DEFINITION LIKE '%' + @Keyword + '%'
          AND ROUTINE_TYPE IN ('PROCEDURE', 'FUNCTION');
END;
GO

-- Тестирование процедуры
EXEC FindFunctionsAndProcedures 'SELECT';
