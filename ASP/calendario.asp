<%@ Language="VBScript" %>
<%
' --- valores dinámicos de ejemplo ---
docsPorFirmar =2
faltasPorAprobar = 0
diasDeVacaciones = 14
diasAlFeriado = 30
CEO = "no"  'simulo ser empleado
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Inicio</title>
    <link rel="stylesheet" href="../css/estilo_calendario.css">
</head>
<body>
    <header class="barra-superior">
        <div class="usuario">
             JUAN IGNACIO SKREKA IVANESEVIC

        </div>
        <div class="espacio"></div>
        <div class="deslogin"><a class="link-deslog" href="http://localhost/Exora_WebSite/ASP/form.asp">Salir</a></div>

    </header>


    <div class="pantalla">
        <!-- Menú lateral -->
        <aside class="menu-lateral">
            <img src= "../imagenes/logo.png" class="img-logo"/>
            <nav>
                <ul>          
                    <li><a href="http://localhost/Exora_WebSite/ASP/principal.asp">⬅ MENU PRINCIPAL</a></li><br>
                    <li><a href="http://localhost/Exora_WebSite/ASP/verDocumentos.asp">📄 DOCUMENTOS</a></li><br>

                </ul>
            </nav>
        </aside>


    

    </div>
</body>..
</html>
