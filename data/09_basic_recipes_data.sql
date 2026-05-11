USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 9 - RECETAS BASE DE PRODUCTOS
   Ejecutar despues del BLOQUE 8B

   Este bloque carga:
   - Insumos faltantes para recetas
   - RecetaProducto para platos principales, entradas,
     brasa, parrillas, wok, chaufa, pastas, complementos,
     postres, menu y bebidas.
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   1. VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.RecetaProducto', N'U') IS NULL
    THROW 60000, 'No existe dbo.RecetaProducto.', 1;

IF OBJECT_ID(N'dbo.Producto', N'U') IS NULL
    THROW 60001, 'No existe dbo.Producto.', 1;

IF OBJECT_ID(N'dbo.Insumo', N'U') IS NULL
    THROW 60002, 'No existe dbo.Insumo.', 1;

IF OBJECT_ID(N'dbo.UnidadMedida', N'U') IS NULL
    THROW 60003, 'No existe dbo.UnidadMedida.', 1;


/* =========================================================
   2. INSUMOS FALTANTES PARA RECETAS
   Stock en 0 porque el BLOQUE 10 hara movimientos iniciales.
   ========================================================= */
DECLARE @InsumosFaltantes TABLE (
    nombre VARCHAR(100),
    abreviatura VARCHAR(5),
    stock_actual DECIMAL(12,3),
    stock_minimo DECIMAL(12,3),
    costo_unitario DECIMAL(10,4)
);

INSERT INTO @InsumosFaltantes
    (nombre, abreviatura, stock_actual, stock_minimo, costo_unitario)
VALUES
('Yuca', 'KG', 0.000, 5.000, 3.8000),
('Platano', 'UND', 0.000, 10.000, 1.2000),
('Salchicha Frankfurt', 'UND', 0.000, 20.000, 1.0000),
('Huevo', 'UND', 0.000, 30.000, 0.8000),
('Palta', 'UND', 0.000, 10.000, 2.5000),
('Queso fresco', 'KG', 0.000, 3.000, 16.0000),
('Vainita', 'KG', 0.000, 3.000, 4.5000),
('Espinaca', 'UND', 0.000, 5.000, 2.5000),
('Zapallo', 'KG', 0.000, 5.000, 3.0000),
('Fideo cabello de angel', 'KG', 0.000, 3.000, 7.5000),
('Fideo tallarin chino', 'KG', 0.000, 3.000, 8.0000),
('Wantan', 'UND', 0.000, 20.000, 0.4000),
('Langostino', 'KG', 0.000, 3.000, 38.0000),
('Cecina', 'KG', 0.000, 3.000, 30.0000),
('Bife', 'KG', 0.000, 4.000, 42.0000),
('Alitas de pollo', 'KG', 0.000, 5.000, 14.0000),
('Mollejitas de pollo', 'KG', 0.000, 5.000, 12.0000),
('Jamon ingles', 'KG', 0.000, 2.000, 20.0000),
('Tocino ahumado', 'KG', 0.000, 2.000, 26.0000),
('Queso Edam', 'KG', 0.000, 2.000, 28.0000),
('Limon', 'KG', 0.000, 5.000, 5.0000),
('Azucar', 'KG', 0.000, 10.000, 4.0000),
('Te filtrante', 'UND', 0.000, 20.000, 0.3500),
('Manzanilla filtrante', 'UND', 0.000, 20.000, 0.3500),
('Anis filtrante', 'UND', 0.000, 20.000, 0.3500),
('Hierba luisa filtrante', 'UND', 0.000, 20.000, 0.3500),
('Leche evaporada', 'LT', 0.000, 5.000, 7.0000),
('Leche condensada', 'LT', 0.000, 5.000, 10.0000),
('Base tres leches', 'POR', 0.000, 10.000, 4.0000),
('Base cheesecake', 'POR', 0.000, 10.000, 4.5000),
('Base selva negra', 'POR', 0.000, 10.000, 4.5000);

IF EXISTS (
    SELECT 1
    FROM @InsumosFaltantes i
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.UnidadMedida um
        WHERE um.abreviatura = i.abreviatura
    )
)
BEGIN
    SELECT DISTINCT i.abreviatura AS unidad_faltante
    FROM @InsumosFaltantes i
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.UnidadMedida um
        WHERE um.abreviatura = i.abreviatura
    );

    THROW 60004, 'Hay unidades de medida faltantes. Revisa el resultado anterior.', 1;
