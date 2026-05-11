USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 4 - VARIANTES DE PASTAS
   Ejecutar despues del BLOQUE 3C

   Requiere:
   - Productos PAS001, PAS002, PAS003
   - Modificadores: Salsa de pasta, Complemento de pasta
   - Tablas: ProductoVariante, ProductoVarianteOpcion
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

DECLARE @DriveBase VARCHAR(200) = 'https://drive.google.com/uc?export=view&id=';
DECLARE @SobrescribirImagenes BIT = 0;


/* =========================================================
   VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.ProductoVariante', N'U') IS NULL
BEGIN
    THROW 54000, 'No existe dbo.ProductoVariante. Ejecuta primero el script de mejora.', 1;
END;

IF OBJECT_ID(N'dbo.ProductoVarianteOpcion', N'U') IS NULL
BEGIN
    THROW 54001, 'No existe dbo.ProductoVarianteOpcion. Ejecuta primero el script de mejora.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Producto WHERE codigo = 'PAS001')
BEGIN
    THROW 54002, 'Falta el producto PAS001 - Fetuccini al pesto. Ejecuta primero el BLOQUE 3C.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Producto WHERE codigo = 'PAS002')
BEGIN
    THROW 54003, 'Falta el producto PAS002 - Fetuccini a la huancaina. Ejecuta primero el BLOQUE 3C.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Producto WHERE codigo = 'PAS003')
BEGIN
    THROW 54004, 'Falta el producto PAS003 - Fetuccini a lo Alfredo. Ejecuta primero el BLOQUE 3C.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Modificador WHERE nombre = 'Salsa de pasta')
BEGIN
    THROW 54005, 'Falta el modificador Salsa de pasta. Ejecuta primero el BLOQUE 1.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Modificador WHERE nombre = 'Complemento de pasta')
BEGIN
    THROW 54006, 'Falta el modificador Complemento de pasta. Ejecuta primero el BLOQUE 1.', 1;
END;


/* =========================================================
   1. ASEGURAR OPCIONES NECESARIAS
   ========================================================= */

DECLARE @OpcionesNecesarias TABLE (
    modificador_nombre VARCHAR(50),
    valor VARCHAR(100),
    precio_extra DECIMAL(10,2),
    orden INT,
    stock_dependiente BIT
);

INSERT INTO @OpcionesNecesarias
    (modificador_nombre, valor, precio_extra, orden, stock_dependiente)
VALUES
('Salsa de pasta', 'Al pesto', 0.00, 1, 1),
('Salsa de pasta', 'A la huancaina', 0.00, 2, 1),
('Salsa de pasta', 'A lo Alfredo', 0.00, 3, 1),

('Complemento de pasta', 'Con 1/4 de pollo', 0.00, 1, 1),
('Complemento de pasta', 'Con pechuga o pierna a la parrilla', 0.00, 2, 1),
('Complemento de pasta', 'Con chuleta', 0.00, 3, 1),
('Complemento de pasta', 'Con churrasco', 0.00, 4, 1),
('Complemento de pasta', 'Con lomo', 0.00, 5, 1);

INSERT INTO dbo.OpcionModificador
    (id_modificador, valor, precio_extra, orden, stock_dependiente)
SELECT
    m.id_modificador,
    o.valor,
    o.precio_extra,
    o.orden,
    o.stock_dependiente
FROM @OpcionesNecesarias o
INNER JOIN dbo.Modificador m
    ON m.nombre = o.modificador_nombre
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.OpcionModificador om
    WHERE om.id_modificador = m.id_modificador
      AND om.valor = o.valor
);


/* =========================================================
   2. DATA DE VARIANTES
   ========================================================= */

DECLARE @Variantes TABLE (
    producto_codigo VARCHAR(10) NOT NULL,
    codigo_variante VARCHAR(20) NOT NULL,
    nombre_variante VARCHAR(120) NOT NULL,
    descripcion VARCHAR(MAX) NULL,
    precio DECIMAL(10,2) NOT NULL,
    orden_visual INT NOT NULL,
    salsa VARCHAR(100) NOT NULL,
    complemento VARCHAR(100) NOT NULL,
    imagen_drive_id VARCHAR(100) NULL
);

INSERT INTO @Variantes
    (producto_codigo, codigo_variante, nombre_variante, descripcion, precio,
     orden_visual, salsa, complemento, imagen_drive_id)
VALUES
/* FETUCCINI AL PESTO */
('PAS001', 'PESTO-POLLO',
 'Fetuccini al pesto + 1/4 de pollo',
 'Fetuccini con salsa al pesto acompanado de 1/4 de pollo.',
 25.50, 1, 'Al pesto', 'Con 1/4 de pollo', 'IMG_VAR_PESTO_POLLO'),

