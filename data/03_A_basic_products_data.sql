USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 3A - PRODUCTOS BASE
   Entradas, ensaladas, brasa y ofertas
   Ejecutar despues del BLOQUE 2
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
    THROW 51000, 'No existe la tabla Producto.', 1;
END;

IF OBJECT_ID(N'dbo.ProductoImagen', N'U') IS NULL
BEGIN
    THROW 51001, 'No existe la tabla ProductoImagen. Ejecuta primero el script de mejora.', 1;
END;

IF COL_LENGTH('dbo.Producto', 'imagen_principal_url') IS NULL
BEGIN
    THROW 51002, 'Falta la columna Producto.imagen_principal_url. Ejecuta primero el script de mejora.', 1;
END;

IF COL_LENGTH('dbo.Producto', 'nombre_corto') IS NULL
BEGIN
    THROW 51003, 'Falta la columna Producto.nombre_corto. Ejecuta primero el script de mejora.', 1;
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
   ENTRADAS
   ========================================================= */
('ENT001', 'PORCION DE CHOCLO', 'PORCION DE CHOCLO',
 'Choclo sancochado con cremas de la casa.',
 6.50, 'Entradas', 420, 0, 'IMG_ENT001'),

('ENT002', 'PLATANO A LA PARRILLA', 'PLATANO A LA PARRILLA',
 'Un delicioso platano a la parrilla.',
 4.50, 'Entradas', 420, 0, 'IMG_ENT002'),

('ENT003', 'YUCAS DORADAS', 'YUCAS DORADAS',
 '6 trozos de deliciosas yucas sancochadas con cremas de la casa.',
 8.00, 'Entradas', 480, 0, 'IMG_ENT003'),

('ENT004', 'SALCHIPAPAS', 'SALCHIPAPAS',
 'Deliciosas papas fritas con salchichas Frankfurt, huevo frito y ensalada.',
 15.50, 'Entradas', 600, 0, 'IMG_ENT004'),

('ENT005', 'CORAZON', 'CORAZON',
 '4 palitos de anticuchos mas 2 rodajas de choclo.',
 14.50, 'Entradas', 600, 0, 'IMG_ENT005'),

('ENT006', 'MOLLEJITAS', 'MOLLEJITAS',
 '250 gramos de mollejitas mas 2 rodajas de choclo.',
 14.00, 'Entradas', 600, 0, 'IMG_ENT006'),


/* =========================================================
   ENSALADAS
   ========================================================= */
('ENS001', 'LA FRESCA', 'LA FRESCA',
 'Cama de lechuga, tomate, pepino, zanahoria y vinagreta de la casa.',
 8.50, 'Ensaladas', 360, 0, 'IMG_ENS001'),

('ENS002', 'LA COCIDA', 'LA COCIDA',
 'Legumbres sancochadas con vainita, zanahoria y beterraga, coronadas con palta y vinagreta de la casa.',
 10.50, 'Ensaladas', 420, 0, 'IMG_ENS002'),

('ENS003', 'ENSALADAS EL OLIVAR', 'ENSALADAS EL OLIVAR',
 'Cama de lechuga, tomate, espinaca y zanahoria, coronada con palta, choclo y queso fresco.',
 15.00, 'Ensaladas', 480, 0, 'IMG_ENS003'),

('ENS004', 'ENSALADA DE PALTA', 'ENSALADA DE PALTA',
 'Deliciosa ensalada de palta cremosa acompanada de granos de choclo.',
 12.00, 'Ensaladas', 420, 0, 'IMG_ENS004'),


/* =========================================================
   OLIVAR BRASA
   ========================================================= */
('BRA001', '1/4 DE POLLO A LA BRASA', '1/4 DE POLLO A LA BRASA',
 'Jugoso pollo a la brasa acompanado de papas fritas o sancochadas, ensalada fresca o cocida y salsas de la casa.',
 21.50, 'Olivar Brasa', 900, 0, 'IMG_BRA001'),

('BRA002', 'HUAYRITO EL OLIVAR', 'HUAYRITO EL OLIVAR',
 'Pollo a la brasa acompanado de papas huayro, ensalada fresca, media porcion de choclo y salsas de la casa.',
 26.00, 'Olivar Brasa', 900, 0, 'IMG_BRA002'),

('BRA003', '1/2 POLLO A LA BRASA', '1/2 POLLO A LA BRASA',
 'Medio pollo a la brasa acompanado de papas fritas o sancochadas, ensalada fresca o cocida y salsas de la casa.',
 39.50, 'Olivar Brasa', 1200, 0, 'IMG_BRA003'),

('BRA004', 'POLLO ENTERO A LA BRASA', 'POLLO ENTERO A LA BRASA',
 'Pollo entero a la brasa acompanado de papas fritas o sancochadas, ensalada fresca y salsas de la casa.',
 67.00, 'Olivar Brasa', 1500, 0, 'IMG_BRA004'),


/* =========================================================
   OFERTAS EN POLLO A LA BRASA
   ========================================================= */
('OFE001', 'POLLO A LA BRASA PARA DOS', 'POLLO A LA BRASA PARA DOS',
 '1/2 pollo a la brasa acompanado de papas fritas, ensalada fresca o cocida y media jarra de limonada o una Inca Kola gordita.',
 44.00, 'Ofertas en Pollo a la Brasa', 1500, 0, 'IMG_OFE001'),

('OFE002', 'OFERTON', 'OFERTON',
 '1 pollo a la brasa acompanado de papas fritas, ensalada fresca o cocida y jarra de limonada o gaseosa de 1.5 litros.',
 73.00, 'Ofertas en Pollo a la Brasa', 1800, 0, 'IMG_OFE002'),

('OFE003', 'SUPER OFERTON EL OLIVAR', 'SUPER OFERTON',
 '1 pollo a la brasa mas 1/4 de pollo pierna, papas fritas, ensalada fresca o cocida y jarra de limonada o gaseosa de 1.5 litros.',
 79.00, 'Ofertas en Pollo a la Brasa', 1800, 0, 'IMG_OFE003'),

('OFE004', 'MEGA OFERTON', 'MEGA OFERTON',
 '1 pollo a la brasa mas 1/4 de pollo pierna, 2 porciones de arroz chaufa, papas fritas, ensalada fresca o cocida y jarra de limonada o gaseosa de 1.5 litros.',
 109.00, 'Ofertas en Pollo a la Brasa', 2100, 0, 'IMG_OFE004');


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

    THROW 51004, 'Hay categorias faltantes. Revisa el resultado anterior.', 1;
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

PRINT 'BLOQUE 3A cargado correctamente: productos base e imagenes principales.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 3A';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
