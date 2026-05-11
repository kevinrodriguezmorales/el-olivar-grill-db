USE BDOlivarGrill;
GO

SELECT * FROM dbo.AreaPreparacion;
SELECT * FROM dbo.Caja;
SELECT * FROM dbo.CategoriaProducto;
SELECT * FROM dbo.Cliente;
SELECT * FROM dbo.Comprobante;
SELECT * FROM dbo.CuentaPedido;
SELECT * FROM dbo.DetalleCuentaPedido;
SELECT * FROM dbo.DetallePedido;
SELECT * FROM dbo.DetallePedidoOpcion;
SELECT * FROM dbo.Empleado;
SELECT * FROM dbo.EstadoDetallePedido;
SELECT * FROM dbo.EstadoPedido;
SELECT * FROM dbo.HistorialEstadoDetallePedido;
SELECT * FROM dbo.HistorialEstadoPedido;
SELECT * FROM dbo.Insumo;
SELECT * FROM dbo.Menu;
SELECT * FROM dbo.MenuProducto;
SELECT * FROM dbo.Mesa;
SELECT * FROM dbo.MetodoPago;
SELECT * FROM dbo.Modificador;
SELECT * FROM dbo.MovimientoInventario;
SELECT * FROM dbo.OpcionModificador;
SELECT * FROM dbo.Pago;
SELECT * FROM dbo.Pedido;
SELECT * FROM dbo.Producto;
SELECT * FROM dbo.ProductoComponente;
SELECT * FROM dbo.ProductoImagen;
SELECT * FROM dbo.ProductoModificador;
SELECT * FROM dbo.ProductoVariante;
SELECT * FROM dbo.ProductoVarianteOpcion;
SELECT * FROM dbo.RecetaProducto;
SELECT * FROM dbo.Rol;
SELECT * FROM dbo.SesionCaja;
SELECT * FROM dbo.Sucursal;
SELECT * FROM dbo.TipoComprobante;
SELECT * FROM dbo.UnidadMedida;
SELECT * FROM dbo.Usuario;

-- 1. Limpiar tablas
-- 1.1 Limpiar
USE BDOlivarGrill;
GO

DELETE FROM dbo.Comprobante;
DELETE FROM dbo.Pago;
DELETE FROM dbo.DetalleCuentaPedido;
DELETE FROM dbo.CuentaPedido;
DELETE FROM dbo.HistorialEstadoDetallePedido;
DELETE FROM dbo.HistorialEstadoPedido;
DELETE FROM dbo.DetallePedidoOpcion;
DELETE FROM dbo.DetallePedido;
DELETE FROM dbo.Pedido;
DELETE FROM dbo.SesionCaja;
DELETE FROM dbo.MenuProducto;
DELETE FROM dbo.ProductoVarianteOpcion;
DELETE FROM dbo.ProductoVariante;
DELETE FROM dbo.ProductoImagen;
DELETE FROM dbo.ProductoComponente;
DELETE FROM dbo.ProductoModificador;
DELETE FROM dbo.RecetaProducto;
DELETE FROM dbo.MovimientoInventario;
DELETE FROM dbo.Menu;
DELETE FROM dbo.Sucursal;
DELETE FROM dbo.Caja;
DELETE FROM dbo.Mesa;
DELETE FROM dbo.OpcionModificador;
DELETE FROM dbo.Modificador;
DELETE FROM dbo.Producto;
DELETE FROM dbo.CategoriaProducto;
DELETE FROM dbo.Insumo;
DELETE FROM dbo.UnidadMedida;
DELETE FROM dbo.TipoComprobante;
DELETE FROM dbo.MetodoPago;
DELETE FROM dbo.EstadoDetallePedido;
DELETE FROM dbo.EstadoPedido;
DELETE FROM dbo.Rol;
DELETE FROM dbo.Usuario;
DELETE FROM dbo.Empleado;
DELETE FROM dbo.Cliente;
DELETE FROM dbo.AreaPreparacion;
GO

-- 1.2 Reiniciar IDENTITY

