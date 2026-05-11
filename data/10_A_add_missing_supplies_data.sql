USE BDOlivarGrill;
GO

/* =========================================================
   PARCHE 10A - INSERTAR INSUMOS FALTANTES FRECUENTES
   Ejecutar antes de repetir el BLOQUE 10
   ========================================================= */

BEGIN TRANSACTION;

BEGIN TRY

DECLARE @id_und INT;
DECLARE @id_kg INT;
DECLARE @id_lt INT;
DECLARE @id_por INT;

SELECT @id_und = id_unidad_medida FROM dbo.UnidadMedida WHERE abreviatura = 'UND';
SELECT @id_kg  = id_unidad_medida FROM dbo.UnidadMedida WHERE abreviatura = 'KG';
SELECT @id_lt  = id_unidad_medida FROM dbo.UnidadMedida WHERE abreviatura = 'LT';
SELECT @id_por = id_unidad_medida FROM dbo.UnidadMedida WHERE abreviatura = 'POR';

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Queso pasteurizado')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Queso pasteurizado', @id_kg, 0.000, 3.000, 16.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Mollejitas de pollo')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Mollejitas de pollo', @id_kg, 0.000, 5.000, 12.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Bife')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Bife', @id_kg, 0.000, 3.000, 42.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Alitas de pollo')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Alitas de pollo', @id_kg, 0.000, 5.000, 14.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Queso Edam')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Queso Edam', @id_kg, 0.000, 2.000, 28.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Jamon ingles')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Jamon ingles', @id_kg, 0.000, 2.000, 20.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Tocino ahumado')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Tocino ahumado', @id_kg, 0.000, 2.000, 26.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Leche evaporada')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Leche evaporada', @id_lt, 0.000, 5.000, 7.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Leche condensada')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Leche condensada', @id_lt, 0.000, 5.000, 10.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Base tres leches')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Base tres leches', @id_por, 0.000, 10.000, 4.0000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Base cheesecake')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Base cheesecake', @id_por, 0.000, 10.000, 4.5000, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Insumo WHERE nombre = 'Base selva negra')
BEGIN
    INSERT INTO dbo.Insumo
        (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
    VALUES
        ('Base selva negra', @id_por, 0.000, 10.000, 4.5000, 1);
END;

COMMIT TRANSACTION;

PRINT 'PARCHE 10A ejecutado correctamente.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN PARCHE 10A';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
