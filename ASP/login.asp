<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<%
Const tipoVarChar = 200
Const parametroEntrada = 1
Const tipoProcedimientoAlmacenado = 4

Dim nombreUsuario, contra, esPrimeraVez, comandoSQL, conjuntoResultados, resultadoValidacion, accionRecibida
resultadoValidacion = ""
nombreUsuario = ""
contra = ""
esPrimeraVez = ""
accionRecibida = Request.Form("accion")

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then

    If LCase(accionRecibida) = "change" Then
        ' Cambio de contra
        nombreUsuario = Request.Form("username")
        contra        = Request.Form("newContra")
        esPrimeraVez  = "S"

    Else
        ' Login normal
        nombreUsuario = Request.Form("username")
        contra        = Request.Form("contra")
        esPrimeraVez  = Request.Form("primeraVez")
    End If

    If Trim(nombreUsuario) <> "" And Trim(contra) <> "" Then
        Set comandoSQL = Server.CreateObject("ADODB.Command")
        Set comandoSQL.ActiveConnection = conn
        comandoSQL.CommandText = "validarUsuarios"
        comandoSQL.CommandType = tipoProcedimientoAlmacenado

        comandoSQL.Parameters.Append comandoSQL.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, nombreUsuario)
        comandoSQL.Parameters.Append comandoSQL.CreateParameter("@contra", tipoVarChar, parametroEntrada, 20, contra)
        comandoSQL.Parameters.Append comandoSQL.CreateParameter("@primeraVez", tipoVarChar, parametroEntrada, 1, esPrimeraVez)

        Set conjuntoResultados = comandoSQL.Execute()
        If Not conjuntoResultados.EOF Then
            resultadoValidacion = conjuntoResultados("validacion")
        Else
            resultadoValidacion = ""
        End If

        conjuntoResultados.Close
        Set conjuntoResultados = Nothing
        Set comandoSQL = Nothing
        conn.Close
        Set conn = Nothing
    End If
End If
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Login</title>
  <link rel="stylesheet" href="../css/estilo_login.css">
</head>
<body>
  <div class="container">
    <!-- Logo -->
    <div class="logo">
      <img src="../imagenes/logo.png" class="img-logo"/>
    </div>

    <!-- Formulario login y cambio de contra -->
    <div class="login-container">
      <h2>EXORA | Empresas</h2>

      <!-- Formulario login -->
      <form method="POST" id="formularioLogin">
        <input type="hidden" name="primeraVez" id="primeraVez" value="">
        <input type="hidden" name="accion" value="login">

        <div class="input-group">
          <input type="text" name="username" required>
          <label for="username">Usuario</label>
        </div>

        <div class="input-group">
          <input type="password" name="contra" id="contra" required>
          <label for="contra">Contra</label>
          <span class="toggle-password" onclick="mostrarContra()">ocultar/mostrar</span>
        </div>

        <button type="submit" class="login-btn">Ingresar</button>
      </form>

      <% If resultadoValidacion <> "" And resultadoValidacion = "P" Then %>
      <!-- Formulario cambio de contra -->
      <form method="POST" id="formularioCambioContra">
        <input type="hidden" name="accion" value="change">
        <input type="hidden" name="username" value="<%= Server.HTMLEncode(nombreUsuario) %>">

        <div class="input-group">
          <input type="text" name="newContra" id="nuevaContra" required>
          <label for="nuevaContra">Nueva Contra</label>
        </div>

        <div class="input-group">
          <input type="text" name="confirmContra" id="confirmarContra" required>
          <label for="confirmarContra">Confirmar Contra</label>
        </div>

        <button type="submit" class="login-btn">Actualizar Contra</button>
      </form>

      <script>
        // Deshabilitar formulario de login cuando se muestra cambio de contra
        document.getElementById("formularioLogin").querySelectorAll("input, button").forEach(function(el){
            el.disabled = true;
        });

        // Validación del formulario de cambio de contra
        document.getElementById("formularioCambioContra").onsubmit = function(){
          var c1 = document.getElementById("nuevaContra").value;
          var c2 = document.getElementById("confirmarContra").value;
          if(c1 === "" || c2 === ""){
            alert("Ambos campos son obligatorios.");
            return false;
          }
          if(c1 !== c2){
            alert("Las contras no coinciden.");
            return false;
          }
          return true;
        };
      </script>
      <% End If %>

      <% If resultadoValidacion <> "" And resultadoValidacion = "N" Then %>
        <script>alert("Usuario o contra incorrectos");</script>
      <% End If %>

      <% If resultadoValidacion <> "" And resultadoValidacion = "S" Then
            Session("usuario") = nombreUsuario
            Response.Redirect "principal.asp"
      End If %>

    </div>
  </div>

  <script>
    function mostrarContra() {
      const inputContra = document.getElementById("contra");
      inputContra.type = inputContra.type === "password" ? "text" : "password"; 
    }
  </script>
</body>
</html>
