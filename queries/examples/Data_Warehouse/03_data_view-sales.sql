USE dw_ventas;
GO

CREATE OR ALTER VIEW VW_Ventas_Totales
AS
	SELECT
		DP.idProducto,
		DP.Nombre as Nombre_Producto,
		SUM(HV.Unidades) as Total_Unidades,
		SUM(HV.Unidades*HV.Precio) as Total_Ventas
	FROM [dbo].[Hechos_Ventas] HV
	INNER JOIN [dbo].[Dimension_Producto] DP ON HV.idProducto = DP.idProducto
	GROUP BY DP.idProducto, DP.Nombre
	--- ORDER BY Total_Ventas desc <- Order By es invalido en Vistas
