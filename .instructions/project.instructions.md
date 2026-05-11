# Instrucciones del Proyecto de Base de Datos
## Restaurante El Olivar Grill

Este documento define la organización del repositorio y recomendaciones para ejecutar los scripts SQL.

---

## ⚙️ Orden de ejecución recomendado

1. **Definir estructura**  
   Ejecutar en orden:
   - `scripts/01_schema.sql`
   - `scripts/02_constraints.sql`
   - `scripts/03_views.sql`
   - `scripts/04_procedures.sql`
   - `scripts/05_triggers.sql`

2. **Cargar datos iniciales**  
   - `data/01_seed_data.sql`

3. **Cargar datos de prueba (opcional)**  
   - `data/02_test_data.sql`

4. **Aplicar actualizaciones**  
   - Ejecutar los scripts en `/updates/` según la fecha o versión indicada.

5. **Validar integridad**  
   - `tests/integrity_tests.sql`

---

## 📂 Estructura del repositorio

- **/scripts/** → Definición inicial de la base de datos
  - `01_schema.sql` → Creación de tablas
  - `02_constraints.sql` → Llaves primarias, foráneas y reglas de integridad
  - `03_views.sql` → Vistas para reportes
  - `04_procedures.sql` → Procedimientos almacenados
  - `05_triggers.sql` → Automatizaciones

- **/updates/** → Scripts de modificaciones posteriores
  - Ejemplo: `2026-05-10_add_column_clientes.sql`
  - Ejemplo: `2026-05-15_alter_table_pedidos.sql`

- **/data/** → Scripts de carga de datos
  - `01_seed_data.sql` → Datos iniciales (menú, mesas, empleados)
  - `02_test_data.sql` → Datos ficticios para pruebas
  - `03_bulk_insert.sql` → Inserciones masivas

- **/tests/** → Validaciones de integridad y consistencia
  - `integrity_tests.sql`

- **/docs/** → Documentación y diagramas
  - `ERD.png` → Diagrama entidad-relación
  - `use_cases.md` → Casos de uso
  - `CHANGELOG.md` → Registro de cambios

---

## 📌 Buenas prácticas

- **Versionado**: usar ramas para cada cambio (`feature/update-clientes`).  
- **Convenciones**: nombres consistentes en tablas y columnas (snake_case).  
- **Documentación**: mantener actualizado `CHANGELOG.md` con cada modificación.  
- **Automatización**: configurar GitHub Actions para ejecutar los scripts en una base de datos de prueba en cada *push*.  

---
