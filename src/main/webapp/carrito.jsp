<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Carrito de compras basado en sesión (Map producto_id -> cantidad).
    Este bloque maneja 3 casos según el parámetro "accion":
      1. agregar/incrementar/decrementar/eliminar -> solo modifica el
         carrito en sesión y redirige (no toca la base de datos).
      2. pagar -> crea la orden en Oracle (iniciar_orden +
         agregar_item_orden, una orden con varios items) y vacía el carrito.
      3. sin acción (carga normal de la página) -> solo arma los datos
         para mostrar la vista del carrito.
--%>
<%
    request.setCharacterEncoding("UTF-8");

    final String DB_URL = "jdbc:oracle:thin:@localhost:1521:xe";
    final String DB_USER = "essence";
    final String DB_PASS = "1234";

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
        // Sin sesión iniciada no hay cliente_id para asociar a la orden
        Object clienteIdObj = session.getAttribute("clienteId");
        if (clienteIdObj == null) {
            response.sendRedirect("login.html");
            return;
        }

        if (!carrito.isEmpty()) {
            int clienteId = (Integer) clienteIdObj;

            String nombreCompleto = request.getParameter("nombre_completo");
            String telefono = request.getParameter("telefono");
            String metodoEnvio = request.getParameter("metodo_envio");
            if (metodoEnvio == null || metodoEnvio.isEmpty()) metodoEnvio = "retiro";
            boolean esExpress = "express".equals(metodoEnvio);

            // Provincia/sucursal solo aplican si el método es express
            String provincia = esExpress ? request.getParameter("provincia") : null;
            String sucursal = esExpress ? request.getParameter("sucursal") : null;
            double costoEnvio = esExpress ? 6.00 : 0.00;

            Connection con = null;
            CallableStatement callOrden = null;
            CallableStatement callItem = null;

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

                // 1 Crear la cabecera de la orden con los datos de envío
                //    (el total arranca en el costo de envío, 0 o 6)
                callOrden = con.prepareCall("{ call iniciar_orden(?, ?, ?, ?, ?, ?, ?, ?) }");
                callOrden.setInt(1, clienteId);
                callOrden.setString(2, nombreCompleto);
                callOrden.setString(3, telefono);
                callOrden.setString(4, metodoEnvio);
                callOrden.setString(5, provincia);
                callOrden.setString(6, sucursal);
                callOrden.setDouble(7, costoEnvio);
                callOrden.registerOutParameter(8, Types.NUMERIC);
                callOrden.execute();
                int ordenId = callOrden.getInt(8);

                // 2 Agregar una línea de Orden_Item por cada producto distinto del carrito
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

    // Trae nombre/precio/descripcion solo de los productos que están en el carrito,
    // para no golpear la base de datos si el carrito está vacío
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

    // Subtotal, envío fijo, impuesto del 7% y total a mostrar en el resumen del pedido
    double subtotal = 0;
    for (Map.Entry<Integer, Integer> item : carrito.entrySet()) {
        Object[] info = productos.get(item.getKey());
        if (info != null) {
            subtotal += ((Double) info[1]) * item.getValue();
        }
    }
    // Por defecto "Retiro en Local" ($0); el monto real se recalcula
    // en el navegador según el método de envío que el usuario elija
    double envio = 0;
    double impuestos = subtotal * 0.07;
    double total = subtotal + envio + impuestos;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carrito</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
</head>
<body>

    <!-- Banner superior: logo, menú de navegación completo e iconos de búsqueda/redes -->
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

                    <form id="form-pago" action="carrito.jsp" method="post" class="cart-checkout-col"
                          data-subtotal="<%= subtotal %>" data-impuestos="<%= impuestos %>">
                        <div class="cart-envio">
                            <h3>Método de Envío</h3>

                            <label class="envio-opcion">
                                <input type="radio" name="metodo_envio" value="retiro" checked>
                                <div class="envio-opcion-info">
                                    <strong>Retiro en Local</strong>
                                    <span>Vía España, Torre Essence, Planta Baja</span>
                                </div>
                                <span class="envio-opcion-costo">$0.00</span>
                            </label>

                            <label class="envio-opcion">
                                <input type="radio" name="metodo_envio" value="express">
                                <div class="envio-opcion-info">
                                    <strong>Uno Express</strong>
                                    <span>Disponible en todo Panamá · 1-2 días hábiles</span>
                                </div>
                                <span class="envio-opcion-costo">$6.00</span>
                            </label>

                            <label for="nombre_completo">Nombre Completo</label>
                            <input type="text" name="nombre_completo" id="nombre_completo" placeholder="Tu nombre completo" required>

                            <label for="telefono">Número de Teléfono</label>
                            <input type="tel" name="telefono" id="telefono" placeholder="6000-0000" required>

                            <div id="campos-express" class="campos-express">
                                <label for="provincia">Provincia</label>
                                <select name="provincia" id="provincia">
                                    <option value="">Seleccione una provincia</option>
                                </select>

                                <label for="sucursal">Sucursal de Retiro</label>
                                <select name="sucursal" id="sucursal">
                                    <option value="">Seleccione una sucursal</option>
                                </select>
                            </div>
                        </div>

                        <aside class="cart-resumen">
                            <h3>Resumen del pedido</h3>
                            <div class="resumen-linea">
                                <span>Subtotal</span>
                                <span>$<%= String.format("%.2f", subtotal) %></span>
                            </div>
                            <div class="resumen-linea">
                                <span>Envío</span>
                                <span id="envio-display">$<%= String.format("%.2f", envio) %></span>
                            </div>
                            <div class="resumen-linea">
                                <span>Impuestos (7%)</span>
                                <span>$<%= String.format("%.2f", impuestos) %></span>
                            </div>
                            <div class="resumen-linea resumen-total">
                                <span>Total</span>
                                <span id="total-display">$<%= String.format("%.2f", total) %></span>
                            </div>
                            <button type="submit" name="accion" value="pagar" class="btn-pagar">Proceder al pago</button>
                            <a href="productos.jsp" class="cart-seguir">← Seguir comprando</a>
                        </aside>
                    </form>
                </div>
            <% } %>
        </section>
    </main>

    <!-- Pie de página: versión reducida del menú, copyright y logout -->
    <footer class="footer">
        <div class="footer-menu">
            <a href="index.jsp">Inicio</a>
            <a href="productos.jsp">Colección</a>
            <a href="contacto.html">Sobre Nosotros</a>
            <a href="logout.jsp">Logout</a>
        </div>
        <p>&copy; 2026 ESSENCE. Todos los derechos reservados.</p>
    </footer>

    <script>
        // Sucursales de retiro disponibles por provincia (solo aplica si el método es "Uno Express")
        var opcionesPorProvincia = {
            'Bocas del Toro': ['Almirante', 'Changuinola', 'Chiriquí Grande', 'Isla Colón'],
            'Chiriquí': ['Boquete', 'Bugaba', 'David', 'David San Mateo', 'Frontera', 'Via Principal, Frente a Hospital del Seguro', 'Volcán'],
            'Coclé': ['Aguadulce', 'El Valle de Antón', 'Penonomé'],
            'Colón': ['Colón'],
            'Herrera': ['Chitré'],
            'Los Santos': ['Las Tablas', 'Pedasí'],
            'Panamá': ['24 de Diciembre', 'Albrook', 'Brisas del Golf', 'Costa del Este', 'El Dorado', 'Juan Díaz', 'Justo Arosemena', 'Las Acacias', 'Los Andes', 'Marbella', 'Obarrio', 'Río Abajo', 'San Francisco', 'Tumba Muerto', 'Vía Brasil', 'Villa Lucre', 'Vista Hermosa'],
            'Panamá Oeste': ['Gorgona', 'La Chorrera', 'Paseo Arraiján', 'Vista Alegre'],
            'Veraguas': ['Santiago', 'Soná']
        };

        // Subtotal e impuestos ya vienen calculados desde el servidor
        // (se leen del atributo data-* del formulario);
        // solo el envío cambia en vivo según el método que se elija
        var formPago = document.getElementById('form-pago');
        var SUBTOTAL = parseFloat(formPago.dataset.subtotal);
        var IMPUESTOS = parseFloat(formPago.dataset.impuestos);

        var radiosEnvio = document.querySelectorAll('input[name="metodo_envio"]');
        var camposExpress = document.getElementById('campos-express');
        var selectProvincia = document.getElementById('provincia');
        var selectSucursal = document.getElementById('sucursal');
        var envioDisplay = document.getElementById('envio-display');
        var totalDisplay = document.getElementById('total-display');

        if (selectProvincia) {
            Object.keys(opcionesPorProvincia).forEach(function (provincia) {
                var option = document.createElement('option');
                option.value = provincia;
                option.textContent = provincia;
                selectProvincia.appendChild(option);
            });

            selectProvincia.addEventListener('change', function () {
                selectSucursal.innerHTML = '<option value="">Seleccione una sucursal</option>';
                var sucursales = opcionesPorProvincia[selectProvincia.value] || [];
                sucursales.forEach(function (sucursal) {
                    var option = document.createElement('option');
                    option.value = sucursal;
                    option.textContent = sucursal;
                    selectSucursal.appendChild(option);
                });
            });
        }

        function actualizarEnvio() {
            var metodo = document.querySelector('input[name="metodo_envio"]:checked').value;
            var costoEnvio = metodo === 'express' ? 6 : 0;

            camposExpress.style.display = metodo === 'express' ? 'block' : 'none';

            var total = SUBTOTAL + costoEnvio + IMPUESTOS;
            envioDisplay.textContent = '$' + costoEnvio.toFixed(2);
            totalDisplay.textContent = '$' + total.toFixed(2);
        }

        radiosEnvio.forEach(function (radio) {
            radio.addEventListener('change', actualizarEnvio);
        });

        if (radiosEnvio.length > 0) {
            actualizarEnvio();
        }
    </script>
</body>
</html>
