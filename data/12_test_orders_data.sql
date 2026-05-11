USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 12 - MAS PEDIDOS DE PRUEBA
   Ejecutar despues del BLOQUE 11

   Este bloque prueba:
   - Pago Yape + boleta
   - Delivery + Plin + boleta
   - Factura + transferencia
   - Pedido anulado

   Requiere:
   - Productos cargados
   - MenuProducto cargado
   - SesionCaja abierta o Caja Principal creada
   - MetodoPago: Yape, Plin, Transferencia
   - TipoComprobante: Boleta y Factura
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   1. VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.Pedido', N'U') IS NULL
    THROW 63000, 'No existe dbo.Pedido.', 1;

IF OBJECT_ID(N'dbo.DetallePedido', N'U') IS NULL
    THROW 63001, 'No existe dbo.DetallePedido.', 1;

IF OBJECT_ID(N'dbo.Pago', N'U') IS NULL
    THROW 63002, 'No existe dbo.Pago.', 1;

IF OBJECT_ID(N'dbo.Comprobante', N'U') IS NULL
    THROW 63003, 'No existe dbo.Comprobante.', 1;

IF OBJECT_ID(N'dbo.CuentaPedido', N'U') IS NULL
    THROW 63004, 'No existe dbo.CuentaPedido.', 1;


/* =========================================================
   2. VARIABLES BASE
   ========================================================= */
DECLARE @id_sucursal INT;
DECLARE @id_mozo INT;
DECLARE @id_cajero INT;
DECLARE @id_caja INT;
DECLARE @id_sesion_caja INT;
DECLARE @id_estado_registrado INT;
DECLARE @id_estado_pagado INT;
DECLARE @id_estado_anulado INT;

SELECT @id_sucursal = id_sucursal
FROM dbo.Sucursal
WHERE codigo = 'PP01';

SELECT TOP 1 @id_mozo = id_usuario
FROM dbo.Usuario
WHERE cargo = 'MOZO'
ORDER BY id_usuario;

SELECT TOP 1 @id_cajero = id_usuario
FROM dbo.Usuario
WHERE cargo IN ('CAJERO', 'ADMIN')
ORDER BY CASE WHEN cargo = 'CAJERO' THEN 1 ELSE 2 END, id_usuario;

SELECT TOP 1 @id_caja = id_caja
FROM dbo.Caja
WHERE nombre_caja = 'Caja Principal'
ORDER BY id_caja;

SELECT @id_estado_registrado = id_estado_pedido
FROM dbo.EstadoPedido
WHERE nombre = 'Registrado';

SELECT @id_estado_pagado = id_estado_pedido
FROM dbo.EstadoPedido
WHERE nombre = 'Pagado';

SELECT @id_estado_anulado = id_estado_pedido
FROM dbo.EstadoPedido
WHERE nombre = 'Anulado';

IF @id_sucursal IS NULL
    THROW 63005, 'No existe Sucursal PP01.', 1;

IF @id_mozo IS NULL
    THROW 63006, 'No existe usuario MOZO.', 1;

IF @id_cajero IS NULL
    THROW 63007, 'No existe usuario CAJERO o ADMIN.', 1;

IF @id_caja IS NULL
    THROW 63008, 'No existe Caja Principal.', 1;


/* =========================================================
   3. ASEGURAR SESION DE CAJA ABIERTA
   ========================================================= */
SELECT TOP 1 @id_sesion_caja = id_sesion_caja
FROM dbo.SesionCaja
WHERE id_caja = @id_caja
  AND estado_sesion = 'ABIERTA'
ORDER BY id_sesion_caja DESC;

IF @id_sesion_caja IS NULL
BEGIN
    INSERT INTO dbo.SesionCaja
        (id_caja, id_usuario_apertura, fecha_hora_apertura,
         monto_inicial, estado_sesion, observaciones)
    VALUES
        (@id_caja, @id_cajero, SYSDATETIME(),
         200.00, 'ABIERTA', 'Sesion de caja abierta para pruebas del bloque 12.');

    SET @id_sesion_caja = SCOPE_IDENTITY();
END;


/* =========================================================
   4. PEDIDOS DE PRUEBA
   ========================================================= */
DECLARE @Pedidos TABLE (
    numero_pedido VARCHAR(20) NOT NULL,
    tipo VARCHAR(15) NOT NULL,
    canal VARCHAR(20) NOT NULL,
    cliente_dni VARCHAR(8) NOT NULL,
    costo_delivery DECIMAL(10,2) NOT NULL,
    estado_final VARCHAR(20) NOT NULL,
    metodo_pago VARCHAR(30) NULL,
    referencia_pago VARCHAR(100) NULL,
    tipo_comprobante_sunat VARCHAR(2) NULL,
    serie VARCHAR(10) NULL,
    numero_comprobante VARCHAR(20) NULL,
    observaciones VARCHAR(MAX) NULL
);

