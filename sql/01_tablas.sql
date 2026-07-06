--------------------------------------------------------------------------
-- Esquema de tablas de ESSENCE.
--------------------------------------------------------------------------

CREATE TABLE Cliente (
    cliente_id NUMBER PRIMARY KEY,
    nombre     VARCHAR2(100) NOT NULL,
    email      VARCHAR2(150) NOT NULL UNIQUE,
    password   VARCHAR2(255) NOT NULL
);

CREATE TABLE Categoria (
    categoria_id NUMBER PRIMARY KEY,
    nombre_cat   VARCHAR2(100) NOT NULL UNIQUE
);

CREATE TABLE Marca (
    marca_id NUMBER PRIMARY KEY,
    nombre_m VARCHAR2(100) NOT NULL UNIQUE
);

CREATE TABLE Producto (
    producto_id  NUMBER PRIMARY KEY,
    nombre_prod  VARCHAR2(150) NOT NULL,
    precio       NUMBER(10,2) NOT NULL CHECK (precio >= 0),
    stock        NUMBER(10) NOT NULL CHECK (stock >= 0),
    categoria_id NUMBER NOT NULL,
    marca_id     NUMBER NOT NULL,
    descripcion  VARCHAR2(200),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (categoria_id) REFERENCES Categoria(categoria_id),
    CONSTRAINT fk_producto_marca FOREIGN KEY (marca_id) REFERENCES Marca(marca_id)
);

CREATE TABLE Ordenes (
    orden_id        NUMBER PRIMARY KEY,
    cliente_id      NUMBER NOT NULL,
    fecha_compra    DATE NOT NULL,
    fecha           DATE DEFAULT SYSDATE,
    total           NUMBER(10,2) NOT NULL CHECK (total >= 0),
    nombre_completo VARCHAR2(150),
    telefono        VARCHAR2(20),
    metodo_envio    VARCHAR2(20) DEFAULT 'retiro' NOT NULL CHECK (metodo_envio IN ('retiro', 'express')),
    provincia       VARCHAR2(50),
    sucursal        VARCHAR2(100),
    CONSTRAINT fk_orden_cliente FOREIGN KEY (cliente_id) REFERENCES Cliente(cliente_id)
);

CREATE TABLE Orden_Item (
    orden_item_id NUMBER PRIMARY KEY,
    orden_id      NUMBER NOT NULL,
    producto_id   NUMBER NOT NULL,
    cantidad      NUMBER(10) NOT NULL CHECK (cantidad > 0),
    precio_uni    NUMBER(10,2) NOT NULL CHECK (precio_uni >= 0),
    CONSTRAINT fk_orden_item_orden FOREIGN KEY (orden_id) REFERENCES Ordenes(orden_id),
    CONSTRAINT fk_orden_item_producto FOREIGN KEY (producto_id) REFERENCES Producto(producto_id)
);
