USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 13 - VALIDACION FINAL DE CONSISTENCIA
   Ejecutar despues del BLOQUE 12

   Este bloque NO modifica data.
   Solo muestra diagnosticos y posibles inconsistencias.
   ========================================================= */

SET NOCOUNT ON;
GO

/* =========================================================
   1. RESUMEN GENERAL DE TABLAS PRINCIPALES
   ========================================================= */
SELECT 'CategoriaProducto' AS tabla, COUNT(*) AS total FROM dbo.CategoriaProducto
UNION ALL SELECT 'Producto', COUNT(*) FROM dbo.Producto
UNION ALL SELECT 'ProductoImagen', COUNT(*) FROM dbo.ProductoImagen
UNION ALL SELECT 'Menu', COUNT(*) FROM dbo.Menu
UNION ALL SELECT 'MenuProducto', COUNT(*) FROM dbo.MenuProducto
UNION ALL SELECT 'Modificador', COUNT(*) FROM dbo.Modificador
UNION ALL SELECT 'OpcionModificador', COUNT(*) FROM dbo.OpcionModificador
UNION ALL SELECT 'ProductoModificador', COUNT(*) FROM dbo.ProductoModificador
UNION ALL SELECT 'ProductoVariante', COUNT(*) FROM dbo.ProductoVariante
UNION ALL SELECT 'ProductoVarianteOpcion', COUNT(*) FROM dbo.ProductoVarianteOpcion
UNION ALL SELECT 'ProductoComponente', COUNT(*) FROM dbo.ProductoComponente
UNION ALL SELECT 'Insumo', COUNT(*) FROM dbo.Insumo
UNION ALL SELECT 'RecetaProducto', COUNT(*) FROM dbo.RecetaProducto
UNION ALL SELECT 'MovimientoInventario', COUNT(*) FROM dbo.MovimientoInventario
UNION ALL SELECT 'Pedido', COUNT(*) FROM dbo.Pedido
UNION ALL SELECT 'DetallePedido', COUNT(*) FROM dbo.DetallePedido
UNION ALL SELECT 'CuentaPedido', COUNT(*) FROM dbo.CuentaPedido
UNION ALL SELECT 'Pago', COUNT(*) FROM dbo.Pago
UNION ALL SELECT 'Comprobante', COUNT(*) FROM dbo.Comprobante
UNION ALL SELECT 'Usuario', COUNT(*) FROM dbo.Usuario
UNION ALL SELECT 'Rol', COUNT(*) FROM dbo.Rol
UNION ALL SELECT 'UsuarioRol', COUNT(*) FROM dbo.UsuarioRol
UNION ALL SELECT 'Permiso', COUNT(*) FROM dbo.Permiso
UNION ALL SELECT 'RolPermiso', COUNT(*) FROM dbo.RolPermiso;
GO


/* =========================================================
   2. PRODUCTOS POR CATEGORIA
   ========================================================= */
SELECT
    c.nombre AS categoria,
    COUNT(p.id_producto) AS total_productos
FROM dbo.CategoriaProducto c
LEFT JOIN dbo.Producto p
    ON p.id_categoria = c.id_categoria
GROUP BY c.nombre, c.orden_visual
ORDER BY c.orden_visual;
GO


/* =========================================================
   3. PRODUCTOS SIN IMAGEN PRINCIPAL
   Resultado esperado: 0 filas o muy pocas.
   ========================================================= */
SELECT
    p.codigo,
    p.nombre,
    p.imagen_principal_url
FROM dbo.Producto p
WHERE p.activo = 1
  AND (
        p.imagen_principal_url IS NULL
        OR LTRIM(RTRIM(p.imagen_principal_url)) = ''
      )
ORDER BY p.codigo;
GO


/* =========================================================
   4. PRODUCTOS ACTIVOS QUE NO APARECEN EN NINGUN MENU
   Resultado esperado: solo productos auxiliares si existieran.
   ========================================================= */
SELECT
    p.codigo,
    p.nombre,
    c.nombre AS categoria
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
WHERE p.activo = 1
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.MenuProducto mp
      WHERE mp.id_producto = p.id_producto
        AND mp.activo = 1
  )
ORDER BY c.orden_visual, p.codigo;
GO


/* =========================================================
   5. PRODUCTOS POR MENU
   ========================================================= */
SELECT
    m.codigo AS codigo_menu,
    m.nombre AS menu,
    COUNT(mp.id_menu_producto) AS total_items
FROM dbo.Menu m
LEFT JOIN dbo.MenuProducto mp
    ON mp.id_menu = m.id_menu
   AND mp.activo = 1