INSERT INTO @Pedidos
    (numero_pedido, tipo, canal, cliente_dni, costo_delivery, estado_final,
     metodo_pago, referencia_pago, tipo_comprobante_sunat,
     serie, numero_comprobante, observaciones)
VALUES
('PED-PRUEBA-002', 'MESA', 'SALON', '11111111', 0.00, 'Pagado',
 'Yape', 'YAPE-PRUEBA-002', '03',
 'B001', '00000002',
 'Pedido de prueba pagado con Yape.'),

('PED-PRUEBA-003', 'DELIVERY', 'WHATSAPP', '22222222', 5.00, 'Pagado',
 'Plin', 'PLIN-PRUEBA-003', '03',
 'B001', '00000003',
 'Pedido delivery de prueba pagado con Plin.'),

('PED-PRUEBA-004', 'MESA', 'SALON', '00000000', 0.00, 'Pagado',
 'Transferencia', 'TRANSF-PRUEBA-004', '01',
 'F001', '00000001',
 'Factura de prueba. RUC receptor: 20600000001. Razon social: Empresa Demo SAC.'),

('PED-PRUEBA-005', 'MESA', 'SALON', '00000000', 0.00, 'Anulado',
 NULL, NULL, NULL,
 NULL, NULL,
 'Pedido de prueba anulado antes del pago.');


/* =========================================================
   5. INSERTAR PEDIDOS
   ========================================================= */
INSERT INTO dbo.Pedido
    (numero_pedido, fecha_hora_creacion, tipo, canal,
     estado_actual, id_mozo_asignado, id_cliente_fidelizacion,
     subtotal, descuento_monto, costo_delivery, total_con_igv,
     observaciones_generales, tiempo_estimado, id_sucursal)
SELECT
    p.numero_pedido,
    SYSDATETIME(),
    p.tipo,
    p.canal,
    'Registrado',
    @id_mozo,
    c.id_cliente,
    0.00,
    0.00,
    p.costo_delivery,
    0.00,
    p.observaciones,
    CASE WHEN p.tipo = 'DELIVERY' THEN 45 ELSE 25 END,
    @id_sucursal
FROM @Pedidos p
INNER JOIN dbo.Cliente c
    ON c.dni = p.cliente_dni
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Pedido x
    WHERE x.numero_pedido = p.numero_pedido
);


/* =========================================================
   6. HISTORIAL INICIAL
   ========================================================= */
IF @id_estado_registrado IS NOT NULL
BEGIN
    INSERT INTO dbo.HistorialEstadoPedido
        (id_pedido, id_estado_pedido, fecha_hora_cambio,
         id_usuario, motivo, observaciones)
    SELECT
        ped.id_pedido,
        @id_estado_registrado,
        SYSDATETIME(),
        @id_mozo,
        'Registro inicial',
        'Pedido creado desde bloque 12.'
    FROM dbo.Pedido ped
    INNER JOIN @Pedidos data
        ON data.numero_pedido = ped.numero_pedido
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.HistorialEstadoPedido h
        WHERE h.id_pedido = ped.id_pedido
          AND h.id_estado_pedido = @id_estado_registrado
    );
END;


/* =========================================================
   7. DETALLES DE LOS PEDIDOS
   ========================================================= */
DECLARE @Detalles TABLE (
    numero_pedido VARCHAR(20) NOT NULL,
    producto_codigo VARCHAR(10) NOT NULL,
    codigo_variante VARCHAR(20) NULL,
    cantidad INT NOT NULL,
    observaciones VARCHAR(MAX) NULL
);

INSERT INTO @Detalles
    (numero_pedido, producto_codigo, codigo_variante, cantidad, observaciones)
VALUES
/* PED-PRUEBA-002: Yape + boleta */
('PED-PRUEBA-002', 'PAS001', 'PESTO-LOMO', 1, 'Fetuccini al pesto con lomo.'),
('PED-PRUEBA-002', 'BEB018', NULL, 1, 'Vaso de chicha morada.'),
('PED-PRUEBA-002', 'POS001', NULL, 1, 'Crema volteada.'),

/* PED-PRUEBA-003: delivery + Plin */
('PED-PRUEBA-003', 'OFE001', NULL, 1, 'Pollo a la brasa para dos.'),
('PED-PRUEBA-003', 'BEB011', NULL, 1, 'Jarra de chicha morada.'),

