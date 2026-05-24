-- 1. Se crea un trigger para registrar las acciones de eliminación en la tabla Empleado_audit
CREATE TRIGGER dbo.trigger_empleado_delete
ON [dbo].[Empleado]
AFTER DELETE
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
		'DELETE'
	FROM deleted;
END;

-- 2. Probamos el trigger eliminando un registro
select * from dbo.Empleado_audit
select * from dbo.Empleado
delete from dbo.Empleado where id_empleado=8
