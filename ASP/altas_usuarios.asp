<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<!--#include file="debug.asp" -->
<%
NombreApellido = Session("nombre")
Admin = Session("admin")
usuarioPrincipal = Session("usuario")

Dim documento, nombreCompleto, esAdminCheck, esDirectivo, mensaje, colorMensaje

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    documento = Trim(Request.Form("documento"))
    nombreCompleto = Trim(Request.Form("nombreCompleto"))
    esAdminCheck = Request.Form("esAdmin")

    If esAdminCheck = "on" Then
        esDirectivo = "S"
    Else
        esDirectivo = "N"
    End If

    ' Ejecutar Store
    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    With cmd
        .ActiveConnection = conn
        .CommandText = "Crear_Usuarios"
        .CommandType = 4 ' Stored Procedure

        .Parameters.Append .CreateParameter("@Documento", 200, 1, 20, documento)
        .Parameters.Append .CreateParameter("@Nombre_Apellido", 200, 1, 20, nombreCompleto)
        .Parameters.Append .CreateParameter("@Directivo", 200, 1, 1, esDirectivo)
        .Parameters.Append .CreateParameter("@Creador_del_usuario", 200, 1, 20, usuarioPrincipal)

        Set rs = .Execute()
    End With
    If Not rs.EOF Then
        If rs("ERROR") = "0" Then
            mensaje = "Usuario creado exitosamente."
            colorMensaje = "green"
        Else
            mensaje = rs("ERROR")
            colorMensaje = "red"
        End If
    End If

    rs.Close
    Set rs = Nothing
    Set cmd = Nothing
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Inicio</title>
    <link rel="stylesheet" href="../css/estilo_alta_usuario.css">
</head>
<body>
    <header class="barra-superior">
        <div class="usuario">
             <%=NombreApellido%>
        </div>

        <div class="espacio"></div>

        <div class="deslogin">
            <a class="link-deslog" href="http://localhost/Exora_WebSite/ASP/form.asp">Salir</a>
        </div>
    </header>

    <div class="pantalla">
        <!-- Menú lateral -->
        <aside class="menu-lateral">
            <img src="../imagenes/logo.png" class="img-logo"/>
            <nav>
                <ul>          
                    <li><a href="http://localhost/Exora_WebSite/ASP/principal.asp">⬅ MENU PRINCIPAL</a></li><br>
                </ul>
            </nav>
        </aside>


        <!-- FORMULARIO CREAR USUARIO -->
        <section style="margin-left:260px; padding:20px;">
            <form method="post" class="form-crear-usuario" onsubmit="return validarFormulario()">
                <h2>Crear nuevo usuario</h2>

                <label>Documento:</label>
                <input type="text" name="documento" id="documento"
                       maxlength="20" required
                       onkeypress="return event.charCode >= 48 && event.charCode <= 57">

                <br><br>

                <label>Nombre y Apellido:</label>
                <input type="text" name="nombreCompleto" id="nombreCompleto"
                       maxlength="20" required
                       onkeypress="return soloLetras(event)">

                <br><br>

                <label style="display:flex; align-items:center; gap:8px;">
                    <input type="checkbox" name="esAdmin">
                    Es administrador
                </label>

                <button type="submit">Crear usuario</button>

                <% If mensaje <> "" Then %>
                    <p style="margin-top:15px; font-weight:bold; color:<%=colorMensaje%>;">
                        <%= mensaje %>
                    </p>
                <% End If %>
            </form>
        </section>


    </div>

<script>
function validarFormulario() {
    const doc = document.getElementById("documento").value.trim();
    const nombre = document.getElementById("nombreCompleto").value.trim();
    const regexLetras = /^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$/;

    if (isNaN(doc)) {
        alert("El documento debe contener solo números.");
        return false;
    }

    if (!regexLetras.test(nombre)) {
        alert("El nombre y apellido solo pueden contener letras y espacios.");
        return false;
    }

    return true;
}

// Bloquea teclas que no sean letras ni espacio
function soloLetras(e) {
    const char = String.fromCharCode(e.keyCode);
    const regex = /^[A-Za-zÁÉÍÓÚáéíóúÑñ ]$/;
    return regex.test(char);
}
</script>

</body>
</html>
