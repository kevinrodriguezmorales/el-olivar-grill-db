USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 8A - PEDIDO DE PRUEBA + DETALLE + CUENTA
   Ejecutar despues del BLOQUE 7

   Este bloque carga:
   - SesionCaja abierta
   - Pedido de prueba
   - DetallePedido
   - DetallePedidoOpcion
   - HistorialEstadoPedido
   - HistorialEstadoDetallePedido
   - CuentaPedido
   - DetalleCuentaPedido

   NO carga Pago ni Comprobante todavia.
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   1. VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.Pedido', N'U') IS NULL
    THROW 58000, 'No existe dbo.Pedido.', 1;

IF OBJECT_ID(N'dbo.DetallePedido', N'U') IS NULL
    THROW 58001, 'No existe dbo.DetallePedido.', 1;

IF OBJECT_ID(N'dbo.CuentaPedido', N'U') IS NULL
    THROW 58002, 'No existe dbo.CuentaPedido.', 1;

IF OBJECT_ID(N'dbo.DetalleCuentaPedido', N'U') IS NULL
    THROW 58003, 'No existe dbo.DetalleCuentaPedido.', 1;

IF OBJECT_ID(N'dbo.SesionCaja', N'U') IS NULL
    THROW 58004, 'No existe dbo.SesionCaja.', 1;

IF COL_LENGTH('dbo.Pedido', 'id_sucursal') IS NULL
    THROW 58005, 'Falta Pedido.id_sucursal. Ejecuta primero el script de mejora.', 1;

IF COL_LENGTH('dbo.DetallePedido', 'id_menu_producto') IS NULL
    THROW 58006, 'Falta DetallePedido.id_menu_producto. Ejecuta primero el script de mejora.', 1;

IF COL_LENGTH('dbo.DetallePedido', 'id_variante') IS NULL
    THROW 58007, 'Falta DetallePedido.id_variante. Ejecuta primero el script de mejora.', 1;


/* =========================================================
   2. VARIABLES BASE
   ========================================================= */
DECLARE @numero_pedido VARCHAR(20) = 'PED-PRUEBA-001';

DECLARE @id_sucursal INT;
DECLARE @id_cliente INT;
DECLARE @id_mozo INT;
DECLARE @id_cajero INT;
DECLARE @id_caja INT;
DECLARE @id_sesion_caja INT;
DECLARE @id_pedido INT;
DECLARE @id_cuenta_pedido INT;

DECLARE @id_estado_pedido_registrado INT;
DECLARE @id_estado_detalle_pendiente INT;

SELECT @id_sucursal = id_sucursal
FROM dbo.Sucursal
WHERE codigo = 'PP01';

SELECT @id_cliente = id_cliente
FROM dbo.Cliente
WHERE dni = '00000000';

SELECT TOP 1 @id_mozo = id_usuario
FROM dbo.Usuario
WHERE cargo = 'MOZO'
ORDER BY id_usuario;

SELECT TOP 1 @id_cajero = id_usuario
FROM dbo.Usuario
WHERE cargo IN ('CAJERO', 'ADMIN')
ORDER BY 
    CASE WHEN cargo = 'CAJERO' THEN 1 ELSE 2 END,
    id_usuario;

SELECT TOP 1 @id_caja = id_caja
FROM dbo.Caja
WHERE nombre_caja = 'Caja Principal'
ORDER BY id_caja;

SELECT @id_estado_pedido_registrado = id_estado_pedido
FROM dbo.EstadoPedido
WHERE nombre = 'Registrado';

SELECT @id_estado_detalle_pendiente = id_estado_detalle
FROM dbo.EstadoDetallePedido
WHERE nombre = 'Pendiente';

IF @id_sucursal IS NULL
    THROW 58008, 'No existe la sucursal PP01.', 1;

IF @id_cliente IS NULL
    THROW 58009, 'No existe el Cliente General con DNI 00000000.', 1;

IF @id_mozo IS NULL
    THROW 58010, 'No existe usuario con cargo MOZO.', 1;

IF @id_cajero IS NULL
    THROW 58011, 'No existe usuario CAJERO o ADMIN.', 1;

IF @id_caja IS NULL
    THROW 58012, 'No existe Caja Principal.', 1;

IF @id_estado_pedido_registrado IS NULL
    THROW 58013, 'No existe EstadoPedido Registrado.', 1;

IF @id_estado_detalle_pendiente IS NULL
    THROW 58014, 'No existe EstadoDetallePedido Pendiente.', 1;


