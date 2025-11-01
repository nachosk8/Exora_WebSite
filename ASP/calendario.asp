<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<!--#include file="debug.asp"-->
<%
' -------------------------------
' BLOQUE DE LÓGICA ASP
' -------------------------------

Dim NombreApellido, Admin, usuarioPrincipal
NombreApellido = Session("nombre")
Admin = Session("admin")
usuarioPrincipal = Session("usuario")

' --- Variables para mensajes ---
Dim mensaje, colorMensaje
mensaje = ""
colorMensaje = "black"

' --- Ejecutar inserción si se presionó Aceptar ---
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim licenciaSel, fechaDesde, fechaHasta, cmdInsert
    licenciaSel = Trim(Request.Form("tipoLicencia"))
    fechaDesde = Trim(Request.Form("fechaDesde"))
    fechaHasta = Trim(Request.Form("fechaHasta"))

    If licenciaSel <> "" And fechaDesde <> "" And fechaHasta <> "" Then
        Set cmdInsert = Server.CreateObject("ADODB.Command")
        With cmdInsert
            .ActiveConnection = conn
            .CommandText = "Solicitar_Licencia"
            .CommandType = 4 ' Stored Procedure
            .Parameters.Append .CreateParameter("@usuario", 200, 1, 20, usuarioPrincipal)
            .Parameters.Append .CreateParameter("@licencia", 200, 1, 50, licenciaSel)
            .Parameters.Append .CreateParameter("@desde", 7, 1, , fechaDesde)
            .Parameters.Append .CreateParameter("@hasta", 7, 1, , fechaHasta)
            .Execute
        End With
        Set cmdInsert = Nothing
        mensaje = "✅ Licencia registrada correctamente."
        colorMensaje = "green"
    Else
        mensaje = "⚠️ Debes completar todos los campos antes de enviar."
        colorMensaje = "red"
    End If
End If

' --- Cargar licencias disponibles ---
Dim cmd, rsLicencias
Set cmd = Server.CreateObject("ADODB.Command")
With cmd
    .ActiveConnection = conn
    .CommandText = "Traer_Licencias_Disponibles"
    .CommandType = 4 ' Stored Procedure
    .Parameters.Append .CreateParameter("@usuario", 200, 1, 20, usuarioPrincipal)
    Set rsLicencias = .Execute()
End With
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Licencias</title>
    <link rel="stylesheet" href="../css/estilo_calendario.css">
</head>
<body>
<header class="barra-superior">
    <div class="usuario"><%=NombreApellido%></div>
    <div class="espacio"></div>
    <div class="deslogin">
        <a class="link-deslog" href="http://localhost/Exora_WebSite/ASP/form.asp">Salir</a>
    </div>
</header>

<div class="pantalla">
    <aside class="menu-lateral">
        <img src="../imagenes/logo.png" class="img-logo"/>
        <nav>
            <ul>          
                <li><a href="http://localhost/Exora_WebSite/ASP/principal.asp">⬅ MENU PRINCIPAL</a></li><br>
                <li><a href="http://localhost/Exora_WebSite/ASP/verDocumentos.asp">📄 DOCUMENTOS</a></li><br>
            </ul>
        </nav>
    </aside>

    <section style="margin-left:260px; padding:25px; width:100%;">
        <h2>Solicitud de Licencia</h2>

        <% If mensaje <> "" Then %>
            <p style="color:<%=colorMensaje%>; font-weight:bold;"><%=mensaje%></p>
        <% End If %>

        <form method="post" id="formLicencia" class="form-licencia">
            <label>Tipo de licencia:</label>
            <select name="tipoLicencia" id="tipoLicencia" onchange="mostrarCalendarios()">
                <option value="">Seleccionar...</option>
                <%
                If Not rsLicencias.EOF Then
                    Do Until rsLicencias.EOF
                %>
                        <option value="<%=rsLicencias("Licencia")%>">
                            <%=rsLicencias("Licencia")%>
                        </option>
                <%
                        rsLicencias.MoveNext
                    Loop
                Else
                %>
                        <option value="">(Sin licencias disponibles)</option>
                <%
                End If
                %>
            </select>

            <div id="seccionFechas" style="display:none; margin-top:20px;">
                <label>Desde:</label>
                <input type="date" name="fechaDesde" id="fechaDesde" required>
                <br><br>
                <label>Hasta:</label>
                <input type="date" name="fechaHasta" id="fechaHasta" required>
                <br><br>
                <button type="submit">Aceptar</button>
            </div>
        </form>
    </section>
</div>

<script>
function mostrarCalendarios() {
    const tipo = document.getElementById("tipoLicencia").value;
    const seccion = document.getElementById("seccionFechas");
    seccion.style.display = (tipo !== "") ? "block" : "none";
}
</script>

</body>
</html>

<%
' -------------------------------
' LIMPIEZA FINAL
' -------------------------------
If Not rsLicencias Is Nothing Then 
    If rsLicencias.State = 1 Then rsLicencias.Close
End If
Set rsLicencias = Nothing
Set cmd = Nothing
%>