END;

INSERT INTO dbo.Insumo
    (nombre, id_unidad_medida, stock_actual, stock_minimo, costo_unitario, activo)
SELECT
    i.nombre,
    um.id_unidad_medida,
    i.stock_actual,
    i.stock_minimo,
    i.costo_unitario,
    1
FROM @InsumosFaltantes i
INNER JOIN dbo.UnidadMedida um
    ON um.abreviatura = i.abreviatura
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Insumo ins
    WHERE ins.nombre = i.nombre
);


/* =========================================================
   3. RECETAS BASE
   Cantidad requerida por una unidad vendida del producto.
   ========================================================= */
DECLARE @Recetas TABLE (
    producto_codigo VARCHAR(10) NOT NULL,
    insumo_nombre VARCHAR(100) NOT NULL,
    cantidad_requerida DECIMAL(10,3) NOT NULL,
    rendimiento_estimado DECIMAL(5,2) NULL,
    observaciones VARCHAR(MAX) NULL
);

INSERT INTO @Recetas
    (producto_codigo, insumo_nombre, cantidad_requerida, rendimiento_estimado, observaciones)
VALUES

/* =========================================================
   ENTRADAS
   ========================================================= */
('ENT001', 'Choclo', 1.000, 1.00, 'Choclo sancochado.'),
('ENT001', 'Mayonesa', 0.020, 1.00, 'Crema referencial.'),
('ENT001', 'Crema de aji', 0.020, 1.00, 'Crema referencial.'),

('ENT002', 'Platano', 1.000, 1.00, 'Platano a la parrilla.'),

('ENT003', 'Yuca', 0.250, 1.00, 'Yucas doradas.'),
('ENT003', 'Aceite vegetal', 0.040, 1.00, 'Fritura referencial.'),

('ENT004', 'Papa blanca', 0.350, 1.00, 'Papas fritas.'),
('ENT004', 'Salchicha Frankfurt', 3.000, 1.00, 'Salchichas para salchipapa.'),
('ENT004', 'Huevo', 1.000, 1.00, 'Huevo frito.'),
('ENT004', 'Aceite vegetal', 0.050, 1.00, 'Fritura referencial.'),

('ENT005', 'Anticucho', 0.250, 1.00, 'Anticuchos de corazon.'),
('ENT005', 'Choclo', 0.500, 1.00, 'Rodajas de choclo.'),

('ENT006', 'Mollejitas de pollo', 0.250, 1.00, 'Mollejitas.'),
('ENT006', 'Choclo', 0.500, 1.00, 'Rodajas de choclo.'),


/* =========================================================
   ENSALADAS
   ========================================================= */
('ENS001', 'Lechuga', 0.250, 1.00, 'Base de ensalada fresca.'),
('ENS001', 'Tomate', 0.080, 1.00, 'Tomate fresco.'),
('ENS001', 'Pepino', 0.060, 1.00, 'Pepino.'),
('ENS001', 'Zanahoria', 0.060, 1.00, 'Zanahoria.'),

('ENS002', 'Vainita', 0.080, 1.00, 'Verdura cocida.'),
('ENS002', 'Zanahoria', 0.080, 1.00, 'Verdura cocida.'),
('ENS002', 'Beterraga', 0.080, 1.00, 'Verdura cocida.'),
('ENS002', 'Palta', 0.500, 1.00, 'Media palta referencial.'),

('ENS003', 'Lechuga', 0.250, 1.00, 'Base de ensalada.'),
('ENS003', 'Tomate', 0.080, 1.00, 'Tomate.'),
('ENS003', 'Espinaca', 0.200, 1.00, 'Espinaca.'),
('ENS003', 'Zanahoria', 0.060, 1.00, 'Zanahoria.'),
('ENS003', 'Palta', 0.500, 1.00, 'Palta.'),
('ENS003', 'Choclo', 0.500, 1.00, 'Choclo.'),
('ENS003', 'Queso fresco', 0.060, 1.00, 'Queso fresco.'),

