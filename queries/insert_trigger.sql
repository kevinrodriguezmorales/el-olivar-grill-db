SELECT * FROM dbo.Empleado

-- Triggers (disparadores)
-- Los triggers se pueden ejecutar en estos eventos como: UPDATE / DELETE / INSERT

/* Estructura básica
	CREATE TRIGGER XXXXX_XXXXXXX
	ON NOMBRE_TABLA
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		-- SQL instructions
	END
*/

-- Objetivo: crear una tabla que permita guardar la auditoría de la tabla Empleado

-- 1. Si la tabla de auditoría existe se elimina
IF OBJECT_ID('dbo.Empleado_audit') IS NOT NULL
	drop table dbo.Empleado_audit
GO

-- 2. Cramos la tabla de auditoría
CREATE TABLE dbo.Empleado_audit
(
	id_audit INT IDENTITY(1,1) primary key,
	id_empleado INT,
	nombres_empleado varchar(100),
	apellidos_empleado varchar(100),
	dni_empleado varchar(8),
	telefono_empleado varchar(15),
	direccion_empleado varchar(200),
	fecha_contratacion_empleado date,
	activo_empleado bit,
	tipo_accion nvarchar(50),
	fecha_accion datetime default getdate(),
	usuario_accion nvarchar(100) default system_user
)
GO -- Se agrega GO para evitar la advertencia de Lote al crear el trigger en la misma sección

-- 3. Creamos trigger
-- (1) Mover a otro script para evitar la advertencia de Lote o agregar GO después de cada sección
-- Se ejecuta una sola vez y se llama cada vez que se inserta un nuevo registro en la tabla Empleado
CREATE TRIGGER dbo.trigger_empleado_insert
ON [dbo].[Empleado]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

  -- INSERT INTO en Columnas de la tabla de auditoría
	INSERT INTO dbo.Empleado_audit
	(
		id_empleado,
		nombres_empleado,
		apellidos_empleado,
		dni_empleado,
		telefono_empleado,
		direccion_empleado,
		fecha_contratacion_empleado,
		activo_empleado,
		tipo_accion
	)
  -- SELECT de la tabla inserted (tabla virtual que contiene los registros afectados por la acción de INSERT)
  -- y que son iguales a las columnas de la tabla de empleado
	SELECT
		id_empleado,
		nombres,
		apellidos,
		dni,
		telefono,
		direccion,
		fecha_contratacion,
		activo,
		'INSERT'
	FROM inserted;
END;
GO

-- 4. Insertamos datos
-- (2) se deberán de cambiar el DNI para evitar errores al guardar
INSERT INTO dbo.Empleado
(
	[nombres],
	[apellidos],
	[dni],
	[telefono],
	[direccion],
	[fecha_contratacion],
	[activo]
)
VALUES
(
	'Anibal Miguel',
	'Rodriguez',
	'99324134',
	'952111135',
	'Los saucez 242 6to piso',
	'2025-12-01',
	1
)
INSERT INTO dbo.Empleado
(
	[nombres],
	[apellidos],
	[dni],
	[telefono],
	[direccion],
	[fecha_contratacion],
	[activo]
)
VALUES
(
	'Joaquín',
	'Ramírez Saavedra',
	'99322221',
	'953125423',
	'Los astros 21 3er piso',
	'2025-12-01',
	1
)

-- 5. Consultar tabla de auditoría
SELECT * FROM dbo.Empleado_audit