DBCC CHECKIDENT ('dbo.AreaPreparacion', RESEED, 0);
DBCC CHECKIDENT ('dbo.Caja', RESEED, 0);
DBCC CHECKIDENT ('dbo.CategoriaProducto', RESEED, 0);
DBCC CHECKIDENT ('dbo.Cliente', RESEED, 0);
DBCC CHECKIDENT ('dbo.Comprobante', RESEED, 0);
DBCC CHECKIDENT ('dbo.CuentaPedido', RESEED, 0);
DBCC CHECKIDENT ('dbo.DetalleCuentaPedido', RESEED, 0);
DBCC CHECKIDENT ('dbo.DetallePedido', RESEED, 0);
DBCC CHECKIDENT ('dbo.DetallePedidoOpcion', RESEED, 0);
DBCC CHECKIDENT ('dbo.Empleado', RESEED, 0);
DBCC CHECKIDENT ('dbo.EstadoDetallePedido', RESEED, 0);
DBCC CHECKIDENT ('dbo.EstadoPedido', RESEED, 0);
DBCC CHECKIDENT ('dbo.HistorialEstadoDetallePedido', RESEED, 0);
DBCC CHECKIDENT ('dbo.HistorialEstadoPedido', RESEED, 0);
DBCC CHECKIDENT ('dbo.Insumo', RESEED, 0);
DBCC CHECKIDENT ('dbo.Menu', RESEED, 0);
DBCC CHECKIDENT ('dbo.MenuProducto', RESEED, 0);
DBCC CHECKIDENT ('dbo.Mesa', RESEED, 0);
DBCC CHECKIDENT ('dbo.MetodoPago', RESEED, 0);
DBCC CHECKIDENT ('dbo.Modificador', RESEED, 0);
DBCC CHECKIDENT ('dbo.MovimientoInventario', RESEED, 0);
DBCC CHECKIDENT ('dbo.OpcionModificador', RESEED, 0);
DBCC CHECKIDENT ('dbo.Pago', RESEED, 0);
DBCC CHECKIDENT ('dbo.Pedido', RESEED, 0);
DBCC CHECKIDENT ('dbo.Producto', RESEED, 0);
DBCC CHECKIDENT ('dbo.ProductoComponente', RESEED, 0);
DBCC CHECKIDENT ('dbo.ProductoImagen', RESEED, 0);
DBCC CHECKIDENT ('dbo.ProductoVariante', RESEED, 0);
DBCC CHECKIDENT ('dbo.ProductoVarianteOpcion', RESEED, 0);
DBCC CHECKIDENT ('dbo.RecetaProducto', RESEED, 0);
DBCC CHECKIDENT ('dbo.Rol', RESEED, 0);
DBCC CHECKIDENT ('dbo.SesionCaja', RESEED, 0);
DBCC CHECKIDENT ('dbo.Sucursal', RESEED, 0);
DBCC CHECKIDENT ('dbo.TipoComprobante', RESEED, 0);
DBCC CHECKIDENT ('dbo.UnidadMedida', RESEED, 0);
DBCC CHECKIDENT ('dbo.Usuario', RESEED, 0);
GO


-- 2. Validar si se ejecuto correctamente el script 01_master_table_data.sql
SELECT COUNT(*) AS total_categorias FROM dbo.CategoriaProducto;
SELECT COUNT(*) AS total_modificadores FROM dbo.Modificador;
SELECT COUNT(*) AS total_usuarios FROM dbo.Usuario;
SELECT COUNT(*) AS total_metodos_pago FROM dbo.MetodoPago;
SELECT COUNT(*) AS total_tipos_comprobante FROM dbo.TipoComprobante;
SELECT COUNT(*) AS total_menus FROM dbo.Menu;

-- 3. Validar si se ejecuto correctamente el script 02_modifying_inputs_data.sql
SELECT 
    m.nombre AS modificador,
    COUNT(om.id_opcion) AS total_opciones
FROM dbo.Modificador m
LEFT JOIN dbo.OpcionModificador om
    ON om.id_modificador = m.id_modificador
GROUP BY m.nombre
ORDER BY m.nombre;

SELECT COUNT(*) AS total_insumos
FROM dbo.Insumo;

-- 4. Validar si se ejecuto correctamente el script 03_A_insumos_base_data.sql
SELECT 
    c.nombre AS categoria,
    COUNT(p.id_producto) AS total_productos
