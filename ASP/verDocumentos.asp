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
    <link rel="stylesheet" href="../css/estilo_verDocs.css">
</head>
<body>
    <header class="barra-superior">
        <div class="usuario">
             JUAN IGNACIO SKREKA IVANESEVIC

        </div><img src= "../imagenes/ndea.png" class="foto-de-perfil"/>
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
                    <% IF CEO <> "si" then%>
                    <li><a href="http://localhost/Exora_WebSite/ASP">📅 CALENDARIO</a></li><br>
                    <li><a href="#">🏖️ VACACIONES</a></li><br>
                    <% end if %>
                </ul>
            </nav>
        </aside>

        <main class="contenido-principal">
               

        </main>
    
 </div>
    </div>
</body>..
</html>
