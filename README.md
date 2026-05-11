# El Olivar Grill Database

Scripts SQL y documentación para el diseño de la base de datos del restaurante El Olivar Grill

## Structure

```txt
el-olivar-grill-db/
│
├── README.md
├── CHANGELOG.md
├── scripts/          # Esquema inicial
│   ├── 01_schema.sql
│   ├── 02_constraints.sql
│   ├── 03_views.sql
│   └── ...
├── updates/          # Cambios posteriores
│   ├── 2026-05-10_add_column_clientes.sql
│   └── ...
├── data/             # Carga de datos
│   ├── 01_seed_data.sql
│   ├── 02_test_data.sql
│   └── ...
├── tests/            # Validaciones
│   └── integrity_tests.sql
└── docs/             # Documentación
    ├── ERD.png
    └── use_cases.md
```

## Data

| Bloque | Nombre                      | Qué carga / qué hace                                                                                                                                                                         | Estado                          |
| -----: | --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
|      1 | Data base / maestra         | `Sucursal`, `CategoriaProducto`, `AreaPreparacion`, `Modificador`, `Cliente`, `Empleado`, `Usuario`, `Rol`, `MetodoPago`, `TipoComprobante`, `UnidadMedida`, estados, `Caja`, `Mesa`, `Menu` | Obligatorio                     |
|      2 | Opciones + insumos base     | `OpcionModificador` e `Insumo` iniciales para pollos, carnes, papas, arroz, bebidas, cremas, postres, empaques, etc.                                                                         | Obligatorio                     |
|     3A | Productos base parte 1      | Productos de `Entradas`, `Ensaladas`, `Olivar Brasa` y `Ofertas en Pollo a la Brasa`, con imagen principal URL Google Drive ficticia                                                         | Obligatorio                     |
|     3B | Productos base parte 2      | Productos de `Fusiones`, `Parrillas Personales`, `Piqueos` y `Parrillas Familiares`, con imágenes                                                                                            | Obligatorio                     |
|     3C | Productos base parte 3      | Productos de `Wok Criollo`, `Pastas`, `Chaufa`, `Complementos`, `Postres`, `Menu El Olivar`, `Bebidas Calientes` y `Bebidas`                                                                 | Obligatorio                     |
|      4 | Variantes de pastas         | `ProductoVariante` y `ProductoVarianteOpcion` para combinaciones de fetuccini + salsa + complemento, con precio final                                                                        | Obligatorio si se usara variantes  |
|      5 | ProductoModificador         | Reglas de selección para papas, ensalada, cremas, término de carne, bebidas y pastas. El original no cargó; funcionó el **Bloque 5B corregido**                                              | Obligatorio                     |
|      6 | MenuProducto                | Relaciona productos con `CARTA_GENERAL`, `MENU_OLIVAR_LV` y `OFERTAS_BRASA`; también incluye variantes de pastas en la carta                                                                 | Obligatorio                     |
|      7 | Componentes de combos       | `ProductoComponente` para ofertas, parrillas familiares, piqueos y fusiones                                                                                                                  | Recomendado                     |
|     8A | Pedido de prueba            | Crea `PED-PRUEBA-001`, detalle, opciones seleccionadas, historial, cuenta y detalle de cuenta                                                                                                | Prueba funcional                |
|     8B | Pago + comprobante          | Crea pago y comprobante para `PED-PRUEBA-001`, actualiza cuenta y pedido a pagado                                                                                                            | Prueba funcional                |
|      9 | Recetas base                | `RecetaProducto`, conectando productos con insumos para futuro descuento de inventario                                                                                                       | Recomendado / importante        |
|     10 | Inventario inicial          | `MovimientoInventario` de entrada inicial y sincronización de `Insumo.stock_actual`. Falló primero por insumos faltantes; funcionó tras el **Parche 10A**                                    | Recomendado / importante        |
|    10A | Parche de insumos faltantes | Inserta insumos faltantes frecuentes como `Queso pasteurizado`, `Mollejitas de pollo`, `Bife`, `Alitas de pollo`, etc.                                                                       | Correctivo                      |
|     11 | Usuarios, roles y permisos  | Crea/carga `UsuarioRol`, `Permiso`, `RolPermiso`, matriz de permisos por rol y asignación de roles a usuarios                                                                                | Recomendado                     |
|     12 | Más pedidos de prueba       | Crea `PED-PRUEBA-002` a `PED-PRUEBA-005`: Yape, Plin, delivery, factura por transferencia y pedido anulado                                                                                   | Prueba funcional                |
|     13 | Validación final            | No modifica datos. Solo revisa consistencia general: menús, productos, imágenes, variantes, modificadores, combos, recetas, inventario, pedidos, pagos, comprobantes, roles                  | Validación                      |
