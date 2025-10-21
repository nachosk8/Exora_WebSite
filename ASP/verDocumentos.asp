<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<!--#include file="debug.asp" -->
<%
Const tipoVarChar = 200
Const parametroEntrada = 1
Const tipoProcedimientoAlmacenado = 4

dim NombreApellido, comandoSQL, Admin
faltasPorAprobar = 0
diasDeVacaciones = 14
diasAlFeriado = 30

NombreApellido = Session("nombre")
Admin = Session("admin")
Admin = "N"

Dim carpetaUploads, sistemaArchivos, carpeta, archivo
Dim usuarioPrincipal, TotalPendientes, TotalFirmados
Dim listaPDFs, listaFirmados

carpetaUploads = "C:\PRASP\Exora_WebSite\Uploads"
usuarioPrincipal = Session("usuario")
TotalPendientes = 0
TotalFirmados = 0
listaPDFs = ""
listaFirmados = ""
Set sistemaArchivos = Server.CreateObject("Scripting.FileSystemObject")

Set comandoSQL = Server.CreateObject("ADODB.Command")
Set comandoSQL.ActiveConnection = conn
comandoSQL.CommandText = "UsuariosDeLaEmpresa"
comandoSQL.CommandType = tipoProcedimientoAlmacenado
comandoSQL.Parameters.Append comandoSQL.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
Set usuariosEmpresaRS = comandoSQL.Execute()

' ============================================================
' 🚀 LLAMADA A SP PARA PENDIENTES (R)
' ============================================================
Dim cmd, rs, palabrasPendientes, tmpListaE
tmpListaE = ""
Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandText = "Get_Archivos"
cmd.CommandType = tipoProcedimientoAlmacenado
cmd.Parameters.Append cmd.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
cmd.Parameters.Append cmd.CreateParameter("@Enviado_Recibido", tipoVarChar, parametroEntrada, 1, "R")
Set rs = cmd.Execute()

If Not rs.EOF Then
    If rs("cantidad") <> 0 Then
        Do While Not rs.EOF
            If Len(Trim(rs("Nombre_Path"))) > 0 Then
                If tmpListaE = "" Then
                    tmpListaE = rs("Nombre_Path")
                Else
                    tmpListaE = tmpListaE & "," & rs("Nombre_Path")
                End If
            End If
            rs.MoveNext
        Loop
    End If
End If

If tmpListaE <> "" Then
    palabrasPendientes = Split(tmpListaE, ",")
Else
    palabrasPendientes = Array()
End If

Set rs = Nothing
Set cmd = Nothing

' ============================================================
' 🚀 LLAMADA A SP PARA FIRMADOS (E)
' ============================================================
Dim cmd2, rs2, palabrasFirmados, tmpListaR
tmpListaR = ""
Set cmd2 = Server.CreateObject("ADODB.Command")
Set cmd2.ActiveConnection = conn
cmd2.CommandText = "Get_Archivos"
cmd2.CommandType = tipoProcedimientoAlmacenado
cmd2.Parameters.Append cmd2.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
cmd2.Parameters.Append cmd2.CreateParameter("@Enviado_Recibido", tipoVarChar, parametroEntrada, 1, "E")
Set rs2 = cmd2.Execute()

If Not rs2.EOF Then
    If rs2("cantidad") <> 0 Then
        Do While Not rs2.EOF
            If Len(Trim(rs2("Nombre_Path"))) > 0 Then
                If tmpListaR = "" Then
                    tmpListaR = rs2("Nombre_Path")
                Else
                    tmpListaR = tmpListaR & "," & rs2("Nombre_Path")
                End If
            End If
            rs2.MoveNext
        Loop
    End If
End If

If tmpListaR <> "" Then
    palabrasFirmados = Split(tmpListaR, ",")
Else
    palabrasFirmados = Array()
End If

Set rs2 = Nothing
Set cmd2 = Nothing