GROUP BY m.codigo, m.nombre
ORDER BY m.codigo;
GO


/* =========================================================
   6. REVISION DE PRECIOS VISIBLES EN MENU
   ========================================================= */
SELECT
    m.codigo AS codigo_menu,
    p.codigo AS codigo_producto,
    p.nombre AS producto,
    pv.codigo_variante,
    pv.nombre_variante,
    p.precio_base,
    pv.precio AS precio_variante,
    mp.precio_menu,
    mp.usa_precio_base,
    CASE
        WHEN mp.usa_precio_base = 1 THEN p.precio_base
        WHEN mp.precio_menu IS NOT NULL THEN mp.precio_menu
        WHEN pv.precio IS NOT NULL THEN pv.precio
        ELSE p.precio_base
    END AS precio_visible,
    mp.visible,
    mp.activo
FROM dbo.MenuProducto mp
INNER JOIN dbo.Menu m
    ON m.id_menu = mp.id_menu
INNER JOIN dbo.Producto p
    ON p.id_producto = mp.id_producto
LEFT JOIN dbo.ProductoVariante pv
    ON pv.id_variante = mp.id_variante
ORDER BY m.codigo, mp.orden_visual;
GO


/* =========================================================
   7. VARIANTES DE PASTAS Y OPCIONES ASOCIADAS
   Resultado esperado:
   Cada variante deberia tener 2 opciones:
   - Salsa de pasta
   - Complemento de pasta
   ========================================================= */
SELECT
    p.codigo AS producto_codigo,
    p.nombre AS producto,
    pv.codigo_variante,
    pv.nombre_variante,
    pv.precio,
    COUNT(pvo.id_opcion) AS total_opciones_variante
FROM dbo.ProductoVariante pv
INNER JOIN dbo.Producto p
    ON p.id_producto = pv.id_producto
LEFT JOIN dbo.ProductoVarianteOpcion pvo
    ON pvo.id_variante = pv.id_variante
WHERE p.codigo IN ('PAS001', 'PAS002', 'PAS003')
GROUP BY
    p.codigo,
    p.nombre,
    pv.codigo_variante,
    pv.nombre_variante,
    pv.precio,
    pv.orden_visual
ORDER BY p.codigo, pv.orden_visual;
GO


/* =========================================================
   8. PRODUCTOS CON MODIFICADORES
   ========================================================= */
SELECT
    p.codigo,
    p.nombre AS producto,
    COUNT(pm.id_modificador) AS total_modificadores
FROM dbo.Producto p
LEFT JOIN dbo.ProductoModificador pm
    ON pm.id_producto = p.id_producto
WHERE p.activo = 1
GROUP BY p.codigo, p.nombre
ORDER BY p.codigo;
GO


/* =========================================================
   9. REGLAS DE MODIFICADORES INVALIDAS
   Resultado esperado: 0 filas.
   ========================================================= */
SELECT
    p.codigo,
    p.nombre AS producto,
    m.nombre AS modificador,
    pm.min_selecciones,
    pm.max_selecciones,
    pm.es_obligatorio
FROM dbo.ProductoModificador pm
INNER JOIN dbo.Producto p
    ON p.id_producto = pm.id_producto
INNER JOIN dbo.Modificador m
    ON m.id_modificador = pm.id_modificador
WHERE pm.min_selecciones < 0
   OR pm.max_selecciones < 0
   OR pm.min_selecciones > pm.max_selecciones
   OR (pm.es_obligatorio = 1 AND pm.min_selecciones = 0)
ORDER BY p.codigo, m.nombre;
GO


/* =========================================================
   10. COMBOS Y COMPONENTES
   ========================================================= */
SELECT
    padre.codigo AS codigo_combo,
    padre.nombre AS combo,
    COUNT(pc.id_producto_hijo) AS total_componentes
FROM dbo.ProductoComponente pc
INNER JOIN dbo.Producto padre
    ON padre.id_producto = pc.id_producto_padre
GROUP BY padre.codigo, padre.nombre
ORDER BY padre.codigo;
GO


/* =========================================================
   11. DETALLE DE COMPONENTES DE COMBOS
   ========================================================= */
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
GO


/* =========================================================
   12. PRODUCTOS SIN RECETA
   Resultado esperado:
   Puede haber algunos productos sin receta si son auxiliares
   o si aun no se modelaron sus insumos.
   ========================================================= */
SELECT
    p.codigo,
    p.nombre,
    c.nombre AS categoria
FROM dbo.Producto p
INNER JOIN dbo.CategoriaProducto c
    ON c.id_categoria = p.id_categoria
WHERE p.activo = 1
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.RecetaProducto rp
      WHERE rp.id_producto = p.id_producto
  )
