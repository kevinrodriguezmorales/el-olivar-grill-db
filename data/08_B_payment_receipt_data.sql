USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 8B - PAGO + COMPROBANTE
   Ejecutar despues del BLOQUE 8A

   Este bloque carga:
   - Pago
   - Comprobante
   - Actualiza CuentaPedido a PAGADA
   - Actualiza Pedido a Pagado
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   1. VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.Pago', N'U') IS NULL
    THROW 59000, 'No existe dbo.Pago.', 1;

IF OBJECT_ID(N'dbo.Comprobante', N'U') IS NULL
    THROW 59001, 'No existe dbo.Comprobante.', 1;

IF OBJECT_ID(N'dbo.Pedido', N'U') IS NULL
    THROW 59002, 'No existe dbo.Pedido.', 1;

IF OBJECT_ID(N'dbo.CuentaPedido', N'U') IS NULL
    THROW 59003, 'No existe dbo.CuentaPedido.', 1;


/* =========================================================
   2. VARIABLES BASE
   ========================================================= */
DECLARE @numero_pedido VARCHAR(20) = 'PED-PRUEBA-001';
DECLARE @referencia_pago VARCHAR(100) = 'PAGO-PRUEBA-001';
DECLARE @serie VARCHAR(10) = 'B001';
DECLARE @numero_comprobante VARCHAR(20) = '00000001';

DECLARE @id_pedido INT;
DECLARE @id_cuenta_pedido INT;
DECLARE @id_sesion_caja INT;
DECLARE @id_metodo_pago INT;
DECLARE @id_usuario_cajero INT;
DECLARE @id_tipo_comprobante INT;
DECLARE @id_pago INT;

DECLARE @total DECIMAL(10,2);
DECLARE @subtotal_sin_igv DECIMAL(10,2);
DECLARE @igv DECIMAL(10,2);

DECLARE @id_estado_pagado INT;


/* =========================================================
   3. OBTENER DATOS NECESARIOS
   ========================================================= */
SELECT
    @id_pedido = id_pedido,
    @total = total_con_igv
FROM dbo.Pedido
WHERE numero_pedido = @numero_pedido;

IF @id_pedido IS NULL
    THROW 59004, 'No existe el pedido PED-PRUEBA-001. Ejecuta primero el BLOQUE 8A.', 1;

SELECT TOP 1
    @id_cuenta_pedido = id_cuenta_pedido,
    @total = total
FROM dbo.CuentaPedido
WHERE id_pedido = @id_pedido
  AND numero_cuenta = 1
ORDER BY id_cuenta_pedido DESC;

IF @id_cuenta_pedido IS NULL
    THROW 59005, 'No existe CuentaPedido para PED-PRUEBA-001. Ejecuta primero el BLOQUE 8A.', 1;

IF @total IS NULL OR @total <= 0
    THROW 59006, 'El total del pedido/cuenta esta en cero o nulo. Revisa el BLOQUE 8A.', 1;

SELECT TOP 1 @id_sesion_caja = sc.id_sesion_caja
FROM dbo.SesionCaja sc
INNER JOIN dbo.Caja c
    ON c.id_caja = sc.id_caja
WHERE sc.estado_sesion = 'ABIERTA'
ORDER BY sc.id_sesion_caja DESC;

IF @id_sesion_caja IS NULL
    THROW 59007, 'No existe una SesionCaja ABIERTA.', 1;

SELECT @id_metodo_pago = id_metodo_pago
FROM dbo.MetodoPago
WHERE nombre = 'Efectivo';

IF @id_metodo_pago IS NULL
    THROW 59008, 'No existe MetodoPago Efectivo.', 1;

SELECT TOP 1 @id_usuario_cajero = id_usuario
FROM dbo.Usuario
WHERE cargo IN ('CAJERO', 'ADMIN')
ORDER BY 
    CASE WHEN cargo = 'CAJERO' THEN 1 ELSE 2 END,
    id_usuario;