('PAS001', 'PESTO-PECH',
 'Fetuccini al pesto + pechuga o pierna a la parrilla',
 'Fetuccini con salsa al pesto acompanado de pechuga o pierna a la parrilla.',
 25.50, 2, 'Al pesto', 'Con pechuga o pierna a la parrilla', 'IMG_VAR_PESTO_PECH'),

('PAS001', 'PESTO-CHULETA',
 'Fetuccini al pesto + chuleta',
 'Fetuccini con salsa al pesto acompanado de chuleta.',
 27.50, 3, 'Al pesto', 'Con chuleta', 'IMG_VAR_PESTO_CHULETA'),

('PAS001', 'PESTO-CHUR',
 'Fetuccini al pesto + churrasco',
 'Fetuccini con salsa al pesto acompanado de churrasco.',
 28.00, 4, 'Al pesto', 'Con churrasco', 'IMG_VAR_PESTO_CHUR'),

('PAS001', 'PESTO-LOMO',
 'Fetuccini al pesto + lomo',
 'Fetuccini con salsa al pesto acompanado de lomo.',
 31.00, 5, 'Al pesto', 'Con lomo', 'IMG_VAR_PESTO_LOMO'),


/* FETUCCINI A LA HUANCAINA */
('PAS002', 'HUAN-POLLO',
 'Fetuccini a la huancaina + 1/4 de pollo',
 'Fetuccini con salsa a la huancaina acompanado de 1/4 de pollo.',
 26.00, 1, 'A la huancaina', 'Con 1/4 de pollo', 'IMG_VAR_HUAN_POLLO'),

('PAS002', 'HUAN-PECH',
 'Fetuccini a la huancaina + pechuga o pierna a la parrilla',
 'Fetuccini con salsa a la huancaina acompanado de pechuga o pierna a la parrilla.',
 26.00, 2, 'A la huancaina', 'Con pechuga o pierna a la parrilla', 'IMG_VAR_HUAN_PECH'),

('PAS002', 'HUAN-CHULETA',
 'Fetuccini a la huancaina + chuleta',
 'Fetuccini con salsa a la huancaina acompanado de chuleta.',
 28.00, 3, 'A la huancaina', 'Con chuleta', 'IMG_VAR_HUAN_CHULETA'),

('PAS002', 'HUAN-CHUR',
 'Fetuccini a la huancaina + churrasco',
 'Fetuccini con salsa a la huancaina acompanado de churrasco.',
 28.00, 4, 'A la huancaina', 'Con churrasco', 'IMG_VAR_HUAN_CHUR'),

('PAS002', 'HUAN-LOMO',
 'Fetuccini a la huancaina + lomo',
 'Fetuccini con salsa a la huancaina acompanado de lomo.',
 32.00, 5, 'A la huancaina', 'Con lomo', 'IMG_VAR_HUAN_LOMO'),


/* FETUCCINI A LO ALFREDO */
('PAS003', 'ALF-POLLO',
 'Fetuccini a lo Alfredo + 1/4 de pollo',
 'Fetuccini con salsa Alfredo acompanado de 1/4 de pollo.',
 28.50, 1, 'A lo Alfredo', 'Con 1/4 de pollo', 'IMG_VAR_ALF_POLLO'),

('PAS003', 'ALF-PECH',
 'Fetuccini a lo Alfredo + pechuga o pierna a la parrilla',
 'Fetuccini con salsa Alfredo acompanado de pechuga o pierna a la parrilla.',
 28.50, 2, 'A lo Alfredo', 'Con pechuga o pierna a la parrilla', 'IMG_VAR_ALF_PECH'),

('PAS003', 'ALF-CHULETA',
 'Fetuccini a lo Alfredo + chuleta',
 'Fetuccini con salsa Alfredo acompanado de chuleta.',
 29.50, 3, 'A lo Alfredo', 'Con chuleta', 'IMG_VAR_ALF_CHULETA'),

('PAS003', 'ALF-CHUR',
 'Fetuccini a lo Alfredo + churrasco',
 'Fetuccini con salsa Alfredo acompanado de churrasco.',
 29.50, 4, 'A lo Alfredo', 'Con churrasco', 'IMG_VAR_ALF_CHUR');


/* =========================================================
   3. VALIDAR QUE EXISTAN LAS OPCIONES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Variantes v
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Modificador m
        INNER JOIN dbo.OpcionModificador om
            ON om.id_modificador = m.id_modificador
        WHERE m.nombre = 'Salsa de pasta'
          AND om.valor = v.salsa
    )
)
BEGIN
    SELECT DISTINCT v.salsa AS salsa_faltante
    FROM @Variantes v
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Modificador m
        INNER JOIN dbo.OpcionModificador om
            ON om.id_modificador = m.id_modificador
        WHERE m.nombre = 'Salsa de pasta'
          AND om.valor = v.salsa
    );

    THROW 54007, 'Faltan opciones de salsa de pasta.', 1;
END;

IF EXISTS (
    SELECT 1
    FROM @Variantes v
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Modificador m
        INNER JOIN dbo.OpcionModificador om
            ON om.id_modificador = m.id_modificador
        WHERE m.nombre = 'Complemento de pasta'
          AND om.valor = v.complemento
    )
)
BEGIN
    SELECT DISTINCT v.complemento AS complemento_faltante
    FROM @Variantes v
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Modificador m
        INNER JOIN dbo.OpcionModificador om
            ON om.id_modificador = m.id_modificador
        WHERE m.nombre = 'Complemento de pasta'
          AND om.valor = v.complemento
    );

    THROW 54008, 'Faltan opciones de complemento de pasta.', 1;
END;


/* =========================================================
   4. INSERTAR / ACTUALIZAR PRODUCTO VARIANTE
   ========================================================= */