('ENS004', 'Palta', 1.000, 1.00, 'Palta cremosa.'),
('ENS004', 'Choclo', 0.500, 1.00, 'Granos de choclo.'),


/* =========================================================
   POLLO A LA BRASA
   ========================================================= */
('BRA001', 'Pollo entero', 0.250, 1.00, 'Un cuarto de pollo.'),
('BRA001', 'Papa blanca', 0.250, 1.00, 'Guarnicion de papa.'),
('BRA001', 'Lechuga', 0.100, 1.00, 'Ensalada.'),
('BRA001', 'Tomate', 0.050, 1.00, 'Ensalada.'),
('BRA001', 'Crema de aji', 0.020, 1.00, 'Crema referencial.'),
('BRA001', 'Mayonesa', 0.020, 1.00, 'Crema referencial.'),

('BRA002', 'Pollo entero', 0.250, 1.00, 'Un cuarto de pollo.'),
('BRA002', 'Papa amarilla', 0.250, 1.00, 'Papa huayro referencial.'),
('BRA002', 'Choclo', 0.500, 1.00, 'Media porcion de choclo.'),
('BRA002', 'Lechuga', 0.100, 1.00, 'Ensalada fresca.'),

('BRA003', 'Pollo entero', 0.500, 1.00, 'Medio pollo.'),
('BRA003', 'Papa blanca', 0.500, 1.00, 'Guarnicion de papa.'),
('BRA003', 'Lechuga', 0.200, 1.00, 'Ensalada.'),
('BRA003', 'Tomate', 0.100, 1.00, 'Ensalada.'),

('BRA004', 'Pollo entero', 1.000, 1.00, 'Pollo entero.'),
('BRA004', 'Papa blanca', 1.000, 1.00, 'Guarnicion familiar de papa.'),
('BRA004', 'Lechuga', 0.400, 1.00, 'Ensalada.'),
('BRA004', 'Tomate', 0.200, 1.00, 'Ensalada.'),


/* =========================================================
   PARRILLAS Y FUSIONES
   ========================================================= */
('PAR001', 'Pechuga de pollo', 1.000, 1.00, 'Pechuga o pierna a la parrilla.'),
('PAR001', 'Papa blanca', 0.250, 1.00, 'Guarnicion.'),
('PAR001', 'Lechuga', 0.100, 1.00, 'Ensalada.'),

('PAR010', 'Mollejitas de pollo', 0.250, 1.00, 'Mollejitas grill.'),
('PAR010', 'Papa blanca', 0.250, 1.00, 'Guarnicion.'),
('PAR010', 'Lechuga', 0.100, 1.00, 'Ensalada.'),

('PAR011', 'Chuleta de cerdo', 0.300, 1.00, 'Chuleta premium.'),
('PAR011', 'Papa blanca', 0.250, 1.00, 'Guarnicion.'),
('PAR011', 'Lechuga', 0.100, 1.00, 'Ensalada.'),

('PAR015', 'Churrasco', 0.250, 1.00, 'Churrasco a la parrilla.'),
('PAR015', 'Papa blanca', 0.250, 1.00, 'Guarnicion.'),
('PAR015', 'Lechuga', 0.100, 1.00, 'Ensalada.'),

('PAR016', 'Churrasco', 0.250, 1.00, 'Churrasco.'),
('PAR016', 'Papa blanca', 0.250, 1.00, 'Papas.'),
('PAR016', 'Huevo', 1.000, 1.00, 'Huevo frito.'),
('PAR016', 'Platano', 1.000, 1.00, 'Platano frito.'),
('PAR016', 'Arroz', 0.120, 1.00, 'Arroz cocido referencial.'),

('PAR017', 'Bife', 0.300, 1.00, 'Bife ejecutivo.'),
('PAR017', 'Papa blanca', 0.250, 1.00, 'Guarnicion.'),

('PAR018', 'Costilla de cerdo', 0.600, 1.00, 'Costillar BBQ.'),
('PAR018', 'Papa blanca', 0.350, 1.00, 'Guarnicion.'),
('PAR018', 'Lechuga', 0.120, 1.00, 'Ensalada.'),

