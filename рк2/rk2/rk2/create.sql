CREATE TABLE Сотрудник (
    PK_ID INTEGER PRIMARY KEY,
    ФИО VARCHAR(255),
    Год_рождения INTEGER,
    Должность VARCHAR(255)
);

CREATE TABLE Виды_валют (
    PK_ID INTEGER PRIMARY KEY,
    Валюта VARCHAR(255)
);

CREATE TABLE Курсы_валют (
    PK_ID INTEGER PRIMARY KEY,
    ID_Валюта INTEGER,
    Продажа DECIMAL(10,2),
    Покупка DECIMAL(10,2),
    FOREIGN KEY (ID_Валюта) REFERENCES Виды_валют(PK_ID)
);


CREATE TABLE Операция_обмена (
    PK_ID INTEGER PRIMARY KEY,
    ID_Сотрудник INTEGER,
    ID_Курс_валют INTEGER,
    Сумма DECIMAL(10,2),
    FOREIGN KEY (ID_Сотрудник) REFERENCES Сотрудник(PK_ID),
    FOREIGN KEY (ID_Курс_валют) REFERENCES Курсы_валют(PK_ID)
);
