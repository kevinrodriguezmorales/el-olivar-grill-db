USE BDOlivarGrill;
GO

/* =========================================================
   MIGRACION: mejoras para carta digital / menu / sucursales
   Base: BDOlivarGrill_.sql
   Motor: SQL Server

   Incluye:
   1) Sucursal
   2) Imagen principal y galeria de imagenes de producto
   3) ProductoVariante y ProductoVarianteOpcion
   4) Menu
   5) MenuProducto
   6) Mejora de ProductoModificador: min/max de opciones
   7) Relaciones utiles con Pedido, Mesa, Caja y DetallePedido
   ========================================================= */

/* =========================================================
   1. SUCURSAL
   ========================================================= */
IF OBJECT_ID(N'dbo.Sucursal', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sucursal (
        id_sucursal       INT IDENTITY(1,1) NOT NULL,
        codigo            VARCHAR(10) NOT NULL,
        nombre            VARCHAR(100) NOT NULL,
        direccion         VARCHAR(200) NOT NULL,
        distrito          VARCHAR(60) NULL,
        provincia         VARCHAR(60) NULL,
        departamento      VARCHAR(60) NULL,
        telefono          VARCHAR(20) NULL,
        referencia        VARCHAR(200) NULL,
        activo            BIT NOT NULL CONSTRAINT DF_Sucursal_activo DEFAULT (1),
        fecha_registro    DATETIME2(0) NOT NULL CONSTRAINT DF_Sucursal_fecha_registro DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_Sucursal PRIMARY KEY (id_sucursal),
        CONSTRAINT UQ_Sucursal_codigo UNIQUE (codigo)
    );
END;
GO

/* Relacionar sucursal con mesas, cajas y pedidos sin romper datos existentes. */
IF COL_LENGTH('dbo.Mesa', 'id_sucursal') IS NULL
BEGIN
    ALTER TABLE dbo.Mesa ADD id_sucursal INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Mesa_Sucursal')
BEGIN
    ALTER TABLE dbo.Mesa WITH CHECK
    ADD CONSTRAINT FK_Mesa_Sucursal
        FOREIGN KEY (id_sucursal) REFERENCES dbo.Sucursal(id_sucursal);
END;
GO

IF COL_LENGTH('dbo.Caja', 'id_sucursal') IS NULL
BEGIN
    ALTER TABLE dbo.Caja ADD id_sucursal INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Caja_Sucursal')
BEGIN
    ALTER TABLE dbo.Caja WITH CHECK
    ADD CONSTRAINT FK_Caja_Sucursal
        FOREIGN KEY (id_sucursal) REFERENCES dbo.Sucursal(id_sucursal);
END;
GO

IF COL_LENGTH('dbo.Pedido', 'id_sucursal') IS NULL
BEGIN
    ALTER TABLE dbo.Pedido ADD id_sucursal INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Pedido_Sucursal')
BEGIN
    ALTER TABLE dbo.Pedido WITH CHECK
    ADD CONSTRAINT FK_Pedido_Sucursal
        FOREIGN KEY (id_sucursal) REFERENCES dbo.Sucursal(id_sucursal);
END;
GO

/* =========================================================
   2. IMAGENES DE PRODUCTO
   ========================================================= */
IF COL_LENGTH('dbo.Producto', 'imagen_principal_url') IS NULL
BEGIN
    ALTER TABLE dbo.Producto ADD imagen_principal_url VARCHAR(300) NULL;
END;
GO

IF COL_LENGTH('dbo.Producto', 'nombre_corto') IS NULL
BEGIN
    ALTER TABLE dbo.Producto ADD nombre_corto VARCHAR(60) NULL;
END;
GO

IF OBJECT_ID(N'dbo.ProductoImagen', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductoImagen (
        id_producto_imagen   INT IDENTITY(1,1) NOT NULL,
        id_producto          INT NOT NULL,
        url_imagen           VARCHAR(300) NOT NULL,
        texto_alt            VARCHAR(150) NULL,
        es_principal         BIT NOT NULL CONSTRAINT DF_ProductoImagen_es_principal DEFAULT (0),
        orden_visual         INT NOT NULL CONSTRAINT DF_ProductoImagen_orden_visual DEFAULT (1),
        activo               BIT NOT NULL CONSTRAINT DF_ProductoImagen_activo DEFAULT (1),
        fecha_registro       DATETIME2(0) NOT NULL CONSTRAINT DF_ProductoImagen_fecha_registro DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_ProductoImagen PRIMARY KEY (id_producto_imagen),
        CONSTRAINT FK_ProductoImagen_Producto
            FOREIGN KEY (id_producto) REFERENCES dbo.Producto(id_producto)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ProductoImagen_Producto' AND object_id = OBJECT_ID(N'dbo.ProductoImagen'))
BEGIN
    CREATE INDEX IX_ProductoImagen_Producto ON dbo.ProductoImagen(id_producto);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ProductoImagen_PrincipalActiva' AND object_id = OBJECT_ID(N'dbo.ProductoImagen'))
BEGIN
    CREATE UNIQUE INDEX UX_ProductoImagen_PrincipalActiva
    ON dbo.ProductoImagen(id_producto)
    WHERE es_principal = 1 AND activo = 1;
END;
GO

/* =========================================================
   3. VARIANTES Y PRECIOS POR COMBINACION

   Caso de uso:
   Producto base: Fettuccini al pesto
   Variante: Fettuccini al pesto + lomo
   Opciones asociadas: salsa = pesto, complemento = lomo
   Precio: precio final de esa combinacion
   ========================================================= */
IF OBJECT_ID(N'dbo.ProductoVariante', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductoVariante (
        id_variante          INT IDENTITY(1,1) NOT NULL,
        id_producto          INT NOT NULL,
        codigo_variante      VARCHAR(20) NULL,
        nombre_variante      VARCHAR(120) NOT NULL,
        descripcion          VARCHAR(MAX) NULL,
        precio               DECIMAL(10,2) NOT NULL,
        es_precio_final      BIT NOT NULL CONSTRAINT DF_ProductoVariante_es_precio_final DEFAULT (1),
        imagen_url           VARCHAR(300) NULL,
        orden_visual         INT NOT NULL CONSTRAINT DF_ProductoVariante_orden_visual DEFAULT (1),
        activo               BIT NOT NULL CONSTRAINT DF_ProductoVariante_activo DEFAULT (1),
        fecha_registro       DATETIME2(0) NOT NULL CONSTRAINT DF_ProductoVariante_fecha_registro DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_ProductoVariante PRIMARY KEY (id_variante),
        CONSTRAINT FK_ProductoVariante_Producto
            FOREIGN KEY (id_producto) REFERENCES dbo.Producto(id_producto),
        CONSTRAINT CK_ProductoVariante_precio CHECK (precio >= 0)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ProductoVariante_Producto' AND object_id = OBJECT_ID(N'dbo.ProductoVariante'))
BEGIN
    CREATE INDEX IX_ProductoVariante_Producto ON dbo.ProductoVariante(id_producto);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ProductoVariante_Codigo' AND object_id = OBJECT_ID(N'dbo.ProductoVariante'))
BEGIN
    CREATE UNIQUE INDEX UX_ProductoVariante_Codigo
    ON dbo.ProductoVariante(id_producto, codigo_variante)
    WHERE codigo_variante IS NOT NULL;
END;
GO

/* Indice unico auxiliar para validar que una opcion pertenece al modificador indicado. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_OpcionModificador_ModificadorOpcion' AND object_id = OBJECT_ID(N'dbo.OpcionModificador'))
BEGIN
    CREATE UNIQUE INDEX UX_OpcionModificador_ModificadorOpcion
    ON dbo.OpcionModificador(id_modificador, id_opcion);
END;
GO

IF OBJECT_ID(N'dbo.ProductoVarianteOpcion', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductoVarianteOpcion (
        id_variante_opcion   INT IDENTITY(1,1) NOT NULL,
        id_variante          INT NOT NULL,
        id_modificador       INT NOT NULL,
        id_opcion            INT NOT NULL,
        orden                INT NOT NULL CONSTRAINT DF_ProductoVarianteOpcion_orden DEFAULT (1),
        CONSTRAINT PK_ProductoVarianteOpcion PRIMARY KEY (id_variante_opcion),
        CONSTRAINT FK_ProductoVarianteOpcion_Variante
            FOREIGN KEY (id_variante) REFERENCES dbo.ProductoVariante(id_variante),
        CONSTRAINT FK_ProductoVarianteOpcion_Modificador
            FOREIGN KEY (id_modificador) REFERENCES dbo.Modificador(id_modificador),
        CONSTRAINT FK_ProductoVarianteOpcion_OpcionModificador
            FOREIGN KEY (id_modificador, id_opcion)
            REFERENCES dbo.OpcionModificador(id_modificador, id_opcion),
        CONSTRAINT UQ_ProductoVarianteOpcion_VarianteOpcion UNIQUE (id_variante, id_opcion)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ProductoVarianteOpcion_Variante' AND object_id = OBJECT_ID(N'dbo.ProductoVarianteOpcion'))
BEGIN
    CREATE INDEX IX_ProductoVarianteOpcion_Variante ON dbo.ProductoVarianteOpcion(id_variante);
END;
GO

IF COL_LENGTH('dbo.DetallePedido', 'id_variante') IS NULL
BEGIN
    ALTER TABLE dbo.DetallePedido ADD id_variante INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_DetallePedido_ProductoVariante')
BEGIN
    ALTER TABLE dbo.DetallePedido WITH CHECK
    ADD CONSTRAINT FK_DetallePedido_ProductoVariante
        FOREIGN KEY (id_variante) REFERENCES dbo.ProductoVariante(id_variante);
END;
GO

/* =========================================================
   4. MENU
   ========================================================= */
IF OBJECT_ID(N'dbo.Menu', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Menu (
        id_menu          INT IDENTITY(1,1) NOT NULL,
        id_sucursal      INT NULL,
        codigo           VARCHAR(20) NOT NULL,
        nombre           VARCHAR(100) NOT NULL,
        tipo             VARCHAR(30) NOT NULL,
        descripcion      VARCHAR(250) NULL,
        fecha_inicio     DATE NULL,
        fecha_fin        DATE NULL,
        hora_inicio      TIME(0) NULL,
        hora_fin         TIME(0) NULL,
        lunes            BIT NOT NULL CONSTRAINT DF_Menu_lunes DEFAULT (1),
        martes           BIT NOT NULL CONSTRAINT DF_Menu_martes DEFAULT (1),
        miercoles        BIT NOT NULL CONSTRAINT DF_Menu_miercoles DEFAULT (1),
        jueves           BIT NOT NULL CONSTRAINT DF_Menu_jueves DEFAULT (1),
        viernes          BIT NOT NULL CONSTRAINT DF_Menu_viernes DEFAULT (1),
        sabado           BIT NOT NULL CONSTRAINT DF_Menu_sabado DEFAULT (1),
        domingo          BIT NOT NULL CONSTRAINT DF_Menu_domingo DEFAULT (1),
        orden_visual     INT NOT NULL CONSTRAINT DF_Menu_orden_visual DEFAULT (1),
        imagen_url       VARCHAR(300) NULL,
        activo           BIT NOT NULL CONSTRAINT DF_Menu_activo DEFAULT (1),
        fecha_registro   DATETIME2(0) NOT NULL CONSTRAINT DF_Menu_fecha_registro DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_Menu PRIMARY KEY (id_menu),
        CONSTRAINT UQ_Menu_codigo UNIQUE (codigo),
        CONSTRAINT FK_Menu_Sucursal
            FOREIGN KEY (id_sucursal) REFERENCES dbo.Sucursal(id_sucursal),
        CONSTRAINT CK_Menu_tipo CHECK (tipo IN ('CARTA_GENERAL', 'MENU_EJECUTIVO', 'PROMOCION', 'DELIVERY', 'TEMPORADA', 'OTRO')),
        CONSTRAINT CK_Menu_fechas CHECK (fecha_inicio IS NULL OR fecha_fin IS NULL OR fecha_inicio <= fecha_fin),
        CONSTRAINT CK_Menu_horas CHECK (hora_inicio IS NULL OR hora_fin IS NULL OR hora_inicio < hora_fin),
        CONSTRAINT CK_Menu_dias CHECK (lunes = 1 OR martes = 1 OR miercoles = 1 OR jueves = 1 OR viernes = 1 OR sabado = 1 OR domingo = 1)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Menu_Sucursal' AND object_id = OBJECT_ID(N'dbo.Menu'))
BEGIN
    CREATE INDEX IX_Menu_Sucursal ON dbo.Menu(id_sucursal);
END;
GO

/* =========================================================
   5. MENU PRODUCTO

   Permite que el mismo producto tenga:
   - precio distinto por menu
   - orden visual distinto por menu
   - imagen o etiqueta distinta por menu
   - una variante especifica dentro de un menu
   ========================================================= */
IF OBJECT_ID(N'dbo.MenuProducto', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MenuProducto (
        id_menu_producto   INT IDENTITY(1,1) NOT NULL,
        id_menu            INT NOT NULL,
        id_producto        INT NOT NULL,
        id_variante        INT NULL,
        precio_menu        DECIMAL(10,2) NULL,
        usa_precio_base    BIT NOT NULL CONSTRAINT DF_MenuProducto_usa_precio_base DEFAULT (1),
        etiqueta           VARCHAR(50) NULL,
        destacado          BIT NOT NULL CONSTRAINT DF_MenuProducto_destacado DEFAULT (0),
        orden_visual       INT NOT NULL CONSTRAINT DF_MenuProducto_orden_visual DEFAULT (1),
        imagen_url         VARCHAR(300) NULL,
        visible            BIT NOT NULL CONSTRAINT DF_MenuProducto_visible DEFAULT (1),
        activo             BIT NOT NULL CONSTRAINT DF_MenuProducto_activo DEFAULT (1),
        fecha_registro     DATETIME2(0) NOT NULL CONSTRAINT DF_MenuProducto_fecha_registro DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_MenuProducto PRIMARY KEY (id_menu_producto),
        CONSTRAINT FK_MenuProducto_Menu
            FOREIGN KEY (id_menu) REFERENCES dbo.Menu(id_menu),
        CONSTRAINT FK_MenuProducto_Producto
            FOREIGN KEY (id_producto) REFERENCES dbo.Producto(id_producto),
        CONSTRAINT FK_MenuProducto_ProductoVariante
            FOREIGN KEY (id_variante) REFERENCES dbo.ProductoVariante(id_variante),
        CONSTRAINT CK_MenuProducto_precio CHECK (precio_menu IS NULL OR precio_menu >= 0),
        CONSTRAINT CK_MenuProducto_precio_base CHECK (
            (usa_precio_base = 1 AND precio_menu IS NULL)
            OR (usa_precio_base = 0 AND precio_menu IS NOT NULL)
        )
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_MenuProducto_Menu' AND object_id = OBJECT_ID(N'dbo.MenuProducto'))
BEGIN
    CREATE INDEX IX_MenuProducto_Menu ON dbo.MenuProducto(id_menu, orden_visual);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_MenuProducto_Producto' AND object_id = OBJECT_ID(N'dbo.MenuProducto'))
BEGIN
    CREATE INDEX IX_MenuProducto_Producto ON dbo.MenuProducto(id_producto);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_MenuProducto_SinVariante' AND object_id = OBJECT_ID(N'dbo.MenuProducto'))
BEGIN
    CREATE UNIQUE INDEX UX_MenuProducto_SinVariante
    ON dbo.MenuProducto(id_menu, id_producto)
    WHERE id_variante IS NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_MenuProducto_ConVariante' AND object_id = OBJECT_ID(N'dbo.MenuProducto'))
BEGIN
    CREATE UNIQUE INDEX UX_MenuProducto_ConVariante
    ON dbo.MenuProducto(id_menu, id_producto, id_variante)
    WHERE id_variante IS NOT NULL;
END;
GO

IF COL_LENGTH('dbo.DetallePedido', 'id_menu_producto') IS NULL
BEGIN
    ALTER TABLE dbo.DetallePedido ADD id_menu_producto INT NULL;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_DetallePedido_MenuProducto')
BEGIN
    ALTER TABLE dbo.DetallePedido WITH CHECK
    ADD CONSTRAINT FK_DetallePedido_MenuProducto
        FOREIGN KEY (id_menu_producto) REFERENCES dbo.MenuProducto(id_menu_producto);
END;
GO

/* =========================================================
   6. MEJORA DE PRODUCTO MODIFICADOR

   Antes: solo se podia decir si era obligatorio.
   Ahora: se puede controlar cuantas opciones debe/elegir el cliente.
   ========================================================= */
IF COL_LENGTH('dbo.ProductoModificador', 'min_selecciones') IS NULL
BEGIN
    ALTER TABLE dbo.ProductoModificador
    ADD min_selecciones INT NOT NULL
        CONSTRAINT DF_ProductoModificador_min_selecciones DEFAULT (0);
END;
GO

IF COL_LENGTH('dbo.ProductoModificador', 'max_selecciones') IS NULL
BEGIN
    ALTER TABLE dbo.ProductoModificador
    ADD max_selecciones INT NOT NULL
        CONSTRAINT DF_ProductoModificador_max_selecciones DEFAULT (1);
END;
GO

IF COL_LENGTH('dbo.ProductoModificador', 'permite_repetir_opcion') IS NULL
BEGIN
    ALTER TABLE dbo.ProductoModificador
    ADD permite_repetir_opcion BIT NOT NULL
        CONSTRAINT DF_ProductoModificador_permite_repetir DEFAULT (0);
END;
GO

IF COL_LENGTH('dbo.ProductoModificador', 'texto_guia') IS NULL
BEGIN
    ALTER TABLE dbo.ProductoModificador ADD texto_guia VARCHAR(150) NULL;
END;
GO

/* Ajuste inicial para que las filas obligatorias existentes no violen la nueva regla. */
UPDATE dbo.ProductoModificador
SET min_selecciones = 1
WHERE es_obligatorio = 1
  AND min_selecciones = 0;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_ProductoModificador_RangoSelecciones')
BEGIN
    ALTER TABLE dbo.ProductoModificador WITH CHECK
    ADD CONSTRAINT CK_ProductoModificador_RangoSelecciones
    CHECK (min_selecciones >= 0 AND max_selecciones >= min_selecciones);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_ProductoModificador_ObligatorioMinimo')
BEGIN
    ALTER TABLE dbo.ProductoModificador WITH CHECK
    ADD CONSTRAINT CK_ProductoModificador_ObligatorioMinimo
    CHECK (es_obligatorio = 0 OR min_selecciones >= 1);
END;
GO

/* =========================================================
   7. SEMILLAS OPCIONALES BASICAS
   Puede dejarlas, modificarlas o eliminarlas.
   ========================================================= */
DECLARE @id_sucursal_pp INT;

IF NOT EXISTS (SELECT 1 FROM dbo.Sucursal WHERE codigo = 'PP01')
BEGIN
    INSERT INTO dbo.Sucursal
        (codigo, nombre, direccion, distrito, provincia, departamento, referencia, activo)
    VALUES
        ('PP01', 'Olivar Grill Puente Piedra', 'Av. Buenos Aires 382', 'Puente Piedra', 'Lima', 'Lima', NULL, 1);
END;

SELECT @id_sucursal_pp = id_sucursal
FROM dbo.Sucursal
WHERE codigo = 'PP01';

IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'CARTA_GENERAL')
BEGIN
    INSERT INTO dbo.Menu
        (id_sucursal, codigo, nombre, tipo, descripcion, orden_visual, activo)
    VALUES
        (@id_sucursal_pp, 'CARTA_GENERAL', 'Carta general', 'CARTA_GENERAL', 'Carta principal del restaurante', 1, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'MENU_OLIVAR_LV')
BEGIN
    INSERT INTO dbo.Menu
        (id_sucursal, codigo, nombre, tipo, descripcion, hora_inicio, hora_fin,
         lunes, martes, miercoles, jueves, viernes, sabado, domingo, orden_visual, activo)
    VALUES
        (@id_sucursal_pp, 'MENU_OLIVAR_LV', 'Menu El Olivar', 'MENU_EJECUTIVO',
         'Menu disponible de lunes a viernes de 12:00 a 15:00',
         CAST('12:00:00' AS TIME), CAST('15:00:00' AS TIME),
         1, 1, 1, 1, 1, 0, 0, 2, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'OFERTAS_BRASA')
BEGIN
    INSERT INTO dbo.Menu
        (id_sucursal, codigo, nombre, tipo, descripcion, orden_visual, activo)
    VALUES
        (@id_sucursal_pp, 'OFERTAS_BRASA', 'Ofertas en pollo a la brasa', 'PROMOCION', 'Ofertas y combos de pollo a la brasa', 3, 1);
END;
GO

/* =========================================================
   8. EJEMPLOS DE USO
   Estos ejemplos quedan comentados para que los adaptes cuando
   ya tengas cargados productos, modificadores y opciones.
   =========================================================

-- A) Acompanamiento obligatorio: elegir exactamente 1 opcion.
-- UPDATE dbo.ProductoModificador
-- SET es_obligatorio = 1,
--     min_selecciones = 1,
--     max_selecciones = 1,
--     texto_guia = 'Elige un acompanamiento'
-- WHERE id_producto = 10 AND id_modificador = 3;

-- B) Cremas opcionales: elegir de 0 a 3 opciones.
-- UPDATE dbo.ProductoModificador
-- SET es_obligatorio = 0,
--     min_selecciones = 0,
--     max_selecciones = 3,
--     texto_guia = 'Elige hasta 3 cremas'
-- WHERE id_producto = 10 AND id_modificador = 4;

-- C) Variante con precio final para una combinacion.
-- INSERT INTO dbo.ProductoVariante
--     (id_producto, codigo_variante, nombre_variante, precio, es_precio_final, orden_visual, activo)
-- VALUES
--     (25, 'FET-PESTO-LOMO', 'Fettuccini al pesto + lomo', 31.00, 1, 5, 1);

-- D) Asociar la variante con opciones de modificadores.
-- INSERT INTO dbo.ProductoVarianteOpcion
--     (id_variante, id_modificador, id_opcion, orden)
-- VALUES
--     (1, 7, 20, 1), -- salsa pesto
--     (1, 8, 31, 2); -- complemento lomo

-- E) Producto dentro de un menu con precio especial.
-- INSERT INTO dbo.MenuProducto
--     (id_menu, id_producto, id_variante, precio_menu, usa_precio_base, etiqueta, destacado, orden_visual, activo)
-- VALUES
--     (2, 10, NULL, 21.00, 0, 'Menu ejecutivo', 1, 1, 1);

*/