('PAR019', 'Alitas de pollo', 0.350, 1.00, 'Alitas BBQ.'),
('PAR019', 'Papa blanca', 0.250, 1.00, 'Guarnicion.'),

('FUS001', 'Pechuga de pollo', 1.000, 1.00, 'Pollo Ricky.'),
('FUS001', 'Anticucho', 0.100, 1.00, 'Palito de anticucho.'),
('FUS001', 'Papa blanca', 0.250, 1.00, 'Guarnicion.'),

('FUS003', 'Pechuga de pollo', 1.000, 1.00, 'Pechuga rellena.'),
('FUS003', 'Jamon ingles', 0.040, 1.00, 'Relleno.'),
('FUS003', 'Tocino ahumado', 0.040, 1.00, 'Relleno.'),
('FUS003', 'Queso Edam', 0.050, 1.00, 'Relleno.'),
('FUS003', 'Mollejitas de pollo', 0.125, 1.00, 'Mollejitas.'),


/* =========================================================
   WOK CRIOLLO
   ========================================================= */
('WOK001', 'Pierna de pollo', 1.000, 1.00, 'Sopa de dieta.'),
('WOK001', 'Zapallo', 0.080, 1.00, 'Verdura para sopa.'),
('WOK001', 'Zanahoria', 0.060, 1.00, 'Verdura para sopa.'),
('WOK001', 'Papa amarilla', 0.150, 1.00, 'Papa para sopa.'),
('WOK001', 'Fideo cabello de angel', 0.050, 1.00, 'Fideo para sopa.'),

('WOK003', 'Lomo fino', 0.220, 1.00, 'Lomo saltado.'),
('WOK003', 'Papa blanca', 0.250, 1.00, 'Papas fritas.'),
('WOK003', 'Arroz', 0.120, 1.00, 'Arroz.'),
('WOK003', 'Cebolla roja', 0.080, 1.00, 'Saltado.'),
('WOK003', 'Tomate', 0.080, 1.00, 'Saltado.'),
('WOK003', 'Sillao', 0.020, 1.00, 'Sazon.'),
('WOK003', 'Aceite vegetal', 0.040, 1.00, 'Coccion.'),

('WOK004', 'Pechuga de pollo', 1.000, 1.00, 'Pollo saltado.'),
('WOK004', 'Papa blanca', 0.250, 1.00, 'Papas fritas.'),
('WOK004', 'Arroz', 0.120, 1.00, 'Arroz.'),
('WOK004', 'Cebolla roja', 0.080, 1.00, 'Saltado.'),
('WOK004', 'Tomate', 0.080, 1.00, 'Saltado.'),

('WOK005', 'Pechuga de pollo', 1.000, 1.00, 'Tallarin saltado de pollo.'),
('WOK005', 'Fideo tallarin chino', 0.200, 1.00, 'Tallarin.'),
('WOK005', 'Cebolla china', 0.040, 1.00, 'Saltado.'),
('WOK005', 'Sillao', 0.020, 1.00, 'Sazon.'),

('WOK006', 'Lomo fino', 0.220, 1.00, 'Tallarin saltado de carne.'),
('WOK006', 'Fideo tallarin chino', 0.200, 1.00, 'Tallarin.'),
('WOK006', 'Cebolla china', 0.040, 1.00, 'Saltado.'),
('WOK006', 'Sillao', 0.020, 1.00, 'Sazon.'),


/* =========================================================
   PASTAS
   ========================================================= */
('PAS001', 'Fideo fettuccini', 0.200, 1.00, 'Base de pasta.'),
('PAS001', 'Salsa pesto', 0.120, 1.00, 'Salsa al pesto.'),

('PAS002', 'Fideo fettuccini', 0.200, 1.00, 'Base de pasta.'),
('PAS002', 'Salsa huancaina', 0.120, 1.00, 'Salsa huancaina.'),

('PAS003', 'Fideo fettuccini', 0.200, 1.00, 'Base de pasta.'),
('PAS003', 'Salsa alfredo', 0.120, 1.00, 'Salsa Alfredo.'),


/* =========================================================
   CHAUFA
   ========================================================= */
