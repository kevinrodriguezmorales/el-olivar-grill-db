IF DB_ID('dw_ventas') IS NULL
    CREATE DATABASE dw_ventas;
GO

USE dw_ventas;

-- =========================
-- TABLAS DE DIMENSIONES
-- =========================

CREATE TABLE Dim_Categoria (
    idCategoria INT PRIMARY KEY,
    NomCategoria VARCHAR(50) NOT NULL
);

CREATE TABLE Dim_Marca (
    idMarca INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE Dim_SubCategoria (
    idSubCat INT PRIMARY KEY,
    idCategoria INT NOT NULL,
    NomSubCat VARCHAR(50) NOT NULL,
    CONSTRAINT fk_subcategoria_categoria
        FOREIGN KEY (idCategoria) REFERENCES Dim_Categoria(idCategoria)
);

CREATE TABLE Dimension_Producto (
    idProducto INT PRIMARY KEY,
    idMarca INT NOT NULL,
    idSubCat INT NOT NULL,
    Nombre VARCHAR(60) NOT NULL,
    Peso FLOAT,
    Altura INT,
    Anchura INT,
    Profundidad INT,
    CONSTRAINT fk_producto_marca
        FOREIGN KEY (idMarca) REFERENCES Dim_Marca(idMarca),
    CONSTRAINT fk_producto_subcategoria
        FOREIGN KEY (idSubCat) REFERENCES Dim_SubCategoria(idSubCat)
);

CREATE TABLE Dimension_Almacen (
    idAlmacen INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Direccion_1 VARCHAR(100),
    Direccion_2 VARCHAR(100),
    CP VARCHAR(5),
    Localidad VARCHAR(70),
    Provincia VARCHAR(50)
);

CREATE TABLE Dimension_Promocion (
    idPromocion INT PRIMARY KEY,
    NomPromocion VARCHAR(80) NOT NULL,
    Tipo VARCHAR(50),
    Coste FLOAT,
    Inicio DATE,
    Fin DATE
);

CREATE TABLE Dimension_Tiempo (
    idTiempo INT PRIMARY KEY,
    fecha DATE NOT NULL,
    anyo INT NOT NULL,
    trimestre INT NOT NULL,
    mes INT NOT NULL,
    semana INT NOT NULL,
    diaSemana VARCHAR(10) NOT NULL
);

CREATE TABLE Dim_Sexo (
    idSexo INT PRIMARY KEY,
    Sexo VARCHAR(10) NOT NULL
);

CREATE TABLE Dim_FranjaEdad (
    idEdad INT PRIMARY KEY,
    Edad_Inicial INT NOT NULL,
    Edad_Final INT NOT NULL
);

CREATE TABLE Dimension_Cliente (
    idCliente INT PRIMARY KEY,
    idEdad INT NOT NULL,
    idSexo INT NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Fecha_Registro DATE,
    CONSTRAINT fk_cliente_edad
        FOREIGN KEY (idEdad) REFERENCES Dim_FranjaEdad(idEdad),
    CONSTRAINT fk_cliente_sexo
        FOREIGN KEY (idSexo) REFERENCES Dim_Sexo(idSexo)
);

-- =========================
-- TABLA DE HECHOS
-- =========================

CREATE TABLE Hechos_Ventas (
    idProducto INT NOT NULL,
    idAlmacen INT NOT NULL,
    idPromocion INT NOT NULL,
    idCliente INT NOT NULL,
    idTiempo INT NOT NULL,
    Unidades INT NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (idProducto, idAlmacen, idPromocion, idCliente, idTiempo),
    CONSTRAINT fk_hechos_producto
        FOREIGN KEY (idProducto) REFERENCES Dimension_Producto(idProducto),
    CONSTRAINT fk_hechos_almacen
        FOREIGN KEY (idAlmacen) REFERENCES Dimension_Almacen(idAlmacen),
    CONSTRAINT fk_hechos_promocion
        FOREIGN KEY (idPromocion) REFERENCES Dimension_Promocion(idPromocion),
    CONSTRAINT fk_hechos_cliente
        FOREIGN KEY (idCliente) REFERENCES Dimension_Cliente(idCliente),
    CONSTRAINT fk_hechos_tiempo
        FOREIGN KEY (idTiempo) REFERENCES Dimension_Tiempo(idTiempo)
);
