USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 3B - PRODUCTOS BASE
   Fusiones, parrillas personales, piqueos y parrillas familiares
   Ejecutar despues del BLOQUE 3A
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.Producto', N'U') IS NULL
BEGIN
    THROW 52000, 'No existe la tabla Producto.', 1;
END;

IF OBJECT_ID(N'dbo.ProductoImagen', N'U') IS NULL
BEGIN
    THROW 52001, 'No existe la tabla ProductoImagen. Ejecuta primero el script de mejora.', 1;
END;

IF COL_LENGTH('dbo.Producto', 'imagen_principal_url') IS NULL
BEGIN
    THROW 52002, 'Falta la columna Producto.imagen_principal_url. Ejecuta primero el script de mejora.', 1;
END;

IF COL_LENGTH('dbo.Producto', 'nombre_corto') IS NULL
BEGIN
    THROW 52003, 'Falta la columna Producto.nombre_corto. Ejecuta primero el script de mejora.', 1;
END;


/* =========================================================
   CONFIGURACION DE IMAGENES
   ========================================================= */
DECLARE @DriveBase VARCHAR(200) = 'https://drive.google.com/uc?export=view&id=';
DECLARE @SobrescribirImagenes BIT = 0;


/* =========================================================
   PRODUCTOS A CARGAR
   ========================================================= */
DECLARE @Productos TABLE (
    codigo VARCHAR(10) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    nombre_corto VARCHAR(60) NULL,
    descripcion VARCHAR(MAX) NULL,
    precio_base DECIMAL(10,2) NOT NULL,
    categoria_nombre VARCHAR(50) NOT NULL,
    tiempo_preparacion_segundos INT NOT NULL,
    requiere_nota_alergia BIT NOT NULL,
    imagen_drive_id VARCHAR(100) NULL
);

INSERT INTO @Productos
    (codigo, nombre, nombre_corto, descripcion, precio_base, categoria_nombre,
     tiempo_preparacion_segundos, requiere_nota_alergia, imagen_drive_id)
VALUES

/* =========================================================
   FUSIONES
   ========================================================= */
('FUS001', 'POLLO RICKY + ANTICUCHO', 'POLLO RICKY + ANTICUCHO',
 'Pechuga o pierna a la parrilla acompanada de un palito de anticucho, papas fritas o sancochadas y ensalada fresca.',
 28.50, 'Fusiones', 1200, 0, 'IMG_FUS001'),

('FUS002', 'POLLO RICKY + MOLLEJITAS', 'POLLO RICKY + MOLLEJITAS',
 'Pollo a la brasa o a la parrilla acompanado de 125 gr de mollejitas, papas fritas o sancochadas y ensalada fresca.',
 27.50, 'Fusiones', 1200, 0, 'IMG_FUS002'),

('FUS003', 'POLLO RICKY RICON + MOLLEJITAS', 'RICKY RICON + MOLLEJITAS',
 'Pechuga rellena de jamon ingles, tocino ahumado y queso Edam, acompanada de 125 gr de mollejitas, papas fritas o sancochadas y ensalada fresca.',
 32.50, 'Fusiones', 1200, 0, 'IMG_FUS003'),

('FUS004', 'CHULETA PREMIUM + MOLLEJITAS', 'CHULETA + MOLLEJITAS',
 'Chuleta de cerdo a la parrilla acompanada de 125 gr de mollejitas, papas fritas o sancochadas y ensalada fresca.',
 28.50, 'Fusiones', 1200, 0, 'IMG_FUS004'),

('FUS005', 'MIXTO EL OLIVAR', 'MIXTO EL OLIVAR',
 'Pollo a la brasa o a la parrilla, palito de anticucho, 125 gr de mollejitas, papas fritas o sancochadas y ensalada fresca.',
 32.00, 'Fusiones', 1200, 0, 'IMG_FUS005'),

('FUS006', '1/4 DE POLLO A LA BRASA EL OLIVAR + ANTICUCHO', '1/4 POLLO + ANTICUCHO',
 'Un cuarto de pollo a la brasa El Olivar acompanado de un palito de anticucho, papas fritas o sancochadas y ensalada fresca.',
 28.00, 'Fusiones', 1200, 0, 'IMG_FUS006'),


/* =========================================================
   PARRILLAS PERSONALES
   ========================================================= */
('PAR001', 'POLLO OLIVAR', 'POLLO OLIVAR',
 'Pechuga o pierna a la parrilla, acompanada de papas fritas o sancochadas y ensalada fresca.',
 25.00, 'Parrillas Personales', 1200, 0, 'IMG_PAR001'),