('CHA001', 'Arroz', 0.220, 1.00, 'Chaufa de pollo.'),
('CHA001', 'Pechuga de pollo', 0.500, 1.00, 'Pollo para chaufa.'),
('CHA001', 'Huevo', 1.000, 1.00, 'Huevo para chaufa.'),
('CHA001', 'Cebolla china', 0.030, 1.00, 'Cebolla china.'),
('CHA001', 'Sillao', 0.020, 1.00, 'Sazon.'),
('CHA001', 'Aceite vegetal', 0.030, 1.00, 'Coccion.'),

('CHA002', 'Arroz', 0.180, 1.00, 'Aeropuerto.'),
('CHA002', 'Fideo tallarin chino', 0.120, 1.00, 'Tallarin chino.'),
('CHA002', 'Pechuga de pollo', 0.500, 1.00, 'Pollo.'),
('CHA002', 'Wantan', 3.000, 1.00, 'Wantan referencial.'),

('CHA003', 'Arroz', 0.220, 1.00, 'Chaufa a lo pobre.'),
('CHA003', 'Pechuga de pollo', 0.500, 1.00, 'Pollo.'),
('CHA003', 'Huevo', 1.000, 1.00, 'Huevo frito.'),
('CHA003', 'Platano', 1.000, 1.00, 'Platano frito.'),

('CHA004', 'Arroz', 0.220, 1.00, 'Mostro Olivar.'),
('CHA004', 'Pollo entero', 0.250, 1.00, '1/4 pollo.'),
('CHA004', 'Papa blanca', 0.200, 1.00, 'Papas fritas.'),

('CHA005', 'Arroz', 0.220, 1.00, 'Chaufa especial.'),
('CHA005', 'Pechuga de pollo', 0.400, 1.00, 'Pollo.'),
('CHA005', 'Langostino', 0.080, 1.00, 'Langostinos.'),
('CHA005', 'Cecina', 0.080, 1.00, 'Cecina.'),


/* =========================================================
   COMPLEMENTOS
   ========================================================= */
('COM001', 'Papa blanca', 0.350, 1.00, 'Porcion de papas fritas.'),
('COM001', 'Aceite vegetal', 0.040, 1.00, 'Fritura.'),

('COM002', 'Papa blanca', 0.250, 1.00, 'Papas doradas.'),
('COM003', 'Papa blanca', 0.250, 1.00, 'Papas sancochadas.'),
('COM004', 'Papa amarilla', 0.250, 1.00, 'Papas huayro.'),
('COM005', 'Arroz', 0.150, 1.00, 'Porcion de arroz blanco.'),
('COM006', 'Queso fresco', 0.080, 1.00, 'Porcion de queso.'),
('COM007', 'Chorizo parrillero', 1.000, 1.00, 'Chorizo a la parrilla.'),
('COM008', 'Huevo', 1.000, 1.00, 'Huevo frito.'),
('COM008', 'Platano', 1.000, 1.00, 'Platano frito.'),


/* =========================================================
   MENU EL OLIVAR
   ========================================================= */
('MNU001', 'Pollo entero', 0.250, 1.00, '1/4 pollo menu.'),
('MNU001', 'Arroz', 0.120, 1.00, 'Arroz.'),
('MNU001', 'Papa blanca', 0.200, 1.00, 'Papas fritas.'),
('MNU001', 'Lechuga', 0.080, 1.00, 'Ensalada.'),

('MNU002', 'Mollejitas de pollo', 0.250, 1.00, 'Mollejitas menu.'),
('MNU002', 'Arroz', 0.120, 1.00, 'Arroz.'),
('MNU002', 'Papa blanca', 0.200, 1.00, 'Papas fritas.'),

('MNU003', 'Anticucho', 0.250, 1.00, 'Anticuchos menu.'),
('MNU003', 'Arroz', 0.120, 1.00, 'Arroz.'),
('MNU003', 'Papa blanca', 0.200, 1.00, 'Papas fritas.'),

('MNU004', 'Chuleta de cerdo', 0.300, 1.00, 'Chuleta menu.'),
('MNU004', 'Arroz', 0.120, 1.00, 'Arroz.'),
('MNU004', 'Papa blanca', 0.200, 1.00, 'Papas fritas.'),

