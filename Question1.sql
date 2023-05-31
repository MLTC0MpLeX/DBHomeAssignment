-- a) Create a database called a3products.
CREATE DATABASE a3products;
GO

USE a3products;
GO


-- b) Create two schemas: loading, and main.
CREATE SCHEMA loading;
CREATE SCHEMA main
GO

-- c) In loading schema, create the table json_data as per given ERD.
-- Assuming that the ERD has columns id, data for the json_data table
CREATE TABLE loading.json_data
(
    id INT PRIMARY KEY IDENTITY(1,1),
    JSONdata NVARCHAR(MAX) NOT NULL , -- NVARCHAR(MAX) can be used to store JSON data as a string
    DateLoaded datetime NOT NULL ,
    DateProcessed datetime

);
GO

ALTER TABLE loading.json_data
ADD CONSTRAINT DF_DateLoaded DEFAULT (getdate()) FOR DateLoaded

-- d) In main schema, create the tables brand, category, and product as per given ERD.
-- Assuming that the ERD has these columns for the brand, category and product tables
CREATE TABLE main.brand
(
    BrandId INT PRIMARY KEY IDENTITY(1,1),
    BrandName NVARCHAR(255) UNIQUE NOT NULL
);
GO

CREATE TABLE main.category
(
    CategoryId INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(255) UNIQUE NOT NULL
);
GO

CREATE TABLE main.product
(
    ProductId INT PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL UNIQUE ,
    Description NVARCHAR(MAX) NOT NULL ,
    Price NUMERIC(8,2) NOT NULL ,
    DiscountPercentage NUMERIC(8,2),
    Rating NUMERIC(8,2) NOT NULL ,
    Stock NUMERIC(8) NOT NULL ,
    brand_id INT FOREIGN KEY REFERENCES main.brand(BrandId),
    category_id INT FOREIGN KEY REFERENCES main.category(CategoryId)
);
GO
