IF DB_ID(N'BDOlivarGrill') IS NULL
BEGIN
    CREATE DATABASE BDOlivarGrill;
END;
GO

USE BDOlivarGrill;
GO

/* 1. CategoriaProducto */
CREATE TABLE dbo.CategoriaProducto (
    id_categoria         INT IDENTITY(1,1) NOT NULL,
    nombre               VARCHAR(50) NOT NULL,
    descripcion          VARCHAR(200) NULL,
    orden_visual         INT NOT NULL,
    activo               BIT NOT NULL,
    CONSTRAINT PK_CategoriaProducto PRIMARY KEY (id_categoria)
);
GO

/* 2. Producto */
CREATE TABLE dbo.Producto (
    id_producto                    INT IDENTITY(1,1) NOT NULL,
    codigo                         VARCHAR(10) NOT NULL,
    nombre                         VARCHAR(100) NOT NULL,
    descripcion                    VARCHAR(MAX) NULL,
    precio_base                    DECIMAL(10,2) NOT NULL,
    id_categoria                   INT NOT NULL,
    tiempo_preparacion_segundos    INT NOT NULL,
    activo                         BIT NOT NULL,
    requiere_nota_alergia          BIT NOT NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (id_producto),
    CONSTRAINT FK_Producto_CategoriaProducto
        FOREIGN KEY (id_categoria) REFERENCES dbo.CategoriaProducto(id_categoria),
    CONSTRAINT UQ_Producto_codigo UNIQUE (codigo)
);
GO

/* 3. ProductoComponente */
CREATE TABLE dbo.ProductoComponente (
    id_producto_componente   INT IDENTITY(1,1) NOT NULL,
    id_producto_padre        INT NOT NULL,
    id_producto_hijo         INT NOT NULL,
    cantidad                 DECIMAL(5,2) NOT NULL,
    orden                    INT NOT NULL,
    CONSTRAINT PK_ProductoComponente PRIMARY KEY (id_producto_componente),
    CONSTRAINT FK_ProductoComponente_ProductoPadre
        FOREIGN KEY (id_producto_padre) REFERENCES dbo.Producto(id_producto),
    CONSTRAINT FK_ProductoComponente_ProductoHijo
        FOREIGN KEY (id_producto_hijo) REFERENCES dbo.Producto(id_producto)
);
GO

/* 4. AreaPreparacion */
CREATE TABLE dbo.AreaPreparacion (
    id_area                    INT IDENTITY(1,1) NOT NULL,
    nombre                     VARCHAR(30) NOT NULL,
    descripcion                VARCHAR(100) NULL,
    tiempo_objetivo_segundo    INT NOT NULL,
    tiempo_alerta_segundos     INT NOT NULL,
    pantalla_ip                VARCHAR(15) NULL,
    CONSTRAINT PK_AreaPreparacion PRIMARY KEY (id_area)
);
GO

/* 5. Modificador */
CREATE TABLE dbo.Modificador (
    id_modificador       INT IDENTITY(1,1) NOT NULL,
    nombre               VARCHAR(50) NOT NULL,
    tipo                 VARCHAR(20) NOT NULL,
    permite_multiple     BIT NOT NULL,
    orden_visual         INT NOT NULL,
    CONSTRAINT PK_Modificador PRIMARY KEY (id_modificador)
);
GO

/* 6. OpcionModificador */
CREATE TABLE dbo.OpcionModificador (
    id_opcion            INT IDENTITY(1,1) NOT NULL,
    id_modificador       INT NOT NULL,
    valor                VARCHAR(100) NOT NULL,
    precio_extra         DECIMAL(10,2) NOT NULL,
    orden                INT NOT NULL,
    stock_dependiente    BIT NOT NULL,
    CONSTRAINT PK_OpcionModificador PRIMARY KEY (id_opcion),
    CONSTRAINT FK_OpcionModificador_Modificador
        FOREIGN KEY (id_modificador) REFERENCES dbo.Modificador(id_modificador)
);
GO