/* =========================================================
   3. SESION DE CAJA ABIERTA
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
         200.00, 'ABIERTA', 'Sesion de caja abierta para pruebas.');

    SET @id_sesion_caja = SCOPE_IDENTITY();
END;


/* =========================================================
   4. CREAR PEDIDO DE PRUEBA
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM dbo.Pedido
    WHERE numero_pedido = @numero_pedido
)
BEGIN
    INSERT INTO dbo.Pedido
        (numero_pedido, fecha_hora_creacion, tipo, canal,
         estado_actual, id_mozo_asignado, id_cliente_fidelizacion,
         subtotal, descuento_monto, costo_delivery, total_con_igv,
         observaciones_generales, tiempo_estimado, id_sucursal)
    VALUES
        (@numero_pedido, SYSDATETIME(), 'MESA', 'SALON',
         'Registrado', @id_mozo, @id_cliente,
         0.00, 0.00, 0.00, 0.00,
         'Pedido de prueba para validar flujo antes de comprobante.',
         25, @id_sucursal);
END;

SELECT @id_pedido = id_pedido
FROM dbo.Pedido
WHERE numero_pedido = @numero_pedido;


/* =========================================================
   5. HISTORIAL DEL PEDIDO
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM dbo.HistorialEstadoPedido
    WHERE id_pedido = @id_pedido
      AND id_estado_pedido = @id_estado_pedido_registrado
)
BEGIN
    INSERT INTO dbo.HistorialEstadoPedido
        (id_pedido, id_estado_pedido, fecha_hora_cambio,
         id_usuario, motivo, observaciones)
    VALUES
        (@id_pedido, @id_estado_pedido_registrado, SYSDATETIME(),
         @id_mozo, 'Registro inicial', 'Pedido registrado desde carga de prueba.');
END;


/* =========================================================
   6. PRODUCTOS DEL PEDIDO
   ========================================================= */
DECLARE @id_bra001 INT;
DECLARE @id_wok003 INT;
DECLARE @id_beb017 INT;

DECLARE @id_mp_bra001 INT;
DECLARE @id_mp_wok003 INT;
DECLARE @id_mp_beb017 INT;

DECLARE @precio_bra001 DECIMAL(10,2);
DECLARE @precio_wok003 DECIMAL(10,2);
DECLARE @precio_beb017 DECIMAL(10,2);

SELECT
    @id_bra001 = p.id_producto,
    @precio_bra001 = p.precio_base
FROM dbo.Producto p
WHERE p.codigo = 'BRA001';

SELECT
    @id_wok003 = p.id_producto,
    @precio_wok003 = p.precio_base
FROM dbo.Producto p
WHERE p.codigo = 'WOK003';

SELECT
    @id_beb017 = p.id_producto,
    @precio_beb017 = p.precio_base
FROM dbo.Producto p
WHERE p.codigo = 'BEB017';

SELECT @id_mp_bra001 = mp.id_menu_producto
FROM dbo.MenuProducto mp
INNER JOIN dbo.Menu m
    ON m.id_menu = mp.id_menu
INNER JOIN dbo.Producto p
    ON p.id_producto = mp.id_producto
WHERE m.codigo = 'CARTA_GENERAL'
  AND p.codigo = 'BRA001'
  AND mp.id_variante IS NULL;

SELECT @id_mp_wok003 = mp.id_menu_producto
FROM dbo.MenuProducto mp
INNER JOIN dbo.Menu m
    ON m.id_menu = mp.id_menu
INNER JOIN dbo.Producto p
    ON p.id_producto = mp.id_producto
WHERE m.codigo = 'CARTA_GENERAL'
  AND p.codigo = 'WOK003'
  AND mp.id_variante IS NULL;

SELECT @id_mp_beb017 = mp.id_menu_producto
FROM dbo.MenuProducto mp
INNER JOIN dbo.Menu m
    ON m.id_menu = mp.id_menu
INNER JOIN dbo.Producto p
    ON p.id_producto = mp.id_producto
WHERE m.codigo = 'CARTA_GENERAL'
  AND p.codigo = 'BEB017'
  AND mp.id_variante IS NULL;

IF @id_bra001 IS NULL
    THROW 58015, 'Falta producto BRA001.', 1;

IF @id_wok003 IS NULL
    THROW 58016, 'Falta producto WOK003.', 1;

IF @id_beb017 IS NULL
    THROW 58017, 'Falta producto BEB017.', 1;

IF @id_mp_bra001 IS NULL OR @id_mp_wok003 IS NULL OR @id_mp_beb017 IS NULL
    THROW 58018, 'Faltan registros en MenuProducto para BRA001, WOK003 o BEB017. Ejecuta Bloque 6.', 1;


/* =========================================================
   7. INSERTAR DETALLES DEL PEDIDO
   ========================================================= */
