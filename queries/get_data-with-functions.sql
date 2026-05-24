USE BDOlivarGrill;
GO

SELECT * FROM Empleado
GO

-- Funciones

-- Función para obtener nombre de empleado
CREATE OR ALTER FUNCTION dbo.fn_getEmployeeName
(
	@employeeID INT
)
RETURNS NVARCHAR(40)
AS
BEGIN
	DECLARE @EmployeeNames NVARCHAR(40);

	SELECT @EmployeeNames=[nombres]
	FROM [dbo].[Empleado]
	WHERE [id_empleado]=@employeeID

	RETURN @EmployeeNames
END;
GO

-- Función para obtener telefono empleado
CREATE OR ALTER FUNCTION dbo.fn_getEmployeeCellphone
(
	@employeeID INT
)
RETURNS NVARCHAR(15)
AS
BEGIN
	DECLARE @EmployeeCellphone NVARCHAR(40);

	SELECT @EmployeeCellphone=[telefono]
	FROM [dbo].[Empleado]
	WHERE [id_empleado]=@employeeID

	RETURN @EmployeeCellphone
END;
GO

-- Función para obtener datos completos
CREATE OR ALTER FUNCTION dbo.fn_getEmployeeData
(
	@employeeID INT
)
RETURNS TABLE
AS
RETURN
(
	SELECT [id_empleado],[nombres],[apellidos],[dni],[telefono],[direccion],[fecha_contratacion],[activo]
	FROM [dbo].[Empleado]
	WHERE [id_empleado]=@employeeID
)
GO

-- Llamamos a las funciones para el empleado con el id 10
SELECT dbo.fn_getEmployeeName(10) as EmployeeName
SELECT dbo.fn_getEmployeeCellphone(10) as EmployeeCellphone
SELECT * FROM dbo.fn_getEmployeeData(10)
