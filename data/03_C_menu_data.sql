USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 3C - PRODUCTOS BASE
   Wok, pastas, chaufa, complementos, postres, menu y bebidas
   Ejecutar despues del BLOQUE 3B
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

DECLARE @DriveBase VARCHAR(200) = 'https://drive.google.com/uc?export=view&id=';
DECLARE @SobrescribirImagenes BIT = 0;

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
/* WOK CRIOLLO */
('WOK001', 'SOPA DE DIETA', 'SOPA DE DIETA',
 'Sopa con pierna de pollo, zapallo, zanahoria, papa amarilla y cabello de angel.',
 14.50, 'Wok Criollo', 900, 0, 'IMG_WOK001'),

('WOK002', 'SUSTANCIA DE CARNE', 'SUSTANCIA DE CARNE',
 'Sustancia con carne, papa amarilla, cabello de angel y tomate.',
 16.00, 'Wok Criollo', 900, 0, 'IMG_WOK002'),

('WOK003', 'LOMO SALTADO', 'LOMO SALTADO',
 'Lomo saltado de carne acompanado con papas fritas, arroz y cremas de la casa.',
 24.50, 'Wok Criollo', 900, 0, 'IMG_WOK003'),

('WOK004', 'POLLO SALTADO', 'POLLO SALTADO',
 'Pollo saltado acompanado con papas fritas, arroz y cremas de la casa.',
 22.50, 'Wok Criollo', 900, 0, 'IMG_WOK004'),

('WOK005', 'TALLARIN SALTADO DE POLLO', 'TALLARIN SALTADO POLLO',
 'Tallarin saltado con pollo y cremas de la casa.',
 22.50, 'Wok Criollo', 900, 0, 'IMG_WOK005'),

('WOK006', 'TALLARIN SALTADO DE CARNE', 'TALLARIN SALTADO CARNE',
 'Tallarin saltado con carne y cremas de la casa.',
 24.50, 'Wok Criollo', 900, 0, 'IMG_WOK006'),

/* PASTAS */
('PAS001', 'FETUCCINI AL PESTO', 'FETUCCINI AL PESTO',
 'Fetuccini con salsa al pesto y complemento a eleccion.',
 25.50, 'Pastas', 900, 0, 'IMG_PAS001'),

('PAS002', 'FETUCCINI A LA HUANCAINA', 'FETUCCINI HUANCAINA',
 'Fetuccini con salsa a la huancaina y complemento a eleccion.',
 26.00, 'Pastas', 900, 0, 'IMG_PAS002'),

('PAS003', 'FETUCCINI A LO ALFREDO', 'FETUCCINI ALFREDO',
 'Fetuccini con salsa Alfredo y complemento a eleccion.',
 28.50, 'Pastas', 900, 0, 'IMG_PAS003'),

/* CHAUFA */
('CHA001', 'CHAUFA DE POLLO', 'CHAUFA DE POLLO',
 'Arroz chaufa de pollo acompanado con cremas de la casa.',
 19.50, 'Chaufa', 900, 0, 'IMG_CHA001'),

('CHA002', 'AEROPUERTO', 'AEROPUERTO',
 'Combinacion de arroz chaufa y tallarin chino con pollo, wantan y cremas de la casa.',
 21.00, 'Chaufa', 900, 0, 'IMG_CHA002'),

('CHA003', 'CHAUFA A LO POBRE', 'CHAUFA A LO POBRE',
 'Chaufa de pollo acompanado de platano frito, huevo frito y cremas de la casa.',
 23.00, 'Chaufa', 900, 0, 'IMG_CHA003'),

('CHA004', 'MOSTRO OLIVAR', 'MOSTRO OLIVAR',
 'Chaufa acompanado de 1/4 de pollo a la brasa, papas fritas, ensalada fresca y cremas.',
 25.00, 'Chaufa', 1000, 0, 'IMG_CHA004'),

('CHA005', 'CHAUFA ESPECIAL', 'CHAUFA ESPECIAL',
 'Chaufa especial con pollo, langostinos, cecina y cremas de la casa.',
 25.00, 'Chaufa', 1000, 0, 'IMG_CHA005'),

/* COMPLEMENTOS */
('COM001', 'PAPAS FRITAS', 'PAPAS FRITAS',
 'Porcion de papas fritas.',
 12.00, 'Complementos', 420, 0, 'IMG_COM001'),

('COM002', 'PAPAS DORADAS', 'PAPAS DORADAS',
 'Porcion de papas doradas.',
 7.00, 'Complementos', 420, 0, 'IMG_COM002'),