FROM dbo.CategoriaProducto c
LEFT JOIN dbo.Producto p
    ON p.id_categoria = c.id_categoria
WHERE c.nombre IN (
    'Entradas',
    'Ensaladas',
    'Olivar Brasa',
    'Ofertas en Pollo a la Brasa'
)
GROUP BY c.nombre
ORDER BY c.nombre;

SELECT 
    codigo,
    nombre,
    precio_base,
    imagen_principal_url
FROM dbo.Producto
WHERE codigo LIKE 'ENT%'
   OR codigo LIKE 'ENS%'
   OR codigo LIKE 'BRA%'
   OR codigo LIKE 'OFE%'
ORDER BY codigo;

SELECT COUNT(*) AS total_imagenes_principales
FROM dbo.ProductoImagen
WHERE es_principal = 1
  AND activo = 1;

-- 5. Validar si se ejecuto correctamente el script 03_B_insumos_base_data.sql
SELECT 
    c.nombre AS categoria,
    COUNT(p.id_producto) AS total_productos
FROM dbo.CategoriaProducto c
LEFT JOIN dbo.Producto p
    ON p.id_categoria = c.id_categoria
WHERE c.nombre IN (
    'Fusiones',
    'Parrillas Personales',
    'Piqueos',
    'Parrillas Familiares'
)
GROUP BY c.nombre
ORDER BY c.nombre;

SELECT 
    codigo,
    nombre,
    precio_base,
    imagen_principal_url
FROM dbo.Producto
WHERE codigo LIKE 'FUS%'
   OR codigo LIKE 'PAR%'
   OR codigo LIKE 'PIQ%'
   OR codigo LIKE 'FAM%'
ORDER BY codigo;

-- 6. Validar si se ejecuto correctamente el script 03_C_menu_data.sql
SELECT 
    c.nombre AS categoria,
    COUNT(p.id_producto) AS total_productos
FROM dbo.CategoriaProducto c
LEFT JOIN dbo.Producto p
    ON p.id_categoria = c.id_categoria
WHERE c.nombre IN (
    'Wok Criollo',
    'Pastas',
    'Chaufa',
    'Complementos',
    'Postres',
    'Menu El Olivar',
    'Bebidas Calientes',
    'Bebidas'
)
GROUP BY c.nombre
ORDER BY c.nombre;

SELECT 
    codigo,
    nombre,
    precio_base,
    imagen_principal_url
FROM dbo.Producto
WHERE codigo LIKE 'WOK%'
   OR codigo LIKE 'PAS%'
   OR codigo LIKE 'CHA%'
   OR codigo LIKE 'COM%'
   OR codigo LIKE 'POS%'
   OR codigo LIKE 'MNU%'
   OR codigo LIKE 'INF%'
   OR codigo LIKE 'BEB%'
ORDER BY codigo;

-- 7. Validar si se ejecuto correctamente el script 04_pasta_data.sql
SELECT
    p.codigo AS codigo_producto,
    p.nombre AS producto_base,
    pv.codigo_variante,
    pv.nombre_variante,
    pv.precio,
    pv.imagen_url,
    pv.activo
FROM dbo.ProductoVariante pv
INNER JOIN dbo.Producto p
    ON p.id_producto = pv.id_producto
WHERE p.codigo IN ('PAS001', 'PAS002', 'PAS003')
ORDER BY p.codigo, pv.orden_visual;

SELECT
    p.codigo AS codigo_producto,
    pv.codigo_variante,
    pv.nombre_variante,
    m.nombre AS modificador,
    om.valor AS opcion
FROM dbo.ProductoVarianteOpcion pvo
INNER JOIN dbo.ProductoVariante pv
    ON pv.id_variante = pvo.id_variante
INNER JOIN dbo.Producto p
    ON p.id_producto = pv.id_producto
INNER JOIN dbo.Modificador m
    ON m.id_modificador = pvo.id_modificador
INNER JOIN dbo.OpcionModificador om
    ON om.id_opcion = pvo.id_opcion
ORDER BY p.codigo, pv.orden_visual, pvo.orden;

-- 8. Validar si se ejecuto correctamente el script 05_A_product_modifying_rules_data.sql
SELECT
    p.codigo,
    p.nombre AS producto,
    m.nombre AS modificador,
    pm.es_obligatorio,
    pm.min_selecciones,
    pm.max_selecciones,
    pm.permite_repetir_opcion,
    pm.orden_aplicacion,
    pm.texto_guia
