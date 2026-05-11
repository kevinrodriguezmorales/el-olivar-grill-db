USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 7 - COMPONENTES DE COMBOS
   Ejecutar despues del BLOQUE 6

   Este bloque carga la tabla ProductoComponente.
   No toca pedidos, pagos ni comprobantes.
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.ProductoComponente', N'U') IS NULL
BEGIN
    THROW 57000, 'No existe dbo.ProductoComponente.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Producto WHERE codigo = 'OFE001')
BEGIN
    THROW 57001, 'Faltan productos de ofertas. Ejecuta primero los bloques 3A, 3B y 3C.', 1;
END;


/* =========================================================
   TABLA TEMPORAL DE COMPONENTES
   ========================================================= */
DECLARE @Componentes TABLE (
    producto_padre_codigo VARCHAR(10) NOT NULL,
    producto_hijo_codigo VARCHAR(10) NOT NULL,
    cantidad DECIMAL(5,2) NOT NULL,
    orden INT NOT NULL
);


/* =========================================================
   OFERTAS EN POLLO A LA BRASA
   ========================================================= */
INSERT INTO @Componentes
    (producto_padre_codigo, producto_hijo_codigo, cantidad, orden)
VALUES
/* POLLO A LA BRASA PARA DOS */
('OFE001', 'BRA003', 1.00, 1),  -- 1/2 pollo
('OFE001', 'COM001', 1.00, 2),  -- papas fritas
('OFE001', 'ENS001', 1.00, 3),  -- ensalada fresca
('OFE001', 'BEB008', 0.50, 4),  -- media jarra de limonada referencial

/* OFERTON */
('OFE002', 'BRA004', 1.00, 1),  -- pollo entero
('OFE002', 'COM001', 1.00, 2),  -- papas fritas
('OFE002', 'ENS001', 1.00, 3),  -- ensalada fresca
('OFE002', 'BEB007', 1.00, 4),  -- gaseosa 1.5 lt

/* SUPER OFERTON EL OLIVAR */
('OFE003', 'BRA004', 1.00, 1),  -- pollo entero
('OFE003', 'BRA001', 1.00, 2),  -- 1/4 de pollo
('OFE003', 'COM001', 1.00, 3),  -- papas fritas
('OFE003', 'ENS001', 1.00, 4),  -- ensalada fresca
('OFE003', 'BEB007', 1.00, 5),  -- gaseosa 1.5 lt

/* MEGA OFERTON */
('OFE004', 'BRA004', 1.00, 1),  -- pollo entero
('OFE004', 'BRA001', 1.00, 2),  -- 1/4 de pollo
('OFE004', 'CHA001', 2.00, 3),  -- 2 porciones de chaufa referenciales
('OFE004', 'COM001', 1.00, 4),  -- papas fritas
('OFE004', 'ENS001', 1.00, 5),  -- ensalada fresca
('OFE004', 'BEB007', 1.00, 6);  -- gaseosa 1.5 lt


/* =========================================================
   PIQUEOS
   ========================================================= */
INSERT INTO @Componentes
    (producto_padre_codigo, producto_hijo_codigo, cantidad, orden)
VALUES
/* PIQUEO EL OLIVAR */
('PIQ001', 'ENT005', 4.00, 1),  -- anticuchos referenciales
('PIQ001', 'PAR002', 1.00, 2),  -- brochetas de pollo
('PIQ001', 'PAR010', 1.00, 3),  -- mollejitas grill
('PIQ001', 'PIQ002', 1.00, 4);  -- chicharron de pollo


/* =========================================================
   PARRILLAS FAMILIARES
   ========================================================= */
INSERT INTO @Componentes
    (producto_padre_codigo, producto_hijo_codigo, cantidad, orden)
VALUES
/* PARRILLA FAMILIAR */
('FAM001', 'BRA004', 1.00, 1),  -- pollo a la brasa
('FAM001', 'PAR017', 1.00, 2),  -- bife ejecutivo referencial
('FAM001', 'PAR011', 1.00, 3),  -- chuleta premium
('FAM001', 'PAR001', 1.00, 4),  -- filete de pollo / pollo olivar referencial
('FAM001', 'ENT005', 2.00, 5),  -- anticuchos
('FAM001', 'COM007', 2.00, 6),  -- chorizos
('FAM001', 'PAR010', 1.00, 7),  -- mollejitas
('FAM001', 'COM001', 1.00, 8),  -- papas fritas
('FAM001', 'ENS001', 1.00, 9),  -- ensalada fresca
('FAM001', 'BEB007', 1.00, 10), -- gaseosa 1.5 lt