/* PED-PRUEBA-004: factura + transferencia */
('PED-PRUEBA-004', 'FAM002', NULL, 1, 'Parrilla para dos.'),
('PED-PRUEBA-004', 'BEB007', NULL, 1, 'Gaseosa de 1.5 litros.'),
('PED-PRUEBA-004', 'POS003', NULL, 1, 'Torta de chocolate.'),

/* PED-PRUEBA-005: anulado */
('PED-PRUEBA-005', 'ENT004', NULL, 1, 'Salchipapas anuladas antes del pago.');


/* Validar productos */
IF EXISTS (
    SELECT 1
    FROM @Detalles d
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = d.producto_codigo
    )
)
BEGIN
    SELECT DISTINCT d.producto_codigo AS producto_faltante
    FROM @Detalles d
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Producto p
        WHERE p.codigo = d.producto_codigo
    );

    THROW 63009, 'Hay productos faltantes para los pedidos de prueba.', 1;
END;

/* Validar variantes */
IF EXISTS (
    SELECT 1
    FROM @Detalles d
    INNER JOIN dbo.Producto p
        ON p.codigo = d.producto_codigo
    WHERE d.codigo_variante IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.ProductoVariante pv
          WHERE pv.id_producto = p.id_producto
            AND pv.codigo_variante = d.codigo_variante
      )
)
BEGIN
    SELECT d.producto_codigo, d.codigo_variante AS variante_faltante
    FROM @Detalles d
    INNER JOIN dbo.Producto p
        ON p.codigo = d.producto_codigo
    WHERE d.codigo_variante IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.ProductoVariante pv
          WHERE pv.id_producto = p.id_producto
            AND pv.codigo_variante = d.codigo_variante
      );

    THROW 63010, 'Hay variantes faltantes para los pedidos de prueba.', 1;
END;


/* Insertar detalles */
INSERT INTO dbo.DetallePedido
    (id_pedido, id_producto, id_variante, id_menu_producto,
     cantidad, precio_unitario, subtotal,
     observaciones, fecha_hora_registro)
SELECT
    ped.id_pedido,
    prod.id_producto,
    pv.id_variante,
    mp.id_menu_producto,
    d.cantidad,
    CAST(
        COALESCE(
            mp.precio_menu,
            pv.precio,
            prod.precio_base
        ) AS DECIMAL(10,2)
    ) AS precio_unitario,
    CAST(
        d.cantidad * COALESCE(
            mp.precio_menu,
            pv.precio,
            prod.precio_base
        ) AS DECIMAL(10,2)
    ) AS subtotal,
    d.observaciones,
    SYSDATETIME()
FROM @Detalles d
INNER JOIN dbo.Pedido ped
    ON ped.numero_pedido = d.numero_pedido
INNER JOIN dbo.Producto prod
    ON prod.codigo = d.producto_codigo
LEFT JOIN dbo.ProductoVariante pv
    ON pv.id_producto = prod.id_producto
   AND pv.codigo_variante = d.codigo_variante
OUTER APPLY (
    SELECT TOP 1 mp2.id_menu_producto, mp2.precio_menu
    FROM dbo.MenuProducto mp2
    INNER JOIN dbo.Menu m2
        ON m2.id_menu = mp2.id_menu
    WHERE mp2.id_producto = prod.id_producto
      AND m2.codigo = 'CARTA_GENERAL'
      AND (
            (d.codigo_variante IS NULL AND mp2.id_variante IS NULL)
            OR
            (d.codigo_variante IS NOT NULL AND mp2.id_variante = pv.id_variante)
          )
    ORDER BY mp2.orden_visual
) mp
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.DetallePedido x
    WHERE x.id_pedido = ped.id_pedido
      AND x.id_producto = prod.id_producto
      AND (
            (d.codigo_variante IS NULL AND x.id_variante IS NULL)
            OR
            (d.codigo_variante IS NOT NULL AND x.id_variante = pv.id_variante)
          )
);


/* =========================================================
   8. ACTUALIZAR TOTALES DE PEDIDOS
   ========================================================= */
UPDATE ped
SET
    ped.subtotal = tot.subtotal,
    ped.descuento_monto = 0.00,
    ped.costo_delivery = data.costo_delivery,
    ped.total_con_igv = tot.subtotal + data.costo_delivery
FROM dbo.Pedido ped
INNER JOIN @Pedidos data
    ON data.numero_pedido = ped.numero_pedido
CROSS APPLY (
    SELECT CAST(ISNULL(SUM(dp.subtotal), 0.00) AS DECIMAL(10,2)) AS subtotal
    FROM dbo.DetallePedido dp
    WHERE dp.id_pedido = ped.id_pedido
) tot;