ORDER BY c.orden_visual, p.codigo;
GO


/* =========================================================
   13. RECETAS POR PRODUCTO
   ========================================================= */
SELECT
    p.codigo,
    p.nombre AS producto,
    COUNT(rp.id_insumo) AS total_insumos_receta
FROM dbo.Producto p
LEFT JOIN dbo.RecetaProducto rp
    ON rp.id_producto = p.id_producto
WHERE p.activo = 1
GROUP BY p.codigo, p.nombre
ORDER BY p.codigo;
GO


/* =========================================================
   14. INSUMOS CON STOCK BAJO
   Resultado esperado: 0 filas despues del Bloque 10.
   ========================================================= */
SELECT
    i.nombre AS insumo,
    i.stock_actual,
    i.stock_minimo,
    um.abreviatura AS unidad
FROM dbo.Insumo i
INNER JOIN dbo.UnidadMedida um
    ON um.id_unidad_medida = i.id_unidad_medida
WHERE i.stock_actual <= i.stock_minimo
ORDER BY i.nombre;
GO


/* =========================================================
   15. MOVIMIENTOS INICIALES DE INVENTARIO
   ========================================================= */
SELECT
    COUNT(*) AS total_movimientos_iniciales
FROM dbo.MovimientoInventario
WHERE motivo = 'Carga inicial de inventario - Bloque 10';
GO


/* =========================================================
   16. PEDIDOS DE PRUEBA
   ========================================================= */
SELECT
    p.numero_pedido,
    p.tipo,
    p.canal,
    p.estado_actual,
    p.subtotal,
    p.descuento_monto,
    p.costo_delivery,
    p.total_con_igv
FROM dbo.Pedido p
WHERE p.numero_pedido LIKE 'PED-PRUEBA-%'
ORDER BY p.numero_pedido;
GO


/* =========================================================
   17. CUADRE PEDIDO VS DETALLE
   Diferencia esperada: 0.00
   ========================================================= */
SELECT
    p.numero_pedido,
    p.subtotal AS subtotal_pedido,
    CAST(ISNULL(SUM(dp.subtotal), 0.00) AS DECIMAL(10,2)) AS subtotal_detalle,
    CAST(p.subtotal - ISNULL(SUM(dp.subtotal), 0.00) AS DECIMAL(10,2)) AS diferencia
FROM dbo.Pedido p
LEFT JOIN dbo.DetallePedido dp
    ON dp.id_pedido = p.id_pedido
WHERE p.numero_pedido LIKE 'PED-PRUEBA-%'
GROUP BY p.numero_pedido, p.subtotal
ORDER BY p.numero_pedido;
GO


/* =========================================================
   18. CUADRE CUENTA VS PEDIDO
   Diferencia esperada: 0.00
   ========================================================= */
SELECT
    p.numero_pedido,
    p.total_con_igv AS total_pedido,
    cp.total AS total_cuenta,
    CAST(p.total_con_igv - cp.total AS DECIMAL(10,2)) AS diferencia
FROM dbo.Pedido p
INNER JOIN dbo.CuentaPedido cp
    ON cp.id_pedido = p.id_pedido
WHERE p.numero_pedido LIKE 'PED-PRUEBA-%'
ORDER BY p.numero_pedido, cp.numero_cuenta;
GO


/* =========================================================
   19. PAGOS Y COMPROBANTES
   ========================================================= */
SELECT
    p.numero_pedido,
    p.estado_actual,
    mp.nombre AS metodo_pago,
    pg.monto AS monto_pago,
    tc.nombre AS tipo_comprobante,
    c.serie,
    c.numero,
    c.total AS total_comprobante,
    c.estado_comprobante
FROM dbo.Pedido p
LEFT JOIN dbo.Pago pg
    ON pg.id_pedido = p.id_pedido
LEFT JOIN dbo.MetodoPago mp
    ON mp.id_metodo_pago = pg.id_metodo_pago
LEFT JOIN dbo.Comprobante c
    ON c.id_pago = pg.id_pago
LEFT JOIN dbo.TipoComprobante tc
    ON tc.id_tipo_comprobante = c.id_tipo_comprobante
WHERE p.numero_pedido LIKE 'PED-PRUEBA-%'
ORDER BY p.numero_pedido;
GO


/* =========================================================
   20. COMPROBANTES SIN PAGO
   Resultado esperado: 0 filas.
   ========================================================= */
SELECT
    c.id_comprobante,
    c.serie,
    c.numero,
    c.total,
    c.estado_comprobante
