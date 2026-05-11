# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Migration script `scripts/updates/2026-05-10_migrations.sql` for digital menu,
  branches and product extension features.
- New table `Sucursal` to manage restaurant branches.
- New table `ProductoImagen` to support product gallery and primary image records.
- New table `ProductoVariante` to support product variants with combination-based pricing.
- New table `ProductoVarianteOpcion` to link variants with modifier options.
- New table `Menu` to manage menu catalogs by branch, schedule and type.
- New table `MenuProducto` to assign products and variants to menus with custom pricing.
- Optional seed data for branch and menu setup.
- Additional indexes and constraints to improve integrity and lookup performance.

### Changed

- Extended `Mesa`, `Caja` and `Pedido` with `id_sucursal` to associate operational data
  with branches.
- Extended `Producto` with `imagen_principal_url` and `nombre_corto`.
- Extended `DetallePedido` with `id_variante` and `id_menu_producto`.
- Enhanced `ProductoModificador` with selection rules:
  `min_selecciones`, `max_selecciones`, `permite_repetir_opcion` and `texto_guia`.
- Added validation rules and migration-safe updates for existing modifier data.

## [1.0.] - 2026-05-10

### Added

- Initial SQL Server schema script in `scripts/01_schema.sql`.
- Database creation logic for `BDOlivarGrill`.
- Core relational model for the restaurant system, including tables for:
  - products, categories, modifiers and options
  - tables, customers, employees, users and roles
  - orders, order details and order status history
  - cash sessions, payments and invoices
  - inventory, supplies and product recipes
- Primary keys, unique constraints and foreign key relationships across the schema.
- Project changelog in `CHANGELOG.md` to document notable changes.

### Changed

- Updated `README.md` to describe the repository as SQL scripts and documentation
  for the database design of El Olivar Grill.
