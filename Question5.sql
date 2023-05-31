USE a3products;
GO

CREATE FUNCTION main.getProductsRating(@rating DECIMAL(3, 2))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @jsonResult NVARCHAR(MAX);

    SELECT @jsonResult = (SELECT p.Title AS title, p.price, p.rating, p.stock, b.BrandName AS brand
                          FROM main.product p
                          JOIN main.brand b ON p.brand_id = b.BrandName
                          WHERE p.rating >= @rating
                          FOR JSON PATH);

    RETURN @jsonResult;
END;
GO