IF @id_usuario_cajero IS NULL
    THROW 59009, 'No existe usuario CAJERO o ADMIN.', 1;

SELECT @id_tipo_comprobante = id_tipo_comprobante
FROM dbo.TipoComprobante
WHERE codigo_sunat = '03';

IF @id_tipo_comprobante IS NULL
    THROW 59010, 'No existe TipoComprobante Boleta codigo SUNAT 03.', 1;

SELECT @id_estado_pagado = id_estado_pedido
FROM dbo.EstadoPedido
WHERE nombre = 'Pagado';


/* =========================================================
   4. CALCULAR SUBTOTAL E IGV
   Total_con_igv representa el total final.
   IGV referencial: 18%
   ========================================================= */
SET @subtotal_sin_igv = ROUND(@total / 1.18, 2);
SET @igv = @total - @subtotal_sin_igv;


/* =========================================================
   5. INSERTAR PAGO
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM dbo.Pago
    WHERE id_pedido = @id_pedido
      AND referencia_pago = @referencia_pago
)
BEGIN
    INSERT INTO dbo.Pago
        (id_pedido, id_cuenta_pedido, id_sesion_caja, id_metodo_pago,
         fecha_hora_pago, monto, referencia_pago, estado_pago,
         id_usuario, observaciones)
    VALUES
        (@id_pedido, @id_cuenta_pedido, @id_sesion_caja, @id_metodo_pago,
         SYSDATETIME(), @total, @referencia_pago, 'CONFIRMADO',
         @id_usuario_cajero, 'Pago de prueba en efectivo.');
END;

SELECT TOP 1 @id_pago = id_pago
FROM dbo.Pago
WHERE id_pedido = @id_pedido
  AND referencia_pago = @referencia_pago
ORDER BY id_pago DESC;

IF @id_pago IS NULL
    THROW 59011, 'No se pudo obtener el id_pago.', 1;


/* =========================================================
   6. INSERTAR COMPROBANTE
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM dbo.Comprobante
    WHERE serie = @serie
      AND numero = @numero_comprobante
)
BEGIN
    INSERT INTO dbo.Comprobante
        (id_pedido, id_cuenta_pedido, id_pago, id_tipo_comprobante,
         serie, numero, fecha_hora_emision,
         subtotal, impuesto, total,
         estado_comprobante, observaciones)
    VALUES
        (@id_pedido, @id_cuenta_pedido, @id_pago, @id_tipo_comprobante,
         @serie, @numero_comprobante, SYSDATETIME(),
         @subtotal_sin_igv, @igv, @total,
         'EMITIDO', 'Boleta de prueba generada desde carga incremental.');
END;


/* =========================================================
   7. ACTUALIZAR CUENTA Y PEDIDO
   ========================================================= */
UPDATE dbo.CuentaPedido
SET estado_cuenta = 'PAGADA'
WHERE id_cuenta_pedido = @id_cuenta_pedido;

UPDATE dbo.Pedido
SET estado_actual = 'Pagado'
WHERE id_pedido = @id_pedido;


/* =========================================================
   8. HISTORIAL DEL PEDIDO COMO PAGADO
   ========================================================= */
IF @id_estado_pagado IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM dbo.HistorialEstadoPedido
    WHERE id_pedido = @id_pedido
      AND id_estado_pedido = @id_estado_pagado
)
BEGIN
    INSERT INTO dbo.HistorialEstadoPedido
        (id_pedido, id_estado_pedido, fecha_hora_cambio,
         id_usuario, motivo, observaciones)
    VALUES
        (@id_pedido, @id_estado_pagado, SYSDATETIME(),
         @id_usuario_cajero, 'Pago confirmado', 'Pedido marcado como pagado desde bloque de prueba.');
END;


COMMIT TRANSACTION;

PRINT 'BLOQUE 8B cargado correctamente: Pago y Comprobante.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 8B';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