('MNU005', 'Pechuga de pollo', 0.700, 1.00, 'Chicharron de pollo menu.'),
('MNU005', 'Arroz', 0.120, 1.00, 'Arroz.'),
('MNU005', 'Papa blanca', 0.200, 1.00, 'Papas fritas.'),

('MNU006', 'Pechuga de pollo', 1.000, 1.00, 'Pollo El Olivar menu.'),
('MNU006', 'Arroz', 0.120, 1.00, 'Arroz.'),
('MNU006', 'Papa blanca', 0.200, 1.00, 'Papas fritas.'),


/* =========================================================
   POSTRES
   ========================================================= */
('POS001', 'Crema volteada', 1.000, 1.00, 'Postre porcionado.'),
('POS002', 'Base tres leches', 1.000, 1.00, 'Postre porcionado.'),
('POS003', 'Torta de chocolate', 1.000, 1.00, 'Postre porcionado.'),
('POS004', 'Base selva negra', 1.000, 1.00, 'Postre porcionado.'),
('POS005', 'Base cheesecake', 1.000, 1.00, 'Postre porcionado.'),


/* =========================================================
   BEBIDAS
   ========================================================= */
('INF001', 'Te filtrante', 1.000, 1.00, 'Infusion referencial.'),
('BEB001', 'Agua mineral personal', 1.000, 1.00, 'Agua mineral.'),
('BEB005', 'Gaseosa 1 litro', 1.000, 1.00, 'Gaseosa 1 litro.'),
('BEB007', 'Gaseosa 1.5 litros', 1.000, 1.00, 'Gaseosa 1.5 litros.'),
('BEB011', 'Chicha morada preparada', 1.000, 1.00, 'Jarra de 1 litro.'),
('BEB017', 'Limonada preparada', 0.350, 1.00, 'Vaso de limonada.'),
('BEB018', 'Chicha morada preparada', 0.350, 1.00, 'Vaso de chicha morada.');


/* =========================================================
   4. VALIDAR PRODUCTOS FALTANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Recetas r
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = r.producto_codigo
    )
)
BEGIN
    SELECT DISTINCT r.producto_codigo AS producto_faltante
    FROM @Recetas r
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = r.producto_codigo
    );

    THROW 60005, 'Hay productos faltantes para recetas. Revisa el resultado anterior.', 1;
END;


/* =========================================================
   5. VALIDAR INSUMOS FALTANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Recetas r
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Insumo i
        WHERE i.nombre = r.insumo_nombre
    )
)
BEGIN
    SELECT DISTINCT r.insumo_nombre AS insumo_faltante
    FROM @Recetas r
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Insumo i
        WHERE i.nombre = r.insumo_nombre
    );

    THROW 60006, 'Hay insumos faltantes para recetas. Revisa el resultado anterior.', 1;
END;


/* =========================================================
   6. ACTUALIZAR RECETAS EXISTENTES
   ========================================================= */
UPDATE rp
SET
    rp.cantidad_requerida = r.cantidad_requerida,
    rp.rendimiento_estimado = r.rendimiento_estimado,
    rp.observaciones = r.observaciones
FROM dbo.RecetaProducto rp
INNER JOIN dbo.Producto p
    ON p.id_producto = rp.id_producto
INNER JOIN dbo.Insumo i
    ON i.id_insumo = rp.id_insumo
INNER JOIN @Recetas r
    ON r.producto_codigo = p.codigo
   AND r.insumo_nombre = i.nombre;


/* =========================================================
   7. INSERTAR RECETAS NUEVAS
   ========================================================= */
INSERT INTO dbo.RecetaProducto
    (id_producto, id_insumo, cantidad_requerida, rendimiento_estimado, observaciones)
SELECT
    p.id_producto,
    i.id_insumo,
    r.cantidad_requerida,
    r.rendimiento_estimado,
    r.observaciones
FROM @Recetas r
INNER JOIN dbo.Producto p
    ON p.codigo = r.producto_codigo
INNER JOIN dbo.Insumo i
    ON i.nombre = r.insumo_nombre
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.RecetaProducto rp
    WHERE rp.id_producto = p.id_producto
      AND rp.id_insumo = i.id_insumo
);


COMMIT TRANSACTION;

PRINT 'BLOQUE 9 cargado correctamente: recetas base de productos.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 9';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