FROM dbo.ProductoModificador pm
INNER JOIN dbo.Producto p
    ON p.id_producto = pm.id_producto
INNER JOIN dbo.Modificador m
    ON m.id_modificador = pm.id_modificador
ORDER BY p.codigo, pm.orden_aplicacion;

SELECT
    m.nombre AS modificador,
    COUNT(*) AS productos_asociados
FROM dbo.ProductoModificador pm
INNER JOIN dbo.Modificador m
    ON m.id_modificador = pm.id_modificador
GROUP BY m.nombre
ORDER BY m.nombre;

-- 9. Validar si se ejecuto correctamente el script 05_B_product_modifying_rules_data.sql
SELECT COUNT(*) AS total_producto_modificador
FROM dbo.ProductoModificador;

SELECT
    m.nombre AS modificador,
    COUNT(*) AS productos_asociados
FROM dbo.ProductoModificador pm
INNER JOIN dbo.Modificador m
    ON m.id_modificador = pm.id_modificador
GROUP BY m.nombre
ORDER BY m.nombre;

-- 10. Validar si se ejecuto correctamente el script 06_show_menu_data.sql
SELECT
    m.codigo AS codigo_menu,
    m.nombre AS menu,
    COUNT(mp.id_menu_producto) AS total_productos_menu
FROM dbo.Menu m
LEFT JOIN dbo.MenuProducto mp
    ON mp.id_menu = m.id_menu
GROUP BY m.codigo, m.nombre
ORDER BY m.codigo;

SELECT
    m.codigo AS codigo_menu,
    p.codigo AS codigo_producto,
    p.nombre AS producto,
    pv.codigo_variante,
    pv.nombre_variante,
    COALESCE(mp.precio_menu, p.precio_base) AS precio_visible,
    mp.usa_precio_base,
    mp.etiqueta,
    mp.destacado,
    mp.visible,
    mp.orden_visual
FROM dbo.MenuProducto mp
INNER JOIN dbo.Menu m
    ON m.id_menu = mp.id_menu
INNER JOIN dbo.Producto p
    ON p.id_producto = mp.id_producto
LEFT JOIN dbo.ProductoVariante pv
    ON pv.id_variante = mp.id_variante
ORDER BY m.codigo, mp.orden_visual;

-- 11. Validar si se ejecuto correctamente el script 07_combos_data.sql
SELECT
    padre.codigo AS codigo_combo,
    padre.nombre AS combo,
    hijo.codigo AS codigo_componente,
    hijo.nombre AS componente,
    pc.cantidad,
    pc.orden
FROM dbo.ProductoComponente pc
INNER JOIN dbo.Producto padre
    ON padre.id_producto = pc.id_producto_padre
INNER JOIN dbo.Producto hijo
    ON hijo.id_producto = pc.id_producto_hijo
ORDER BY padre.codigo, pc.orden;

SELECT
    padre.codigo,
    padre.nombre,
    COUNT(*) AS total_componentes
FROM dbo.ProductoComponente pc
INNER JOIN dbo.Producto padre
    ON padre.id_producto = pc.id_producto_padre
GROUP BY padre.codigo, padre.nombre
ORDER BY padre.codigo;

-- 12. Validar si se ejecuto correctamente el script 08_A_test_request_data.sql
SELECT
    p.id_pedido,
    p.numero_pedido,
    p.estado_actual,
    p.subtotal,
    p.descuento_monto,
    p.costo_delivery,
    p.total_con_igv
FROM dbo.Pedido p
WHERE p.numero_pedido = 'PED-PRUEBA-001';

SELECT
    dp.id_detalle_pedido,
    prod.codigo,
    prod.nombre,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal
FROM dbo.DetallePedido dp
INNER JOIN dbo.Producto prod
    ON prod.id_producto = dp.id_producto
INNER JOIN dbo.Pedido p
    ON p.id_pedido = dp.id_pedido
WHERE p.numero_pedido = 'PED-PRUEBA-001';

SELECT
    prod.codigo,
    prod.nombre AS producto,
    m.nombre AS modificador,
    om.valor AS opcion,
    dpo.cantidad,
    dpo.precio_adicional