/* 7. ProductoModificador */
CREATE TABLE dbo.ProductoModificador (
    id_producto          INT NOT NULL,
    id_modificador       INT NOT NULL,
    es_obligatorio       BIT NOT NULL,
    orden_aplicacion     INT NOT NULL,
    CONSTRAINT PK_ProductoModificador PRIMARY KEY (id_producto, id_modificador),
    CONSTRAINT FK_ProductoModificador_Producto
        FOREIGN KEY (id_producto) REFERENCES dbo.Producto(id_producto),
    CONSTRAINT FK_ProductoModificador_Modificador
        FOREIGN KEY (id_modificador) REFERENCES dbo.Modificador(id_modificador)
);
GO

/* 8. Mesa */
CREATE TABLE dbo.Mesa (
    id_mesa              INT IDENTITY(1,1) NOT NULL,
    codigo               VARCHAR(10) NOT NULL,
    capacidad            INT NOT NULL,
    zona                 VARCHAR(20) NOT NULL,
    estado_actual        VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Mesa PRIMARY KEY (id_mesa),
    CONSTRAINT UQ_Mesa_codigo UNIQUE (codigo)
);
GO

/* 9. Cliente */
CREATE TABLE dbo.Cliente (
    id_cliente             INT IDENTITY(1,1) NOT NULL,
    nombres                VARCHAR(100) NOT NULL,
    apellidos              VARCHAR(100) NOT NULL,
    dni                    VARCHAR(8) NOT NULL,
    telefono               VARCHAR(15) NULL,
    email                  VARCHAR(100) NULL,
    fecha_nacimiento       DATE NULL,
    fecha_registro         DATE NOT NULL,
    puntos_acumulados      INT NOT NULL,
    nivel                  VARCHAR(10) NOT NULL,
    activo                 BIT NOT NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_Cliente_dni UNIQUE (dni)
);
GO

/* 10. Empleado */
CREATE TABLE dbo.Empleado (
    id_empleado            INT IDENTITY(1,1) NOT NULL,
    nombres                VARCHAR(100) NOT NULL,
    apellidos              VARCHAR(100) NOT NULL,
    dni                    VARCHAR(8) NOT NULL,
    telefono               VARCHAR(15) NULL,
    direccion              VARCHAR(200) NULL,
    fecha_contratacion     DATE NOT NULL,
    activo                 BIT NOT NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY (id_empleado),
    CONSTRAINT UQ_Empleado_dni UNIQUE (dni)
);
GO

/* 11. Usuario */
CREATE TABLE dbo.Usuario (
    id_usuario          INT IDENTITY(1,1) NOT NULL,
    nombre_completo     VARCHAR(100) NOT NULL,
    cargo               VARCHAR(30) NOT NULL,
    pin_acceso          VARCHAR(6) NOT NULL,
    turno_asignado      VARCHAR(20) NOT NULL,
    fecha_ingreso       DATE NOT NULL,
    activo              BIT NOT NULL,
    CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario)
);
GO

/* 12. Rol */
CREATE TABLE dbo.Rol (
    id_rol              INT IDENTITY(1,1) NOT NULL,
    nombre              VARCHAR(30) NOT NULL,
    descripcion         VARCHAR(100) NULL,
    nivel_permiso       INT NOT NULL,
    CONSTRAINT PK_Rol PRIMARY KEY (id_rol)
);
GO

/* 13. MetodoPago */
CREATE TABLE dbo.MetodoPago (
    id_metodo_pago            INT IDENTITY(1,1) NOT NULL,
    nombre                    VARCHAR(30) NOT NULL,
    requiere_autorizacion     BIT NOT NULL,
    activo                    BIT NOT NULL,
    CONSTRAINT PK_MetodoPago PRIMARY KEY (id_metodo_pago)
);
GO

/* 14. TipoComprobante */
CREATE TABLE dbo.TipoComprobante (
    id_tipo_comprobante     INT IDENTITY(1,1) NOT NULL,
    codigo_sunat            VARCHAR(2) NOT NULL,
    nombre                  VARCHAR(20) NOT NULL,
    requiere_ruc            BIT NOT NULL,
    CONSTRAINT PK_TipoComprobante PRIMARY KEY (id_tipo_comprobante)
);
GO