/* =========================================================
   9. CREAR CUENTAS
   ========================================================= */
INSERT INTO dbo.CuentaPedido
    (id_pedido, numero_cuenta, nombre_referencia,
     subtotal, descuento, total, estado_cuenta, observaciones)
SELECT
    ped.id_pedido,
    1,
    'Cuenta principal',
    ped.subtotal,
    0.00,
    ped.total_con_igv,
    'ABIERTA',
    'Cuenta creada desde bloque 12.'
FROM dbo.Pedido ped
INNER JOIN @Pedidos data
    ON data.numero_pedido = ped.numero_pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.CuentaPedido cp
    WHERE cp.id_pedido = ped.id_pedido
      AND cp.numero_cuenta = 1
);

UPDATE cp
SET
    cp.subtotal = ped.subtotal,
    cp.descuento = 0.00,
    cp.total = ped.total_con_igv
FROM dbo.CuentaPedido cp
INNER JOIN dbo.Pedido ped
    ON ped.id_pedido = cp.id_pedido
INNER JOIN @Pedidos data
    ON data.numero_pedido = ped.numero_pedido
WHERE cp.numero_cuenta = 1;


/* =========================================================
   10. DETALLE DE CUENTA
   ========================================================= */
INSERT INTO dbo.DetalleCuentaPedido
    (id_cuenta_pedido, id_detalle_pedido,
     cantidad_asignada, monto_asignado, observaciones)
SELECT
    cp.id_cuenta_pedido,
    dp.id_detalle_pedido,
    dp.cantidad,
    dp.subtotal,
    'Asignado automaticamente desde bloque 12.'
FROM dbo.Pedido ped
INNER JOIN @Pedidos data
    ON data.numero_pedido = ped.numero_pedido
INNER JOIN dbo.CuentaPedido cp
    ON cp.id_pedido = ped.id_pedido
   AND cp.numero_cuenta = 1
INNER JOIN dbo.DetallePedido dp
    ON dp.id_pedido = ped.id_pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.DetalleCuentaPedido dcp
    WHERE dcp.id_cuenta_pedido = cp.id_cuenta_pedido
      AND dcp.id_detalle_pedido = dp.id_detalle_pedido
);


/* =========================================================
   11. PAGOS
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Pedidos p
    WHERE p.estado_final = 'Pagado'
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.MetodoPago mp
          WHERE mp.nombre = p.metodo_pago
      )
)
BEGIN
    SELECT DISTINCT p.metodo_pago AS metodo_pago_faltante
    FROM @Pedidos p
    WHERE p.estado_final = 'Pagado'
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.MetodoPago mp
          WHERE mp.nombre = p.metodo_pago
      );

    THROW 63011, 'Hay metodos de pago faltantes.', 1;
END;

INSERT INTO dbo.Pago
    (id_pedido, id_cuenta_pedido, id_sesion_caja, id_metodo_pago,
     fecha_hora_pago, monto, referencia_pago, estado_pago,
     id_usuario, observaciones)
SELECT
    ped.id_pedido,
    cp.id_cuenta_pedido,
    @id_sesion_caja,
    mp.id_metodo_pago,
    SYSDATETIME(),
    cp.total,
    data.referencia_pago,
    'CONFIRMADO',
    @id_cajero,
    'Pago de prueba generado desde bloque 12.'
FROM @Pedidos data
INNER JOIN dbo.Pedido ped
    ON ped.numero_pedido = data.numero_pedido
INNER JOIN dbo.CuentaPedido cp
    ON cp.id_pedido = ped.id_pedido
   AND cp.numero_cuenta = 1
INNER JOIN dbo.MetodoPago mp
    ON mp.nombre = data.metodo_pago
WHERE data.estado_final = 'Pagado'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Pago pg
      WHERE pg.id_pedido = ped.id_pedido
        AND pg.referencia_pago = data.referencia_pago
  );


/* =========================================================
   12. COMPROBANTES
   ========================================================= */
IF EXISTS (
    SELECT 1
    FROM @Pedidos p
    WHERE p.estado_final = 'Pagado'
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.TipoComprobante tc
          WHERE tc.codigo_sunat = p.tipo_comprobante_sunat
      )
)
BEGIN
    SELECT DISTINCT p.tipo_comprobante_sunat AS tipo_comprobante_faltante
    FROM @Pedidos p
    WHERE p.estado_final = 'Pagado'
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.TipoComprobante tc
          WHERE tc.codigo_sunat = p.tipo_comprobante_sunat
      );

    THROW 63012, 'Hay tipos de comprobante faltantes.', 1;
