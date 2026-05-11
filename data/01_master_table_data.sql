USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 1 - DATA BASE / MAESTRA
   Ejecutar despues de:
   1. BDOlivarGrill_.sql
   2. Mejora_BDOlivarGrill_MenuDigital.sql
   ========================================================= */

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   1. SUCURSAL
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Sucursal WHERE codigo = 'PP01')
BEGIN
    INSERT INTO dbo.Sucursal
        (codigo, nombre, direccion, distrito, provincia, departamento, telefono, referencia, activo)
    VALUES
        ('PP01', 'Olivar Grill Puente Piedra', 'Av. Buenos Aires 382', 'Puente Piedra', 'Lima', 'Lima', '999999999', 'Referencia pendiente de actualizar', 1);
END;


/* =========================================================
   2. CATEGORIAS DE PRODUCTO
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.CategoriaProducto WHERE nombre = 'Entradas')
BEGIN
    INSERT INTO dbo.CategoriaProducto (nombre, descripcion, orden_visual, activo)
    VALUES
    ('Entradas', 'Entradas y piqueos iniciales de la carta.', 1, 1),
    ('Ensaladas', 'Ensaladas frescas y cocidas.', 2, 1),
    ('Olivar Brasa', 'Platos principales con pollo a la brasa.', 3, 1),
    ('Ofertas en Pollo a la Brasa', 'Promociones y combos de pollo a la brasa.', 4, 1),
    ('Fusiones', 'Platos fusionados con pollo, arroz, tallarines y otros acompañamientos.', 5, 1),
    ('Parrillas Personales', 'Cortes y parrillas para una persona.', 6, 1),
    ('Piqueos', 'Piqueos para compartir.', 7, 1),
    ('Parrillas Familiares', 'Parrillas y combos familiares.', 8, 1),
    ('Wok Criollo', 'Saltados y preparaciones al wok.', 9, 1),
    ('Pastas', 'Fettuccinis y pastas con diferentes acompañamientos.', 10, 1),
    ('Chaufa', 'Arroces chaufa de la casa.', 11, 1),
    ('Complementos', 'Porciones adicionales y acompañamientos.', 12, 1),
    ('Postres', 'Postres de la casa.', 13, 1),
    ('Menu El Olivar', 'Menu ejecutivo disponible de lunes a viernes.', 14, 1),
    ('Bebidas Calientes', 'Infusiones, cafe y bebidas calientes.', 15, 1),
    ('Bebidas', 'Gaseosas, aguas, jugos y bebidas frias.', 16, 1);
END;


/* =========================================================
   3. AREAS DE PREPARACION
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.AreaPreparacion WHERE nombre = 'BRASA')
BEGIN
    INSERT INTO dbo.AreaPreparacion
        (nombre, descripcion, tiempo_objetivo_segundo, tiempo_alerta_segundos, pantalla_ip)
    VALUES
    ('BRASA', 'Area de pollo a la brasa.', 900, 1200, NULL),
    ('COCINA', 'Area de cocina general.', 1200, 1500, NULL),
    ('PARRILLA', 'Area de carnes y parrillas.', 1500, 1800, NULL),
    ('WOK', 'Area de saltados, chaufas y platos criollos.', 1200, 1500, NULL),
    ('PASTAS', 'Area de pastas y fettuccinis.', 1200, 1500, NULL),
    ('BAR', 'Area de bebidas frias y calientes.', 300, 600, NULL),
    ('POSTRES', 'Area de postres.', 300, 600, NULL);
END;


/* =========================================================
   4. MODIFICADORES BASE
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Modificador WHERE nombre = 'Tipo de papa')
BEGIN
    INSERT INTO dbo.Modificador
        (nombre, tipo, permite_multiple, orden_visual)
    VALUES
    ('Tipo de papa', 'SELECCION', 0, 1),
    ('Tipo de ensalada', 'SELECCION', 0, 2),
    ('Cremas', 'MULTIPLE', 1, 3),
    ('Termino de carne', 'SELECCION', 0, 4),
    ('Salsa de pasta', 'SELECCION', 0, 5),
    ('Complemento de pasta', 'SELECCION', 0, 6),
    ('Sabor de bebida', 'SELECCION', 0, 7),
    ('Temperatura de bebida', 'SELECCION', 0, 8),
    ('Presentacion de bebida', 'SELECCION', 0, 9);
END;


/* =========================================================
   5. CLIENTES BASE
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Cliente WHERE dni = '00000000')
BEGIN
    INSERT INTO dbo.Cliente
        (nombres, apellidos, dni, telefono, email, fecha_nacimiento, fecha_registro, puntos_acumulados, nivel, activo)
    VALUES
    ('Cliente', 'General', '00000000', NULL, NULL, NULL, CAST(GETDATE() AS DATE), 0, 'BASICO', 1),
    ('Maria', 'Lopez', '11111111', '987654321', 'maria.lopez@email.com', '1995-05-12', CAST(GETDATE() AS DATE), 120, 'BASICO', 1),
    ('Carlos', 'Ramirez', '22222222', '976543210', 'carlos.ramirez@email.com', '1990-08-20', CAST(GETDATE() AS DATE), 250, 'PLATA', 1);
END;


/* =========================================================
   6. EMPLEADOS
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Empleado WHERE dni = '70000001')
BEGIN
    INSERT INTO dbo.Empleado
        (nombres, apellidos, dni, telefono, direccion, fecha_contratacion, activo)
    VALUES
    ('Administrador', 'Principal', '70000001', '900000001', 'Puente Piedra', '2024-01-10', 1),
    ('Cajero', 'Turno Manana', '70000002', '900000002', 'Puente Piedra', '2024-02-01', 1),
    ('Mozo', 'Salon Uno', '70000003', '900000003', 'Puente Piedra', '2024-02-15', 1),
    ('Cocinero', 'Principal', '70000004', '900000004', 'Puente Piedra', '2024-03-01', 1);
END;


/* =========================================================
   7. USUARIOS DEL SISTEMA
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE pin_acceso = '123456')
BEGIN
    INSERT INTO dbo.Usuario
        (nombre_completo, cargo, pin_acceso, turno_asignado, fecha_ingreso, activo)
    VALUES
    ('Administrador Principal', 'ADMIN', '123456', 'COMPLETO', '2024-01-10', 1),
    ('Cajero Turno Manana', 'CAJERO', '111111', 'MANANA', '2024-02-01', 1),
    ('Mozo Salon Uno', 'MOZO', '222222', 'TARDE', '2024-02-15', 1),
    ('Cocinero Principal', 'COCINA', '333333', 'COMPLETO', '2024-03-01', 1);
END;


/* =========================================================
   8. ROLES
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE nombre = 'ADMINISTRADOR')
BEGIN
    INSERT INTO dbo.Rol
        (nombre, descripcion, nivel_permiso)
    VALUES
    ('ADMINISTRADOR', 'Acceso completo al sistema.', 100),
    ('CAJERO', 'Gestion de caja, pagos y comprobantes.', 80),
    ('MOZO', 'Registro y seguimiento de pedidos.', 60),
    ('COCINA', 'Visualizacion y actualizacion de preparacion.', 50),
    ('SUPERVISOR', 'Supervision operativa del local.', 90);
END;


/* =========================================================
   9. METODOS DE PAGO
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.MetodoPago WHERE nombre = 'Efectivo')
BEGIN
    INSERT INTO dbo.MetodoPago
        (nombre, requiere_autorizacion, activo)
    VALUES
    ('Efectivo', 0, 1),
    ('Tarjeta Debito', 1, 1),
    ('Tarjeta Credito', 1, 1),
    ('Yape', 1, 1),
    ('Plin', 1, 1),
    ('Transferencia', 1, 1);
END;


/* =========================================================
   10. TIPOS DE COMPROBANTE
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.TipoComprobante WHERE codigo_sunat = '03')
BEGIN
    INSERT INTO dbo.TipoComprobante
        (codigo_sunat, nombre, requiere_ruc)
    VALUES
    ('03', 'Boleta', 0),
    ('01', 'Factura', 1),
    ('00', 'Ticket', 0);
END;


/* =========================================================
   11. UNIDADES DE MEDIDA
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.UnidadMedida WHERE abreviatura = 'UND')
BEGIN
    INSERT INTO dbo.UnidadMedida
        (nombre, abreviatura)
    VALUES
    ('Unidad', 'UND'),
    ('Kilogramo', 'KG'),
    ('Gramo', 'GR'),
    ('Litro', 'LT'),
    ('Mililitro', 'ML'),
    ('Porcion', 'POR'),
    ('Paquete', 'PQT'),
    ('Caja', 'CAJ');
END;


/* =========================================================
   12. ESTADOS DE PEDIDO
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.EstadoPedido WHERE nombre = 'Registrado')
BEGIN
    INSERT INTO dbo.EstadoPedido
        (nombre, secuencia, visible_cliente)
    VALUES
    ('Registrado', 1, 1),
    ('En preparacion', 2, 1),
    ('Listo', 3, 1),
    ('Entregado', 4, 1),
    ('Pagado', 5, 1),
    ('Anulado', 99, 0);
END;


/* =========================================================
   13. ESTADOS DE DETALLE DE PEDIDO
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.EstadoDetallePedido WHERE nombre = 'Pendiente')
BEGIN
    INSERT INTO dbo.EstadoDetallePedido
        (nombre, secuencia)
    VALUES
    ('Pendiente', 1),
    ('En preparacion', 2),
    ('Preparado', 3),
    ('Entregado', 4),
    ('Anulado', 99);
END;


/* =========================================================
   14. CAJA
   ========================================================= */
DECLARE @id_sucursal_pp INT;

SELECT @id_sucursal_pp = id_sucursal
FROM dbo.Sucursal
WHERE codigo = 'PP01';

IF NOT EXISTS (SELECT 1 FROM dbo.Caja WHERE nombre_caja = 'Caja Principal')
BEGIN
    INSERT INTO dbo.Caja
        (nombre_caja, ubicacion, descripcion, estado, id_sucursal)
    VALUES
    ('Caja Principal', 'Primer nivel', 'Caja principal del local Puente Piedra.', 'ABIERTA', @id_sucursal_pp);
END;


/* =========================================================
   15. MESAS
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Mesa WHERE codigo = 'M01')
BEGIN
    INSERT INTO dbo.Mesa
        (codigo, capacidad, zona, estado_actual, id_sucursal)
    VALUES
    ('M01', 2, 'SALON', 'DISPONIBLE', @id_sucursal_pp),
    ('M02', 4, 'SALON', 'DISPONIBLE', @id_sucursal_pp),
    ('M03', 4, 'SALON', 'DISPONIBLE', @id_sucursal_pp),
    ('M04', 6, 'SALON', 'DISPONIBLE', @id_sucursal_pp),
    ('M05', 6, 'SALON', 'DISPONIBLE', @id_sucursal_pp),
    ('M06', 8, 'SALON', 'DISPONIBLE', @id_sucursal_pp),
    ('T01', 4, 'TERRAZA', 'DISPONIBLE', @id_sucursal_pp),
    ('T02', 4, 'TERRAZA', 'DISPONIBLE', @id_sucursal_pp);
END;


/* =========================================================
   16. MENUS BASE
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'CARTA_GENERAL')
BEGIN
    INSERT INTO dbo.Menu
        (id_sucursal, codigo, nombre, tipo, descripcion, orden_visual, imagen_url, activo)
    VALUES
        (@id_sucursal_pp, 'CARTA_GENERAL', 'Carta general', 'CARTA_GENERAL',
         'Carta principal del restaurante.',
         1,
         'https://drive.google.com/uc?export=view&id=IMG_MENU_CARTA_GENERAL',
         1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'MENU_OLIVAR_LV')
BEGIN
    INSERT INTO dbo.Menu
        (id_sucursal, codigo, nombre, tipo, descripcion,
         hora_inicio, hora_fin,
         lunes, martes, miercoles, jueves, viernes, sabado, domingo,
         orden_visual, imagen_url, activo)
    VALUES
        (@id_sucursal_pp, 'MENU_OLIVAR_LV', 'Menu El Olivar', 'MENU_EJECUTIVO',
         'Menu disponible de lunes a viernes de 12:00 a 15:00.',
         CAST('12:00:00' AS TIME), CAST('15:00:00' AS TIME),
         1, 1, 1, 1, 1, 0, 0,
         2,
         'https://drive.google.com/uc?export=view&id=IMG_MENU_OLIVAR_LV',
         1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Menu WHERE codigo = 'OFERTAS_BRASA')
BEGIN
    INSERT INTO dbo.Menu
        (id_sucursal, codigo, nombre, tipo, descripcion, orden_visual, imagen_url, activo)
    VALUES
        (@id_sucursal_pp, 'OFERTAS_BRASA', 'Ofertas en pollo a la brasa', 'PROMOCION',
         'Promociones y combos de pollo a la brasa.',
         3,
         'https://drive.google.com/uc?export=view&id=IMG_MENU_OFERTAS_BRASA',
         1);
END;

COMMIT TRANSACTION;

PRINT 'BLOQUE 1 cargado correctamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 1';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