/* 15. UnidadMedida */
CREATE TABLE dbo.UnidadMedida (
    id_unidad_medida     INT IDENTITY(1,1) NOT NULL,
    nombre               VARCHAR(20) NOT NULL,
    abreviatura          VARCHAR(5) NOT NULL,
    CONSTRAINT PK_UnidadMedida PRIMARY KEY (id_unidad_medida)
);
GO

/* 16. Insumo */
CREATE TABLE dbo.Insumo (
    id_insumo              INT IDENTITY(1,1) NOT NULL,
    nombre                 VARCHAR(100) NOT NULL,
    id_unidad_medida       INT NOT NULL,
    stock_actual           DECIMAL(12,3) NOT NULL,
    stock_minimo           DECIMAL(12,3) NOT NULL,
    costo_unitario         DECIMAL(10,4) NOT NULL,
    activo                 BIT NOT NULL,
    CONSTRAINT PK_Insumo PRIMARY KEY (id_insumo),
    CONSTRAINT FK_Insumo_UnidadMedida
        FOREIGN KEY (id_unidad_medida) REFERENCES dbo.UnidadMedida(id_unidad_medida)
);
GO

/* 17. EstadoPedido */
CREATE TABLE dbo.EstadoPedido (
    id_estado_pedido      INT IDENTITY(1,1) NOT NULL,
    nombre                VARCHAR(20) NOT NULL,
    secuencia             INT NOT NULL,
    visible_cliente       BIT NOT NULL,
    CONSTRAINT PK_EstadoPedido PRIMARY KEY (id_estado_pedido)
);
GO

/* 18. EstadoDetallePedido */
CREATE TABLE dbo.EstadoDetallePedido (
    id_estado_detalle     INT IDENTITY(1,1) NOT NULL,
    nombre                VARCHAR(20) NOT NULL,
    secuencia             INT NOT NULL,
    CONSTRAINT PK_EstadoDetallePedido PRIMARY KEY (id_estado_detalle)
);
GO

/* 19. Pedido */
CREATE TABLE dbo.Pedido (
    id_pedido                   INT IDENTITY(1,1) NOT NULL,
    numero_pedido               VARCHAR(20) NOT NULL,
    fecha_hora_creacion         DATETIME2(0) NOT NULL,
    tipo                        VARCHAR(15) NOT NULL,
    canal                       VARCHAR(20) NOT NULL,
    estado_actual               VARCHAR(20) NOT NULL,
    id_mozo_asignado            INT NULL,
    id_cliente_fidelizacion     INT NULL,
    subtotal                    DECIMAL(10,2) NOT NULL,
    descuento_monto             DECIMAL(10,2) NOT NULL,
    costo_delivery              DECIMAL(10,2) NOT NULL,
    total_con_igv               DECIMAL(10,2) NOT NULL,
    observaciones_generales     VARCHAR(MAX) NULL,
    tiempo_estimado             INT NOT NULL,
    CONSTRAINT PK_Pedido PRIMARY KEY (id_pedido),
    CONSTRAINT FK_Pedido_Usuario
        FOREIGN KEY (id_mozo_asignado) REFERENCES dbo.Usuario(id_usuario),
    CONSTRAINT FK_Pedido_Cliente
        FOREIGN KEY (id_cliente_fidelizacion) REFERENCES dbo.Cliente(id_cliente)
);
GO

/* 20. DetallePedido */
CREATE TABLE dbo.DetallePedido (
    id_detalle_pedido        INT IDENTITY(1,1) NOT NULL,
    id_pedido                INT NOT NULL,
    id_producto              INT NOT NULL,
    cantidad                 INT NOT NULL,
    precio_unitario          DECIMAL(10,2) NOT NULL,
    subtotal                 DECIMAL(10,2) NOT NULL,
    observaciones            VARCHAR(MAX) NULL,
    fecha_hora_registro      DATETIME2(0) NOT NULL,
    CONSTRAINT PK_DetallePedido PRIMARY KEY (id_detalle_pedido),
    CONSTRAINT FK_DetallePedido_Pedido
        FOREIGN KEY (id_pedido) REFERENCES dbo.Pedido(id_pedido),
    CONSTRAINT FK_DetallePedido_Producto
        FOREIGN KEY (id_producto) REFERENCES dbo.Producto(id_producto)
);
GO

