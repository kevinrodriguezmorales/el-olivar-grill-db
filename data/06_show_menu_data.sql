USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 6 - MENU PRODUCTO
   Ejecutar despues del BLOQUE 5B

   Este bloque:
   - Carga productos en Carta General
   - Carga productos MNU en Menu El Olivar
   - Carga productos OFE en Ofertas Brasa
   - Carga variantes de pastas en Carta General
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.MenuProducto', N'U') IS NULL
BEGIN
    THROW 56000, 'No existe dbo.MenuProducto. Ejecuta primero el script de mejora.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'CARTA_GENERAL')
BEGIN
    THROW 56001, 'No existe el menu CARTA_GENERAL. Ejecuta primero el BLOQUE 1.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'MENU_OLIVAR_LV')
BEGIN
    THROW 56002, 'No existe el menu MENU_OLIVAR_LV. Ejecuta primero el BLOQUE 1.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'OFERTAS_BRASA')
BEGIN
    THROW 56003, 'No existe el menu OFERTAS_BRASA. Ejecuta primero el BLOQUE 1.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Producto WHERE activo = 1)
BEGIN
    THROW 56004, 'No hay productos activos cargados.', 1;
END;


/* =========================================================
   TABLA TEMPORAL DE MENU PRODUCTO
   ========================================================= */
DECLARE @MenuProductos TABLE (
    menu_codigo VARCHAR(20) NOT NULL,
    producto_codigo VARCHAR(10) NOT NULL,
    codigo_variante VARCHAR(20) NULL,
    precio_menu DECIMAL(10,2) NULL,
    usa_precio_base BIT NOT NULL,
    etiqueta VARCHAR(50) NULL,
    destacado BIT NOT NULL,
    orden_visual INT NOT NULL,
    imagen_url VARCHAR(300) NULL,
    visible BIT NOT NULL,
    activo BIT NOT NULL
);


/* =========================================================
   1. CARTA GENERAL - PRODUCTOS BASE
   Excluye productos MNU, porque esos van al menu ejecutivo.
   ========================================================= */
INSERT INTO @MenuProductos
    (menu_codigo, producto_codigo, codigo_variante, precio_menu,
     usa_precio_base, etiqueta, destacado, orden_visual,
     imagen_url, visible, activo)
SELECT
    'CARTA_GENERAL' AS menu_codigo,
    p.codigo AS producto_codigo,
    NULL AS codigo_variante,
    NULL AS precio_menu,
    1 AS usa_precio_base,
    CASE
        WHEN c.nombre = 'Ofertas en Pollo a la Brasa' THEN 'Oferta'
        WHEN c.nombre = 'Parrillas Familiares' THEN 'Familiar'
        WHEN c.nombre = 'Pastas' THEN 'Base'
        ELSE NULL
    END AS etiqueta,
    CASE
        WHEN c.nombre IN ('Ofertas en Pollo a la Brasa', 'Parrillas Familiares') THEN 1
        ELSE 0
    END AS destacado,
    ROW_NUMBER() OVER (
        ORDER BY c.orden_visual, p.codigo
    ) AS orden_visual,
    p.imagen_principal_url AS imagen_url,
    1 AS visible,
    1 AS activo
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
WHERE p.activo = 1
  AND p.codigo NOT LIKE 'MNU%';


/* =========================================================
   2. CARTA GENERAL - VARIANTES DE PASTAS
   Usa precio final de ProductoVariante.
   ========================================================= */
DECLARE @orden_base_carta INT;

SELECT @orden_base_carta = ISNULL(MAX(orden_visual), 0)
FROM @MenuProductos
WHERE menu_codigo = 'CARTA_GENERAL';

INSERT INTO @MenuProductos
    (menu_codigo, producto_codigo, codigo_variante, precio_menu,
     usa_precio_base, etiqueta, destacado, orden_visual,
     imagen_url, visible, activo)
SELECT
    'CARTA_GENERAL' AS menu_codigo,
    p.codigo AS producto_codigo,
    pv.codigo_variante,
    pv.precio AS precio_menu,
    0 AS usa_precio_base,
    'Variante pasta' AS etiqueta,
    0 AS destacado,
    @orden_base_carta + ROW_NUMBER() OVER (
        ORDER BY p.codigo, pv.orden_visual
    ) AS orden_visual,
    COALESCE(pv.imagen_url, p.imagen_principal_url) AS imagen_url,
    1 AS visible,
    1 AS activo
FROM dbo.ProductoVariante pv
INNER JOIN dbo.Producto p
    ON p.id_producto = pv.id_producto
WHERE p.codigo IN ('PAS001', 'PAS002', 'PAS003')
  AND pv.activo = 1;


/* =========================================================
   3. MENU EL OLIVAR - MENU EJECUTIVO
   ========================================================= */
INSERT INTO @MenuProductos
    (menu_codigo, producto_codigo, codigo_variante, precio_menu,
     usa_precio_base, etiqueta, destacado, orden_visual,
     imagen_url, visible, activo)
SELECT
    'MENU_OLIVAR_LV' AS menu_codigo,
    p.codigo AS producto_codigo,
    NULL AS codigo_variante,
    NULL AS precio_menu,
    1 AS usa_precio_base,
    'Menu ejecutivo' AS etiqueta,
    1 AS destacado,
    ROW_NUMBER() OVER (
        ORDER BY p.codigo
    ) AS orden_visual,
    p.imagen_principal_url AS imagen_url,
    1 AS visible,
    1 AS activo
FROM dbo.Producto p
WHERE p.codigo LIKE 'MNU%'
  AND p.activo = 1;


