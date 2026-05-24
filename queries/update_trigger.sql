-- 1. Se crea un trigger para registrar las acciones de actualización en la tabla Empleado_audit
CREATE TRIGGER dbo.trigger_empleado_update
ON [dbo].[Empleado]
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;

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
	SELECT
		id_empleado,
		nombres,
		apellidos,
		dni,
		telefono,
		direccion,
		fecha_contratacion,
		activo,
		'UPDATE'
	FROM inserted;
END;

-- 2. Probamos el trigger actualizando un registro

-- 2.1 Insertamos un nuevo registro para luego actualizarlo
insert into Empleado
(
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
	'Kevin Deywin',
	'Rodriguez Morales',
	'70009567',
	'925451349',
	'Los cedros 748 2do piso',
	'2026-01-01',
	1
)

-- 2.2 Actualizamos el registro insertado
UPDATE [dbo].[Empleado] SET [apellidos]='Rodriguez', [telefono]='+51925451347' WHERE id_empleado=10


select * from dbo.Empleado_audit
select * from dbo.Empleado


-- Apartados____________________________________
-- Reiniciar correlativo de tabla
DBCC CHECKIDENT('[Empleado_audit]', RESEED, 0)

-- Borrar tabla y reiniciar correlativo
TRUNCATE TABLE [Empleado_audit]

-- Actualizar trigger
-- 1. Eliminar trigger
DROP TRIGGER dbo.trigger_empleado_update;
GO

-- 2. Se vuelve a crear con la estructura básica