/* 21. DetallePedidoOpcion */
CREATE TABLE dbo.DetallePedidoOpcion (
    id_detalle_pedido_opcion   INT IDENTITY(1,1) NOT NULL,
    id_detalle_pedido          INT NOT NULL,
    id_modificador             INT NOT NULL,
    id_opcion_modificador      INT NOT NULL,
    cantidad                   INT NOT NULL,
    precio_adicional           DECIMAL(10,2) NOT NULL,
    observaciones              VARCHAR(MAX) NULL,
    CONSTRAINT PK_DetallePedidoOpcion PRIMARY KEY (id_detalle_pedido_opcion),
    CONSTRAINT FK_DetallePedidoOpcion_DetallePedido
        FOREIGN KEY (id_detalle_pedido) REFERENCES dbo.DetallePedido(id_detalle_pedido),
    CONSTRAINT FK_DetallePedidoOpcion_Modificador
        FOREIGN KEY (id_modificador) REFERENCES dbo.Modificador(id_modificador),
    CONSTRAINT FK_DetallePedidoOpcion_OpcionModificador
        FOREIGN KEY (id_opcion_modificador) REFERENCES dbo.OpcionModificador(id_opcion)
);
GO

/* 22. HistorialEstadoPedido */
CREATE TABLE dbo.HistorialEstadoPedido (
    id_historial_estado_pedido   INT IDENTITY(1,1) NOT NULL,
    id_pedido                    INT NOT NULL,
    id_estado_pedido             INT NOT NULL,
    fecha_hora_cambio            DATETIME2(0) NOT NULL,
    id_usuario                   INT NOT NULL,
    motivo                       VARCHAR(255) NULL,
    observaciones                VARCHAR(MAX) NULL,
    CONSTRAINT PK_HistorialEstadoPedido PRIMARY KEY (id_historial_estado_pedido),
    CONSTRAINT FK_HistorialEstadoPedido_Pedido
        FOREIGN KEY (id_pedido) REFERENCES dbo.Pedido(id_pedido),
    CONSTRAINT FK_HistorialEstadoPedido_EstadoPedido
        FOREIGN KEY (id_estado_pedido) REFERENCES dbo.EstadoPedido(id_estado_pedido),
    CONSTRAINT FK_HistorialEstadoPedido_Usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.Usuario(id_usuario)
);
GO

/* 23. HistorialEstadoDetallePedido */
CREATE TABLE dbo.HistorialEstadoDetallePedido (
    id_historial_estado_detalle     INT IDENTITY(1,1) NOT NULL,
    id_detalle_pedido               INT NOT NULL,
    id_estado_detalle_pedido        INT NOT NULL,
    fecha_hora_cambio               DATETIME2(0) NOT NULL,
    id_usuario                      INT NOT NULL,
    motivo                          VARCHAR(255) NULL,
    observaciones                   VARCHAR(MAX) NULL,
    CONSTRAINT PK_HistorialEstadoDetallePedido PRIMARY KEY (id_historial_estado_detalle),
    CONSTRAINT FK_HistorialEstadoDetallePedido_DetallePedido
        FOREIGN KEY (id_detalle_pedido) REFERENCES dbo.DetallePedido(id_detalle_pedido),
    CONSTRAINT FK_HistorialEstadoDetallePedido_EstadoDetallePedido
        FOREIGN KEY (id_estado_detalle_pedido) REFERENCES dbo.EstadoDetallePedido(id_estado_detalle),
    CONSTRAINT FK_HistorialEstadoDetallePedido_Usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.Usuario(id_usuario)
);
GO

/* 24. Caja */
CREATE TABLE dbo.Caja (
    id_caja             INT IDENTITY(1,1) NOT NULL,
    nombre_caja         VARCHAR(100) NOT NULL,
    ubicacion           VARCHAR(100) NULL,
    descripcion         VARCHAR(255) NULL,
    estado              VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Caja PRIMARY KEY (id_caja)
);
GO