/* =========================================================
   4. OFERTAS BRASA
   ========================================================= */
INSERT INTO @MenuProductos
    (menu_codigo, producto_codigo, codigo_variante, precio_menu,
     usa_precio_base, etiqueta, destacado, orden_visual,
     imagen_url, visible, activo)
SELECT
    'OFERTAS_BRASA' AS menu_codigo,
    p.codigo AS producto_codigo,
    NULL AS codigo_variante,
    NULL AS precio_menu,
    1 AS usa_precio_base,
    'Oferta' AS etiqueta,
    1 AS destacado,
    ROW_NUMBER() OVER (
        ORDER BY p.codigo
    ) AS orden_visual,
    p.imagen_principal_url AS imagen_url,
    1 AS visible,
    1 AS activo
FROM dbo.Producto p
WHERE p.codigo LIKE 'OFE%'
  AND p.activo = 1;


/* =========================================================
   5. VALIDAR PRODUCTOS FALTANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @MenuProductos mp
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = mp.producto_codigo
    )
)
BEGIN
    SELECT DISTINCT mp.producto_codigo AS producto_faltante
    FROM @MenuProductos mp
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = mp.producto_codigo
    );

    THROW 56005, 'Hay productos faltantes para MenuProducto.', 1;
END;


/* =========================================================
   6. VALIDAR VARIANTES FALTANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @MenuProductos mp
    INNER JOIN dbo.Producto p
        ON p.codigo = mp.producto_codigo
    WHERE mp.codigo_variante IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.ProductoVariante pv
          WHERE pv.id_producto = p.id_producto
            AND pv.codigo_variante = mp.codigo_variante
      )
)
BEGIN
    SELECT
        mp.producto_codigo,
        mp.codigo_variante AS variante_faltante
    FROM @MenuProductos mp
    INNER JOIN dbo.Producto p
        ON p.codigo = mp.producto_codigo
    WHERE mp.codigo_variante IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.ProductoVariante pv
          WHERE pv.id_producto = p.id_producto
            AND pv.codigo_variante = mp.codigo_variante
      );

    THROW 56006, 'Hay variantes faltantes para MenuProducto.', 1;
END;


/* =========================================================
   7. ACTUALIZAR MENU PRODUCTO EXISTENTE SIN VARIANTE
   ========================================================= */
UPDATE mp
SET
    mp.precio_menu = data.precio_menu,
    mp.usa_precio_base = data.usa_precio_base,
    mp.etiqueta = data.etiqueta,
    mp.destacado = data.destacado,
    mp.orden_visual = data.orden_visual,
    mp.imagen_url = data.imagen_url,
    mp.visible = data.visible,
    mp.activo = data.activo
FROM dbo.MenuProducto mp
INNER JOIN dbo.Menu m
    ON m.id_menu = mp.id_menu
INNER JOIN dbo.Producto p
    ON p.id_producto = mp.id_producto
INNER JOIN @MenuProductos data
    ON data.menu_codigo = m.codigo
   AND data.producto_codigo = p.codigo
WHERE data.codigo_variante IS NULL
  AND mp.id_variante IS NULL;


/* =========================================================
   8. ACTUALIZAR MENU PRODUCTO EXISTENTE CON VARIANTE
   ========================================================= */
UPDATE mp
SET
    mp.precio_menu = data.precio_menu,
    mp.usa_precio_base = data.usa_precio_base,
    mp.etiqueta = data.etiqueta,
    mp.destacado = data.destacado,
    mp.orden_visual = data.orden_visual,
    mp.imagen_url = data.imagen_url,
    mp.visible = data.visible,
    mp.activo = data.activo
FROM dbo.MenuProducto mp
INNER JOIN dbo.Menu m
    ON m.id_menu = mp.id_menu
INNER JOIN dbo.Producto p
    ON p.id_producto = mp.id_producto
INNER JOIN dbo.ProductoVariante pv
    ON pv.id_variante = mp.id_variante
INNER JOIN @MenuProductos data
    ON data.menu_codigo = m.codigo
   AND data.producto_codigo = p.codigo
   AND data.codigo_variante = pv.codigo_variante
WHERE data.codigo_variante IS NOT NULL;


/* =========================================================
   9. INSERTAR MENU PRODUCTO NUEVO
   ========================================================= */
INSERT INTO dbo.MenuProducto
    (id_menu, id_producto, id_variante, precio_menu,
     usa_precio_base, etiqueta, destacado, orden_visual,
     imagen_url, visible, activo)
SELECT
    m.id_menu,
    p.id_producto,
    pv.id_variante,
    data.precio_menu,
    data.usa_precio_base,
    data.etiqueta,
    data.destacado,
    data.orden_visual,
    data.imagen_url,
    data.visible,
    data.activo
FROM @MenuProductos data
INNER JOIN dbo.Menu m
    ON m.codigo = data.menu_codigo
INNER JOIN dbo.Producto p
    ON p.codigo = data.producto_codigo
LEFT JOIN dbo.ProductoVariante pv
    ON pv.id_producto = p.id_producto
   AND pv.codigo_variante = data.codigo_variante
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.MenuProducto mp
    WHERE mp.id_menu = m.id_menu
      AND mp.id_producto = p.id_producto
      AND (
            (data.codigo_variante IS NULL AND mp.id_variante IS NULL)
            OR
            (data.codigo_variante IS NOT NULL AND mp.id_variante = pv.id_variante)
          )
);


COMMIT TRANSACTION;

PRINT 'BLOQUE 6 cargado correctamente: MenuProducto.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 6';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
