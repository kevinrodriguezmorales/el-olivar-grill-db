USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 5B - CARGA FORZADA PRODUCTO MODIFICADOR
   Ejecutar solo si ProductoModificador quedo vacia
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* Productos de comida con papa */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    1,
    1,
    1,
    1,
    0,
    'Elige una opcion de papa.'
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Tipo de papa'
WHERE c.nombre IN (
    'Olivar Brasa',
    'Ofertas en Pollo a la Brasa',
    'Fusiones',
    'Parrillas Personales',
    'Parrillas Familiares',
    'Menu El Olivar'
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);


/* Productos de comida con ensalada */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    1,
    2,
    1,
    1,
    0,
    'Elige una opcion de ensalada.'
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Tipo de ensalada'
WHERE c.nombre IN (
    'Olivar Brasa',
    'Ofertas en Pollo a la Brasa',
    'Fusiones',
    'Parrillas Personales',
    'Parrillas Familiares',
    'Menu El Olivar'
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);


/* Cremas para comida */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    0,
    3,
    0,
    4,
    0,
    'Puedes elegir hasta 4 cremas.'
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Cremas'
WHERE c.nombre IN (
    'Entradas',
    'Olivar Brasa',
    'Ofertas en Pollo a la Brasa',
    'Fusiones',
    'Parrillas Personales',
    'Piqueos',
    'Parrillas Familiares',
    'Wok Criollo',
    'Chaufa',
    'Complementos',
    'Menu El Olivar'
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);


/* Termino de carne */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    0,
    4,
    0,
    1,
    0,
    'Indica el termino de coccion si aplica.'
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Termino de carne'
WHERE c.nombre IN (
    'Fusiones',
    'Parrillas Personales',
    'Parrillas Familiares',
    'Wok Criollo'
)
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);


/* Pastas con complemento */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    1,
    1,
    1,
    1,
    0,
    'Elige un complemento para la pasta.'
FROM dbo.Producto p
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Complemento de pasta'
WHERE p.codigo IN ('PAS001', 'PAS002', 'PAS003')
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);


/* Bebidas con sabor */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    0,
    1,
    0,
    1,
    0,
    'Elige sabor o marca si aplica.'
FROM dbo.Producto p
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Sabor de bebida'
WHERE p.codigo LIKE 'BEB%'
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);


/* Bebidas con temperatura */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    0,
    2,
    0,
    1,
    0,
    'Indica temperatura si aplica.'
FROM dbo.Producto p
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Temperatura de bebida'
WHERE p.codigo LIKE 'BEB%'
   OR p.codigo LIKE 'INF%'
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);


/* Bebidas con presentacion */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    0,
    3,
    0,
    1,
    0,
    'Indica presentacion si aplica.'
FROM dbo.Producto p
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Presentacion de bebida'
WHERE p.codigo LIKE 'BEB%'
   OR p.codigo LIKE 'INF%'
AND NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);

COMMIT TRANSACTION;

PRINT 'BLOQUE 5B cargado correctamente.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 5B';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO