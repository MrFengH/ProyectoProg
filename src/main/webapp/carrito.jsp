<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    final String DB_USER = "essence";
    final String DB_PASS = "1234";

    @SuppressWarnings("unchecked")
    LinkedHashMap<Integer, Integer> carrito = (LinkedHashMap<Integer, Integer>) session.getAttribute("carrito");
    if (carrito == null) {
        carrito = new LinkedHashMap<Integer, Integer>();
        session.setAttribute("carrito", carrito);
    }

    String accion = request.getParameter("accion");
    String mensajePago = null;

    if ("agregar".equals(accion) || "incrementar".equals(accion) || "decrementar".equals(accion) || "eliminar".equals(accion)) {
        int productoId = Integer.parseInt(request.getParameter("producto_id"));
        Integer cantidadActual = carrito.get(productoId);

        if ("agregar".equals(accion) || "incrementar".equals(accion)) {
            carrito.put(productoId, (cantidadActual == null ? 0 : cantidadActual) + 1);
        } else if ("decrementar".equals(accion)) {
            if (cantidadActual != null) {
                if (cantidadActual <= 1) carrito.remove(productoId);
                else carrito.put(productoId, cantidadActual - 1);
            }
        } else if ("eliminar".equals(accion)) {
            carrito.remove(productoId);
        }

        response.sendRedirect("carrito.jsp");
        return;
    } else if ("pagar".equals(accion)) {
        Object clienteIdObj = session.getAttribute("clienteId");
        if (clienteIdObj == null) {
            response.sendRedirect("login.html");
            return;
        }

        if (!carrito.isEmpty()) {
            int clienteId = (Integer) clienteIdObj;
            Connection con = null;
            CallableStatement callOrden = null;
            CallableStatement callItem = null;

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

                callOrden = con.prepareCall("{ call iniciar_orden(?, ?) }");
                callOrden.setInt(1, clienteId);
                callOrden.registerOutParameter(2, Types.NUMERIC);
                callOrden.execute();
                int ordenId = callOrden.getInt(2);

                for (Map.Entry<Integer, Integer> item : carrito.entrySet()) {
                    callItem = con.prepareCall("{ call agregar_item_orden(?, ?, ?) }");
                    callItem.setInt(1, ordenId);
                    callItem.setInt(2, item.getKey());
                    callItem.setInt(3, item.getValue());
                    callItem.execute();
                    callItem.close();
                    callItem = null;
                }

                mensajePago = "¡Gracias por tu compra! Tu orden #" + ordenId + " fue registrada.";
                carrito.clear();
            } catch (Exception e) {
                mensajePago = "No se pudo procesar el pago: " + e.getMessage();
            } finally {
                try {
                    if (callItem != null) callItem.close();
                    if (callOrden != null) callOrden.close();
                    if (con != null) con.close();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    Map<Integer, Object[]> productos = new HashMap<Integer, Object[]>();
    if (!carrito.isEmpty()) {
        Connection con = null;
        CallableStatement call = null;
        ResultSet rs = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            call = con.prepareCall("{ call mostrar_productos(?) }");
            call.registerOutParameter(1, oracle.jdbc.OracleTypes.CURSOR);
            call.execute();

            rs = (ResultSet) call.getObject(1);
            while (rs.next()) {
                int pid = rs.getInt("producto_id");
                if (carrito.containsKey(pid)) {
                    productos.put(pid, new Object[] {
                        rs.getString("nombre_prod"),
                        rs.getDouble("precio"),
                        rs.getString("descripcion")
                    });
                }
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        } finally {
            try {
                if (call != null) call.close();
                if (rs != null) rs.close();
                if (con != null) con.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    double subtotal = 0;
    for (Map.Entry<Integer, Integer> item : carrito.entrySet()) {
        Object[] info = productos.get(item.getKey());
        if (info != null) {
            subtotal += ((Double) info[1]) * item.getValue();
        }
    }
    double envio = carrito.isEmpty() ? 0 : 5.00;
    double impuestos = subtotal * 0.07;
    double total = subtotal + envio + impuestos;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mahmoud Parfums</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">
</head>
<body>

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

    <main>
        <section class="cart">
            <div class="section-title">
                <span>Tu Selección</span>
                <h2>Carrito de Compras</h2>
                <p>Revisa tus fragancias antes de finalizar la compra.</p>
            </div>

            <% if (mensajePago != null) { %>
                <div class="cart-mensaje">
                    <p><%= mensajePago %></p>
                    <a href="productos.jsp">Seguir comprando →</a>
                </div>
            <% } else if (carrito.isEmpty()) { %>
                <div class="cart-vacio">
                    <p>Tu carrito está vacío.</p>
                    <a href="productos.jsp">Ver colección →</a>
                </div>
            <% } else { %>
                <div class="cart-body">
                    <div class="cart-items">
                        <% for (Map.Entry<Integer, Integer> item : carrito.entrySet()) {
                            int pid = item.getKey();
                            int cantidad = item.getValue();
                            Object[] info = productos.get(pid);
                            if (info == null) continue;
                            String nombre = (String) info[0];
                            double precio = (Double) info[1];
                            String descripcion = (String) info[2];
                        %>
                        <article class="cart-item">
                            <img src="assets/<%= nombre %>.webp" alt="<%= nombre %>">
                            <div class="cart-item-info">
                                <h3><%= nombre %></h3>
                                <p><%= descripcion %></p>
                                <span class="cart-item-precio">$<%= String.format("%.2f", precio) %></span>
                            </div>
                            <form class="cart-item-qty" action="carrito.jsp" method="post">
                                <input type="hidden" name="producto_id" value="<%= pid %>">
                                <button type="submit" name="accion" value="decrementar">-</button>
                                <span><%= cantidad %></span>
                                <button type="submit" name="accion" value="incrementar">+</button>
                            </form>
                            <div class="cart-item-total">
                                <strong>$<%= String.format("%.2f", precio * cantidad) %></strong>
                                <form action="carrito.jsp" method="post">
                                    <input type="hidden" name="producto_id" value="<%= pid %>">
                                    <button type="submit" name="accion" value="eliminar" class="cart-item-remove">×</button>
                                </form>
                            </div>
                        </article>
                        <% } %>
                    </div>

                    <aside class="cart-resumen">
                        <h3>Resumen del pedido</h3>
                        <div class="resumen-linea">
                            <span>Subtotal</span>
                            <span>$<%= String.format("%.2f", subtotal) %></span>
                        </div>
                        <div class="resumen-linea">
                            <span>Envío</span>
                            <span>$<%= String.format("%.2f", envio) %></span>
                        </div>
                        <div class="resumen-linea">
                            <span>Impuestos (7%)</span>
                            <span>$<%= String.format("%.2f", impuestos) %></span>
                        </div>
                        <div class="resumen-linea resumen-total">
                            <span>Total</span>
                            <span>$<%= String.format("%.2f", total) %></span>
                        </div>
                        <form action="carrito.jsp" method="post">
                            <button type="submit" name="accion" value="pagar" class="btn-pagar">Proceder al pago</button>
                        </form>
                        <a href="productos.jsp" class="cart-seguir">← Seguir comprando</a>
                    </aside>
                </div>
            <% } %>
        </section>
    </main>

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
