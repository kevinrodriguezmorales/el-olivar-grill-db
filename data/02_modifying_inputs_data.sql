USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 2 - OPCIONES DE MODIFICADORES + INSUMOS BASE
   Ejecutar despues del BLOQUE 1
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   VALIDACIONES MINIMAS
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Modificador WHERE nombre = 'Tipo de papa')
BEGIN
    RAISERROR('Falta ejecutar el BLOQUE 1: no existe el modificador Tipo de papa.', 16, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.UnidadMedida WHERE abreviatura = 'UND')
BEGIN
    RAISERROR('Falta ejecutar el BLOQUE 1: no existen unidades de medida.', 16, 1);
END;


/* =========================================================
   1. OPCIONES DE MODIFICADORES
   ========================================================= */

DECLARE @Opciones TABLE (
    modificador VARCHAR(50),
    valor VARCHAR(100),
    precio_extra DECIMAL(10,2),
    orden INT,
    stock_dependiente BIT
);

INSERT INTO @Opciones
    (modificador, valor, precio_extra, orden, stock_dependiente)
VALUES
/* Tipo de papa */
('Tipo de papa', 'Papas fritas', 0.00, 1, 1),
('Tipo de papa', 'Papas sancochadas', 0.00, 2, 1),
('Tipo de papa', 'Sin papas', 0.00, 3, 0),

/* Tipo de ensalada */
('Tipo de ensalada', 'Ensalada fresca', 0.00, 1, 1),
('Tipo de ensalada', 'Ensalada cocida', 0.00, 2, 1),
('Tipo de ensalada', 'Sin ensalada', 0.00, 3, 0),

/* Cremas */
('Cremas', 'Mayonesa', 0.00, 1, 1),
('Cremas', 'Ketchup', 0.00, 2, 1),
('Cremas', 'Mostaza', 0.00, 3, 1),
('Cremas', 'Aji de la casa', 0.00, 4, 1),
('Cremas', 'Rocoto', 0.00, 5, 1),
('Cremas', 'Huacatay', 0.00, 6, 1),
('Cremas', 'Todas las cremas', 0.00, 7, 1),
('Cremas', 'Sin cremas', 0.00, 8, 0),

/* Termino de carne */
('Termino de carne', 'Jugoso', 0.00, 1, 0),
('Termino de carne', 'Tres cuartos', 0.00, 2, 0),
('Termino de carne', 'Bien cocido', 0.00, 3, 0),

/* Salsa de pasta */
('Salsa de pasta', 'Al pesto', 0.00, 1, 1),
('Salsa de pasta', 'A la huancaina', 0.00, 2, 1),
('Salsa de pasta', 'A lo Alfredo', 0.00, 3, 1),

/* Complemento de pasta */
('Complemento de pasta', 'Con 1/4 de pollo', 0.00, 1, 1),
('Complemento de pasta', 'Con pechuga', 0.00, 2, 1),
('Complemento de pasta', 'Con pierna', 0.00, 3, 1),
('Complemento de pasta', 'Con chuleta', 0.00, 4, 1),
('Complemento de pasta', 'Con churrasco', 0.00, 5, 1),
('Complemento de pasta', 'Con lomo', 0.00, 6, 1),

/* Sabor de bebida */
('Sabor de bebida', 'Coca Cola', 0.00, 1, 1),
('Sabor de bebida', 'Inca Kola', 0.00, 2, 1),
('Sabor de bebida', 'Sprite', 0.00, 3, 1),
('Sabor de bebida', 'Fanta', 0.00, 4, 1),
('Sabor de bebida', 'Chicha morada', 0.00, 5, 1),
('Sabor de bebida', 'Maracuya', 0.00, 6, 1),
('Sabor de bebida', 'Limonada', 0.00, 7, 1),
('Sabor de bebida', 'Agua mineral', 0.00, 8, 1),

/* Temperatura de bebida */
('Temperatura de bebida', 'Helada', 0.00, 1, 0),
('Temperatura de bebida', 'Sin hielo', 0.00, 2, 0),
('Temperatura de bebida', 'Al tiempo', 0.00, 3, 0),
('Temperatura de bebida', 'Caliente', 0.00, 4, 0),

/* Presentacion de bebida */
('Presentacion de bebida', 'Vaso', 0.00, 1, 1),
('Presentacion de bebida', 'Jarra', 0.00, 2, 1),
('Presentacion de bebida', 'Botella personal', 0.00, 3, 1),
('Presentacion de bebida', 'Botella 500 ml', 0.00, 4, 1),
('Presentacion de bebida', 'Botella 1 litro', 0.00, 5, 1),
('Presentacion de bebida', 'Botella 1.5 litros', 0.00, 6, 1);

INSERT INTO dbo.OpcionModificador
    (id_modificador, valor, precio_extra, orden, stock_dependiente)
SELECT
    m.id_modificador,
    o.valor,
    o.precio_extra,
    o.orden,
    o.stock_dependiente
FROM @Opciones o
INNER JOIN dbo.Modificador m
    ON m.nombre = o.modificador
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.OpcionModificador om
    WHERE om.id_modificador = m.id_modificador
      AND om.valor = o.valor
);


/* =========================================================
   2. INSUMOS BASE
   ========================================================= */

