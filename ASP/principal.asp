<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<!--#include file="debug.asp" -->
<%
Const tipoVarChar = 200
Const parametroEntrada = 1
Const tipoProcedimientoAlmacenado = 4

Dim usuarioPrincipal, comandoSQL, datosUsuario, nombreYApellido, esAdmin, empresa
usuarioPrincipal = Session("usuario")

' === Si se envió el formulario ===
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    Dim titulo, contenido, destinatario, cmd
    titulo = Trim(Request.Form("titulo"))
    contenido = Trim(Request.Form("contenido"))
    destinatario = Trim(Request.Form("destinatario"))

    If titulo <> "" And contenido <> "" And destinatario <> "" Then
        Set cmd = Server.CreateObject("ADODB.Command")
        Set cmd.ActiveConnection = conn
        cmd.CommandText = "CrearPublicacion"
        cmd.CommandType = tipoProcedimientoAlmacenado

        ' ⚠️ Orden correcto de parámetros según tu SP:
        cmd.Parameters.Append cmd.CreateParameter("@remitente", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
        cmd.Parameters.Append cmd.CreateParameter("@destinatario", tipoVarChar, parametroEntrada, 500, destinatario)
        cmd.Parameters.Append cmd.CreateParameter("@titulo", tipoVarChar, parametroEntrada, 50, titulo)
        cmd.Parameters.Append cmd.CreateParameter("@contenido", tipoVarChar, parametroEntrada, 1000, contenido)

        cmd.Execute
        Set cmd = Nothing

        ' Redirigir para recargar la página y mostrar la nueva publicación
        Response.Redirect "principal.asp?ok=1"
    Else
        Response.Write "<script>alert('Faltan datos en el formulario');</script>"
    End If
End If

' === Obtener datos del usuario ===
Set comandoSQL = Server.CreateObject("ADODB.Command")
Set comandoSQL.ActiveConnection = conn
comandoSQL.CommandText = "DatosDelUsuario"
comandoSQL.CommandType = tipoProcedimientoAlmacenado
comandoSQL.Parameters.Append comandoSQL.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
Set datosUsuario = comandoSQL.Execute()

nombreYApellido = datosUsuario("NombreApellido")
Session("nombre") = nombreYApellido
esAdmin = datosUsuario("directivo")
Session("admin") = esAdmin
empresa = datosUsuario("empresa")

datosUsuario.Close
Set datosUsuario = Nothing
Set comandoSQL = Nothing

' === Obtener publicaciones ===
Set comandoSQL = Server.CreateObject("ADODB.Command")
Set comandoSQL.ActiveConnection = conn
comandoSQL.CommandText = "VerPublicaciones"
comandoSQL.CommandType = tipoProcedimientoAlmacenado
comandoSQL.CursorType = 1
comandoSQL.Parameters.Append comandoSQL.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
Set publicacionesRS = comandoSQL.Execute()

' === Obtener usuarios de la empresa ===
Set comandoSQL = Server.CreateObject("ADODB.Command")
Set comandoSQL.ActiveConnection = conn
comandoSQL.CommandText = "UsuariosDeLaEmpresa"
comandoSQL.CommandType = tipoProcedimientoAlmacenado
comandoSQL.Parameters.Append comandoSQL.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
Set usuariosEmpresaRS = comandoSQL.Execute()

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
        <div class="usuario"><%= nombreYApellido %></div>
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
                        <button type="button" id="btnAgregar">PUBLICAR</button>
                    </div>
                    <% end if %>
                </ul>
            </nav>
        </aside>

        <!-- Contenido principal -->
        <main class="contenido-principal">
            <div class="cuadros-estadisticas">
                <a href="verDocumentos.asp" class="acceso-a-otra-pag">
                    <div class="tarjeta">
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
                <a href="calendario.asp" class="acceso-a-otra-pag">
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

            <!-- Formulario de anuncio -->
            <div class="form-anuncio" id="formAnuncio" style="display:none; margin-top:10px;">
                <form method="POST" action="principal.asp">
                    <input type="text" name="titulo" placeholder="Título del anuncio" style="width:100%; margin-bottom:6px; padding:6px;">
                    <textarea name="contenido" placeholder="Contenido del anuncio" style="width:100%; padding:6px;"></textarea>

                    <label style="display:block; margin-top:6px;">Enviar a:</label>
                    <div style="border:1px solid #ccc; padding:6px; max-height:150px; overflow-y:auto;">
                        <label><input type="checkbox" id="chkTodos"> <strong>-- TODOS --</strong></label><br>
                        <% 
                        If Not usuariosEmpresaRS.EOF Then
                            Do While Not usuariosEmpresaRS.EOF
                                Response.Write "<label><input type='checkbox' name='destinatario' value='" & usuariosEmpresaRS("usuario") & "'> " & usuariosEmpresaRS("NombreApellido") & "</label><br>"
                                usuariosEmpresaRS.MoveNext
                            Loop
                        Else
                            Response.Write "<p>No hay usuarios disponibles</p>"
                        End If
                        %>
                    </div>

                    <button type="submit" style="margin-top:6px;">Crear anuncio</button>
                </form>
            </div>

            <!-- Publicaciones -->
            <div id="contenedorPublicaciones">
                <%
                If Not publicacionesRS.EOF Then
                    Do While Not publicacionesRS.EOF
                        Response.Write "<div class='noticia'>"
                        Response.Write "<div class='cabecera-noticia'>"
                        Response.Write "<div class='autor'>" & publicacionesRS("NombreRemitente") & " - " & empresa & "</div>"
                        Response.Write "</div>"
                        Response.Write "<div class='cuerpo-noticia'>"
                        Response.Write "<h3>" & Server.HTMLEncode(publicacionesRS("Titulo")) & "</h3>"
                        Response.Write "<p>" & Server.HTMLEncode(publicacionesRS("Contenido")) & "</p>"
                        Response.Write "<small style='color:gray; font-size:12px;'>Publicado el " & publicacionesRS("Fecha") & "</small>"
                        Response.Write "</div>"
                        Response.Write "</div>"
                        publicacionesRS.MoveNext
                    Loop
                Else
                    Response.Write "<p>No hay publicaciones disponibles.</p>"
                End If

                publicacionesRS.Close
                Set publicacionesRS = Nothing
                conn.Close
                Set conn = Nothing
                %>
            </div>
        </main>
    </div>

<script>
// Mostrar/ocultar formulario
document.getElementById("btnAgregar").addEventListener("click", function() {
    let form = document.getElementById("formAnuncio");
    form.style.display = (form.style.display === "none") ? "block" : "none";
});

// Checkbox TODOS
const chkTodos = document.getElementById("chkTodos");
chkTodos.addEventListener("change", function() {
    const checkboxes = document.querySelectorAll("input[name='destinatario']");
    checkboxes.forEach(cb => cb.checked = chkTodos.checked);
});
</script>

</body>
</html>