END;

INSERT INTO dbo.Comprobante
    (id_pedido, id_cuenta_pedido, id_pago, id_tipo_comprobante,
     serie, numero, fecha_hora_emision,
     subtotal, impuesto, total,
     estado_comprobante, observaciones)
SELECT
    ped.id_pedido,
    cp.id_cuenta_pedido,
    pg.id_pago,
    tc.id_tipo_comprobante,
    data.serie,
    data.numero_comprobante,
    SYSDATETIME(),
    ROUND(cp.total / 1.18, 2) AS subtotal,
    cp.total - ROUND(cp.total / 1.18, 2) AS impuesto,
    cp.total,
    'EMITIDO',
    data.observaciones
FROM @Pedidos data
INNER JOIN dbo.Pedido ped
    ON ped.numero_pedido = data.numero_pedido
INNER JOIN dbo.CuentaPedido cp
    ON cp.id_pedido = ped.id_pedido
   AND cp.numero_cuenta = 1
INNER JOIN dbo.Pago pg
    ON pg.id_pedido = ped.id_pedido
   AND pg.referencia_pago = data.referencia_pago
INNER JOIN dbo.TipoComprobante tc
    ON tc.codigo_sunat = data.tipo_comprobante_sunat
WHERE data.estado_final = 'Pagado'
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Comprobante c
      WHERE c.serie = data.serie
        AND c.numero = data.numero_comprobante
  );


/* =========================================================
   13. ACTUALIZAR ESTADOS FINALES
   ========================================================= */

/* Pedidos pagados */
UPDATE cp
SET cp.estado_cuenta = 'PAGADA'
FROM dbo.CuentaPedido cp
INNER JOIN dbo.Pedido ped
    ON ped.id_pedido = cp.id_pedido
INNER JOIN @Pedidos data
    ON data.numero_pedido = ped.numero_pedido
WHERE data.estado_final = 'Pagado';

UPDATE ped
SET ped.estado_actual = 'Pagado'
FROM dbo.Pedido ped
INNER JOIN @Pedidos data
    ON data.numero_pedido = ped.numero_pedido
WHERE data.estado_final = 'Pagado';

/* Pedidos anulados */
UPDATE cp
SET cp.estado_cuenta = 'ANULADA'
FROM dbo.CuentaPedido cp
INNER JOIN dbo.Pedido ped
    ON ped.id_pedido = cp.id_pedido
INNER JOIN @Pedidos data
    ON data.numero_pedido = ped.numero_pedido
WHERE data.estado_final = 'Anulado';

UPDATE ped
SET ped.estado_actual = 'Anulado'
FROM dbo.Pedido ped
INNER JOIN @Pedidos data
    ON data.numero_pedido = ped.numero_pedido
WHERE data.estado_final = 'Anulado';


/* =========================================================
   14. HISTORIAL DE ESTADOS FINALES
   ========================================================= */
IF @id_estado_pagado IS NOT NULL
BEGIN
    INSERT INTO dbo.HistorialEstadoPedido
        (id_pedido, id_estado_pedido, fecha_hora_cambio,
         id_usuario, motivo, observaciones)
    SELECT
        ped.id_pedido,
        @id_estado_pagado,
        SYSDATETIME(),
        @id_cajero,
        'Pago confirmado',
        'Pedido pagado desde bloque 12.'
    FROM dbo.Pedido ped
    INNER JOIN @Pedidos data
        ON data.numero_pedido = ped.numero_pedido
    WHERE data.estado_final = 'Pagado'
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.HistorialEstadoPedido h
          WHERE h.id_pedido = ped.id_pedido
            AND h.id_estado_pedido = @id_estado_pagado
      );
END;

IF @id_estado_anulado IS NOT NULL
BEGIN
    INSERT INTO dbo.HistorialEstadoPedido
        (id_pedido, id_estado_pedido, fecha_hora_cambio,
         id_usuario, motivo, observaciones)
    SELECT
        ped.id_pedido,
        @id_estado_anulado,
        SYSDATETIME(),
        @id_mozo,
        'Anulacion de prueba',
        'Pedido anulado desde bloque 12 antes del pago.'
    FROM dbo.Pedido ped
    INNER JOIN @Pedidos data
        ON data.numero_pedido = ped.numero_pedido
    WHERE data.estado_final = 'Anulado'
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.HistorialEstadoPedido h
          WHERE h.id_pedido = ped.id_pedido
            AND h.id_estado_pedido = @id_estado_anulado
      );
END;


COMMIT TRANSACTION;

PRINT 'BLOQUE 12 cargado correctamente: pedidos adicionales de prueba.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 12';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