FROM dbo.DetallePedidoOpcion dpo
INNER JOIN dbo.DetallePedido dp
    ON dp.id_detalle_pedido = dpo.id_detalle_pedido
INNER JOIN dbo.Producto prod
    ON prod.id_producto = dp.id_producto
INNER JOIN dbo.Modificador m
    ON m.id_modificador = dpo.id_modificador
INNER JOIN dbo.OpcionModificador om
    ON om.id_opcion = dpo.id_opcion_modificador
INNER JOIN dbo.Pedido p
    ON p.id_pedido = dp.id_pedido
WHERE p.numero_pedido = 'PED-PRUEBA-001'
ORDER BY prod.codigo, m.nombre, om.valor;

SELECT
    cp.id_cuenta_pedido,
    cp.numero_cuenta,
    cp.subtotal,
    cp.descuento,
    cp.total,
    cp.estado_cuenta
FROM dbo.CuentaPedido cp
INNER JOIN dbo.Pedido p
    ON p.id_pedido = cp.id_pedido
WHERE p.numero_pedido = 'PED-PRUEBA-001';

-- 13. Validar si se ejecuto correctamente el script 08_B_payment_receipt_data.sql
SELECT
    p.id_pedido,
    p.numero_pedido,
    p.estado_actual,
    p.subtotal,
    p.total_con_igv
FROM dbo.Pedido p
WHERE p.numero_pedido = 'PED-PRUEBA-001';

SELECT
    cp.id_cuenta_pedido,
    cp.numero_cuenta,
    cp.subtotal,
    cp.descuento,
    cp.total,
    cp.estado_cuenta
FROM dbo.CuentaPedido cp
INNER JOIN dbo.Pedido p
    ON p.id_pedido = cp.id_pedido
WHERE p.numero_pedido = 'PED-PRUEBA-001';

SELECT
    pg.id_pago,
    p.numero_pedido,
    mp.nombre AS metodo_pago,
    pg.monto,
    pg.referencia_pago,
    pg.estado_pago,
    pg.fecha_hora_pago
FROM dbo.Pago pg
INNER JOIN dbo.Pedido p
    ON p.id_pedido = pg.id_pedido
INNER JOIN dbo.MetodoPago mp
    ON mp.id_metodo_pago = pg.id_metodo_pago
WHERE p.numero_pedido = 'PED-PRUEBA-001';

SELECT
    c.id_comprobante,
    p.numero_pedido,
    tc.nombre AS tipo_comprobante,
    c.serie,
    c.numero,
    c.subtotal,
    c.impuesto,
    c.total,
    c.estado_comprobante,
    c.fecha_hora_emision
FROM dbo.Comprobante c
INNER JOIN dbo.Pedido p
    ON p.id_pedido = c.id_pedido
INNER JOIN dbo.TipoComprobante tc
    ON tc.id_tipo_comprobante = c.id_tipo_comprobante
WHERE p.numero_pedido = 'PED-PRUEBA-001';

-- 14. Validar si se ejecuto correctamente el script 09_basic_recipes_data.sql
SELECT COUNT(*) AS total_recetas
FROM dbo.RecetaProducto;

SELECT
    p.codigo,
    p.nombre AS producto,
    COUNT(rp.id_receta_producto) AS total_insumos_receta
FROM dbo.RecetaProducto rp
INNER JOIN dbo.Producto p
    ON p.id_producto = rp.id_producto
GROUP BY p.codigo, p.nombre
ORDER BY p.codigo;

SELECT
    p.codigo,
    p.nombre AS producto,
    i.nombre AS insumo,
    rp.cantidad_requerida,
    um.abreviatura AS unidad,
    rp.rendimiento_estimado,
    rp.observaciones
FROM dbo.RecetaProducto rp
INNER JOIN dbo.Producto p
    ON p.id_producto = rp.id_producto
INNER JOIN dbo.Insumo i
    ON i.id_insumo = rp.id_insumo
INNER JOIN dbo.UnidadMedida um
    ON um.id_unidad_medida = i.id_unidad_medida
ORDER BY p.codigo, i.nombre;

-- Consultar insumos faltantes
USE BDOlivarGrill;
GO

