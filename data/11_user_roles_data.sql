USE BDOlivarGrill;
GO

/* =========================================================
   BLOQUE 11 - USUARIOS, ROLES Y PERMISOS DETALLADOS
   Ejecutar despues del BLOQUE 10

   Este bloque:
   - Crea UsuarioRol si no existe
   - Crea Permiso si no existe
   - Crea RolPermiso si no existe
   - Carga permisos base del sistema
   - Asigna permisos a roles
   - Asigna roles a usuarios
   ========================================================= */

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

/* =========================================================
   1. VALIDACIONES MINIMAS
   ========================================================= */
IF OBJECT_ID(N'dbo.Usuario', N'U') IS NULL
    THROW 62000, 'No existe dbo.Usuario.', 1;

IF OBJECT_ID(N'dbo.Rol', N'U') IS NULL
    THROW 62001, 'No existe dbo.Rol.', 1;


/* =========================================================
   2. CREAR TABLA USUARIOROL SI NO EXISTE
   ========================================================= */
IF OBJECT_ID(N'dbo.UsuarioRol', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.UsuarioRol (
        id_usuario_rol INT IDENTITY(1,1) PRIMARY KEY,
        id_usuario INT NOT NULL,
        id_rol INT NOT NULL,
        fecha_asignacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        activo BIT NOT NULL DEFAULT 1,
        observaciones VARCHAR(250) NULL,

        CONSTRAINT FK_UsuarioRol_Usuario
            FOREIGN KEY (id_usuario) REFERENCES dbo.Usuario(id_usuario),

        CONSTRAINT FK_UsuarioRol_Rol
            FOREIGN KEY (id_rol) REFERENCES dbo.Rol(id_rol),

        CONSTRAINT UQ_UsuarioRol_Usuario_Rol
            UNIQUE (id_usuario, id_rol)
    );
END;


/* =========================================================
   3. CREAR TABLA PERMISO SI NO EXISTE
   ========================================================= */
IF OBJECT_ID(N'dbo.Permiso', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Permiso (
        id_permiso INT IDENTITY(1,1) PRIMARY KEY,
        codigo VARCHAR(80) NOT NULL UNIQUE,
        nombre VARCHAR(120) NOT NULL,
        modulo VARCHAR(60) NOT NULL,
        descripcion VARCHAR(250) NULL,
        activo BIT NOT NULL DEFAULT 1
    );
END;


/* =========================================================
   4. CREAR TABLA ROLPERMISO SI NO EXISTE
   ========================================================= */
IF OBJECT_ID(N'dbo.RolPermiso', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RolPermiso (
        id_rol_permiso INT IDENTITY(1,1) PRIMARY KEY,
        id_rol INT NOT NULL,
        id_permiso INT NOT NULL,
        fecha_asignacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        activo BIT NOT NULL DEFAULT 1,

        CONSTRAINT FK_RolPermiso_Rol
            FOREIGN KEY (id_rol) REFERENCES dbo.Rol(id_rol),

        CONSTRAINT FK_RolPermiso_Permiso
            FOREIGN KEY (id_permiso) REFERENCES dbo.Permiso(id_permiso),

        CONSTRAINT UQ_RolPermiso_Rol_Permiso
            UNIQUE (id_rol, id_permiso)
    );
END;


/* =========================================================
   5. ASEGURAR ROLES BASE
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE nombre = 'ADMINISTRADOR')
BEGIN
    INSERT INTO dbo.Rol (nombre, descripcion, nivel_permiso)
    VALUES ('ADMINISTRADOR', 'Acceso completo al sistema.', 100);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE nombre = 'CAJERO')
BEGIN
    INSERT INTO dbo.Rol (nombre, descripcion, nivel_permiso)
    VALUES ('CAJERO', 'Gestion de caja, pagos y comprobantes.', 80);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE nombre = 'MOZO')
BEGIN
    INSERT INTO dbo.Rol (nombre, descripcion, nivel_permiso)
    VALUES ('MOZO', 'Registro y seguimiento de pedidos.', 60);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE nombre = 'COCINA')
BEGIN
    INSERT INTO dbo.Rol (nombre, descripcion, nivel_permiso)
    VALUES ('COCINA', 'Visualizacion y actualizacion de preparacion.', 50);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE nombre = 'SUPERVISOR')
BEGIN
    INSERT INTO dbo.Rol (nombre, descripcion, nivel_permiso)
    VALUES ('SUPERVISOR', 'Supervision operativa del local.', 90);
END;


/* =========================================================
   6. CARGAR PERMISOS BASE
   ========================================================= */
DECLARE @Permisos TABLE (
    codigo VARCHAR(80) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    modulo VARCHAR(60) NOT NULL,
    descripcion VARCHAR(250) NULL
);

INSERT INTO @Permisos
    (codigo, nombre, modulo, descripcion)
VALUES
/* Seguridad */
('SEG_USUARIO_VER', 'Ver usuarios', 'SEGURIDAD', 'Permite consultar usuarios del sistema.'),
('SEG_USUARIO_CREAR', 'Crear usuarios', 'SEGURIDAD', 'Permite crear usuarios.'),
('SEG_USUARIO_EDITAR', 'Editar usuarios', 'SEGURIDAD', 'Permite modificar usuarios.'),
('SEG_ROL_GESTIONAR', 'Gestionar roles', 'SEGURIDAD', 'Permite administrar roles y permisos.'),

/* Carta digital */
('CARTA_VER', 'Ver carta', 'CARTA', 'Permite consultar productos, categorias y menus.'),
('CARTA_EDITAR', 'Editar carta', 'CARTA', 'Permite editar productos, precios, imagenes y menus.'),
('CARTA_PROMOCION_GESTIONAR', 'Gestionar promociones', 'CARTA', 'Permite administrar promociones y combos.'),

/* Pedidos */
('PEDIDO_CREAR', 'Crear pedidos', 'PEDIDOS', 'Permite registrar nuevos pedidos.'),
('PEDIDO_EDITAR', 'Editar pedidos', 'PEDIDOS', 'Permite modificar pedidos abiertos.'),
('PEDIDO_ANULAR', 'Anular pedidos', 'PEDIDOS', 'Permite anular pedidos.'),
('PEDIDO_VER_TODOS', 'Ver todos los pedidos', 'PEDIDOS', 'Permite ver pedidos de todos los usuarios.'),

/* Cocina */
('COCINA_VER_COMANDAS', 'Ver comandas', 'COCINA', 'Permite ver pedidos pendientes de preparacion.'),
('COCINA_ACTUALIZAR_ESTADO', 'Actualizar estado de preparacion', 'COCINA', 'Permite marcar productos en preparacion, listos o entregados.'),

/* Caja */
('CAJA_ABRIR', 'Abrir caja', 'CAJA', 'Permite abrir sesion de caja.'),
('CAJA_CERRAR', 'Cerrar caja', 'CAJA', 'Permite cerrar sesion de caja.'),
('CAJA_VER', 'Ver caja', 'CAJA', 'Permite consultar movimientos y sesiones de caja.'),

/* Pagos y comprobantes */
('PAGO_REGISTRAR', 'Registrar pagos', 'PAGOS', 'Permite registrar pagos de pedidos.'),
('PAGO_ANULAR', 'Anular pagos', 'PAGOS', 'Permite anular pagos.'),
('COMPROBANTE_EMITIR', 'Emitir comprobantes', 'COMPROBANTES', 'Permite emitir boletas, facturas o tickets.'),
('COMPROBANTE_ANULAR', 'Anular comprobantes', 'COMPROBANTES', 'Permite anular comprobantes.'),

/* Inventario */
('INV_VER', 'Ver inventario', 'INVENTARIO', 'Permite consultar insumos y stock.'),
('INV_MOVIMIENTO_CREAR', 'Registrar movimientos de inventario', 'INVENTARIO', 'Permite registrar entradas, salidas y ajustes.'),
('INV_RECETA_EDITAR', 'Editar recetas', 'INVENTARIO', 'Permite editar recetas de productos.'),

/* Reportes */
('REPORTE_VENTAS_VER', 'Ver reporte de ventas', 'REPORTES', 'Permite consultar reportes de ventas.'),
('REPORTE_INVENTARIO_VER', 'Ver reporte de inventario', 'REPORTES', 'Permite consultar reportes de inventario.'),
('REPORTE_OPERACION_VER', 'Ver reporte operativo', 'REPORTES', 'Permite consultar indicadores operativos.');

INSERT INTO dbo.Permiso
    (codigo, nombre, modulo, descripcion, activo)
SELECT
    p.codigo,
    p.nombre,
    p.modulo,
    p.descripcion,
    1
FROM @Permisos p
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Permiso per
    WHERE per.codigo = p.codigo
);


/* =========================================================
   7. MATRIZ ROL - PERMISO
   ========================================================= */
DECLARE @RolPermisos TABLE (
    rol_nombre VARCHAR(50) NOT NULL,
    permiso_codigo VARCHAR(80) NOT NULL
);

/* ADMINISTRADOR: todos los permisos */
INSERT INTO @RolPermisos
    (rol_nombre, permiso_codigo)
SELECT
    'ADMINISTRADOR',
    codigo
FROM @Permisos;

/* SUPERVISOR */
INSERT INTO @RolPermisos
    (rol_nombre, permiso_codigo)
VALUES
('SUPERVISOR', 'CARTA_VER'),
('SUPERVISOR', 'CARTA_EDITAR'),
('SUPERVISOR', 'CARTA_PROMOCION_GESTIONAR'),
('SUPERVISOR', 'PEDIDO_CREAR'),
('SUPERVISOR', 'PEDIDO_EDITAR'),
('SUPERVISOR', 'PEDIDO_ANULAR'),
('SUPERVISOR', 'PEDIDO_VER_TODOS'),
('SUPERVISOR', 'COCINA_VER_COMANDAS'),
('SUPERVISOR', 'COCINA_ACTUALIZAR_ESTADO'),
('SUPERVISOR', 'CAJA_VER'),
('SUPERVISOR', 'PAGO_REGISTRAR'),
('SUPERVISOR', 'COMPROBANTE_EMITIR'),
('SUPERVISOR', 'INV_VER'),
('SUPERVISOR', 'INV_MOVIMIENTO_CREAR'),
('SUPERVISOR', 'REPORTE_VENTAS_VER'),
('SUPERVISOR', 'REPORTE_INVENTARIO_VER'),
('SUPERVISOR', 'REPORTE_OPERACION_VER');

/* CAJERO */
INSERT INTO @RolPermisos
    (rol_nombre, permiso_codigo)
VALUES
('CAJERO', 'CARTA_VER'),
('CAJERO', 'PEDIDO_CREAR'),
('CAJERO', 'PEDIDO_EDITAR'),
('CAJERO', 'PEDIDO_VER_TODOS'),
('CAJERO', 'CAJA_ABRIR'),
('CAJERO', 'CAJA_CERRAR'),
('CAJERO', 'CAJA_VER'),
('CAJERO', 'PAGO_REGISTRAR'),
('CAJERO', 'COMPROBANTE_EMITIR'),
('CAJERO', 'INV_VER'),
('CAJERO', 'REPORTE_VENTAS_VER');

/* MOZO */
INSERT INTO @RolPermisos
    (rol_nombre, permiso_codigo)
VALUES
('MOZO', 'CARTA_VER'),
('MOZO', 'PEDIDO_CREAR'),
('MOZO', 'PEDIDO_EDITAR'),
('MOZO', 'COCINA_VER_COMANDAS');

/* COCINA */
INSERT INTO @RolPermisos
    (rol_nombre, permiso_codigo)
VALUES
('COCINA', 'CARTA_VER'),
('COCINA', 'COCINA_VER_COMANDAS'),
('COCINA', 'COCINA_ACTUALIZAR_ESTADO'),
('COCINA', 'INV_VER');


/* =========================================================
   8. INSERTAR ROLPERMISO
   ========================================================= */
INSERT INTO dbo.RolPermiso
    (id_rol, id_permiso, fecha_asignacion, activo)
SELECT
    r.id_rol,
    p.id_permiso,
    SYSDATETIME(),
    1
FROM @RolPermisos rp
INNER JOIN dbo.Rol r
    ON r.nombre = rp.rol_nombre
INNER JOIN dbo.Permiso p
    ON p.codigo = rp.permiso_codigo
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.RolPermiso x
    WHERE x.id_rol = r.id_rol
      AND x.id_permiso = p.id_permiso
);


/* =========================================================
   9. ASIGNAR ROLES A USUARIOS
   Segun el campo Usuario.cargo cargado en el Bloque 1.
   ========================================================= */
DECLARE @UsuarioRoles TABLE (
    cargo_usuario VARCHAR(50) NOT NULL,
    rol_nombre VARCHAR(50) NOT NULL,
    observaciones VARCHAR(250) NULL
);

INSERT INTO @UsuarioRoles
    (cargo_usuario, rol_nombre, observaciones)
VALUES
('ADMIN', 'ADMINISTRADOR', 'Rol asignado automaticamente por cargo ADMIN.'),
('CAJERO', 'CAJERO', 'Rol asignado automaticamente por cargo CAJERO.'),
('MOZO', 'MOZO', 'Rol asignado automaticamente por cargo MOZO.'),
('COCINA', 'COCINA', 'Rol asignado automaticamente por cargo COCINA.');


INSERT INTO dbo.UsuarioRol
    (id_usuario, id_rol, fecha_asignacion, activo, observaciones)
SELECT
    u.id_usuario,
    r.id_rol,
    SYSDATETIME(),
    1,
    ur.observaciones
FROM dbo.Usuario u
INNER JOIN @UsuarioRoles ur
    ON ur.cargo_usuario = u.cargo
INNER JOIN dbo.Rol r
    ON r.nombre = ur.rol_nombre
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.UsuarioRol x
    WHERE x.id_usuario = u.id_usuario
      AND x.id_rol = r.id_rol
);


/* =========================================================
   10. ACTIVAR ASIGNACIONES EXISTENTES
   ========================================================= */
UPDATE ur
SET
    ur.activo = 1
FROM dbo.UsuarioRol ur
INNER JOIN dbo.Usuario u
    ON u.id_usuario = ur.id_usuario
INNER JOIN dbo.Rol r
    ON r.id_rol = ur.id_rol
INNER JOIN @UsuarioRoles data
    ON data.cargo_usuario = u.cargo
   AND data.rol_nombre = r.nombre;

UPDATE rp
SET
    rp.activo = 1
FROM dbo.RolPermiso rp
INNER JOIN dbo.Rol r
    ON r.id_rol = rp.id_rol
INNER JOIN dbo.Permiso p
    ON p.id_permiso = rp.id_permiso
INNER JOIN @RolPermisos data
    ON data.rol_nombre = r.nombre
   AND data.permiso_codigo = p.codigo;


COMMIT TRANSACTION;

PRINT 'BLOQUE 11 cargado correctamente: usuarios, roles y permisos detallados.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'ERROR EN BLOQUE 11';
    PRINT ERROR_MESSAGE();

    THROW;
END CATCH;
GO