UPDATE pv
SET
    pv.nombre_variante = v.nombre_variante,
    pv.descripcion = v.descripcion,
    pv.precio = v.precio,
    pv.es_precio_final = 1,
    pv.orden_visual = v.orden_visual,
    pv.activo = 1,
    pv.imagen_url =
        CASE
            WHEN @SobrescribirImagenes = 1
              OR pv.imagen_url IS NULL
              OR pv.imagen_url LIKE '%IMG_%'
              OR pv.imagen_url LIKE '%REEMPLAZAR%'
            THEN @DriveBase + v.imagen_drive_id
            ELSE pv.imagen_url
        END
FROM dbo.ProductoVariante pv
INNER JOIN dbo.Producto p
    ON p.id_producto = pv.id_producto
INNER JOIN @Variantes v
    ON v.producto_codigo = p.codigo
   AND v.codigo_variante = pv.codigo_variante;


INSERT INTO dbo.ProductoVariante
    (id_producto, codigo_variante, nombre_variante, descripcion, precio,
     es_precio_final, imagen_url, orden_visual, activo)
SELECT
    p.id_producto,
    v.codigo_variante,
    v.nombre_variante,
    v.descripcion,
    v.precio,
    1,
    @DriveBase + v.imagen_drive_id,
    v.orden_visual,
    1
FROM @Variantes v
INNER JOIN dbo.Producto p
    ON p.codigo = v.producto_codigo
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoVariante pv
    WHERE pv.id_producto = p.id_producto
      AND pv.codigo_variante = v.codigo_variante
);


/* =========================================================
   5. VINCULAR VARIANTES CON OPCIONES DE MODIFICADOR
   ========================================================= */

DECLARE @VarianteOpciones TABLE (
    id_variante INT NOT NULL,
    id_modificador INT NOT NULL,
    id_opcion INT NOT NULL,
    orden INT NOT NULL
);

INSERT INTO @VarianteOpciones
    (id_variante, id_modificador, id_opcion, orden)
SELECT
    pv.id_variante,
    m.id_modificador,
    om.id_opcion,
    1 AS orden
FROM @Variantes v
INNER JOIN dbo.Producto p
    ON p.codigo = v.producto_codigo
INNER JOIN dbo.ProductoVariante pv
    ON pv.id_producto = p.id_producto
   AND pv.codigo_variante = v.codigo_variante
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Salsa de pasta'
INNER JOIN dbo.OpcionModificador om
    ON om.id_modificador = m.id_modificador
   AND om.valor = v.salsa

UNION ALL

SELECT
    pv.id_variante,
    m.id_modificador,
    om.id_opcion,
    2 AS orden
FROM @Variantes v
INNER JOIN dbo.Producto p
    ON p.codigo = v.producto_codigo
INNER JOIN dbo.ProductoVariante pv
    ON pv.id_producto = p.id_producto
   AND pv.codigo_variante = v.codigo_variante
INNER JOIN dbo.Modificador m
    ON m.nombre = 'Complemento de pasta'
INNER JOIN dbo.OpcionModificador om
    ON om.id_modificador = m.id_modificador
   AND om.valor = v.complemento;


/* Actualizar si ya existe la misma opcion vinculada */
UPDATE pvo
SET
    pvo.id_modificador = vo.id_modificador,
    pvo.orden = vo.orden
FROM dbo.ProductoVarianteOpcion pvo
INNER JOIN @VarianteOpciones vo
    ON vo.id_variante = pvo.id_variante
   AND vo.id_opcion = pvo.id_opcion;


/* Insertar si no existe */
INSERT INTO dbo.ProductoVarianteOpcion
    (id_variante, id_modificador, id_opcion, orden)
SELECT
    vo.id_variante,
    vo.id_modificador,
    vo.id_opcion,
    vo.orden
FROM @VarianteOpciones vo
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ProductoVarianteOpcion pvo
    WHERE pvo.id_variante = vo.id_variante
      AND pvo.id_opcion = vo.id_opcion
);


COMMIT TRANSACTION;

PRINT 'BLOQUE 4 cargado correctamente: variantes de pastas y precios por combinacion.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 4';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