' ============================================================
' 📂 RECORRIDO DE ARCHIVOS LOCALES
' ============================================================
If sistemaArchivos.FolderExists(carpetaUploads) Then
    Set carpeta = sistemaArchivos.GetFolder(carpetaUploads)

    For Each archivo In carpeta.Files
        If LCase(sistemaArchivos.GetExtensionName(archivo.Name)) = "pdf" Then
            Dim nombreArchivo, coincide, palabra
            nombreArchivo = LCase(archivo.Name)
            coincide = False

            For Each palabra In palabrasPendientes
                If InStr(nombreArchivo, LCase(Trim(palabra))) > 0 Then
                    coincide = True
                    Exit For
                End If
            Next

            If coincide Then
                TotalPendientes = TotalPendientes + 1
                listaPDFs = listaPDFs & "<li><a href='../Uploads/" & archivo.Name & "' target='_blank'>" & archivo.Name & "</a>"
                If Admin <> "S" Then
                    listaPDFs = listaPDFs & " <button class='btnFirmar' data-archivo='" & archivo.Name & "'>Firmar</button>"
                End If
                listaPDFs = listaPDFs & "</li>"
            End If
        End If
    Next

    For Each archivo In carpeta.Files
        If LCase(sistemaArchivos.GetExtensionName(archivo.Name)) = "pdf" Then
            Dim nombreArchivo2, coincide2, palabra2
            nombreArchivo2 = LCase(archivo.Name)
            coincide2 = False

            For Each palabra2 In palabrasFirmados
                If InStr(nombreArchivo2, LCase(Trim(palabra2))) > 0 Then
                    coincide2 = True
                    Exit For
                End If
            Next

            If coincide2 Then
                TotalFirmados = TotalFirmados + 1
                listaFirmados = listaFirmados & "<li><a href='../Uploads/" & archivo.Name & "' target='_blank'>" & archivo.Name & "</a></li>"
            End If
        End If
    Next
