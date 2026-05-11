USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 10 - MOVIMIENTOS INICIALES DE INVENTARIO
   Ejecutar despues del BLOQUE 9

   Este bloque carga:
   - MovimientoInventario como ENTRADA_INICIAL
   - Sincroniza stock_actual, stock_minimo y costo_unitario
     en la tabla Insumo.

   Es idempotente:
   - No duplica movimientos iniciales si ya existen.
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   1. VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.MovimientoInventario', N'U') IS NULL
    THROW 61000, 'No existe dbo.MovimientoInventario.', 1;

IF OBJECT_ID(N'dbo.Insumo', N'U') IS NULL
    THROW 61001, 'No existe dbo.Insumo.', 1;

IF OBJECT_ID(N'dbo.Usuario', N'U') IS NULL
    THROW 61002, 'No existe dbo.Usuario.', 1;


/* =========================================================
   2. USUARIO RESPONSABLE DEL MOVIMIENTO
   ========================================================= */
DECLARE @id_usuario_admin INT;

SELECT TOP 1 @id_usuario_admin = id_usuario
FROM dbo.Usuario
WHERE cargo IN ('ADMIN', 'CAJERO')
ORDER BY 
    CASE WHEN cargo = 'ADMIN' THEN 1 ELSE 2 END,
    id_usuario;

IF @id_usuario_admin IS NULL
    THROW 61003, 'No existe usuario ADMIN o CAJERO para registrar movimientos.', 1;


/* =========================================================
   3. STOCK INICIAL REFERENCIAL
   ========================================================= */
DECLARE @StockInicial TABLE (
    insumo_nombre VARCHAR(100) NOT NULL,
    stock_inicial DECIMAL(12,3) NOT NULL,
    stock_minimo DECIMAL(12,3) NOT NULL,
    costo_unitario DECIMAL(10,4) NOT NULL
);

INSERT INTO @StockInicial
    (insumo_nombre, stock_inicial, stock_minimo, costo_unitario)
VALUES
/* Pollos y carnes */
('Pollo entero', 80.000, 15.000, 18.0000),
('Pierna de pollo', 80.000, 20.000, 5.5000),
('Pechuga de pollo', 80.000, 20.000, 6.5000),
('Lomo fino', 20.000, 5.000, 38.0000),
('Churrasco', 25.000, 5.000, 30.0000),
('Chuleta de cerdo', 25.000, 5.000, 22.0000),
('Costilla de cerdo', 20.000, 5.000, 24.0000),
('Anticucho', 15.000, 4.000, 28.0000),
('Chorizo parrillero', 60.000, 15.000, 3.5000),
('Bife', 10.000, 3.000, 42.0000),
('Alitas de pollo', 18.000, 5.000, 14.0000),
('Mollejitas de pollo', 20.000, 5.000, 12.0000),

/* Acompanamientos */
('Papa blanca', 120.000, 25.000, 2.8000),
('Papa amarilla', 50.000, 10.000, 4.5000),
('Arroz', 100.000, 20.000, 4.2000),
('Fideo fettuccini', 40.000, 8.000, 8.5000),
('Fideo tallarin chino', 18.000, 3.000, 8.0000),
('Fideo cabello de angel', 10.000, 3.000, 7.5000),
('Choclo', 60.000, 10.000, 2.5000),
('Camote', 40.000, 8.000, 3.2000),
('Yuca', 35.000, 5.000, 3.8000),
('Platano', 80.000, 10.000, 1.2000),
('Salchicha Frankfurt', 90.000, 20.000, 1.0000),
('Huevo', 180.000, 30.000, 0.8000),
('Wantan', 80.000, 20.000, 0.4000),

/* Verduras */
('Lechuga', 40.000, 8.000, 2.5000),
('Tomate', 35.000, 5.000, 3.5000),
('Pepino', 20.000, 4.000, 3.0000),
('Zanahoria', 30.000, 5.000, 2.8000),
('Beterraga', 20.000, 4.000, 3.2000),
('Cebolla roja', 35.000, 5.000, 3.0000),
('Cebolla china', 15.000, 3.000, 5.0000),
('Aji amarillo', 12.000, 2.000, 7.5000),
('Ajo molido', 10.000, 2.000, 9.0000),
('Vainita', 12.000, 3.000, 4.5000),
('Espinaca', 15.000, 5.000, 2.5000),
('Zapallo', 20.000, 5.000, 3.0000),
('Palta', 50.000, 10.000, 2.5000),

/* Lacteos, fiambres y complementos */
('Queso fresco', 8.000, 3.000, 16.0000),
('Queso pasteurizado', 8.000, 3.000, 16.0000),
('Queso Edam', 6.000, 2.000, 28.0000),
('Jamon ingles', 6.000, 2.000, 20.0000),
('Tocino ahumado', 6.000, 2.000, 26.0000),
('Leche evaporada', 12.000, 5.000, 7.0000),
('Leche condensada', 10.000, 5.000, 10.0000),

