USE a3products;
GO

CREATE TRIGGER loading.after_insert ON loading.json_data
AFTER INSERT
AS
BEGIN
    -- a) Start a transaction.
    BEGIN TRANSACTION;

    -- b) Set the isolation level to prevent dirty reads and nonrepeatable reads.
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

    BEGIN TRY
        -- c) Get the ID of the inserted record.
        DECLARE @id INT = (SELECT id FROM inserted);

        -- d) Use the ID obtained in part C and try to replace the quotes using the previously created
        -- procedure loading.replaceQuotes. This must have error handling. If not successful throw an
        -- error message with number 60001, state 1 and an appropriate message; then rollback the transaction.
        EXEC loading.replaceQuotes @id;

        -- e) Use the ID obtained in part C and try to process the JSON data using the previously created
        -- procedure main.processJson. This must have error handling. If not successful throw an error message with
        -- number 60002, state 1 and an appropriate message; then rollback the transaction.
        EXEC main.processJson @id;

        -- f) If part D and E were successful, update the date processed field in the loading.json_data table
        -- with the current time and commit the transaction.
        UPDATE loading.json_data
        SET loading.json_data.DateProcessed = GETDATE()
        WHERE id = @id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If an error occurs within the try block, rollback the transaction and throw an error message.
        ROLLBACK TRANSACTION;

        IF ERROR_NUMBER() = 60001
        BEGIN
            THROW 60001, 'Error in executing procedure loading.replaceQuotes.', 1;
        END
        ELSE
        BEGIN
            THROW 60002, 'Error in executing procedure main.processJson.', 1;
        END
    END CATCH
END;
GO