('COM003', 'PAPAS SANCOCHADAS', 'PAPAS SANCOCHADAS',
 'Porcion de papas sancochadas.',
 6.50, 'Complementos', 420, 0, 'IMG_COM003'),

('COM004', 'PAPAS HUAYRO', 'PAPAS HUAYRO',
 'Porcion de papas huayro.',
 8.00, 'Complementos', 420, 0, 'IMG_COM004'),

('COM005', 'ARROZ BLANCO', 'ARROZ BLANCO',
 'Porcion de arroz blanco.',
 4.50, 'Complementos', 300, 0, 'IMG_COM005'),

('COM006', 'QUESO PASTEURIZADO', 'QUESO PASTEURIZADO',
 'Porcion de queso pasteurizado.',
 8.50, 'Complementos', 300, 0, 'IMG_COM006'),

('COM007', '1 CHORIZO A LA PARRILLA', 'CHORIZO A LA PARRILLA',
 'Un chorizo a la parrilla.',
 8.50, 'Complementos', 480, 0, 'IMG_COM007'),

('COM008', 'A LO POBRE', 'A LO POBRE',
 'Complemento con huevo frito y platano frito.',
 7.00, 'Complementos', 480, 0, 'IMG_COM008'),

/* POSTRES */
('POS001', 'CREMA VOLTEADA', 'CREMA VOLTEADA',
 'Postre crema volteada.',
 8.00, 'Postres', 300, 0, 'IMG_POS001'),

('POS002', 'TRES LECHES DE VAINILLA', 'TRES LECHES VAINILLA',
 'Postre tres leches de vainilla.',
 9.00, 'Postres', 300, 0, 'IMG_POS002'),

('POS003', 'TORTA DE CHOCOLATE', 'TORTA CHOCOLATE',
 'Porcion de torta de chocolate.',
 9.00, 'Postres', 300, 0, 'IMG_POS003'),

('POS004', 'SELVA NEGRA', 'SELVA NEGRA',
 'Porcion de selva negra.',
 9.00, 'Postres', 300, 0, 'IMG_POS004'),

('POS005', 'CHEESECAKE FRESA O MARACUYA', 'CHEESECAKE',
 'Cheesecake de fresa o maracuya.',
 9.00, 'Postres', 300, 0, 'IMG_POS005'),

/* MENU EL OLIVAR */
('MNU001', '1/4 DE POLLO A LA BRASA MENU', '1/4 POLLO MENU',
 '1/4 de pollo a la brasa acompanado de arroz, papas fritas y ensalada fresca.',
 21.00, 'Menu El Olivar', 900, 0, 'IMG_MNU001'),

('MNU002', 'MOLLEJITAS A LA BRASA MENU', 'MOLLEJITAS MENU',
 'Mollejitas a la parrilla acompanadas de arroz, papas fritas y ensalada fresca.',
 21.00, 'Menu El Olivar', 900, 0, 'IMG_MNU002'),

('MNU003', 'ANTICUCHOS DE CORAZON MENU', 'ANTICUCHOS MENU',
 'Anticuchos de corazon acompanados de arroz, papas fritas y ensalada fresca.',
 22.00, 'Menu El Olivar', 900, 0, 'IMG_MNU003'),

('MNU004', 'CHULETA PREMIUM MENU', 'CHULETA MENU',
 'Chuleta a la parrilla acompanada de arroz, papas fritas y ensalada fresca.',
 22.50, 'Menu El Olivar', 900, 0, 'IMG_MNU004'),

('MNU005', 'CHICHARRON DE POLLO MENU', 'CHICHARRON MENU',
 'Chicharron de pollo acompanado de arroz, papas fritas y ensalada fresca.',
 22.50, 'Menu El Olivar', 900, 0, 'IMG_MNU005'),

('MNU006', 'POLLO EL OLIVAR MENU', 'POLLO OLIVAR MENU',
 'Pechuga o pierna a la parrilla acompanada de arroz, papas fritas y ensalada fresca.',
 22.50, 'Menu El Olivar', 900, 0, 'IMG_MNU006'),

/* BEBIDAS CALIENTES */
('INF001', 'INFUSIONES', 'INFUSIONES',
 'Te, anis, manzanilla o hierba luisa.',
 3.50, 'Bebidas Calientes', 180, 0, 'IMG_INF001'),

/* BEBIDAS */
('BEB001', 'AGUA MINERAL', 'AGUA MINERAL',
 'Agua mineral personal.',
 4.00, 'Bebidas', 60, 0, 'IMG_BEB001'),