/* 25. SesionCaja */
CREATE TABLE dbo.SesionCaja (
    id_sesion_caja         INT IDENTITY(1,1) NOT NULL,
    id_caja                INT NOT NULL,
    id_usuario_apertura    INT NOT NULL,
    fecha_hora_apertura    DATETIME2(0) NOT NULL,
    monto_inicial          DECIMAL(10,2) NOT NULL,
    id_usuario_cierre      INT NULL,
    fecha_hora_cierre      DATETIME2(0) NULL,
    monto_cierre_real      DECIMAL(10,2) NULL,
    diferencia_cierre      DECIMAL(10,2) NULL,
    estado_sesion          VARCHAR(20) NOT NULL,
    observaciones          VARCHAR(MAX) NULL,
    CONSTRAINT PK_SesionCaja PRIMARY KEY (id_sesion_caja),
    CONSTRAINT FK_SesionCaja_Caja
        FOREIGN KEY (id_caja) REFERENCES dbo.Caja(id_caja),
    CONSTRAINT FK_SesionCaja_UsuarioApertura
        FOREIGN KEY (id_usuario_apertura) REFERENCES dbo.Usuario(id_usuario),
    CONSTRAINT FK_SesionCaja_UsuarioCierre
        FOREIGN KEY (id_usuario_cierre) REFERENCES dbo.Usuario(id_usuario)
);
GO

/* 26. CuentaPedido */
CREATE TABLE dbo.CuentaPedido (
    id_cuenta_pedido      INT IDENTITY(1,1) NOT NULL,
    id_pedido             INT NOT NULL,
    numero_cuenta         INT NOT NULL,
    nombre_referencia     VARCHAR(100) NULL,
    subtotal              DECIMAL(10,2) NOT NULL,
    descuento             DECIMAL(10,2) NOT NULL,
    total                 DECIMAL(10,2) NOT NULL,
    estado_cuenta         VARCHAR(20) NOT NULL,
    observaciones         VARCHAR(MAX) NULL,
    CONSTRAINT PK_CuentaPedido PRIMARY KEY (id_cuenta_pedido),
    CONSTRAINT FK_CuentaPedido_Pedido
        FOREIGN KEY (id_pedido) REFERENCES dbo.Pedido(id_pedido)
);
GO

/* 27. DetalleCuentaPedido */
CREATE TABLE dbo.DetalleCuentaPedido (
    id_detalle_cuenta_pedido   INT IDENTITY(1,1) NOT NULL,
    id_cuenta_pedido           INT NOT NULL,
    id_detalle_pedido          INT NOT NULL,
    cantidad_asignada          INT NOT NULL,
    monto_asignado             DECIMAL(10,2) NOT NULL,
    observaciones              VARCHAR(MAX) NULL,
    CONSTRAINT PK_DetalleCuentaPedido PRIMARY KEY (id_detalle_cuenta_pedido),
    CONSTRAINT FK_DetalleCuentaPedido_CuentaPedido
        FOREIGN KEY (id_cuenta_pedido) REFERENCES dbo.CuentaPedido(id_cuenta_pedido),
    CONSTRAINT FK_DetalleCuentaPedido_DetallePedido
        FOREIGN KEY (id_detalle_pedido) REFERENCES dbo.DetallePedido(id_detalle_pedido)
);
GO

/* 28. Pago */
CREATE TABLE dbo.Pago (
    id_pago               INT IDENTITY(1,1) NOT NULL,
    id_pedido             INT NOT NULL,
    id_cuenta_pedido      INT NULL,
    id_sesion_caja        INT NOT NULL,
    id_metodo_pago        INT NOT NULL,
    fecha_hora_pago       DATETIME2(0) NOT NULL,
    monto                 DECIMAL(10,2) NOT NULL,
    referencia_pago       VARCHAR(100) NULL,
    estado_pago           VARCHAR(20) NOT NULL,
    id_usuario            INT NOT NULL,
    observaciones         VARCHAR(MAX) NULL,
    CONSTRAINT PK_Pago PRIMARY KEY (id_pago),
    CONSTRAINT FK_Pago_Pedido
        FOREIGN KEY (id_pedido) REFERENCES dbo.Pedido(id_pedido),
    CONSTRAINT FK_Pago_CuentaPedido
        FOREIGN KEY (id_cuenta_pedido) REFERENCES dbo.CuentaPedido(id_cuenta_pedido),
    CONSTRAINT FK_Pago_SesionCaja
        FOREIGN KEY (id_sesion_caja) REFERENCES dbo.SesionCaja(id_sesion_caja),
    CONSTRAINT FK_Pago_MetodoPago
        FOREIGN KEY (id_metodo_pago) REFERENCES dbo.MetodoPago(id_metodo_pago),
    CONSTRAINT FK_Pago_Usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.Usuario(id_usuario)
);
GO

