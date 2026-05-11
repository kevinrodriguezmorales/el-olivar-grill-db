USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 5 - REGLAS PRODUCTO MODIFICADOR
   Ejecutar despues del BLOQUE 4

   Este bloque NO toca pedidos, pagos ni comprobantes.
   Solo relaciona productos con modificadores.
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.ProductoModificador', N'U') IS NULL
BEGIN
    THROW 55000, 'No existe dbo.ProductoModificador.', 1;
END;

IF COL_LENGTH('dbo.ProductoModificador', 'min_selecciones') IS NULL
BEGIN
    THROW 55001, 'Falta la columna min_selecciones en ProductoModificador. Ejecuta el script de mejora.', 1;
END;

IF COL_LENGTH('dbo.ProductoModificador', 'max_selecciones') IS NULL
BEGIN
    THROW 55002, 'Falta la columna max_selecciones en ProductoModificador. Ejecuta el script de mejora.', 1;
END;

IF COL_LENGTH('dbo.ProductoModificador', 'permite_repetir_opcion') IS NULL
BEGIN
    THROW 55003, 'Falta la columna permite_repetir_opcion en ProductoModificador. Ejecuta el script de mejora.', 1;
END;

IF COL_LENGTH('dbo.ProductoModificador', 'texto_guia') IS NULL
BEGIN
    THROW 55004, 'Falta la columna texto_guia en ProductoModificador. Ejecuta el script de mejora.', 1;
END;


/* =========================================================
   TABLA TEMPORAL DE REGLAS
   ========================================================= */
DECLARE @Reglas TABLE (
    producto_codigo VARCHAR(10) NOT NULL,
    modificador_nombre VARCHAR(50) NOT NULL,
    es_obligatorio BIT NOT NULL,
    min_selecciones INT NOT NULL,
    max_selecciones INT NOT NULL,
    permite_repetir_opcion BIT NOT NULL,
    orden_aplicacion INT NOT NULL,
    texto_guia VARCHAR(200) NULL
);


/* =========================================================
   1. PRODUCTOS CON PAPA + ENSALADA + CREMAS
   Brasa, ofertas, fusiones, parrillas, familiares y menu.
   ========================================================= */
DECLARE @ProductosConAcompanamiento TABLE (
    codigo VARCHAR(10) PRIMARY KEY
);

INSERT INTO @ProductosConAcompanamiento (codigo)
SELECT p.codigo
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
WHERE c.nombre IN (
    'Olivar Brasa',
    'Ofertas en Pollo a la Brasa',
    'Fusiones',
    'Parrillas Personales',
    'Parrillas Familiares',
    'Menu El Olivar'
);

INSERT INTO @ProductosConAcompanamiento (codigo)
SELECT p.codigo
FROM dbo.Producto p
WHERE p.codigo IN ('PIQ002', 'CHA004')
  AND NOT EXISTS (
      SELECT 1
      FROM @ProductosConAcompanamiento x
      WHERE x.codigo = p.codigo
  );


INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    codigo,
    'Tipo de papa',
    1,
    1,
    1,
    0,
    1,
    'Elige una opcion de papa.'
FROM @ProductosConAcompanamiento;

INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    codigo,
    'Tipo de ensalada',
    1,
    1,
    1,
    0,
    2,
    'Elige una opcion de ensalada.'
FROM @ProductosConAcompanamiento;

INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    codigo,
    'Cremas',
    0,
    0,
    4,
    0,
    3,
    'Puedes elegir hasta 4 cremas.'
FROM @ProductosConAcompanamiento;


/* =========================================================
   2. PRODUCTOS CON CREMAS SOLAMENTE
   Entradas, chaufas, wok, complementos y piqueos.
   ========================================================= */
INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    p.codigo,
    'Cremas',
    0,
    0,
    4,
    0,
    1,
    'Puedes elegir hasta 4 cremas.'
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
WHERE c.nombre IN (
    'Entradas',
    'Piqueos',
    'Wok Criollo',
    'Chaufa',
    'Complementos'
)
AND NOT EXISTS (
    SELECT 1
    FROM @Reglas r
    WHERE r.producto_codigo = p.codigo
      AND r.modificador_nombre = 'Cremas'
);


/* =========================================================
   3. TERMINO DE CARNE
   Para parrillas y preparaciones con carne.
   ========================================================= */
INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    p.codigo,
    'Termino de carne',
    0,
    0,
    1,
    0,
    4,
    'Indica el termino de coccion si aplica.'
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
WHERE c.nombre IN (
    'Fusiones',
    'Parrillas Personales',
    'Parrillas Familiares'
)
AND NOT EXISTS (
    SELECT 1
    FROM @Reglas r
    WHERE r.producto_codigo = p.codigo
      AND r.modificador_nombre = 'Termino de carne'
);

INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    p.codigo,
    'Termino de carne',
    0,
    0,
    1,
    0,
    4,
    'Indica el termino de coccion si aplica.'
