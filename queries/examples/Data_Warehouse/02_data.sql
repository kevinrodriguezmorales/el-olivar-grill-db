USE dw_ventas;
GO

-- =====================================
-- INSERTS DE TABLAS DE DIMENSIONES
-- =====================================

-- Dim_Categoria
INSERT INTO Dim_Categoria (idCategoria, NomCategoria) VALUES
(1, 'Electrónica'),
(2, 'Hogar'),
(3, 'Oficina');
GO

-- Dim_Marca
INSERT INTO Dim_Marca (idMarca, Nombre) VALUES
(1, 'Samsung'),
(2, 'LG'),
(3, 'HP'),
(4, 'Lenovo'),
(5, 'Philips');
GO

-- Dim_SubCategoria
INSERT INTO Dim_SubCategoria (idSubCat, idCategoria, NomSubCat) VALUES
(1, 1, 'Televisores'),
(2, 1, 'Laptops'),
(3, 2, 'Licuadoras'),
(4, 2, 'Microondas'),
(5, 3, 'Impresoras');
GO

-- Dimension_Producto
INSERT INTO Dimension_Producto
(idProducto, idMarca, idSubCat, Nombre, Peso, Altura, Anchura, Profundidad)
VALUES
(1, 1, 1, 'Smart TV 55 Pulgadas', 18.5, 78, 123, 8),
(2, 3, 2, 'Laptop HP EliteBook', 2.1, 2, 36, 25),
(3, 4, 2, 'Laptop Lenovo IdeaPad', 2.3, 2, 35, 24),
(4, 5, 3, 'Licuadora Philips 600W', 3.5, 40, 18, 18),
(5, 2, 4, 'Microondas LG 20L', 11.8, 26, 45, 34),
(6, 3, 5, 'Impresora HP LaserJet', 7.6, 28, 40, 32);
GO

-- Dimension_Almacen
INSERT INTO Dimension_Almacen
(idAlmacen, Nombre, Direccion_1, Direccion_2, CP, Localidad, Provincia)
VALUES
(1, 'Almacén Central Lima', 'Av. Primavera 123', 'Surco', '15039', 'Lima', 'Lima'),
(2, 'Almacén Norte', 'Jr. Los Olivos 456', 'Independencia', '15311', 'Lima', 'Lima'),
(3, 'Almacén Cusco', 'Av. Sol 789', 'Centro', '08001', 'Cusco', 'Cusco');
GO

-- Dimension_Promocion
INSERT INTO Dimension_Promocion
(idPromocion, NomPromocion, Tipo, Coste, Inicio, Fin)
VALUES
(1, 'Campaña Escolar', 'Descuento', 1500.00, '2026-03-01', '2026-03-31'),
(2, 'Cyber Oferta', 'Online', 3000.00, '2026-04-10', '2026-04-15'),
(3, 'Promo Hogar', 'Temporada', 1800.00, '2026-05-01', '2026-05-31');
GO

-- Dimension_Tiempo
INSERT INTO Dimension_Tiempo
(idTiempo, fecha, anyo, trimestre, mes, semana, diaSemana)
VALUES
(1, '2026-03-05', 2026, 1, 3, 10, 'Jueves'),
(2, '2026-03-12', 2026, 1, 3, 11, 'Jueves'),
(3, '2026-04-11', 2026, 2, 4, 15, 'Sabado'),
(4, '2026-05-08', 2026, 2, 5, 19, 'Viernes'),
(5, '2026-05-20', 2026, 2, 5, 21, 'Miercoles');
GO

-- Dim_Sexo
INSERT INTO Dim_Sexo (idSexo, Sexo) VALUES
(1, 'Masculino'),
(2, 'Femenino');
GO

-- Dim_FranjaEdad
INSERT INTO Dim_FranjaEdad (idEdad, Edad_Inicial, Edad_Final) VALUES
(1, 18, 25),
(2, 26, 35),
(3, 36, 45),
(4, 46, 60);
GO

-- Dimension_Cliente
INSERT INTO Dimension_Cliente
(idCliente, idEdad, idSexo, Nombre, Fecha_Registro)
VALUES
(1, 2, 1, 'Carlos Ramirez', '2025-01-15'),
(2, 1, 2, 'Maria Lopez', '2025-02-10'),
(3, 3, 1, 'Jose Fernandez', '2025-03-22'),
(4, 2, 2, 'Ana Torres', '2025-04-05'),
(5, 4, 1, 'Luis Mendoza', '2025-05-18');
GO

-- =====================================
-- INSERTS DE TABLA DE HECHOS
-- =====================================

INSERT INTO Hechos_Ventas
(idProducto, idAlmacen, idPromocion, idCliente, idTiempo, Unidades, Precio)
VALUES
(1, 1, 1, 1, 1, 2, 1899.90),
(2, 1, 1, 2, 2, 1, 3200.50),
(3, 2, 2, 3, 3, 1, 2800.00),
(4, 3, 3, 4, 4, 3, 250.75),
(5, 2, 3, 5, 5, 1, 699.90),
(6, 1, 2, 1, 3, 2, 950.40),
(1, 2, 2, 2, 3, 1, 1850.00),
(4, 3, 3, 3, 5, 2, 245.00),
(2, 1, 1, 4, 2, 1, 3150.00),
(5, 3, 3, 5, 4, 2, 680.50);
GO

---
select * from Hechos_Ventas