('PAR002', 'BROCHETAS DE POLLO A LA PARRILLA', 'BROCHETAS DE POLLO',
 'Cuatro brochetas de pollo a la parrilla, acompanadas de papas fritas o sancochadas y ensalada fresca o cocida.',
 23.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR002'),

('PAR003', 'ANTICUCHOS A LA PARRILLA', 'ANTICUCHOS A LA PARRILLA',
 'Dos palitos de anticucho a la parrilla, con papas fritas o sancochadas, choclo y ensalada fresca o cocida.',
 23.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR003'),

('PAR004', 'RICKY HUAYRO', 'RICKY HUAYRO',
 'Pechuga o pierna a la parrilla, con papas sancochadas huayro, media porcion de choclo y ensalada fresca.',
 28.00, 'Parrillas Personales', 1200, 0, 'IMG_PAR004'),

('PAR005', 'RICKY A LA BBQ', 'RICKY A LA BBQ',
 'Pechuga o pierna a la parrilla con salsa BBQ, papas fritas o sancochadas y ensalada fresca o cocida.',
 26.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR005'),

('PAR006', 'BROCHETAS DE CARNE A LA PARRILLA', 'BROCHETAS DE CARNE',
 'Cuatro brochetas de carne a la parrilla, acompanadas de papas fritas o sancochadas y ensalada fresca.',
 26.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR006'),

('PAR007', 'BROCHETAS MIXTAS A LA PARRILLA', 'BROCHETAS MIXTAS',
 'Dos brochetas de carne y dos brochetas de pollo a la parrilla, acompanadas de papas fritas o sancochadas y ensalada fresca.',
 27.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR007'),

('PAR008', 'RICKY RICON', 'RICKY RICON',
 'Pechuga rellena de jamon ingles, tocino ahumado y queso Edam, acompanada de papas fritas y ensalada fresca o cocida.',
 32.00, 'Parrillas Personales', 1200, 0, 'IMG_PAR008'),

('PAR009', 'LOMO MEDALLON', 'LOMO MEDALLON',
 'Lomo fino a la parrilla, acompanado de papas fritas o sancochadas y ensalada fresca o cocida.',
 37.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR009'),

('PAR010', 'MOLLEJITAS GRILL', 'MOLLEJITAS GRILL',
 'Mollejitas a la parrilla, acompanadas de papas fritas o sancochadas y ensalada fresca o cocida.',
 21.00, 'Parrillas Personales', 1200, 0, 'IMG_PAR010'),

('PAR011', 'CHULETA PREMIUM', 'CHULETA PREMIUM',
 'Chuleta a la parrilla, acompanada de papas fritas o sancochadas y ensalada fresca o cocida.',
 27.00, 'Parrillas Personales', 1200, 0, 'IMG_PAR011'),

('PAR012', 'MOLLEJITAS BBQ', 'MOLLEJITAS BBQ',
 'Mollejitas a la parrilla con salsa BBQ, acompanadas de papas fritas o sancochadas y ensalada fresca o cocida.',
 23.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR012'),

('PAR013', 'CHULETA BBQ', 'CHULETA BBQ',
 'Chuleta a la parrilla con salsa BBQ, acompanada de papas fritas o sancochadas y ensalada fresca o cocida.',
 28.00, 'Parrillas Personales', 1200, 0, 'IMG_PAR013'),

('PAR014', '1/2 COSTILLAR A LA BBQ', '1/2 COSTILLAR BBQ',
 'Tres costillas de cerdo a la parrilla con salsa BBQ, acompanadas de papas fritas o sancochadas y ensalada fresca.',
 27.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR014'),

('PAR015', 'CHURRASCO A LA PARRILLA', 'CHURRASCO A LA PARRILLA',
 'Churrasco a la parrilla, acompanado de papas fritas o sancochadas y ensalada fresca o cocida.',
 27.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR015'),

('PAR016', 'CHURRASCO A LO POBRE', 'CHURRASCO A LO POBRE',
 'Churrasco a la parrilla con papas fritas o sancochadas, huevo frito, arroz, platano frito y ensalada fresca o cocida.',
 31.50, 'Parrillas Personales', 1200, 0, 'IMG_PAR016'),

('PAR017', 'BIFE EJECUTIVO', 'BIFE EJECUTIVO',
 'Bife a la parrilla acompanado de papas fritas o sancochadas y ensalada fresca.',
 39.00, 'Parrillas Personales', 1200, 0, 'IMG_PAR017'),

('PAR018', 'COSTILLAR A LA BBQ', 'COSTILLAR A LA BBQ',
 'Seis costillas de cerdo a la parrilla con salsa BBQ, acompanadas de papas fritas o sancochadas y ensalada fresca o cocida.',
 48.00, 'Parrillas Personales', 1500, 0, 'IMG_PAR018'),

('PAR019', 'ALITAS A LA BBQ', 'ALITAS A LA BBQ',
 'Alitas con salsa BBQ, acompanadas de papas fritas o sancochadas.',
 23.50, 'Parrillas Personales', 900, 0, 'IMG_PAR019'),


/* =========================================================
   PIQUEOS
   ========================================================= */
('PIQ001', 'PIQUEO EL OLIVAR', 'PIQUEO EL OLIVAR',
 'Cuatro palitos de anticucho, cuatro brochetas de pollo, 250 gr de mollejitas y cuatro chicharrones de pollo acompanados de cremas.',
 42.00, 'Piqueos', 1500, 0, 'IMG_PIQ001'),

('PIQ002', 'CHICHARRON DE POLLO', 'CHICHARRON DE POLLO',
 'Seis piezas de chicharron de pollo con papas fritas o sancochadas, ensalada fresca y salsas de la casa.',
 27.00, 'Piqueos', 1200, 0, 'IMG_PIQ002'),


/* =========================================================
   PARRILLAS FAMILIARES
   ========================================================= */
('FAM001', 'PARRILLA FAMILIAR', 'PARRILLA FAMILIAR',
 'Parrilla familiar con pollo a la brasa, bife, chuleta, filete de pierna, anticuchos, chorizos, mollejitas, papas fritas, ensalada y gaseosa de 1.5 litros.',
 115.00, 'Parrillas Familiares', 2100, 0, 'IMG_FAM001'),

('FAM002', 'PARRILLA PARA DOS', 'PARRILLA PARA DOS',
 'Parrilla para dos con pollo a la brasa, churrasco, anticucho, chorizo, filete de pierna, mollejitas, papas fritas, ensalada y gaseosa personal.',
 89.00, 'Parrillas Familiares', 1800, 0, 'IMG_FAM002');


/* =========================================================
   VALIDAR QUE EXISTAN LAS CATEGORIAS
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Productos p
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.CategoriaProducto c
        WHERE c.nombre = p.categoria_nombre
    )
)
BEGIN
    SELECT DISTINCT p.categoria_nombre AS categoria_faltante
    FROM @Productos p
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.CategoriaProducto c
        WHERE c.nombre = p.categoria_nombre
    );

    THROW 52004, 'Hay categorias faltantes. Revisa el resultado anterior.', 1;
END;


/* =========================================================
   ACTUALIZAR PRODUCTOS EXISTENTES
   ========================================================= */
UPDATE prod
SET
    prod.nombre = p.nombre,
    prod.nombre_corto = p.nombre_corto,
    prod.descripcion = p.descripcion,
    prod.precio_base = p.precio_base,
    prod.id_categoria = c.id_categoria,
    prod.tiempo_preparacion_segundos = p.tiempo_preparacion_segundos,
    prod.activo = 1,
    prod.requiere_nota_alergia = p.requiere_nota_alergia,
    prod.imagen_principal_url =
        CASE
            WHEN @SobrescribirImagenes = 1
              OR prod.imagen_principal_url IS NULL
              OR prod.imagen_principal_url LIKE '%IMG_%'
              OR prod.imagen_principal_url LIKE '%REEMPLAZAR%'
            THEN @DriveBase + p.imagen_drive_id
            ELSE prod.imagen_principal_url
        END
FROM dbo.Producto prod
INNER JOIN @Productos p
    ON p.codigo = prod.codigo
INNER JOIN dbo.CategoriaProducto c
    ON c.nombre = p.categoria_nombre;


/* =========================================================
   INSERTAR PRODUCTOS NUEVOS
   ========================================================= */
INSERT INTO dbo.Producto
    (codigo, nombre, nombre_corto, descripcion, precio_base, id_categoria,
     tiempo_preparacion_segundos, activo, requiere_nota_alergia, imagen_principal_url)
SELECT
    p.codigo,
    p.nombre,
    p.nombre_corto,
    p.descripcion,
    p.precio_base,
    c.id_categoria,
    p.tiempo_preparacion_segundos,
    1,
    p.requiere_nota_alergia,
    @DriveBase + p.imagen_drive_id
FROM @Productos p
INNER JOIN dbo.CategoriaProducto c
    ON c.nombre = p.categoria_nombre
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Producto prod
    WHERE prod.codigo = p.codigo
);


/* =========================================================
   ACTUALIZAR IMAGEN PRINCIPAL EXISTENTE
   ========================================================= */
UPDATE pi
SET
    pi.url_imagen = prod.imagen_principal_url,
    pi.texto_alt = prod.nombre,
    pi.orden_visual = 1,
    pi.activo = 1
FROM dbo.ProductoImagen pi
INNER JOIN dbo.Producto prod
    ON prod.id_producto = pi.id_producto
INNER JOIN @Productos p
    ON p.codigo = prod.codigo
WHERE pi.es_principal = 1
  AND pi.activo = 1
  AND prod.imagen_principal_url IS NOT NULL
  AND (
        @SobrescribirImagenes = 1
        OR pi.url_imagen LIKE '%IMG_%'
        OR pi.url_imagen LIKE '%REEMPLAZAR%'
      );


/* =========================================================
   INSERTAR IMAGEN PRINCIPAL SI NO EXISTE
   ========================================================= */
INSERT INTO dbo.ProductoImagen
    (id_producto, url_imagen, texto_alt, es_principal, orden_visual, activo)
SELECT
    prod.id_producto,
    prod.imagen_principal_url,
    prod.nombre,
    1,
    1,
    1
FROM dbo.Producto prod
INNER JOIN @Productos p
    ON p.codigo = prod.codigo
WHERE prod.imagen_principal_url IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.ProductoImagen pi
      WHERE pi.id_producto = prod.id_producto
        AND pi.es_principal = 1
        AND pi.activo = 1
  );


COMMIT TRANSACTION;

PRINT 'BLOQUE 3B cargado correctamente: fusiones, parrillas, piqueos y familiares.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 3B';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