FROM dbo.Producto p
WHERE p.codigo IN ('WOK003', 'WOK006')
AND NOT EXISTS (
    SELECT 1
    FROM @Reglas r
    WHERE r.producto_codigo = p.codigo
      AND r.modificador_nombre = 'Termino de carne'
);


/* =========================================================
   4. PASTAS
   Las variantes ya guardan precio por combinacion.
   Esta regla sirve para la seleccion operativa del complemento.
   ========================================================= */
INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    p.codigo,
    'Complemento de pasta',
    1,
    1,
    1,
    0,
    1,
    'Elige un complemento para la pasta.'
FROM dbo.Producto p
WHERE p.codigo IN ('PAS001', 'PAS002', 'PAS003')
AND NOT EXISTS (
    SELECT 1
    FROM @Reglas r
    WHERE r.producto_codigo = p.codigo
      AND r.modificador_nombre = 'Complemento de pasta'
);


/* =========================================================
   5. BEBIDAS
   ========================================================= */

/* Sabor de bebida para productos que tienen opcion de marca/sabor */
INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    p.codigo,
    'Sabor de bebida',
    0,
    0,
    1,
    0,
    1,
    'Elige sabor o marca si aplica.'
FROM dbo.Producto p
WHERE p.codigo IN (
    'BEB002',
    'BEB004',
    'BEB005',
    'BEB007',
    'BEB008',
    'BEB009',
    'BEB010',
    'BEB011',
    'BEB013',
    'BEB014',
    'BEB015',
    'BEB016',
    'BEB017',
    'BEB018'
)
AND NOT EXISTS (
    SELECT 1
    FROM @Reglas r
    WHERE r.producto_codigo = p.codigo
      AND r.modificador_nombre = 'Sabor de bebida'
);

/* Temperatura de bebida */
INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    p.codigo,
    'Temperatura de bebida',
    0,
    0,
    1,
    0,
    2,
    'Indica temperatura si aplica.'
FROM dbo.Producto p
WHERE p.codigo LIKE 'BEB%'
   OR p.codigo LIKE 'INF%';

/* Presentacion de bebida */
INSERT INTO @Reglas
    (producto_codigo, modificador_nombre, es_obligatorio,
     min_selecciones, max_selecciones, permite_repetir_opcion,
     orden_aplicacion, texto_guia)
SELECT
    p.codigo,
    'Presentacion de bebida',
    0,
    0,
    1,
    0,
    3,
    'Indica presentacion si aplica.'
FROM dbo.Producto p
WHERE p.codigo LIKE 'BEB%'
   OR p.codigo LIKE 'INF%';


/* =========================================================
   6. VALIDAR MODIFICADORES FALTANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Reglas r
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Modificador m
        WHERE m.nombre = r.modificador_nombre
    )
)
BEGIN
    SELECT DISTINCT r.modificador_nombre AS modificador_faltante
    FROM @Reglas r
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Modificador m
        WHERE m.nombre = r.modificador_nombre
    );

    THROW 55005, 'Hay modificadores faltantes. Revisa el resultado anterior.', 1;
END;


/* =========================================================
   7. ACTUALIZAR REGLAS EXISTENTES
   ========================================================= */
UPDATE pm
SET
    pm.es_obligatorio = r.es_obligatorio,
    pm.orden_aplicacion = r.orden_aplicacion,
    pm.min_selecciones = r.min_selecciones,
    pm.max_selecciones = r.max_selecciones,
    pm.permite_repetir_opcion = r.permite_repetir_opcion,
    pm.texto_guia = r.texto_guia
FROM dbo.ProductoModificador pm
INNER JOIN dbo.Producto p
    ON p.id_producto = pm.id_producto
INNER JOIN dbo.Modificador m
    ON m.id_modificador = pm.id_modificador
INNER JOIN @Reglas r
    ON r.producto_codigo = p.codigo
   AND r.modificador_nombre = m.nombre;


/* =========================================================
   8. INSERTAR REGLAS NUEVAS
   ========================================================= */
INSERT INTO dbo.ProductoModificador
    (id_producto, id_modificador, es_obligatorio, orden_aplicacion,
     min_selecciones, max_selecciones, permite_repetir_opcion, texto_guia)
SELECT
    p.id_producto,
    m.id_modificador,
    r.es_obligatorio,
    r.orden_aplicacion,
    r.min_selecciones,
    r.max_selecciones,
    r.permite_repetir_opcion,
    r.texto_guia
FROM @Reglas r
INNER JOIN dbo.Producto p
    ON p.codigo = r.producto_codigo
INNER JOIN dbo.Modificador m
    ON m.nombre = r.modificador_nombre
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoModificador pm
    WHERE pm.id_producto = p.id_producto
      AND pm.id_modificador = m.id_modificador
);


COMMIT TRANSACTION;

PRINT 'BLOQUE 5 cargado correctamente: reglas ProductoModificador.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 5';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