/* Salsas y cremas */
('Mayonesa', 25.000, 5.000, 8.0000),
('Ketchup', 18.000, 4.000, 7.0000),
('Mostaza', 12.000, 3.000, 6.5000),
('Crema de aji', 18.000, 4.000, 9.0000),
('Salsa huacatay', 12.000, 3.000, 10.0000),
('Salsa huancaina', 16.000, 3.000, 11.0000),
('Salsa pesto', 16.000, 3.000, 13.0000),
('Salsa alfredo', 16.000, 3.000, 12.0000),

/* Condimentos */
('Sal', 25.000, 5.000, 1.5000),
('Pimienta', 6.000, 1.000, 18.0000),
('Comino', 6.000, 1.000, 16.0000),
('Sillao', 15.000, 3.000, 7.0000),
('Vinagre', 12.000, 3.000, 4.0000),
('Aceite vegetal', 70.000, 15.000, 7.5000),
('Limon', 30.000, 5.000, 5.0000),
('Azucar', 40.000, 10.000, 4.0000),

/* Bebidas */
('Gaseosa personal', 120.000, 30.000, 2.0000),
('Gaseosa 1 litro', 50.000, 15.000, 5.0000),
('Gaseosa 1.5 litros', 50.000, 15.000, 6.5000),
('Agua mineral personal', 80.000, 20.000, 1.8000),
('Chicha morada preparada', 40.000, 8.000, 3.5000),
('Maracuya preparada', 35.000, 8.000, 3.8000),
('Limonada preparada', 40.000, 8.000, 3.2000),
('Te filtrante', 80.000, 20.000, 0.3500),
('Manzanilla filtrante', 80.000, 20.000, 0.3500),
('Anis filtrante', 80.000, 20.000, 0.3500),
('Hierba luisa filtrante', 80.000, 20.000, 0.3500),

/* Postres */
('Crema volteada', 30.000, 8.000, 3.5000),
('Torta de chocolate', 25.000, 6.000, 4.0000),
('Mazamorra morada', 25.000, 6.000, 2.5000),
('Arroz con leche', 25.000, 6.000, 2.5000),
('Base tres leches', 25.000, 10.000, 4.0000),
('Base cheesecake', 25.000, 10.000, 4.5000),
('Base selva negra', 25.000, 10.000, 4.5000),

/* Otros insumos especiales */
('Langostino', 8.000, 3.000, 38.0000),
('Cecina', 8.000, 3.000, 30.0000),

/* Empaques */
('Bolsa delivery', 300.000, 80.000, 0.2500),
('Envase descartable', 300.000, 80.000, 0.6000),
('Cubiertos descartables', 300.000, 80.000, 0.2000),
('Vaso descartable', 300.000, 80.000, 0.1800);


/* =========================================================
   4. VALIDAR INSUMOS FALTANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @StockInicial si
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Insumo i
        WHERE i.nombre = si.insumo_nombre
    )
)
BEGIN
    SELECT si.insumo_nombre AS insumo_faltante
    FROM @StockInicial si
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Insumo i
        WHERE i.nombre = si.insumo_nombre
    )
    ORDER BY si.insumo_nombre;

    THROW 61004, 'Hay insumos faltantes. Revisa el resultado anterior.', 1;
END;


/* =========================================================
   5. INSERTAR MOVIMIENTOS INICIALES
   Solo se inserta una vez por insumo.
   ========================================================= */
INSERT INTO dbo.MovimientoInventario
    (id_insumo, fecha_hora_movimiento, tipo_movimiento,
     cantidad, costo_unitario, stock_anterior, stock_resultante,
     motivo, id_usuario, observaciones)
SELECT
    i.id_insumo,
    SYSDATETIME(),
    'ENTRADA_INICIAL',
    si.stock_inicial,
    CAST(si.costo_unitario AS DECIMAL(10,2)),
    0.000,
    si.stock_inicial,
    'Carga inicial de inventario - Bloque 10',
    @id_usuario_admin,
    'Movimiento inicial generado para pruebas del sistema.'
FROM @StockInicial si
INNER JOIN dbo.Insumo i
    ON i.nombre = si.insumo_nombre
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.MovimientoInventario mi
    WHERE mi.id_insumo = i.id_insumo
      AND mi.motivo = 'Carga inicial de inventario - Bloque 10'
);


/* =========================================================
   6. SINCRONIZAR STOCK ACTUAL DEL INSUMO
   ========================================================= */
UPDATE i
SET
    i.stock_actual = si.stock_inicial,
    i.stock_minimo = si.stock_minimo,
    i.costo_unitario = si.costo_unitario,
    i.activo = 1
FROM dbo.Insumo i
INNER JOIN @StockInicial si
    ON si.insumo_nombre = i.nombre;


COMMIT TRANSACTION;

PRINT 'BLOQUE 10 cargado correctamente: movimientos iniciales de inventario.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 10';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
