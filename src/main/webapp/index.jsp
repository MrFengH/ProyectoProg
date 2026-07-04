<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Oracle JSP</title>
</head>
<body>

<h1>Conexión Oracle</h1>

<%
    String url = "jdbc:oracle:thin:@localhost:1521/XEPDB1";
    String usuario = "system";
    String password = "1234";

    try {
        Class.forName("oracle.jdbc.OracleDriver");

        Connection con = DriverManager.getConnection(url, usuario, password);

        out.println("<p>Conexión exitosa a Oracle.</p>");

        con.close();

    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>