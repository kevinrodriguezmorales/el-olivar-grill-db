-- Crear tabla temporal para uso de cursores

-- 1. Validar si la tabla temporal ya existe
IF OBJECT_ID('dbo.Empleado_copy') is not null
	DROP TABLE dbo.Empleado_copy
GO

-- 2. Crear tabla temporal pque permita recibir los datos del cursor
CREATE TABLE dbo.Empleado_copy
(
	id_empleado				INT NOT NULL,
	nombres					varchar(100) NOT NULL,
	apellidos				varchar(100) NOT NULL,
	dni						varchar(8) NOT NULL,
	telefono				varchar(15) NULL,
	direccion				varchar(200) NULL,
	fecha_contratacion		date NOT NULL,
	activo					bit NOT NULL
)
GO

-- 3. Crear Cursor
-- 3.1 Crear variables para almacenar los datos de cada registro el cursor
DECLARE
	@id_empleado			INT,
	@nombres				varchar(100),
	@apellidos				varchar(100),
	@dni					varchar(8),
	@telefono				varchar(15),
	@direccion				varchar(200),
	@fecha_contratacion		date,
	@activo					bit

-- 3.2 Crear cursor
DECLARE cursor_empleado CURSOR FOR
SELECT
	[id_empleado],
	[nombres],
	[apellidos],
	[dni],
	[telefono],
	[direccion],
	[fecha_contratacion],
	[activo]
FROM dbo.Empleado

-- 3.3 Abrir cursor
OPEN cursor_empleado

-- 3.4 Leer la primera fila y colocarlas en las variables
FETCH NEXT FROM cursor_empleado
INTO
	@id_empleado,
	@nombres,
	@apellidos,
	@dni,
	@telefono,
	@direccion,
	@fecha_contratacion,
	@activo;

-- 3.5 Recorrer fila por fila mientras existan registros
WHILE @@FETCH_STATUS=0
	BEGIN
		INSERT INTO dbo.Empleado_copy
		(
			id_empleado,
			nombres,
			apellidos,
			dni,
			telefono,
			direccion,
			fecha_contratacion,
			activo
		)
		VALUES
		(
			@id_empleado,
			@nombres,
			@apellidos,
			@dni,
			@telefono,
			@direccion,
			@fecha_contratacion,
			@activo
		)
		-- Apuntar a la siguiente fila
		FETCH NEXT FROM cursor_empleado
		INTO
			@id_empleado,
			@nombres,
			@apellidos,
			@dni,
			@telefono,
			@direccion,
			@fecha_contratacion,
			@activo;
	END;

-- 3.6 Cerramos el cursor
CLOSE cursor_empleado
DEALLOCATE cursor_empleado
GO

-- ver resultado
SELECT * FROM dbo.Empleado_copy