('BEB002', 'REFRESCANTES', 'REFRESCANTES',
 'Refrescantes de maracuya, fresa o frutos rojos.',
 9.90, 'Bebidas', 180, 0, 'IMG_BEB002'),

('BEB003', 'VASO DE LIMONADA FROZEN 500ML', 'LIMONADA FROZEN 500ML',
 'Vaso de limonada frozen de 500 ml.',
 11.00, 'Bebidas', 180, 0, 'IMG_BEB003'),

('BEB004', 'ICE TEA FRUTOS ROJOS', 'ICE TEA FRUTOS ROJOS',
 'Ice tea de frutos rojos.',
 9.90, 'Bebidas', 180, 0, 'IMG_BEB004'),

('BEB005', 'GASEOSA DE 1 LITRO', 'GASEOSA 1 LITRO',
 'Gaseosa de 1 litro.',
 10.00, 'Bebidas', 60, 0, 'IMG_BEB005'),

('BEB006', 'ALOE VERA 500ML', 'ALOE VERA 500ML',
 'Bebida Aloe Vera de 500 ml.',
 8.00, 'Bebidas', 60, 0, 'IMG_BEB006'),

('BEB007', 'GASEOSA DE 1.5 LT', 'GASEOSA 1.5 LT',
 'Gaseosa de 1.5 litros.',
 13.00, 'Bebidas', 60, 0, 'IMG_BEB007'),

('BEB008', 'JARRA DE LIMONADA DE 1 LITRO', 'JARRA LIMONADA 1L',
 'Jarra de limonada de 1 litro.',
 16.00, 'Bebidas', 240, 0, 'IMG_BEB008'),

('BEB009', 'JARRA DE MARACUYA DE 1 LITRO', 'JARRA MARACUYA 1L',
 'Jarra de maracuya de 1 litro.',
 18.00, 'Bebidas', 240, 0, 'IMG_BEB009'),

('BEB010', 'JARRA DE LIMONADA FROZEN', 'JARRA LIMONADA FROZEN',
 'Jarra de limonada frozen.',
 19.00, 'Bebidas', 240, 0, 'IMG_BEB010'),

('BEB011', 'JARRA DE CHICHA MORADA DE 1 LITRO', 'JARRA CHICHA 1L',
 'Jarra de chicha morada de 1 litro.',
 18.00, 'Bebidas', 240, 0, 'IMG_BEB011'),

('BEB012', 'ALOE VERA DE 1.5 LT', 'ALOE VERA 1.5 LT',
 'Bebida Aloe Vera de 1.5 litros.',
 16.00, 'Bebidas', 60, 0, 'IMG_BEB012'),

('BEB013', 'JARRA DE LIMONADA FROZEN BLUE RED GREEN', 'FROZEN BLUE RED GREEN',
 'Jarra de limonada frozen en presentaciones Blue, Red o Green.',
 19.00, 'Bebidas', 240, 0, 'IMG_BEB013'),

('BEB014', 'GASEOSA MEDIANA COCA COLA O INCA KOLA', 'GASEOSA MEDIANA',
 'Gaseosa mediana Coca Cola o Inca Kola.',
 4.00, 'Bebidas', 60, 0, 'IMG_BEB014'),

('BEB015', 'GASEOSA 600ML DESCARTABLE', 'GASEOSA 600ML',
 'Gaseosa descartable de 600 ml.',
 5.00, 'Bebidas', 60, 0, 'IMG_BEB015'),

('BEB016', 'GORDITA INCA KOLA', 'GORDITA INCA KOLA',
 'Gaseosa Inca Kola gordita.',
 6.00, 'Bebidas', 60, 0, 'IMG_BEB016'),

('BEB017', 'VASO DE LIMONADA', 'VASO LIMONADA',
 'Vaso de limonada.',
 4.00, 'Bebidas', 120, 0, 'IMG_BEB017'),

('BEB018', 'VASO DE CHICHA MORADA', 'VASO CHICHA MORADA',
 'Vaso de chicha morada.',
 5.00, 'Bebidas', 120, 0, 'IMG_BEB018');


/* Validar categorias */
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

    THROW 53001, 'Hay categorias faltantes. Revisa el resultado anterior.', 1;
END;


/* Actualizar productos existentes */
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


/* Insertar productos nuevos */
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


/* Actualizar imagen principal existente */
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


/* Insertar imagen principal si no existe */
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

PRINT 'BLOQUE 3C cargado correctamente.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 3C';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
