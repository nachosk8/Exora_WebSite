<%@ Language=VBScript %>
<%
' --- Variables ---
Dim accion, usuario, contrasena, mensaje
accion = Request("accion")
usuario = Trim(Request.Form("usuario"))
contrasena = Trim(Request.Form("contrasena"))
mensaje = ""

' --- Lógica para login ---
If accion = "login" Then
    If usuario = "admin" And contrasena = "1234" Then
        mensaje = "<div class='msg success'>Bienvenido, " & usuario & "!</div>"
    Else
        mensaje = "<div class='msg error'>Usuario o contraseña incorrectos.</div>"
    End If

' --- Lógica para registro (simulada) ---
ElseIf accion = "registro" Then
    If usuario <> "" And contrasena <> "" Then
        mensaje = "<div class='msg success'>Usuario registrado con éxito (ficticio).</div>"
    Else
        mensaje = "<div class='msg error'>Completa todos los campos para registrarte.</div>"
    End If
End If
%>

<!DOCTYPE html>
<html>
<head>
    <title>Login ASP Classic</title>
    <link rel="stylesheet" type="text/css" href="estilos.css" />
</head>
<body>
    <div class="login-box">
        <h2><% If accion = "registro" Then Response.Write "Registrarse" Else Response.Write "Iniciar Sesión" End If %></h2>

        <%= mensaje %>

        <!-- Formulario de Login -->
        <form id="login-form" method="post" style="<% If accion = "registro" Then Response.Write "display:none;" End If %>">
            <input type="hidden" name="accion" value="login" />

            <input type="text" name="usuario" placeholder="Usuario" required onblur="validaCampos(this)" />
            <div class="error-msg" id="error-usuario"></div>

            <input id="passone" type="password" name="contrasena" placeholder="Contraseña" required onblur="validaCampos(this)" />
            <div class="error-msg" id="error-contrasena"></div>

            <input type="checkbox" id="ocultarPassword" onclick="Mostrar_Contra(this)" />
            <label for="ocultarPassword" id="txtcheck">Ocultar Contraseña</label>

            <input id="submit" type="submit" value="Ingresar" disabled />
        </form>

        <!-- Formulario de Registro -->
        <form id="register-form" method="post" style="<% If accion <> "registro" Then Response.Write "display:none;" End If %>">
            <input type="hidden" name="accion" value="registro" />
            <input type="text" name="usuario" placeholder="Nuevo usuario" required />
            <input type="password" name="contrasena" placeholder="Nueva contraseña" required />
            <input type="submit" value="Registrarme" />
        </form>

        <!-- Botón para cambiar de formulario -->
        <div class="toggle-form">
            <% If accion = "registro" Then %>
                ¿Ya tenés cuenta? <a onclick="toggleForm('login')">Iniciar sesión</a>
            <% Else %>
                ¿No tenés cuenta? <a onclick="toggleForm('registro')">Registrate</a>
            <% End If %>
        </div>
    </div>
</body>

<script>
function toggleForm(idToShow) {
    document.getElementById("login-form").style.display = (idToShow === "login") ? "block" : "none";
    document.getElementById("register-form").style.display = (idToShow === "registro") ? "block" : "none";
}

function validaCampos(obj) {
    const nombreCampo = obj.name;
    const divError = document.getElementById("error-" + nombreCampo);
    const valor = obj.value.trim();

    if (valor === "") {
        obj.style.borderColor = "red";
        divError.innerText = nombreCampo === "usuario" ? "El usuario no puede estar vacío." : "La contraseña es obligatoria.";
    } else {
        obj.style.borderColor = "";
        divError.innerText = "";
    }

    validarFormularioCompleto(); // Verifica si ambos campos están llenos
}

function validarFormularioCompleto() {
    const usuario = document.querySelector('#login-form [name="usuario"]');
    const contrasena = document.querySelector('#login-form [name="contrasena"]');
    const aceptar = document.getElementById("submit");

    if (usuario.value.trim() !== "" && contrasena.value.trim() !== "") {
        aceptar.disabled = false;
    } else {
        aceptar.disabled = true;
    }
}

function Mostrar_Contra(checkbox) {
    const passInput = document.getElementById("passone");
    const label = document.getElementById("txtcheck");

    if (checkbox.checked) {
        passInput.type = "text";
        label.innerText = "Mostrar Contraseña";
    } else {
        passInput.type = "password";
        label.innerText = "Ocultar Contraseña";
    }
}
</script>
</html>
