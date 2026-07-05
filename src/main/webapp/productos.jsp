<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Colección</title>
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
                    <h4>Usuario</h4>
                    <a href="login.html">Iniciar Sesión</a>
                </div>
            </div>
        </nav>
    </header>

    <main>
        <section class="coleccion">
            <div class="cards-coleccion">
                <%
                    Connection con = null;
                    CallableStatement call = null;
                    ResultSet rs = null;

                    try {
                        Class.forName("oracle.jdbc.driver.OracleDriver");
                        con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "essence", "1234");

                        call = con.prepareCall("{ call mostrar_productos(?) }");
                        call.registerOutParameter(1, oracle.jdbc.OracleTypes.CURSOR);
                        
                        call.execute();

                        rs = (ResultSet) call.getObject(1);

                        while (rs.next()){
                %>  
                <article class="card-perfume">
                    <img src="assets/<%= rs.getString("nombre_prod") %>.webp" alt="<%= rs.getString("nombre_prod") %>">
                    <div class="card-info">
                        <span style="color: #d6ad60;font-weight: bold;">Stock: <%= rs.getInt("stock")%></span>
                        <h3><%= rs.getString("nombre_prod") %></h3>
                        <p><%= rs.getString("descripcion") %></p>
                        <div class="card-compra">
                            <p class="precio">$<%= rs.getDouble("precio") %></p>
                            <form action="carrito.jsp" method="post">
                                <input type="hidden" name="producto_id" value="<%= rs.getInt("producto_id") %>">
                                <button type="submit" name="accion" value="agregar" <%= rs.getInt("stock") <= 0 ? "disabled" : "" %>>Añadir al carrito</button>
                            </form>
                        </div>
                    </div>
                </article>
                    <%
                        }
                    }
                    catch (Exception e) {
                        System.out.println("Error: " + e.getMessage());
                    } finally {
                        if (call != null) call.close();
                        if (rs != null) rs.close();
                        if (con  != null) con.close();
                    }
                    %>
            </div>
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
