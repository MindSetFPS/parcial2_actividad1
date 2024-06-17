CREATE DATABASE Banco;

USE Banco;

CREATE TABLE Cuentas (
    CuentaID INT PRIMARY KEY IDENTITY(1, 1),
    Titular NVARCHAR(100),
    Saldo DECIMAL(18, 2)
);

CREATE TABLE Transacciones (
    TransaccionID INT PRIMARY KEY IDENTITY(1, 1),
    CuentaOrigenID INT,
    CuentaDestinoID INT,
    Monto DECIMAL(18, 2),
    FechaTransaccion DATETIME,
    FOREIGN KEY (CuentaOrigenID) REFERENCES Cuentas(CuentaID),
    FOREIGN KEY (CuentaDestinoID) REFERENCES Cuentas(CuentaID)
);

INSERT INTO
    Cuentas (Titular, Saldo)
VALUES
    ('Juan Pérez', 1000.00);

INSERT INTO
    Cuentas (Titular, Saldo)
VALUES
    ('Ana López', 500.00);

--Creación de procedimiento almacenado para transferencia de fondos.
CREATE PROCEDURE 
TransferirFondos @CuentaOrigenID INT,
@CuentaDestinoID INT,
@Monto DECIMAL(18, 2)

AS BEGIN BEGIN TRANSACTION;

BEGIN TRY -- Verificar que la cuenta origen tiene suficiente saldo
DECLARE @SaldoOrigen DECIMAL(18, 2);

SELECT
    @SaldoOrigen = Saldo
FROM
    Cuentas
WHERE
    CuentaID = @CuentaOrigenID;

IF @SaldoOrigen < @Monto BEGIN THROW 50000,
'Saldo insuficiente en la cuenta de origen.',
1;

END -- Debitar el monto de la cuenta de origen
UPDATE
    Cuentas
SET
    Saldo = Saldo - @Monto
WHERE
    CuentaID = @CuentaOrigenID;

-- Acreditar el monto a la cuenta de destino
UPDATE
    Cuentas
SET
    Saldo = Saldo + @Monto
WHERE
    CuentaID = @CuentaDestinoID;

-- Registrar la transacción
INSERT INTO
    Transacciones (
        CuentaOrigenID,
        CuentaDestinoID,
        Monto,
        FechaTransaccion
    )
VALUES
    (
        @CuentaOrigenID,
        @CuentaDestinoID,
        @Monto,
        GETDATE()
    );

-- Confirmar la transacción
COMMIT TRANSACTION;

END TRY BEGIN CATCH -- En caso de error, deshacer la transacción
ROLLBACK TRANSACTION;

-- Obtener el mensaje de error
DECLARE @ErrorMessage NVARCHAR(4000);

DECLARE @ErrorSeverity INT;

DECLARE @ErrorState INT;

SELECT
    @ErrorMessage = ERROR_MESSAGE(),
    @ErrorSeverity = ERROR_SEVERITY(),
    @ErrorState = ERROR_STATE();

-- Lanzar el error
RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH
END;