End If
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Inicio</title>
<link rel="stylesheet" href="../css/estilo_verDocs.css">
<style>
#visorPDF {
    flex: 1;
    border: 1px solid #ddd;
    display: none;
    justify-content: center;
    align-items: center;
    margin-top: 10px;
}
#listaPDFs, #listaFirmados { display: none; margin-top: 10px; }
#selectorUsuarioBox {
    display: none;
    margin: 10px 0;
    border: 1px solid #ddd;
    padding: 8px;
    background: #fafafa;
}
.btnFirmar {
    margin-left: 10px;
    background-color: #2d89ef;
    color: white;
    border: none;
    padding: 4px 8px;
    border-radius: 4px;
    cursor: pointer;
}
.btnFirmar:hover { background-color: #1b5fbf; }
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
                <li><a href="http://localhost/Exora_WebSite/ASP/calendario.asp">📅 LICENCIAS</a></li><br>
            </ul>
        </nav>
    </aside>

    <main class="contenido-principal">
        <div class="tabs" role="tablist">
            <button class="tab activo" data-target="pendientes" type="button">
                Pendientes <span class="badge"><%=TotalPendientes%></span>
            </button>
            <button class="tab" data-target="firmados" type="button">
                Firmados <span class="badge"><%=TotalFirmados%></span>
            </button>
            <%if Admin = "S" then%>
                <button class="tab" data-target="cargar" type="button">Cargar PDF</button>
            <%else%>
                <button class="tab" data-target="cargar" type="button">Firmar PDF</button>
            <%end if%> 
        </div>

        <div class="lista-tarjetas">
            <div class="tarjeta" data-grupo="pendientes">
                <ul id="listaPDFs"><%=listaPDFs%></ul>
            </div>
            <div class="tarjeta" data-grupo="firmados">
                <ul id="listaFirmados"><%=listaFirmados%></ul>
            </div>
        </div>

        <div id="selectorUsuarioBox">
            <label for="selectorUsuario"><strong>Seleccioná destinatario:</strong></label><br>
            <select id="selectorUsuario">
                <option value="">-- Seleccione un destinatario --</option>
                <% 
                If Not usuariosEmpresaRS.EOF Then
                    Do While Not usuariosEmpresaRS.EOF
                        Response.Write "<option value='" & usuariosEmpresaRS("usuario") & "'>" & usuariosEmpresaRS("NombreApellido") & "</option>"
                        usuariosEmpresaRS.MoveNext
                    Loop
                Else
                    Response.Write "<option value=''>No hay usuarios disponibles</option>"
                End If
                %>
            </select>
            <button id="btnSeleccionOK" type="button">OK</button>
        </div>
    </main> 

    <div id="visorPDF"></div>
    <div id="adjuntar" style="display:none;">Arrastra y suelta un PDF aquí</div>
    <button id="btnGuardar" style="display:none;">Guardar PDF</button>
</div>

<%
Set carpeta = Nothing
Set sistemaArchivos = Nothing
conn.Close
Set conn = Nothing
%>

<script>
document.addEventListener('DOMContentLoaded', function(){
    const tabs = document.querySelectorAll('.tab');
    const visor = document.getElementById("visorPDF");
    const listaPDFs = document.getElementById("listaPDFs");
    const listaFirmados = document.getElementById("listaFirmados");
    const adjuntar = document.getElementById("adjuntar");
    const btnGuardar = document.getElementById("btnGuardar");
    const selectorBox = document.getElementById("selectorUsuarioBox");
    const selector = document.getElementById("selectorUsuario");
    const btnOK = document.getElementById("btnSeleccionOK");
    const botonesFirmar = document.querySelectorAll('.btnFirmar');

    let archivoPDF = null;
    let archivoSeleccionado = null;

    function activarTab(target) {
        tabs.forEach(t => t.classList.remove("activo"));
        document.querySelector(`.tab[data-target="${target}"]`).classList.add("activo");
        visor.style.display = "none";
        listaPDFs.style.display = "none";
        listaFirmados.style.display = "none";
        adjuntar.style.display = "none";
        btnGuardar.style.display = "none";
        selectorBox.style.display = "none";

        if(target === "pendientes") listaPDFs.style.display = "block";
        if(target === "firmados") listaFirmados.style.display = "block";
        if(target === "cargar") selectorBox.style.display = "block";
    }

    activarTab("pendientes");

    tabs.forEach(tab => {
        tab.addEventListener("click", () => activarTab(tab.dataset.target));
    });

    // 💾 Guardar destinatario
    btnOK.addEventListener("click", function(){
        const val = selector.value;
        if(!val){
            alert("Debes seleccionar un destinatario antes de continuar.");
            return;
        }

        fetch("guardar_destinatario.asp?user=" + encodeURIComponent(val))
            .then(res => res.text())
            .then(txt => {
                alert("Destinatario guardado en sesión: " + val);
            })
            .catch(err => alert("Error al guardar destinatario: " + err));

        selectorBox.style.display = "none";
        adjuntar.style.display = "block";
        visor.style.display = "flex";
    });

    // 🔹 Evento firmar (no admin)
    botonesFirmar.forEach(b => {
        b.addEventListener('click', e => {
            archivoSeleccionado = e.target.dataset.archivo;
            alert("Vas a firmar el archivo: " + archivoSeleccionado);
            activarTab('cargar');
        });
    });

    // Drag & Drop PDF
    adjuntar.addEventListener("dragover", e => { e.preventDefault(); adjuntar.style.background = "#eef"; });
    adjuntar.addEventListener("dragleave", () => adjuntar.style.background = "");
    adjuntar.addEventListener("drop", e => {
        e.preventDefault();
        adjuntar.style.background = "";
        const file = e.dataTransfer.files[0];
        if(file && file.type === "application/pdf"){
            archivoPDF = file;
            const url = URL.createObjectURL(file);
            visor.innerHTML = `<iframe src="${url}" width="100%" height="600px"></iframe>`;
            visor.style.display = "flex";
            btnGuardar.style.display = "inline-block";
        } else alert("Solo se aceptan archivos PDF");
    });

    // Guardar PDF
    btnGuardar.addEventListener("click", function(){
        if(!archivoPDF) return alert("No hay archivo cargado");
        const formData = new FormData();
        formData.append("archivoPDF", archivoPDF);
        if(archivoSeleccionado) formData.append("original", archivoSeleccionado);
        fetch("guardar_pdf.asp", { method: "POST", body: formData })
            .then(res => res.text())
            .then(resp => { alert(resp); location.reload(); })
            .catch(err => alert("Error subiendo archivo: " + err));
    });
});
</script>
</body>
</html>