DECLARE @StockInicial TABLE (
    insumo_nombre VARCHAR(100) NOT NULL
);

INSERT INTO @StockInicial (insumo_nombre)
VALUES
('Pollo entero'),
('Pierna de pollo'),
('Pechuga de pollo'),
('Lomo fino'),
('Churrasco'),
('Chuleta de cerdo'),
('Costilla de cerdo'),
('Anticucho'),
('Chorizo parrillero'),
('Bife'),
('Alitas de pollo'),
('Mollejitas de pollo'),
('Papa blanca'),
('Papa amarilla'),
('Arroz'),
('Fideo fettuccini'),
('Fideo tallarin chino'),
('Fideo cabello de angel'),
('Choclo'),
('Camote'),
('Yuca'),
('Platano'),
('Salchicha Frankfurt'),
('Huevo'),
('Wantan'),
('Lechuga'),
('Tomate'),
('Pepino'),
('Zanahoria'),
('Beterraga'),
('Cebolla roja'),
('Cebolla china'),
('Aji amarillo'),
('Ajo molido'),
('Vainita'),
('Espinaca'),
('Zapallo'),
('Palta'),
('Queso fresco'),
('Queso pasteurizado'),
('Queso Edam'),
('Jamon ingles'),
('Tocino ahumado'),
('Leche evaporada'),
('Leche condensada'),
('Mayonesa'),
('Ketchup'),
('Mostaza'),
('Crema de aji'),
('Salsa huacatay'),
('Salsa huancaina'),
('Salsa pesto'),
('Salsa alfredo'),
('Sal'),
('Pimienta'),
('Comino'),
('Sillao'),
('Vinagre'),
('Aceite vegetal'),
('Limon'),
('Azucar'),
('Gaseosa personal'),
('Gaseosa 1 litro'),
('Gaseosa 1.5 litros'),
('Agua mineral personal'),
('Chicha morada preparada'),
('Maracuya preparada'),
('Limonada preparada'),
('Te filtrante'),
('Manzanilla filtrante'),
('Anis filtrante'),
('Hierba luisa filtrante'),
('Crema volteada'),
('Torta de chocolate'),
('Mazamorra morada'),
('Arroz con leche'),
('Base tres leches'),
('Base cheesecake'),
('Base selva negra'),
('Langostino'),
('Cecina'),
('Bolsa delivery'),
('Envase descartable'),
('Cubiertos descartables'),
('Vaso descartable');

SELECT 
    si.insumo_nombre AS insumo_faltante
FROM @StockInicial si
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Insumo i
    WHERE i.nombre = si.insumo_nombre
)
ORDER BY si.insumo_nombre;

-- 15. Validar si se ejecuto correctamente el script 10_initial_movements_data.sql
SELECT COUNT(*) AS total_movimientos_inventario
FROM dbo.MovimientoInventario
WHERE motivo = 'Carga inicial de inventario - Bloque 10';

SELECT
    i.nombre AS insumo,
    i.stock_actual,
    i.stock_minimo,
    i.costo_unitario,
    um.abreviatura AS unidad
FROM dbo.Insumo i
INNER JOIN dbo.UnidadMedida um
    ON um.id_unidad_medida = i.id_unidad_medida
ORDER BY i.nombre;

SELECT
    i.nombre AS insumo,
    mi.tipo_movimiento,
    mi.cantidad,
    mi.stock_anterior,
    mi.stock_resultante,
    mi.costo_unitario,
    mi.motivo,
    mi.fecha_hora_movimiento
FROM dbo.MovimientoInventario mi
INNER JOIN dbo.Insumo i
    ON i.id_insumo = mi.id_insumo
WHERE mi.motivo = 'Carga inicial de inventario - Bloque 10'
ORDER BY i.nombre;

SELECT
    i.nombre AS insumo,
    i.stock_actual,
    i.stock_minimo
FROM dbo.Insumo i
WHERE i.stock_actual <= i.stock_minimo
ORDER BY i.nombre;

-- 16. Validar si se ejecuto correctamente el script 11_user_roles_data.sql
SELECT
    u.id_usuario,
    u.nombre_completo,
    u.cargo,
    r.nombre AS rol,
    ur.activo