/* PARRILLA PARA DOS */
('FAM002', 'BRA003', 1.00, 1),  -- 1/2 pollo referencial
('FAM002', 'PAR015', 1.00, 2),  -- churrasco
('FAM002', 'ENT005', 1.00, 3),  -- anticucho
('FAM002', 'COM007', 1.00, 4),  -- chorizo
('FAM002', 'PAR001', 1.00, 5),  -- filete de pierna / pollo referencial
('FAM002', 'PAR010', 1.00, 6),  -- mollejitas
('FAM002', 'COM001', 1.00, 7),  -- papas fritas
('FAM002', 'ENS001', 1.00, 8),  -- ensalada fresca
('FAM002', 'BEB014', 1.00, 9); -- gaseosa mediana referencial


/* =========================================================
   FUSIONES PRINCIPALES
   ========================================================= */
INSERT INTO @Componentes
    (producto_padre_codigo, producto_hijo_codigo, cantidad, orden)
VALUES
/* POLLO RICKY + ANTICUCHO */
('FUS001', 'PAR001', 1.00, 1),
('FUS001', 'ENT005', 1.00, 2),
('FUS001', 'COM001', 1.00, 3),
('FUS001', 'ENS001', 1.00, 4),

/* POLLO RICKY + MOLLEJITAS */
('FUS002', 'PAR001', 1.00, 1),
('FUS002', 'PAR010', 0.50, 2),
('FUS002', 'COM001', 1.00, 3),
('FUS002', 'ENS001', 1.00, 4),

/* MIXTO EL OLIVAR */
('FUS005', 'PAR001', 1.00, 1),
('FUS005', 'ENT005', 1.00, 2),
('FUS005', 'PAR010', 0.50, 3),
('FUS005', 'COM001', 1.00, 4),
('FUS005', 'ENS001', 1.00, 5),

/* 1/4 POLLO + ANTICUCHO */
('FUS006', 'BRA001', 1.00, 1),
('FUS006', 'ENT005', 1.00, 2),
('FUS006', 'COM001', 1.00, 3),
('FUS006', 'ENS001', 1.00, 4);


/* =========================================================
   VALIDAR PRODUCTOS PADRE FALTANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Componentes c
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = c.producto_padre_codigo
    )
)
BEGIN
    SELECT DISTINCT c.producto_padre_codigo AS producto_padre_faltante
    FROM @Componentes c
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = c.producto_padre_codigo
    );

    THROW 57002, 'Hay productos padre faltantes. Revisa el resultado anterior.', 1;
END;


/* =========================================================
   VALIDAR PRODUCTOS HIJO FALTANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Componentes c
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = c.producto_hijo_codigo
    )
)
BEGIN
    SELECT DISTINCT c.producto_hijo_codigo AS producto_hijo_faltante
    FROM @Componentes c
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = c.producto_hijo_codigo
    );

    THROW 57003, 'Hay productos hijo faltantes. Revisa el resultado anterior.', 1;
END;


/* =========================================================
   ACTUALIZAR COMPONENTES EXISTENTES
   ========================================================= */
UPDATE pc
SET
    pc.cantidad = c.cantidad,
    pc.orden = c.orden
FROM dbo.ProductoComponente pc
INNER JOIN dbo.Producto padre
    ON padre.id_producto = pc.id_producto_padre
INNER JOIN dbo.Producto hijo
    ON hijo.id_producto = pc.id_producto_hijo
INNER JOIN @Componentes c
    ON c.producto_padre_codigo = padre.codigo
   AND c.producto_hijo_codigo = hijo.codigo;


/* =========================================================
   INSERTAR COMPONENTES NUEVOS
   ========================================================= */
INSERT INTO dbo.ProductoComponente
    (id_producto_padre, id_producto_hijo, cantidad, orden)
SELECT
    padre.id_producto,
    hijo.id_producto,
    c.cantidad,
    c.orden
FROM @Componentes c
INNER JOIN dbo.Producto padre
    ON padre.codigo = c.producto_padre_codigo
INNER JOIN dbo.Producto hijo
    ON hijo.codigo = c.producto_hijo_codigo
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoComponente pc
    WHERE pc.id_producto_padre = padre.id_producto
      AND pc.id_producto_hijo = hijo.id_producto
);


COMMIT TRANSACTION;

PRINT 'BLOQUE 7 cargado correctamente: componentes de combos.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 7';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO

-- Nota rápida: ProductoComponente solo guarda componentes fijos. Las alternativas como ensalada fresca o cocida, papas fritas o sancochadas o limonada/gaseosa se controlan mejor con ProductoModificador, que ya cargamos en el bloque anterior.