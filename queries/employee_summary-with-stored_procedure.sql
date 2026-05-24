-- Procedimiento almacenado
-- Las funciones deben ser creadas inicialmente
CREATE OR ALTER PROCEDURE dbo.storedProcedureEmployeeSummary
(
	@EmployeeID INT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @EmployeeNames NVARCHAR(40);
	DECLARE @EmployeeCellphone NVARCHAR(40);

	SET @EmployeeNames=dbo.fn_getEmployeeName(@EmployeeID);
	SET @EmployeeCellphone=dbo.fn_getEmployeeCellphone(@EmployeeID);

	SELECT @EmployeeID as EmployeeID, @EmployeeNames as EmployeeNames, @EmployeeCellphone as EmployeeCellpohone
END

-- Ejecutamos el procedimiento almacenado
EXEC dbo.storedProcedureEmployeeSummary 10
