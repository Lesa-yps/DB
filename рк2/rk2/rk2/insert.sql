INSERT INTO Сотрудник (PK_ID, ФИО, Год_рождения, Должность) VALUES
(1, 'Иванов Иван Иванович', 1985, 'Менеджер'),
(2, 'Петрова Елена Сергеевна', 1990, 'Кассир'),
(3, 'Сидоров Петр Алексеевич', 1988, 'Старший менеджер'),
(4, 'Кузнецова Ольга Владимировна', 1992, 'Кассир'),
(5, 'Смирнов Андрей Николаевич', 1987, 'Менеджер'),
(6, 'Васильева Екатерина Игоревна', 1995, 'Кассир'),
(7, 'Попов Александр Михайлович', 1983, 'Старший менеджер'),
(8, 'Соколова Марина Викторовна', 1991, 'Менеджер'),
(9, 'Михайлов Дмитрий Олегович', 1989, 'Кассир'),
(10, 'Новикова Анна Андреевна', 1994, 'Менеджер');

INSERT INTO Виды_валют (PK_ID, Валюта) VALUES
(1, 'USD'),
(2, 'EUR'),
(3, 'GBP'),
(4, 'JPY'),
(5, 'CHF'),
(6, 'CAD'),
(7, 'AUD'),
(8, 'CNY'),
(9, 'HKD'),
(10, 'SGD');

INSERT INTO Курсы_валют (PK_ID, ID_Валюта, Продажа, Покупка) VALUES
(1, 1, 73.50, 72.50),
(2, 2, 87.20, 86.00),
(3, 3, 105.00, 103.50),
(4, 4, 0.68, 0.66),
(5, 5, 78.00, 77.00),
(6, 6, 58.50, 57.50),
(7, 7, 56.00, 55.00),
(8, 8, 11.50, 11.00),
(9, 9, 9.50, 9.00),
(10, 10, 55.00, 54.00);

INSERT INTO Операция_обмена (PK_ID, ID_Сотрудник, ID_Курс_валют, Сумма) VALUES
(1, 2, 1, 500.00),
(2, 4, 2, 750.00),
(3, 9, 3, 1000.00),
(4, 2, 4, 250.00),
(5, 6, 5, 600.00),
(6, 4, 6, 800.00),
(7, 9, 7, 400.00),
(8, 2, 8, 900.00),
(9, 6, 9, 1200.00),
(10, 4, 10, 350.00);