FROM dbo.UsuarioRol ur
INNER JOIN dbo.Usuario u
    ON u.id_usuario = ur.id_usuario
INNER JOIN dbo.Rol r
    ON r.id_rol = ur.id_rol
ORDER BY u.id_usuario, r.nombre;

SELECT
    r.nombre AS rol,
    COUNT(rp.id_permiso) AS total_permisos
FROM dbo.Rol r
LEFT JOIN dbo.RolPermiso rp
    ON rp.id_rol = r.id_rol
   AND rp.activo = 1
GROUP BY r.nombre
ORDER BY r.nombre;

SELECT
    r.nombre AS rol,
    p.modulo,
    p.codigo,
    p.nombre AS permiso
FROM dbo.RolPermiso rp
INNER JOIN dbo.Rol r
    ON r.id_rol = rp.id_rol
INNER JOIN dbo.Permiso p
    ON p.id_permiso = rp.id_permiso
WHERE rp.activo = 1
ORDER BY r.nombre, p.modulo, p.codigo;

-- 17. Validar si se ejecuto correctamente el script 12_test_orders_data.sql
SELECT
    p.numero_pedido,
    p.tipo,
    p.canal,
    p.estado_actual,
    p.subtotal,
    p.costo_delivery,
    p.total_con_igv,
    p.observaciones_generales
FROM dbo.Pedido p
WHERE p.numero_pedido IN (
    'PED-PRUEBA-002',
    'PED-PRUEBA-003',
    'PED-PRUEBA-004',
    'PED-PRUEBA-005'
)
ORDER BY p.numero_pedido;

SELECT
    p.numero_pedido,
    prod.codigo,
    prod.nombre AS producto,
    pv.codigo_variante,
    pv.nombre_variante,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal
FROM dbo.DetallePedido dp
INNER JOIN dbo.Pedido p
    ON p.id_pedido = dp.id_pedido
INNER JOIN dbo.Producto prod
    ON prod.id_producto = dp.id_producto
LEFT JOIN dbo.ProductoVariante pv
    ON pv.id_variante = dp.id_variante
WHERE p.numero_pedido IN (
    'PED-PRUEBA-002',
    'PED-PRUEBA-003',
    'PED-PRUEBA-004',
    'PED-PRUEBA-005'
)
ORDER BY p.numero_pedido, dp.id_detalle_pedido;

SELECT
    p.numero_pedido,
    cp.numero_cuenta,
    cp.subtotal,
    cp.descuento,
    cp.total,
    cp.estado_cuenta
FROM dbo.CuentaPedido cp
INNER JOIN dbo.Pedido p
    ON p.id_pedido = cp.id_pedido
WHERE p.numero_pedido IN (
    'PED-PRUEBA-002',
    'PED-PRUEBA-003',
    'PED-PRUEBA-004',
    'PED-PRUEBA-005'
)
ORDER BY p.numero_pedido;

SELECT
    p.numero_pedido,
    mp.nombre AS metodo_pago,
    pg.monto,
    pg.referencia_pago,
    pg.estado_pago
FROM dbo.Pago pg
INNER JOIN dbo.Pedido p
    ON p.id_pedido = pg.id_pedido
INNER JOIN dbo.MetodoPago mp
    ON mp.id_metodo_pago = pg.id_metodo_pago
WHERE p.numero_pedido IN (
    'PED-PRUEBA-002',
    'PED-PRUEBA-003',
    'PED-PRUEBA-004',
    'PED-PRUEBA-005'
)
ORDER BY p.numero_pedido;

SELECT
    p.numero_pedido,
    tc.nombre AS tipo_comprobante,
    c.serie,
    c.numero,
    c.subtotal,
    c.impuesto,
    c.total,
    c.estado_comprobante,
    c.observaciones
FROM dbo.Comprobante c
INNER JOIN dbo.Pedido p
    ON p.id_pedido = c.id_pedido
INNER JOIN dbo.TipoComprobante tc
    ON tc.id_tipo_comprobante = c.id_tipo_comprobante
WHERE p.numero_pedido IN (
    'PED-PRUEBA-002',
    'PED-PRUEBA-003',
    'PED-PRUEBA-004',
    'PED-PRUEBA-005'
)
ORDER BY p.numero_pedido;
