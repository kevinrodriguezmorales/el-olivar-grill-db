# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