/* 29. Comprobante */
CREATE TABLE dbo.Comprobante (
    id_comprobante         INT IDENTITY(1,1) NOT NULL,
    id_pedido              INT NOT NULL,
    id_cuenta_pedido       INT NULL,
    id_pago                INT NOT NULL,
    id_tipo_comprobante    INT NOT NULL,
    serie                  VARCHAR(10) NOT NULL,
    numero                 VARCHAR(20) NOT NULL,
    fecha_hora_emision     DATETIME2(0) NOT NULL,
    subtotal               DECIMAL(10,2) NOT NULL,
    impuesto               DECIMAL(10,2) NOT NULL,
    total                  DECIMAL(10,2) NOT NULL,
    estado_comprobante     VARCHAR(20) NOT NULL,
    observaciones          VARCHAR(MAX) NULL,
    CONSTRAINT PK_Comprobante PRIMARY KEY (id_comprobante),
    CONSTRAINT FK_Comprobante_Pedido
        FOREIGN KEY (id_pedido) REFERENCES dbo.Pedido(id_pedido),
    CONSTRAINT FK_Comprobante_CuentaPedido
        FOREIGN KEY (id_cuenta_pedido) REFERENCES dbo.CuentaPedido(id_cuenta_pedido),
    CONSTRAINT FK_Comprobante_Pago
        FOREIGN KEY (id_pago) REFERENCES dbo.Pago(id_pago),
    CONSTRAINT FK_Comprobante_TipoComprobante
        FOREIGN KEY (id_tipo_comprobante) REFERENCES dbo.TipoComprobante(id_tipo_comprobante)
);
GO

/* 30. MovimientoInventario */
CREATE TABLE dbo.MovimientoInventario (
    id_movimiento_inventario   INT IDENTITY(1,1) NOT NULL,
    id_insumo                  INT NOT NULL,
    fecha_hora_movimiento      DATETIME2(0) NOT NULL,
    tipo_movimiento            VARCHAR(20) NOT NULL,
    cantidad                   DECIMAL(10,3) NOT NULL,
    costo_unitario             DECIMAL(10,2) NULL,
    stock_anterior             DECIMAL(10,3) NOT NULL,
    stock_resultante           DECIMAL(10,3) NOT NULL,
    motivo                     VARCHAR(255) NULL,
    id_usuario                 INT NOT NULL,
    observaciones              VARCHAR(MAX) NULL,
    CONSTRAINT PK_MovimientoInventario PRIMARY KEY (id_movimiento_inventario),
    CONSTRAINT FK_MovimientoInventario_Insumo
        FOREIGN KEY (id_insumo) REFERENCES dbo.Insumo(id_insumo),
    CONSTRAINT FK_MovimientoInventario_Usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.Usuario(id_usuario)
);
GO

/* 31. RecetaProducto */
CREATE TABLE dbo.RecetaProducto (
    id_receta_producto      INT IDENTITY(1,1) NOT NULL,
    id_producto             INT NOT NULL,
    id_insumo               INT NOT NULL,
    cantidad_requerida      DECIMAL(10,3) NOT NULL,
    rendimiento_estimado    DECIMAL(5,2) NULL,
    observaciones           VARCHAR(MAX) NULL,
    CONSTRAINT PK_RecetaProducto PRIMARY KEY (id_receta_producto),
    CONSTRAINT FK_RecetaProducto_Producto
        FOREIGN KEY (id_producto) REFERENCES dbo.Producto(id_producto),
    CONSTRAINT FK_RecetaProducto_Insumo
        FOREIGN KEY (id_insumo) REFERENCES dbo.Insumo(id_insumo)
);
GO
