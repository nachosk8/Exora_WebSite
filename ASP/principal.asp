
<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<!--#include file="debug.asp" -->
<%
Const tipoVarChar = 200
Const parametroEntrada = 1
Const tipoProcedimientoAlmacenado = 4

Dim usuarioPrincipal, comandoSQL, datosUsuario, nombreYApellido, esAdmin
usuarioPrincipal = Session("usuario")

Set comandoSQL = Server.CreateObject("ADODB.Command")
Set comandoSQL.ActiveConnection = conn
comandoSQL.CommandText = "DatosDelUsuario"
comandoSQL.CommandType = tipoProcedimientoAlmacenado

comandoSQL.Parameters.Append comandoSQL.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)

Set datosUsuario = comandoSQL.Execute()
nombreYApellido = datosUsuario("NombreApellido")
esAdmin = datosUsuario("directivo")
empresa = datosUsuario("empresa")
datosUsuario.Close
Set datosUsuario = Nothing
Set comandoSQL = Nothing

Set comandoSQL = Server.CreateObject("ADODB.Command")
Set comandoSQL.ActiveConnection = conn
comandoSQL.CommandText = "VerPublicaciones"
comandoSQL.CommandType = tipoProcedimientoAlmacenado

comandoSQL.Parameters.Append comandoSQL.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)

Set publicacionesRS = comandoSQL.Execute()

If Not publicacionesRS.EOF Then
    If publicacionesRS("Error") = 0 Then
        ' Avanzar al siguiente recordset → las publicaciones
      

        ' Mostrar publicaciones
        Response.Write "<h3>Publicaciones</h3>"
        Response.Write "<table border=1 cellpadding=4>"
        Do While Not publicacionesRS.EOF
            Response.Write "<tr>"
            Response.Write "<td>" & publicacionesRS("Titulo") & "</td>"
            Response.Write "<td>" & publicacionesRS("Contenido") & "</td>"
            Response.Write "<td>" & publicacionesRS("Fecha") & "</td>"
            Response.Write "</tr>"
            publicacionesRS.MoveNext
        Loop
        Response.Write "</table>"

    Else
        Response.Write "<p>No hay publicaciones para este usuario.</p>"
    End If
End If

Set comandoSQL = Nothing


conn.Close
Set conn = Nothing







' --- valores dinámicos de ejemplo ---
docsPorFirmar = 2
faltasPorAprobar = 0
diasDeVacaciones = 14
diasAlFeriado = 30
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Inicio</title>
    <link rel="stylesheet" href="../css/estilo_principal.css">
</head>
<body>
    <header class="barra-superior">
        <div class="usuario">
             <%= nombreYApellido %>
        </div>
        <div class="espacio"></div>
        <div class="deslogin"><a class="link-deslog" href="http://localhost/Exora_WebSite/ASP/login.asp">Salir</a></div>
    </header>

    <div class="pantalla">
        <!-- Menú lateral -->
        <aside class="menu-lateral">
            <img src="../imagenes/logo.png" class="img-logo"/>
            <nav>
                <ul>
                    <br><li><a href="http://localhost/Exora_WebSite/ASP/verDocumentos.asp">📄 DOCUMENTOS</a></li><br>
                    <li><a href="http://localhost/Exora_WebSite/ASP/calendario.asp">📅 LICENCIAS</a></li><br>
                    <% IF esAdmin = "S" then %>
                    <div class="agregar-anuncio">
                        <button id="btnAgregar">PUBLICAR</button>
                    </div>
                    <% end if %>
                </ul>
            </nav>
        </aside>

        <!-- Contenido principal -->
        <main class="contenido-principal">
            <!-- Cuadros de estadísticas -->
            <div class="cuadros-estadisticas">
                <a class="acceso-a-otra-pag" href="http://localhost/Exora_WebSite/ASP/verDocumentos.asp">
                    <div class="tarjeta" id="ver_documentos">
                        <div class="lado-izquierdo">
                            <div class="icono-tarjeta">📄</div>
                            <div class="contenido-tarjeta">
                                <div class="titulo-tarjeta">Documentos</div>
                                <div class="subtitulo-tarjeta">Por firmar</div>
                            </div>
                        </div>
                        <div class="numero-tarjeta"><%= docsPorFirmar %></div>
                    </div>
                </a>

                <% IF esAdmin <> "S" THEN %>
                <a class="acceso-a-otra-pag" href="http://localhost/Exora_WebSite/ASP/calendario.asp">
                    <div class="tarjeta">
                        <div class="lado-izquierdo">
                            <div class="icono-tarjeta">📥</div>
                            <div class="contenido-tarjeta">
                                <div class="titulo-tarjeta">Faltas</div>
                                <div class="subtitulo-tarjeta">Por aprobar</div>
                            </div>
                        </div>
                        <div class="numero-tarjeta"><%= faltasPorAprobar %></div>
                    </div>
                </a>

                <div class="tarjeta">
                    <div class="lado-izquierdo">
                        <div class="icono-tarjeta">🏖️</div>
                        <div class="contenido-tarjeta">
                            <div class="titulo-tarjeta">Vacaciones</div>
                            <div class="subtitulo-tarjeta">Días disponibles</div>
                        </div>
                    </div>
                    <div class="numero-tarjeta"><%= diasDeVacaciones %></div>
                </div>
                <% END IF %>
            </div>
        </main>

        <!-- Formulario oculto para anuncios -->
        <div class="form-anuncio" id="formAnuncio" style="display:none; margin-top:10px;">
            <input type="text" id="tituloAnuncio" placeholder="Título del anuncio" style="width:100%; margin-bottom:6px; padding:6px;">
            <textarea id="parrafoAnuncio" placeholder="Contenido del anuncio" style="width:100%; padding:6px;"></textarea>
            <button id="btnCrearAnuncio" style="margin-top:6px;">Crear anuncio</button>
        </div>
    </div>
</body>
</html>

<script>
document.getElementById("btnAgregar").addEventListener("click", function() {
    let form = document.getElementById("formAnuncio");
    form.style.display = form.style.display === "none" ? "block" : "none";
});

document.getElementById("btnCrearAnuncio").addEventListener("click", function() {
    let titulo = document.getElementById("tituloAnuncio").value.trim();
    let parrafo = document.getElementById("parrafoAnuncio").value.trim();
    if(titulo === "" || parrafo === "") {
        alert("Completa ambos campos antes de agregar el anuncio.");
        return;
    }

    // Crear contenedor de noticia
    let noticia = document.createElement("div");
    noticia.className = "noticia";
    noticia.innerHTML = `
        <div class="cabecera-noticia">
            <div class="autor"><%=nombreYApellido + " - " + empresa%> </div>
        </div>
        <div class="cuerpo-noticia">
            <h3>${titulo}</h3>
            <p>${parrafo}</p>
        </div>
    `;

    // Insertar antes del formulario
    let contenedor = document.querySelector(".cuadros-estadisticas").parentNode;
    contenedor.appendChild(noticia);

    // Limpiar formulario
    document.getElementById("tituloAnuncio").value = "";
    document.getElementById("parrafoAnuncio").value = "";
});
</script>
