<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ESSENCE | Iniciar Sesion</title>
    <link rel="stylesheet" href="css/login.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">
</head>
<body>
    <nav class="login-nav">
        <a href="index.jsp" class="logo">
            <img src="assets/logo.png" alt="Logo ESSENCE">
            <span>ESSENCE</span>
        </a>

        <div class="nav-links">
            <a href="index.jsp">Inicio</a>
            <a href="productos.jsp">Colección</a>
            <a href="registro.html">Registrar</a>
        </div>
        <div class="top-icons">
            <a href="https://www.google.com">
                <img src="assets/lupa.png" alt="Buscar" class="search-icon">
            </a>
            <a href="https://www.instagram.com">IG</a>
            <a href="https://www.facebook.com">F</a>
            <a href="https://www.x.com">X</a>
        </div>
    </nav>
    <%
        String email = request.getParameter("login-email");
        String password = request.getParameter("login-password");

        String mensaje = "";
        boolean exito = false;

        Connection con = null;
        CallableStatement call = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "essence", "1234");

            call = con.prepareCall("{ call validar_login(?, ?, ?, ?, ?) }");
            call.setString(1, email);
            call.setString(2, password);
            call.registerOutParameter(3, Types.NUMERIC);
            call.registerOutParameter(4, Types.NUMERIC);
            call.registerOutParameter(5, Types.VARCHAR);
            call.execute();

            int resultado = call.getInt(3);

            if (resultado == 1) {
                session.setAttribute("clienteId", call.getInt(4));
                session.setAttribute("clienteNombre", call.getString(5));
                exito = true;
                mensaje = "Bienvenido, " + call.getString(5) + ".";
            } else {
                mensaje = "Correo o contraseña incorrectos.";
            }
        } catch (Exception e) {
            mensaje = "Error: " + e.getMessage();
        } finally {
            try {
                if (call != null) call.close();
                if (con  != null) con.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    %>
    <main class="main-container">
        <article class="form-card" style="justify-content: center; text-align: center;">
            <p><%= mensaje %></p>
            <% if (exito) { %>
                <p class="form-link"><a href="index.jsp">Ir al inicio</a></p>
            <% } else { %>
                <p class="form-link"><a href="login.html">Volver a intentar</a></p>
            <% } %>
        </article>
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
