<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Panel de administracion de solo lectura
--%>
<%
    final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    final String DB_USER = "essence";
    final String DB_PASS = "1234";

    // Clases locales para agrupar los datos de cada orden y sus items
    class OrdenItem {
        String nombreProd;
        int cantidad;
        double precioUni;
        double subtotal;
    }

    class Orden {
        int ordenId;
        String clienteNombre;
        String fechaCompra;
        double total;
        String nombreCompleto;
        String telefono;
        String metodoEnvio;
        String provincia;
        String sucursal;
        List<OrdenItem> items = new ArrayList<OrdenItem>();
    }

    List<Orden> ordenes = new ArrayList<Orden>();

    Connection con = null;
    CallableStatement callOrdenes = null;
    CallableStatement callItems = null;
    ResultSet rsOrdenes = null;
    ResultSet rsItems = null;

    try {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // 1 Traer la cabecera de todas las ordenes (mas reciente primero)
        callOrdenes = con.prepareCall("{ call mostrar_ordenes(?) }");
        callOrdenes.registerOutParameter(1, oracle.jdbc.OracleTypes.CURSOR);
        callOrdenes.execute();
        rsOrdenes = (ResultSet) callOrdenes.getObject(1);

        while (rsOrdenes.next()) {
            Orden orden = new Orden();
            orden.ordenId = rsOrdenes.getInt("orden_id");
            orden.clienteNombre = rsOrdenes.getString("cliente_nombre");
            orden.fechaCompra = rsOrdenes.getString("fecha_compra");
            orden.total = rsOrdenes.getDouble("total");
            orden.nombreCompleto = rsOrdenes.getString("nombre_completo");
            orden.telefono = rsOrdenes.getString("telefono");
            orden.metodoEnvio = rsOrdenes.getString("metodo_envio");
            orden.provincia = rsOrdenes.getString("provincia");
            orden.sucursal = rsOrdenes.getString("sucursal");

            // 2 Por cada orden, traer sus items (producto, cantidad, subtotal)
            callItems = con.prepareCall("{ call mostrar_items_orden(?, ?) }");
            callItems.setInt(1, orden.ordenId);
            callItems.registerOutParameter(2, oracle.jdbc.OracleTypes.CURSOR);
            callItems.execute();
            rsItems = (ResultSet) callItems.getObject(2);

            while (rsItems.next()) {
                OrdenItem item = new OrdenItem();
                item.nombreProd = rsItems.getString("nombre_prod");
                item.cantidad = rsItems.getInt("cantidad");
                item.precioUni = rsItems.getDouble("precio_uni");
                item.subtotal = rsItems.getDouble("subtotal");
                orden.items.add(item);
            }
            rsItems.close();
            callItems.close();
            callItems = null;

            ordenes.add(orden);
        }
    } catch (Exception e) {
        System.out.println("Error: " + e.getMessage());
    } finally {
        try {
            if (rsItems != null) rsItems.close();
            if (callItems != null) callItems.close();
            if (rsOrdenes != null) rsOrdenes.close();
            if (callOrdenes != null) callOrdenes.close();
            if (con != null) con.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Ordenes</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">
</head>
<body>

    <!-- Banner superior: logo, menu de navegacion completo e iconos de busqueda/redes -->
    <header>
        <nav>
            <div class="logo">
                <a href="index.jsp">
                    <img src="assets/logo.png">
                </a>
                <a href="index.jsp"><h2>ESSENCE</h2></a>
            </div>
            <div class="nav-links">
                <a href="index.jsp">Inicio</a>
                <a href="productos.jsp">Colección</a>
                <a href="contacto.html">Sobre Nosotros</a>
                <a href="carrito.jsp">Carrito</a>
                <a href="admin.jsp">Admin</a>
            </div>
            <div class="top-icons">
                <a href="https://www.google.com">
                    <img src="assets/lupa.png" alt="Buscar" class="search-icon">
                </a>
                <a href="https://www.instagram.com">IG</a>
                <a href="https://www.facebook.com">F</a>
                <a href="https://www.x.com">X</a>
            </div>
            <div class="perfil">
                <img src="assets/IconoPerfil.png" alt="Icono de perfil">
                <div class="perfil-info">
                    <% if (session.getAttribute("clienteNombre") != null) { %>
                        <h4><%= session.getAttribute("clienteNombre") %></h4>
                        <a href="logout.jsp">Cerrar sesión</a>
                    <% } else { %>
                        <h4>Usuario</h4>
                        <a href="login.html">Iniciar Sesión</a>
                    <% } %>
                </div>
            </div>
        </nav>
    </header>

    <!-- Contenido principal: una tarjeta por orden, con sus items adentro -->
    <main>
        <section class="cart">
            <div class="section-title">
                <span>Panel Admin</span>
                <h2>Órdenes</h2>
                <p>Historial de compras realizadas por los clientes.</p>
            </div>

            <% if (ordenes.isEmpty()) { %>
                <div class="cart-vacio">
                    <p>Todavía no hay órdenes registradas.</p>
                </div>
            <% } else { %>
                <div class="ordenes-lista">
                    <% for (Orden orden : ordenes) { %>
                    <article class="orden-card">
                        <div class="orden-header">
                            <div>
                                <span class="orden-id">Orden #<%= orden.ordenId %></span>
                                <h3><%= orden.nombreCompleto != null ? orden.nombreCompleto : orden.clienteNombre %></h3>
                                <span class="orden-fecha"><%= orden.fechaCompra %></span>
                            </div>
                            <div class="orden-total">
                                <span>Total</span>
                                <strong>$<%= String.format("%.2f", orden.total) %></strong>
                            </div>
                        </div>
                        <div class="orden-envio">
                            <span>
                                Teléfono: <%= orden.telefono != null ? orden.telefono : "-" %>
                            </span>
                            <span>
                                <% if ("express".equals(orden.metodoEnvio)) { %>
                                    Uno Express · <%= orden.provincia %>, <%= orden.sucursal %>
                                <% } else { %>
                                    Retiro en Local
                                <% } %>
                            </span>
                        </div>
                        <div class="orden-items">
                            <% for (OrdenItem item : orden.items) { %>
                            <div class="orden-item-linea">
                                <span><%= item.nombreProd %> × <%= item.cantidad %></span>
                                <span>$<%= String.format("%.2f", item.subtotal) %></span>
                            </div>
                            <% } %>
                        </div>
                    </article>
                    <% } %>
                </div>
            <% } %>
        </section>
    </main>

    <!-- Pie de pagina: version reducida del menu, copyright y logout -->
    <footer class="footer">
        <div class="footer-menu">
            <a href="index.jsp">Inicio</a>
            <a href="productos.jsp">Colección</a>
            <a href="contacto.html">Sobre Nosotros</a>
            <a href="logout.jsp">Logout</a>
        </div>
        <p>&copy; 2026 ESSENCE. Todos los derechos reservados.</p>
    </footer>
</body>
</html>