IF NOT EXISTS (
    SELECT 1 FROM dbo.DetallePedido
    WHERE id_pedido = @id_pedido
      AND id_producto = @id_bra001
)
BEGIN
    INSERT INTO dbo.DetallePedido
        (id_pedido, id_producto, id_variante, id_menu_producto,
         cantidad, precio_unitario, subtotal,
         observaciones, fecha_hora_registro)
    VALUES
        (@id_pedido, @id_bra001, NULL, @id_mp_bra001,
         1, @precio_bra001, @precio_bra001,
         '1/4 pollo con papas fritas, ensalada fresca y cremas.',
         SYSDATETIME());
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.DetallePedido
    WHERE id_pedido = @id_pedido
      AND id_producto = @id_wok003
)
BEGIN
    INSERT INTO dbo.DetallePedido
        (id_pedido, id_producto, id_variante, id_menu_producto,
         cantidad, precio_unitario, subtotal,
         observaciones, fecha_hora_registro)
    VALUES
        (@id_pedido, @id_wok003, NULL, @id_mp_wok003,
         1, @precio_wok003, @precio_wok003,
         'Lomo saltado termino tres cuartos.',
         SYSDATETIME());
END;

IF NOT EXISTS (
    SELECT 1 FROM dbo.DetallePedido
    WHERE id_pedido = @id_pedido
      AND id_producto = @id_beb017
)
BEGIN
    INSERT INTO dbo.DetallePedido
        (id_pedido, id_producto, id_variante, id_menu_producto,
         cantidad, precio_unitario, subtotal,
         observaciones, fecha_hora_registro)
    VALUES
        (@id_pedido, @id_beb017, NULL, @id_mp_beb017,
         1, @precio_beb017, @precio_beb017,
         'Vaso de limonada helada.',
         SYSDATETIME());
END;


/* =========================================================
   8. HISTORIAL DE DETALLES
   ========================================================= */
INSERT INTO dbo.HistorialEstadoDetallePedido
    (id_detalle_pedido, id_estado_detalle_pedido,
     fecha_hora_cambio, id_usuario, motivo, observaciones)
SELECT
    dp.id_detalle_pedido,
    @id_estado_detalle_pendiente,
    SYSDATETIME(),
    @id_mozo,
    'Registro inicial',
    'Detalle registrado desde carga de prueba.'
FROM dbo.DetallePedido dp
WHERE dp.id_pedido = @id_pedido
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.HistorialEstadoDetallePedido h
      WHERE h.id_detalle_pedido = dp.id_detalle_pedido
        AND h.id_estado_detalle_pedido = @id_estado_detalle_pendiente
  );


/* =========================================================
   9. OPCIONES DE DETALLE
   ========================================================= */
DECLARE @id_detalle_bra001 INT;
DECLARE @id_detalle_wok003 INT;
DECLARE @id_detalle_beb017 INT;

SELECT @id_detalle_bra001 = id_detalle_pedido
FROM dbo.DetallePedido
WHERE id_pedido = @id_pedido
  AND id_producto = @id_bra001;

SELECT @id_detalle_wok003 = id_detalle_pedido
FROM dbo.DetallePedido
WHERE id_pedido = @id_pedido
  AND id_producto = @id_wok003;

SELECT @id_detalle_beb017 = id_detalle_pedido
FROM dbo.DetallePedido
WHERE id_pedido = @id_pedido
  AND id_producto = @id_beb017;


DECLARE @OpcionesDetalle TABLE (
    id_detalle_pedido INT NOT NULL,
    modificador VARCHAR(50) NOT NULL,
    opcion VARCHAR(100) NOT NULL,
    cantidad INT NOT NULL,
    precio_adicional DECIMAL(10,2) NOT NULL,
    observaciones VARCHAR(MAX) NULL
);

INSERT INTO @OpcionesDetalle
    (id_detalle_pedido, modificador, opcion, cantidad, precio_adicional, observaciones)
VALUES
/* BRA001 */
(@id_detalle_bra001, 'Tipo de papa', 'Papas fritas', 1, 0.00, NULL),
(@id_detalle_bra001, 'Tipo de ensalada', 'Ensalada fresca', 1, 0.00, NULL),
(@id_detalle_bra001, 'Cremas', 'Mayonesa', 1, 0.00, NULL),
(@id_detalle_bra001, 'Cremas', 'Aji de la casa', 1, 0.00, NULL),

/* WOK003 */
(@id_detalle_wok003, 'Termino de carne', 'Tres cuartos', 1, 0.00, NULL),
(@id_detalle_wok003, 'Cremas', 'Aji de la casa', 1, 0.00, NULL),

