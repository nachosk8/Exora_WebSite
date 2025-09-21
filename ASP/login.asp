<%@ Language="VBScript" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Login</title>
    <link rel="stylesheet" href="../css/estilo_login.css">
</head>
<body>

  <div class="login-container">
    <h2>EXORA | Empresas</h2>

    <!-- Usuario -->
    <div class="input-group">
      <input type="text" id="username" placeholder=" " required maxlength="20" >
      <label for="username">Usuario</label>
    </div>

    <!-- Contraseña -->
    <div class="input-group">
      <input type="password" id="password" placeholder=" " required maxlength="20">
      <label for="password">Contraseña</label>
      <span  class="toggle-password"  onclick="togglePassword()">ocultar/mostrar </span>
    </div>

    <div class="forgot">
      <a href="#">¿Olvidó su contraseña?</a>
    </div>

    <button class="login-btn">Ingresar</button>

  </div>

  <script>
    function togglePassword() {
      const passInput = document.getElementById("password");
      passInput.type = passInput.type === "password" ? "text" : "password";
    }
  </script>

</body>
</html>
