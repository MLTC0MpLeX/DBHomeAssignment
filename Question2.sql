USE a3products;
GO


CREATE PROCEDURE loading.replaceQuotes
    @id INT
AS
BEGIN
    UPDATE loading.json_data
    SET loading.json_data.JSONdata = REPLACE(loading.json_data.JSONdata, '''', '"')
    WHERE id = @id;
END;
GO
