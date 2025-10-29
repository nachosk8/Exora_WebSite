<%@ Language="VBScript" %>
<%
NombreApellido = Session("nombre")
Admin = Session("admin")
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
        <div class="usuario">
             <%=NombreApellido%>
        </div>
        <div class="espacio"></div>
        <div class="deslogin"><a class="link-deslog" href="http://localhost/Exora_WebSite/ASP/form.asp">Salir</a></div>
    </header>

    <div class="pantalla">
        <!-- Menú lateral -->
        <aside class="menu-lateral">
            <img src="../imagenes/logo.png" class="img-logo"/>
            <nav>
                <ul>          
                    <li><a href="http://localhost/Exora_WebSite/ASP/principal.asp">⬅ MENU PRINCIPAL</a></li><br>
                    <li><a href="http://localhost/Exora_WebSite/ASP/verDocumentos.asp">📄 DOCUMENTOS</a></li><br>
                </ul>
            </nav>
        </aside>

        <!-- FORMULARIO LICENCIAS -->
        <section style="margin-left:260px; padding:25px; width:100%;">
            <h2>Solicitud de Licencia</h2>

            <form method="post" id="formLicencia" class="form-licencia">
                <label>Tipo de licencia:</label>
                <select name="tipoLicencia" id="tipoLicencia" onchange="mostrarCalendarios()">
                    <option value="">Seleccionar...</option>
                    <option value="01">Enfermedad</option>
                    <option value="02">Días de estudio</option>
                    <option value="03">Vacaciones</option>
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

    </div> <!-- cierre correcto de pantalla -->

    <script>
    function mostrarCalendarios() {
        const tipo = document.getElementById("tipoLicencia").value;
        const seccion = document.getElementById("seccionFechas");

        if (tipo !== "") {
            seccion.style.display = "block";
        } else {
            seccion.style.display = "none";
        }
    }
    </script>

</body>
</html>
