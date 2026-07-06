<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.CallableStatement" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resultado de Registro</title>
    <link rel="stylesheet" href="css/login.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <!-- Banner superior: logo, menu de navegacion completo e iconos de busqueda/redes -->
    <header>
        <nav class="login-nav">
            <a href="index.jsp" class="logo">
                <img src="assets/logo.png" alt="Logo ESSENCE">
                <span>ESSENCE</span>
            </a>

            <div class="nav-links">
                <a href="index.jsp">Inicio</a>
                <a href="productos.jsp">Colección</a>
                <a href="contacto.html">Sobre Nosotros</a>
                <a href="carrito.jsp">Carrito</a>
                <a href="admin.jsp">Admin</a>
                <a href="login.html">Iniciar Sesión</a>
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
    </header>
    <%--
        Registra un cliente nuevo (nombre, email, password) llamando al
        procedure registrar_usuario. No valida si el email ya existe:
        eso lo controla la restriccion UNIQUE de la tabla Cliente.
    --%>
    <%
        request.setCharacterEncoding("UTF-8");

        String nombre = request.getParameter("register-name");
        String email = request.getParameter("register-email");
        String password = request.getParameter("register-password");

        String mensaje = "";
        Connection con = null;
        CallableStatement call = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "essence", "1234");

            call = con.prepareCall("{ call registrar_usuario(?, ?, ?) }");
            call.setString(1, nombre);
            call.setString(2, email);
            call.setString(3, password);
            call.execute();

            mensaje = "Registro Exitoso";
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
    <!-- Contenido principal: resultado del intento de registro -->
    <main class="main-container">
        <section class="form-card" style="justify-content: center; text-align: center;">
            <p><%= mensaje %></p>
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