/* BEB017 */
(@id_detalle_beb017, 'Sabor de bebida', 'Limonada', 1, 0.00, NULL),
(@id_detalle_beb017, 'Temperatura de bebida', 'Helada', 1, 0.00, NULL),
(@id_detalle_beb017, 'Presentacion de bebida', 'Vaso', 1, 0.00, NULL);


IF EXISTS (
    SELECT 1
    FROM @OpcionesDetalle od
    WHERE od.id_detalle_pedido IS NULL
)
BEGIN
    THROW 58019, 'Hay detalle de pedido nulo para opciones.', 1;
END;

IF EXISTS (
    SELECT 1
    FROM @OpcionesDetalle od
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Modificador m
        INNER JOIN dbo.OpcionModificador om
            ON om.id_modificador = m.id_modificador
        WHERE m.nombre = od.modificador
          AND om.valor = od.opcion
    )
)
BEGIN
    SELECT od.modificador, od.opcion
    FROM @OpcionesDetalle od
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Modificador m
        INNER JOIN dbo.OpcionModificador om
            ON om.id_modificador = m.id_modificador
        WHERE m.nombre = od.modificador
          AND om.valor = od.opcion
    );

    THROW 58020, 'Hay opciones de modificador faltantes. Revisa el resultado anterior.', 1;
END;


INSERT INTO dbo.DetallePedidoOpcion
    (id_detalle_pedido, id_modificador, id_opcion_modificador,
     cantidad, precio_adicional, observaciones)
SELECT
    od.id_detalle_pedido,
    m.id_modificador,
    om.id_opcion,
    od.cantidad,
    od.precio_adicional,
    od.observaciones
FROM @OpcionesDetalle od
INNER JOIN dbo.Modificador m
    ON m.nombre = od.modificador
INNER JOIN dbo.OpcionModificador om
    ON om.id_modificador = m.id_modificador
   AND om.valor = od.opcion
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.DetallePedidoOpcion dpo
    WHERE dpo.id_detalle_pedido = od.id_detalle_pedido
      AND dpo.id_modificador = m.id_modificador
      AND dpo.id_opcion_modificador = om.id_opcion
);


/* =========================================================
   10. ACTUALIZAR TOTALES DEL PEDIDO
   ========================================================= */
DECLARE @subtotal_pedido DECIMAL(10,2);

SELECT @subtotal_pedido = SUM(dp.subtotal)
FROM dbo.DetallePedido dp
WHERE dp.id_pedido = @id_pedido;

UPDATE dbo.Pedido
SET
    subtotal = @subtotal_pedido,
    descuento_monto = 0.00,
    costo_delivery = 0.00,
    total_con_igv = @subtotal_pedido,
    estado_actual = 'Registrado'
WHERE id_pedido = @id_pedido;


/* =========================================================
   11. CREAR CUENTA DEL PEDIDO
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM dbo.CuentaPedido
    WHERE id_pedido = @id_pedido
      AND numero_cuenta = 1
)
BEGIN
    INSERT INTO dbo.CuentaPedido
        (id_pedido, numero_cuenta, nombre_referencia,
         subtotal, descuento, total, estado_cuenta, observaciones)
    VALUES
        (@id_pedido, 1, 'Cuenta principal',
         @subtotal_pedido, 0.00, @subtotal_pedido,
         'ABIERTA', 'Cuenta de prueba para validar pago y comprobante.');
END;

SELECT @id_cuenta_pedido = id_cuenta_pedido
FROM dbo.CuentaPedido
WHERE id_pedido = @id_pedido
  AND numero_cuenta = 1;

UPDATE dbo.CuentaPedido
SET
    subtotal = @subtotal_pedido,
    descuento = 0.00,
    total = @subtotal_pedido,
    estado_cuenta = 'ABIERTA'
WHERE id_cuenta_pedido = @id_cuenta_pedido;


/* =========================================================
   12. DETALLE DE CUENTA
   ========================================================= */
INSERT INTO dbo.DetalleCuentaPedido
    (id_cuenta_pedido, id_detalle_pedido,
     cantidad_asignada, monto_asignado, observaciones)
SELECT
    @id_cuenta_pedido,
    dp.id_detalle_pedido,
    dp.cantidad,
    dp.subtotal,
    'Asignado automaticamente a cuenta principal.'
FROM dbo.DetallePedido dp
WHERE dp.id_pedido = @id_pedido
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.DetalleCuentaPedido dcp
      WHERE dcp.id_cuenta_pedido = @id_cuenta_pedido
        AND dcp.id_detalle_pedido = dp.id_detalle_pedido
  );


COMMIT TRANSACTION;

PRINT 'BLOQUE 8A cargado correctamente: pedido, detalle, opciones y cuenta.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 8A';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
