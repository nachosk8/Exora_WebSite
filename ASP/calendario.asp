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
            .Parameters.Append .CreateParameter("@nombreApellido", 200, 1, 50, NombreApellido)
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

' --- Obtener licencias solicitadas ---
Dim cmdSolic, rsSolicitadas
Set cmdSolic = Server.CreateObject("ADODB.Command")
With cmdSolic
    .ActiveConnection = conn
    .CommandText = "obtener_licencias_solicitadas"
    .CommandType = 4 ' Stored Procedure
    .Parameters.Append .CreateParameter("@usuario", 200, 1, 20, usuarioPrincipal)
    .Parameters.Append .CreateParameter("@admin", 200, 1, 1, Admin)
    Set rsSolicitadas = .Execute()
End With
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Licencias</title>
    <link rel="stylesheet" href="../css/estilo_calendario.css">
    <style>
        table.tabla-licencias {
            border-collapse: collapse;
            width: 100%;
            margin-top: 30px;
            font-family: Arial, sans-serif;
        }
        .tabla-licencias th {
            background-color: #0078D7;
            color: white;
            padding: 10px;
            text-align: left;
        }
        .tabla-licencias td {
            border-bottom: 1px solid #ccc;
            padding: 8px 10px;
            vertical-align: top;
        }
        .tabla-licencias tr:hover {
            background-color: #f1f5ff;
        }

        /* 🎨 Colores según estado */
        .estado {
            font-weight: bold;
            text-align: center;
            border-radius: 4px;
            padding: 5px 8px;
            color: white;
        }
        .estado.aceptado { background-color: #28a745; }
        .estado.pendiente { background-color: #ffc107; color: #333; }
        .estado.rechazado { background-color: #dc3545; }

        /* 🎛 Botones admin */
        .acciones-admin {
            text-align: center;
            position: relative;
        }
        .btn-aprobar, .btn-rechazar {
            border: none;
            border-radius: 4px;
            cursor: pointer;
            padding: 6px 10px;
            font-size: 16px;
            margin: 0 3px;
            color: white;
            transition: 0.2s;
        }
        .btn-aprobar { background-color: #28a745; }
        .btn-aprobar:hover { background-color: #1e7e34; }
        .btn-rechazar { background-color: #dc3545; }
        .btn-rechazar:hover { background-color: #b21f2d; }

        /* Popup del motivo */
        .motivo-rechazo {
            display: none;
            position: absolute;
            top: 40px;
            left: 50%;
            transform: translateX(-50%);
            background: #fff;
            border: 1px solid #ccc;
            border-radius: 6px;
            padding: 10px;
            width: 220px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            z-index: 10;
        }
        .motivo-rechazo textarea {
            width: 100%;
            height: 60px;
            resize: none;
            font-size: 13px;
            padding: 4px;
        }
        .motivo-btns {
            text-align: right;
            margin-top: 6px;
        }
        .motivo-btns button {
            font-size: 12px;
            padding: 4px 8px;
            margin-left: 4px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        .btn-aceptar { background-color: #28a745; color: white; }
        .btn-cancelar { background-color: #ccc; color: black; }
    </style>
</head>
<body>
<header class="barra-superior">
    <div class="usuario"><%=NombreApellido%></div>
    <div class="espacio"></div>
    <div class="deslogin">
        <a class="link-deslog" href="http://localhost/Exora_WebSite/ASP/login.asp">Salir</a>
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
    <% If Admin <> "S" Then %>
        <h2>Solicitud de Licencia</h2>

        <% If mensaje <> "" Then %>
            <p style="color:<%=colorMensaje%>; font-weight:bold;"><%=mensaje%></p>
        <% End If %>

        <!-- formulario -->
        <form method="post" id="formLicencia" class="form-licencia">
            <label>Tipo de licencia:</label>
            <select name="tipoLicencia" id="tipoLicencia" onchange="mostrarCalendarios()">
                <option value="">Seleccionar...</option>
                <%
                If Not rsLicencias.EOF Then
                    Do Until rsLicencias.EOF
                %>
                    <option value="<%=rsLicencias("Licencia")%>"
                            data-disponible="<%=rsLicencias("CantidadDisponible")%>">
                        <%=rsLicencias("Licencia")%> (<%=rsLicencias("CantidadDisponible")%>)
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
    <% End If %>

    <!-- tabla -->
    <% If Not rsSolicitadas.EOF Then 
        Dim cantidad : cantidad = rsSolicitadas("cantidad")
        If cantidad > 0 Then %>
        <h3 style="margin-top:40px;">Licencias solicitadas</h3>
        <table class="tabla-licencias">
            <tr>
                <th>DNI</th>
                <th>Nombre y Apellido</th>
                <th>Tipo de Licencia</th>
                <th>Desde</th>
                <th>Hasta</th>
                <th>Días Totales</th>
                <th>Estado</th>
                <% If Admin = "S" Then %><th>Acciones</th><% End If %>
            </tr>
            <% Do Until rsSolicitadas.EOF
                Dim estado, claseEstado
                estado = Trim(UCase(rsSolicitadas("Estado")))
                Select Case estado
                    Case "ACEPTADO", "APROBADO": claseEstado = "aceptado"
                    Case "PENDIENTE": claseEstado = "pendiente"
                    Case "RECHAZADO": claseEstado = "rechazado"
                    Case Else: claseEstado = ""
                End Select
            %>
            <tr>
                <td><%=rsSolicitadas("usuario")%></td>
                <td><%=rsSolicitadas("nombreapellido")%></td>
                <td><%=rsSolicitadas("licencia")%></td>
                <td><%=FormatDateTime(rsSolicitadas("inicio"), 2)%></td>
                <td><%=FormatDateTime(rsSolicitadas("fin"), 2)%></td>
                <td style="text-align:center;"><%=rsSolicitadas("DiasTotales")%></td>
                <td class="estado <%=claseEstado%>"><%=rsSolicitadas("Estado")%></td>

                <% If Admin = "S" And estado = "PENDIENTE" Then %>
                    <td class="acciones-admin">
                        <button class="btn-aprobar" title="Aprobar">✔</button>
                        <button class="btn-rechazar" title="Rechazar">✖</button>
                        <div class="motivo-rechazo">
                            <textarea placeholder="Motivo de rechazo..."></textarea>
                            <div class="motivo-btns">
                                <button class="btn-aceptar">Aceptar</button>
                                <button class="btn-cancelar">Cancelar</button>
                            </div>
                        </div>
                    </td>
                <% ElseIf Admin = "S" Then %>
                    <td></td>
                <% End If %>
            </tr>
            <% rsSolicitadas.MoveNext : Loop %>
        </table>
    <% End If
    End If %>
    </section>
</div>

<script>
function mostrarCalendarios() {
    const tipo = document.getElementById("tipoLicencia").value;
    const seccion = document.getElementById("seccionFechas");
    seccion.style.display = (tipo !== "") ? "block" : "none";
}

document.addEventListener("DOMContentLoaded", function(){
    document.querySelectorAll(".btn-rechazar").forEach(btn=>{
        btn.addEventListener("click",e=>{
            e.preventDefault();
            const box = e.currentTarget.parentElement.querySelector(".motivo-rechazo");
            box.style.display = box.style.display==="block"?"none":"block";
        });
    });

    document.querySelectorAll(".btn-cancelar").forEach(btn=>{
        btn.addEventListener("click",e=>{
            e.preventDefault();
            const box = e.currentTarget.closest(".motivo-rechazo");
            box.querySelector("textarea").value="";
            box.style.display="none";
        });
    });

    document.querySelectorAll(".btn-aceptar").forEach(btn=>{
        btn.addEventListener("click",e=>{
            e.preventDefault();
            const box=e.currentTarget.closest(".motivo-rechazo");
            const motivo=box.querySelector("textarea").value.trim();
            const fila=e.currentTarget.closest("tr");
            enviarDecision(fila,"RECHAZADO",motivo);
        });
    });

    document.querySelectorAll(".btn-aprobar").forEach(btn=>{
        btn.addEventListener("click",e=>{
            e.preventDefault();
            const fila=e.currentTarget.closest("tr");
            enviarDecision(fila,"APROBADO","");
        });
    });
});

function enviarDecision(fila,estado,motivo){
    const usuario=fila.children[0].innerText.trim();
    const licencia=fila.children[2].innerText.trim();
    const desde=fila.children[3].innerText.trim();
    const hasta=fila.children[4].innerText.trim();
    const dias=fila.children[5].innerText.trim();

    fetch("aprobar_rechazar_licencia.asp",{
        method:"POST",
        body:new URLSearchParams({
            usuario_solicitante:usuario,
            licencia:licencia,
            desde:desde,
            hasta:hasta,
            dias:dias,
            motivo:motivo,
            aprobacion:estado
        })
    })
    .then(r=>r.json())
    .then(data=>{
        alert(data.msg);
        if(data.ok) location.reload();
    })
    .catch(err=>alert("Error: "+err));
}
</script>

</body>
</html>

<%
If Not rsLicencias Is Nothing Then If rsLicencias.State=1 Then rsLicencias.Close
If Not rsSolicitadas Is Nothing Then If rsSolicitadas.State=1 Then rsSolicitadas.Close
Set rsLicencias=Nothing
Set rsSolicitadas=Nothing
Set cmd=Nothing
Set cmdSolic=Nothing
%>