FROM dbo.Comprobante c
WHERE c.id_pago IS NULL
   OR NOT EXISTS (
       SELECT 1
       FROM dbo.Pago pg
       WHERE pg.id_pago = c.id_pago
   )
ORDER BY c.id_comprobante;
GO


/* =========================================================
   21. PAGOS SIN COMPROBANTE
   Resultado esperado:
   Puede ser 0 si todos los pagos generan comprobante.
   ========================================================= */
SELECT
    pg.id_pago,
    p.numero_pedido,
    pg.monto,
    pg.referencia_pago,
    pg.estado_pago
FROM dbo.Pago pg
INNER JOIN dbo.Pedido p
    ON p.id_pedido = pg.id_pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Comprobante c
    WHERE c.id_pago = pg.id_pago
)
ORDER BY pg.id_pago;
GO


/* =========================================================
   22. USUARIOS, ROLES Y PERMISOS
   ========================================================= */
SELECT
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
GO


/* =========================================================
   23. PERMISOS POR ROL
   ========================================================= */
SELECT
    r.nombre AS rol,
    COUNT(rp.id_permiso) AS total_permisos
FROM dbo.Rol r
LEFT JOIN dbo.RolPermiso rp
    ON rp.id_rol = r.id_rol
   AND rp.activo = 1
GROUP BY r.nombre
ORDER BY r.nombre;
GO


/* =========================================================
   24. RESUMEN DE ALERTAS PRINCIPALES
   Si total_observaciones = 0, esa regla esta OK.
   ========================================================= */
SELECT
    'Productos activos sin imagen principal' AS validacion,
    COUNT(*) AS total_observaciones
FROM dbo.Producto p
WHERE p.activo = 1
  AND (
        p.imagen_principal_url IS NULL
        OR LTRIM(RTRIM(p.imagen_principal_url)) = ''
      )

UNION ALL

SELECT
    'Productos activos fuera de menus',
    COUNT(*)
FROM dbo.Producto p
WHERE p.activo = 1
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.MenuProducto mp
      WHERE mp.id_producto = p.id_producto
        AND mp.activo = 1
  )

UNION ALL

SELECT
    'Variantes de pasta sin 2 opciones',
    COUNT(*)
FROM (
    SELECT
        pv.id_variante,
        COUNT(pvo.id_opcion) AS total_opciones
    FROM dbo.ProductoVariante pv
    INNER JOIN dbo.Producto p
        ON p.id_producto = pv.id_producto
    LEFT JOIN dbo.ProductoVarianteOpcion pvo
        ON pvo.id_variante = pv.id_variante
    WHERE p.codigo IN ('PAS001', 'PAS002', 'PAS003')
    GROUP BY pv.id_variante
    HAVING COUNT(pvo.id_opcion) <> 2
) x

UNION ALL

SELECT
    'Reglas ProductoModificador invalidas',
    COUNT(*)
FROM dbo.ProductoModificador pm
WHERE pm.min_selecciones < 0
   OR pm.max_selecciones < 0
   OR pm.min_selecciones > pm.max_selecciones
   OR (pm.es_obligatorio = 1 AND pm.min_selecciones = 0)

UNION ALL

SELECT
    'Insumos con stock bajo',
    COUNT(*)
FROM dbo.Insumo i
WHERE i.stock_actual <= i.stock_minimo

UNION ALL

SELECT
    'Comprobantes sin pago valido',
    COUNT(*)
FROM dbo.Comprobante c
WHERE c.id_pago IS NULL
   OR NOT EXISTS (
       SELECT 1
       FROM dbo.Pago pg
       WHERE pg.id_pago = c.id_pago
   )

UNION ALL

SELECT
    'Pedidos de prueba descuadrados contra detalle',
    COUNT(*)
FROM (
    SELECT
        p.id_pedido,
        p.subtotal,
        CAST(ISNULL(SUM(dp.subtotal), 0.00) AS DECIMAL(10,2)) AS subtotal_detalle
    FROM dbo.Pedido p
    LEFT JOIN dbo.DetallePedido dp
        ON dp.id_pedido = p.id_pedido
    WHERE p.numero_pedido LIKE 'PED-PRUEBA-%'
    GROUP BY p.id_pedido, p.subtotal
    HAVING CAST(p.subtotal - ISNULL(SUM(dp.subtotal), 0.00) AS DECIMAL(10,2)) <> 0.00
) y

UNION ALL

SELECT
    'Pedidos pagados sin comprobante',
    COUNT(*)
FROM dbo.Pedido p
WHERE p.estado_actual = 'Pagado'
  AND p.numero_pedido LIKE 'PED-PRUEBA-%'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Comprobante c
      WHERE c.id_pedido = p.id_pedido
  );
GO
