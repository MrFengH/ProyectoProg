--------------------------------------------------------------------------
-- Datos iniciales de ESSENCE.
--------------------------------------------------------------------------

INSERT INTO Categoria VALUES (seq_categoria.NEXTVAL, 'Diseñador');
INSERT INTO Categoria VALUES (seq_categoria.NEXTVAL, 'Nicho');

INSERT INTO Marca VALUES (seq_marca.NEXTVAL, 'Chanel');
INSERT INTO Marca VALUES (seq_marca.NEXTVAL, 'Dior');
INSERT INTO Marca VALUES (seq_marca.NEXTVAL, 'Creed');
INSERT INTO Marca VALUES (seq_marca.NEXTVAL, 'Xerjoff');
INSERT INTO Marca VALUES (seq_marca.NEXTVAL, 'Maison Francis Kurkdjian');
INSERT INTO Marca VALUES (seq_marca.NEXTVAL, 'Parfums de Marly');

INSERT INTO Producto
VALUES (seq_producto.NEXTVAL,
        'Bleu de Chanel Eau de Parfum',
        145.00,
        20,
        1,
        1,
        'Cítricos, jengibre, incienso y sándalo.');

INSERT INTO Producto
VALUES (seq_producto.NEXTVAL,
        'Sauvage Elixir',
        180.00,
        15,
        1,
        2,
        'Lavanda, especias, ámbar y vetiver.');

INSERT INTO Producto
VALUES (seq_producto.NEXTVAL,
        'Aventus',
        420.00,
        10,
        2,
        3,
        'Piña, abedul, musgo de roble y almizcle.');

INSERT INTO Producto
VALUES (seq_producto.NEXTVAL,
        'Naxos',
        285.00,
        12,
        2,
        4,
        'Miel, tabaco, vainilla y haba tonka.');

INSERT INTO Producto
VALUES (seq_producto.NEXTVAL,
        'Baccarat Rouge 540',
        325.00,
        8,
        2,
        5,
        'Azafrán, jazmín, cedro y ámbar.');

INSERT INTO Producto
VALUES (seq_producto.NEXTVAL,
        'Layton',
        295.00,
        14,
        2,
        6,
        'Manzana, lavanda, vainilla y especias.');

COMMIT;
