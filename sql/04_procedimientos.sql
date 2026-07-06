--------------------------------------------------------------------------
-- Procedimientos de ESSENCE, ajustados a lo que llaman los JSP.
--
-- Nota: el procedure original crear_orden (un producto = una orden) ya
-- no se usa: carrito.jsp arma una orden con varios productos usando
-- iniciar_orden + agregar_item_orden, por eso no se incluye aqui.
--------------------------------------------------------------------------

/* Registro de un cliente nuevo (usado por procesarRegistro.jsp). */
CREATE OR REPLACE PROCEDURE registrar_usuario (
    p_nombre   IN Cliente.nombre%TYPE,
    p_email    IN Cliente.email%TYPE,
    p_password IN Cliente.password%TYPE
)
AS
BEGIN
    INSERT INTO Cliente (cliente_id, nombre, email, password)
    VALUES (seq_cliente.NEXTVAL, p_nombre, p_email, p_password);

    COMMIT;
END;
/

/* Valida credenciales de login y devuelve el cliente_id + nombre para
   guardarlos en sesion (usado por procesarLogin.jsp). */
CREATE OR REPLACE PROCEDURE validar_login (
    p_email      IN  Cliente.email%TYPE,
    p_password   IN  Cliente.password%TYPE,
    p_resultado  OUT NUMBER,
    p_cliente_id OUT Cliente.cliente_id%TYPE,
    p_nombre     OUT Cliente.nombre%TYPE
)
AS
BEGIN
    SELECT cliente_id, nombre
    INTO p_cliente_id, p_nombre
    FROM Cliente
    WHERE email = p_email
    AND password = p_password;

    p_resultado := 1;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_resultado := 0;
        p_cliente_id := NULL;
        p_nombre := NULL;
END;
/

/* Lista de productos, incluye producto_id para poder agregarlos al
   carrito (usado por productos.jsp y carrito.jsp). */
CREATE OR REPLACE PROCEDURE mostrar_productos (
    p_resultado OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_resultado FOR
        SELECT producto_id, nombre_prod, precio, stock, descripcion
        FROM Producto;
END;
/

/* Crea la cabecera de una orden con los datos de envio, con el total
   inicial en el costo de envio (0 si es retiro, 6 si es express); se
   va acumulando con agregar_item_orden. Usado por carrito.jsp al pagar. */
CREATE OR REPLACE PROCEDURE iniciar_orden (
    p_cliente_id      IN  Ordenes.cliente_id%TYPE,
    p_nombre_completo IN  Ordenes.nombre_completo%TYPE,
    p_telefono        IN  Ordenes.telefono%TYPE,
    p_metodo_envio    IN  Ordenes.metodo_envio%TYPE,
    p_provincia       IN  Ordenes.provincia%TYPE,
    p_sucursal        IN  Ordenes.sucursal%TYPE,
    p_costo_envio     IN  Ordenes.total%TYPE,
    p_orden_id        OUT Ordenes.orden_id%TYPE
)
AS
BEGIN
    p_orden_id := seq_orden.NEXTVAL;

    INSERT INTO Ordenes (
        orden_id, cliente_id, fecha_compra, fecha, total,
        nombre_completo, telefono, metodo_envio, provincia, sucursal
    )
    VALUES (
        p_orden_id, p_cliente_id, SYSDATE, SYSDATE, p_costo_envio,
        p_nombre_completo, p_telefono, p_metodo_envio, p_provincia, p_sucursal
    );

    COMMIT;
END;
/

/* Agrega una linea de producto a una orden ya iniciada: valida stock,
   descuenta stock y acumula el total de la orden. Se llama una vez
   por cada producto distinto del carrito. */
CREATE OR REPLACE PROCEDURE agregar_item_orden (
    p_orden_id    IN Orden_Item.orden_id%TYPE,
    p_producto_id IN Producto.producto_id%TYPE,
    p_cantidad    IN Orden_Item.cantidad%TYPE
)
AS
    v_precio Producto.precio%TYPE;
    v_stock  Producto.stock%TYPE;
BEGIN
    SELECT precio, stock
    INTO v_precio, v_stock
    FROM Producto
    WHERE producto_id = p_producto_id
    FOR UPDATE;

    IF v_stock < p_cantidad THEN
        RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente');
    END IF;

    INSERT INTO Orden_Item (orden_item_id, orden_id, producto_id, cantidad, precio_uni)
    VALUES (seq_orden_item.NEXTVAL, p_orden_id, p_producto_id, p_cantidad, v_precio);

    UPDATE Producto
       SET stock = stock - p_cantidad
     WHERE producto_id = p_producto_id;

    UPDATE Ordenes
       SET total = total + (v_precio * p_cantidad)
     WHERE orden_id = p_orden_id;

    COMMIT;
END;
/

/* Cabecera de cada orden con el nombre del cliente que la hizo, mas
   reciente primero (usado por admin.jsp). Solo lectura. */
CREATE OR REPLACE PROCEDURE mostrar_ordenes (
    p_resultado OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_resultado FOR
        SELECT o.orden_id,
               o.cliente_id,
               c.nombre AS cliente_nombre,
               TO_CHAR(o.fecha_compra, 'DD/MM/YYYY HH24:MI') AS fecha_compra,
               o.total,
               o.nombre_completo,
               o.telefono,
               o.metodo_envio,
               o.provincia,
               o.sucursal
        FROM Ordenes o
        JOIN Cliente c ON c.cliente_id = o.cliente_id
        ORDER BY o.orden_id DESC;
END;
/

/* Lineas de producto de una orden puntual (usado por admin.jsp). */
CREATE OR REPLACE PROCEDURE mostrar_items_orden (
    p_orden_id  IN  Orden_Item.orden_id%TYPE,
    p_resultado OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_resultado FOR
        SELECT p.nombre_prod,
               oi.cantidad,
               oi.precio_uni,
               (oi.cantidad * oi.precio_uni) AS subtotal
        FROM Orden_Item oi
        JOIN Producto p ON p.producto_id = oi.producto_id
        WHERE oi.orden_id = p_orden_id
        ORDER BY oi.orden_item_id;
END;
/
