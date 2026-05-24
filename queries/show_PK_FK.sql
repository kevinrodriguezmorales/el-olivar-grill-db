USE BDOlivarGrill;
GO

/* PK (claves primarias) */
SELECT
  s.name  AS schema_name,
  t.name  AS table_name,
  kc.name AS pk_name,
  c.name  AS column_name,
  ic.key_ordinal
FROM sys.key_constraints kc
JOIN sys.tables t
  ON t.object_id = kc.parent_object_id
JOIN sys.schemas s
  ON s.schema_id = t.schema_id
JOIN sys.index_columns ic
  ON ic.object_id = t.object_id
 AND ic.index_id  = kc.unique_index_id
JOIN sys.columns c
  ON c.object_id  = t.object_id
 AND c.column_id  = ic.column_id
WHERE kc.type = 'PK'
ORDER BY s.name, t.name, ic.key_ordinal;

/* FK (claves foráneas) */
SELECT
  s_from.name AS schema_name,
  t_from.name AS table_name,
  fk.name     AS fk_name,
  c_from.name AS column_name,
  s_to.name   AS referenced_schema,
  t_to.name   AS referenced_table,
  c_to.name   AS referenced_column,
  fkc.constraint_column_id AS ordinal
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc
  ON fkc.constraint_object_id = fk.object_id
JOIN sys.tables t_from
  ON t_from.object_id = fk.parent_object_id
JOIN sys.schemas s_from
  ON s_from.schema_id = t_from.schema_id
JOIN sys.columns c_from
  ON c_from.object_id = t_from.object_id
 AND c_from.column_id = fkc.parent_column_id
JOIN sys.tables t_to
  ON t_to.object_id = fk.referenced_object_id
JOIN sys.schemas s_to
  ON s_to.schema_id = t_to.schema_id
JOIN sys.columns c_to
  ON c_to.object_id = t_to.object_id
 AND c_to.column_id = fkc.referenced_column_id
ORDER BY s_from.name, t_from.name, fk.name, fkc.constraint_column_id;


-- A) Tablas sin FK salientes (no tienen columnas que referencien a otras tablas):
SELECT
s.name AS schema_name,
t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s
ON s.schema_id = t.schema_id
LEFT JOIN sys.foreign_keys fk
ON fk.parent_object_id = t.object_id
WHERE fk.object_id IS NULL
ORDER BY s.name, t.name;

-- B) Tablas sin FK entrantes (ninguna otra tabla las referencia):
SELECT
s.name AS schema_name,
t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s
ON s.schema_id = t.schema_id
LEFT JOIN sys.foreign_keys fk
ON fk.referenced_object_id = t.object_id
WHERE fk.object_id IS NULL
ORDER BY s.name, t.name;


-- C) Tablas sin ninguna relación por FK (ni salientes ni entrantes):
SELECT
s.name AS schema_name,
t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s
ON s.schema_id = t.schema_id
LEFT JOIN sys.foreign_keys fk_out
ON fk_out.parent_object_id = t.object_id
LEFT JOIN sys.foreign_keys fk_in
ON fk_in.referenced_object_id = t.object_id
WHERE fk_out.object_id IS NULL
AND fk_in.object_id IS NULL
ORDER BY s.name, t.name;
