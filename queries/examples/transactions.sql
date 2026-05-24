-- Transactions

-- Basic structure

  -- BEGIN TRANSACTION
    -- Instruction 1 -> INSERT
    -- Instruction 2 -> UPDATE
    -- Instruction 3 -> DELETE
  -- COMMIT TRANSACTION
  -- GO
  -- BEGIN TRANSACTION
    -- Instruction 1
    -- Instruction 2
    -- Instruction 3
  -- ROLLBACK TRANSACTION

CREATE DATABASE TEST_BD
GO
USE TEST_BD

CREATE TABLE Accounts
(
	accountID int Primary key,
	holder nvarchar(50),
	balance decimal(10,2)
)

INSERT INTO Accounts	(accountID, holder, balance)
				values	(1, 'Ricardo Nuñez', 1500.93),
						(2, 'Ricardo Nuñez', 500.30),
						(3, 'Ricardo Nuñez', 100.03),
						(4, 'Ricardo Nuñez', 1530.13),
						(5, 'Ricardo Nuñez', 11500.00)

SELECT * FROM Accounts

-- Crear transacción

BEGIN TRY
	BEGIN TRANSACTION;
		UPDATE Accounts
			set balance=balance-200
		WHERE accountID = 1;

		-- validacion de cuenta origen
		IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('La cuenta 1 no existe', 16, 1);
        END;

		UPDATE Accounts
			set balance=balance+200
		WHERE accountID = 17;

		-- validación de cuenta destino
		IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('La cuenta 17 no existe', 16, 1);
        END;

	COMMIT TRANSACTION;
	PRINT 'Transacción finalizada correctamente'
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Ocurrió un error en la transacción, se deshicieron los cambios'

	-- Opcional: mostrar mensaje real del error
    PRINT ERROR_MESSAGE();
END CATCH