DECLARE @Insumos TABLE (
    nombre VARCHAR(100),
    abreviatura VARCHAR(5),
    stock_actual DECIMAL(12,3),
    stock_minimo DECIMAL(12,3),
    costo_unitario DECIMAL(10,4)
);

INSERT INTO @Insumos
    (nombre, abreviatura, stock_actual, stock_minimo, costo_unitario)
VALUES
/* Pollos y carnes */
('Pollo entero', 'UND', 80.000, 15.000, 18.0000),
('Pierna de pollo', 'UND', 80.000, 20.000, 5.5000),
('Pechuga de pollo', 'UND', 80.000, 20.000, 6.5000),
('Lomo fino', 'KG', 20.000, 5.000, 38.0000),
('Churrasco', 'KG', 25.000, 5.000, 30.0000),
('Chuleta de cerdo', 'KG', 25.000, 5.000, 22.0000),
('Costilla de cerdo', 'KG', 20.000, 5.000, 24.0000),
('Anticucho', 'KG', 15.000, 4.000, 28.0000),
('Chorizo parrillero', 'UND', 60.000, 15.000, 3.5000),

/* Acompanamientos */
('Papa blanca', 'KG', 100.000, 25.000, 2.8000),
('Papa amarilla', 'KG', 40.000, 10.000, 4.5000),
('Arroz', 'KG', 80.000, 20.000, 4.2000),
('Fideo fettuccini', 'KG', 35.000, 8.000, 8.5000),
('Choclo', 'UND', 50.000, 10.000, 2.5000),
('Camote', 'KG', 40.000, 8.000, 3.2000),

/* Verduras */
('Lechuga', 'UND', 30.000, 8.000, 2.5000),
('Tomate', 'KG', 25.000, 5.000, 3.5000),
('Pepino', 'KG', 15.000, 4.000, 3.0000),
('Zanahoria', 'KG', 20.000, 5.000, 2.8000),
('Beterraga', 'KG', 15.000, 4.000, 3.2000),
('Cebolla roja', 'KG', 25.000, 5.000, 3.0000),
('Cebolla china', 'KG', 10.000, 3.000, 5.0000),
('Aji amarillo', 'KG', 10.000, 2.000, 7.5000),
('Ajo molido', 'KG', 8.000, 2.000, 9.0000),

/* Salsas y cremas */
('Mayonesa', 'KG', 20.000, 5.000, 8.0000),
('Ketchup', 'KG', 15.000, 4.000, 7.0000),
('Mostaza', 'KG', 10.000, 3.000, 6.5000),
('Crema de aji', 'KG', 15.000, 4.000, 9.0000),
('Salsa huacatay', 'KG', 10.000, 3.000, 10.0000),
('Salsa huancaina', 'KG', 12.000, 3.000, 11.0000),
('Salsa pesto', 'KG', 12.000, 3.000, 13.0000),
('Salsa alfredo', 'KG', 12.000, 3.000, 12.0000),

/* Condimentos */
('Sal', 'KG', 20.000, 5.000, 1.5000),
('Pimienta', 'KG', 5.000, 1.000, 18.0000),
('Comino', 'KG', 5.000, 1.000, 16.0000),
('Sillao', 'LT', 12.000, 3.000, 7.0000),
('Vinagre', 'LT', 10.000, 3.000, 4.0000),
('Aceite vegetal', 'LT', 60.000, 15.000, 7.5000),

/* Bebidas */
('Gaseosa personal', 'UND', 120.000, 30.000, 2.0000),
('Gaseosa 1 litro', 'UND', 50.000, 15.000, 5.0000),
('Gaseosa 1.5 litros', 'UND', 50.000, 15.000, 6.5000),
('Agua mineral personal', 'UND', 80.000, 20.000, 1.8000),
('Chicha morada preparada', 'LT', 30.000, 8.000, 3.5000),
('Maracuya preparada', 'LT', 30.000, 8.000, 3.8000),
('Limonada preparada', 'LT', 30.000, 8.000, 3.2000),

/* Postres */
('Crema volteada', 'POR', 30.000, 8.000, 3.5000),
('Torta de chocolate', 'POR', 25.000, 6.000, 4.0000),
('Mazamorra morada', 'POR', 25.000, 6.000, 2.5000),
('Arroz con leche', 'POR', 25.000, 6.000, 2.5000),

/* Empaques */
('Bolsa delivery', 'UND', 300.000, 80.000, 0.2500),
('Envase descartable', 'UND', 300.000, 80.000, 0.6000),
('Cubiertos descartables', 'UND', 300.000, 80.000, 0.2000),
('Vaso descartable', 'UND', 300.000, 80.000, 0.1800);

INSERT INTO dbo.Insumo
    (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
SELECT
    i.nombre,
    um.id_unidad_medida,
    i.stock_actual,
    i.stock_minimo,
    i.costo_unitario,
    1
FROM @Insumos i
INNER JOIN dbo.UnidadMedida um
    ON um.abreviatura = i.abreviatura
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Insumo ins
    WHERE ins.nombre = i.nombre
);

COMMIT TRANSACTION;

PRINT 'BLOQUE 2 cargado correctamente.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 2';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
