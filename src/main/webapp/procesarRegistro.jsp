<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ESSENCE | Registrar</title>
    <link rel="stylesheet" href="css/login.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Lora:ital,wght@0,400..700;1,400..700&display=swap" rel="stylesheet">
</head>
<body>
    <nav class="login-nav">
        <a href="index.html" class="logo">
            <img src="assets/logo.png" alt="Logo ESSENCE">
            <span>ESSENCE</span>
        </a>

        <div class="nav-links">
            <a href="index.html">Inicio</a>
            <a href="index.html#coleccion">Colección</a>
            <a href="registro.html">Registrar</a>
        </div>
        <div class="top-icons">
            <a href="https://www.google.com" aria-label="Buscar en Google">
                <img src="assets/lupa.png" alt="Buscar" class="search-icon">
            </a>
            <a href="https://www.instagram.com" aria-label="Instagram">IG</a>
            <a href="https://www.facebook.com" aria-label="Facebook">F</a>
            <a href="https://www.x.com" aria-label="X">X</a>
        </div>
    </nav>
    <%
        String nombre = request.getParameter("register-name");
        String email = request.getParameter("register-email");
        String password = request.getParameter("register-password");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");

            String url = "jdbc:oracle:thin:@localhost:1521:xe";
            String user = "essence";
            String pass = "1234";

            con = DriverManager.getConnection(url, user, pass);

            String sql = "INSERT INTO cliente (cliente_id, nombre, email, password) VALUES (seq_cliente.NEXTVAL, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setString(1, nombre);
            ps.setString(2, email);
            ps.setString(3, password);

            ps.executeUpdate();

            out.println("Cliente registrado correctamente");

        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    %>
    <main class="main-container">
        <article class="form-card">
            <p>Registro Exitoso</p>
        </article>
    </main>

    <footer class="footer">
        <div class="footer-menu">
            <a href="index.html">Inicio</a>
            <a href="index.html#coleccion">Colección</a>
            <a href="contacto.html">Sobre Nosotros</a>
            <a href="login.html">Logout</a>
        </div>
        <p>&copy; 2026 ESSENCE. Todos los derechos reservados.</p>
    </footer>
</body>
</html>
