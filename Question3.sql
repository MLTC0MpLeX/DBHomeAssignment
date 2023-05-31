USE a3products;
GO

CREATE PROCEDURE main.processJson @id INT
AS
BEGIN
    -- a) Turn off row counting.
    SET NOCOUNT ON;

    -- b) Declare a temporary table that will store only the following fields from the JSON data: id, title,
    -- description, price, discountedPercentage, rating, stock, brand, category.
    CREATE TABLE #tempTable
    (
        id INT,
        title NVARCHAR(MAX),
        description NVARCHAR(MAX),
        price FLOAT,
        discountedPercentage FLOAT,
        rating INT,
        stock INT,
        brand NVARCHAR(255),
        category NVARCHAR(255)
    )

    -- c) Find the record from loading.json_data that has an ID that matches the passed parameter,
    -- process the JSON data and store it in the temporary table.
  
    INSERT INTO #tempTable
    SELECT 
        JSON_VALUE(JSONdata, '$.id'),
        JSON_VALUE(JSONdata, '$.title'),
        JSON_VALUE(JSONdata, '$.description'),
        JSON_VALUE(JSONdata, '$.price'),
        JSON_VALUE(JSONdata, '$.discountedPercentage'),
        JSON_VALUE(JSONdata, '$.rating'),
        JSON_VALUE(JSONdata, '$.stock'),
        JSON_VALUE(JSONdata, '$.brand'),
        JSON_VALUE(JSONdata, '$.category')
    FROM loading.json_data


    -- d) Insert the unique brands obtained from the temporary table into the table main.brand. Make
    -- sure not to insert existing brands.
    INSERT INTO main.brand (BrandName)
    SELECT DISTINCT brand 
    FROM #tempTable 
    WHERE brand NOT IN (SELECT BrandName FROM main.brand)

    -- e) Insert the unique categories obtained from the temporary table into the table main.category.
    -- Make sure not to insert existing categories.
    INSERT INTO main.category (CategoryName)
    SELECT DISTINCT category 
    FROM #tempTable 
    WHERE category NOT IN (SELECT CategoryName FROM main.category)

    -- f) Insert the products obtained from the temporary table into the table main.product. Make sure
    -- not to insert existing products (you can check this using the productid).
    INSERT INTO main.product (ProductId, Title, brand_id, category_id)
    SELECT id, title, b.BrandId, c.CategoryId
    FROM #tempTable t
    JOIN main.brand b ON t.brand = b.BrandName
    JOIN main.category c ON t.category = c.CategoryName
    WHERE t.id NOT IN (SELECT id FROM main.product)
    
    -- drop temporary table
    DROP TABLE #tempTable
END
GO
