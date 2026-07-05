<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Cierra la sesion del cliente y lo regresa a la pagina de login --%>
<%
    session.invalidate();
    response.sendRedirect("login.html");
%>
