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

' === Usuarios de la empresa para el selector (solo admin) ===
Set comandoSQL = Server.CreateObject("ADODB.Command")
Set comandoSQL.ActiveConnection = conn
comandoSQL.CommandText = "UsuariosDeLaEmpresa"
comandoSQL.CommandType = tipoProcedimientoAlmacenado
comandoSQL.Parameters.Append comandoSQL.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
Set usuariosEmpresaRS = comandoSQL.Execute()

' ============================================================
' PENDIENTES (R)
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

If tmpListaE <> "" Then
    palabrasPendientes = Split(tmpListaE, ",")
Else
    palabrasPendientes = Array()
End If

If Not rs Is Nothing Then
    If Not rs.State = 0 Then rs.Close
    Set rs = Nothing
End If
Set cmd = Nothing

' ============================================================
' FIRMADOS (E)
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

If tmpListaR <> "" Then
    palabrasFirmados = Split(tmpListaR, ",")
Else
    palabrasFirmados = Array()
End If

If Not rs2 Is Nothing Then
    If Not rs2.State = 0 Then rs2.Close
    Set rs2 = Nothing
End If
Set cmd2 = Nothing

' ============================================================
' ARCHIVOS LOCALES
' ============================================================
If sistemaArchivos.FolderExists(carpetaUploads) Then
    Set carpeta = sistemaArchivos.GetFolder(carpetaUploads)

    ' PENDIENTES
    Dim palabra
    For Each archivo In carpeta.Files
        If LCase(sistemaArchivos.GetExtensionName(archivo.Name)) = "pdf" Then
            Dim nombreArchivo, coincide
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

    ' FIRMADOS
    Dim palabra2
    For Each archivo In carpeta.Files
        If LCase(sistemaArchivos.GetExtensionName(archivo.Name)) = "pdf" Then
            Dim nombreArchivo2, coincide2
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
            <% If Admin <> "S" Then %>
                <button class="tab activo" data-target="pendientes" type="button">
                    Pendientes <span class="badge"><%=TotalPendientes%></span>
                </button>
            <% End If %>
            <button class="tab" data-target="firmados" type="button">
                Firmados <span class="badge"><%=TotalFirmados%></span>
            </button>
            <% If Admin = "S" Then %>
                <button class="tab" data-target="cargar" type="button">Cargar PDF</button>
            <% Else %>
                <button class="tab" data-target="cargar" type="button">Firmar PDF</button>
            <% End If %>
        </div>

        <div class="lista-tarjetas">
            <div class="tarjeta" data-grupo="pendientes">
                <ul id="listaPDFs"><%=listaPDFs%></ul>
            </div>
            <div class="tarjeta" data-grupo="firmados">
                <ul id="listaFirmados"><%=listaFirmados%></ul>
            </div>
        </div>

        <% If Admin = "S" Then %>
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
        <% End If %>
    </main>

    <div id="visorPDF"></div>
    <div id="adjuntar" style="display:none;">Soltá tu PDF acá</div>
    <button id="btnGuardar" style="display:none;">Guardar PDF</button>
</div>

<%
' Limpieza de objetos de servidor
On Error Resume Next
If Not usuariosEmpresaRS Is Nothing Then
    If Not usuariosEmpresaRS.State = 0 Then usuariosEmpresaRS.Close
    Set usuariosEmpresaRS = Nothing
End If
If Not carpeta Is Nothing Then Set carpeta = Nothing
If Not sistemaArchivos Is Nothing Then Set sistemaArchivos = Nothing
If Not conn Is Nothing Then
    If Not conn.State = 0 Then conn.Close
    Set conn = Nothing
End If
On Error GoTo 0
%>

<script>
document.addEventListener('DOMContentLoaded', function(){

    const $ = sel => document.querySelector(sel);
    const $$ = sel => Array.from(document.querySelectorAll(sel) || []);

    const tabs = $$('.tab');
    const visor = $('#visorPDF');
    const listaPDFs = $('#listaPDFs');
    const listaFirmados = $('#listaFirmados');
    const adjuntar = $('#adjuntar');
    const btnGuardar = $('#btnGuardar');
    const selectorBox = $('#selectorUsuarioBox');
    const selector = $('#selectorUsuario');
    const btnOK = $('#btnSeleccionOK');
    const botonesFirmar = $$('.btnFirmar');

    const esAdmin = '<%= Admin %>' === 'S';
    const usuarioPrincipal = '<%= usuarioPrincipal %>';

    let archivoPDF = null;
    let archivoSeleccionado = null;
    let destinatario = null;

    if(!esAdmin){
        destinatario = usuarioPrincipal; // quien firma
    }

    function safeHide(el){ if(el) el.style.display = 'none'; }
    function safeShow(el, disp){ if(el) el.style.display = disp || 'block'; }

    function activarTab(target){
        // quitar "activo"
        tabs.forEach(t => t && t.classList && t.classList.remove('activo'));
        // marcar activo si existe
        const activeBtn = $(`.tab[data-target="${target}"]`);
        if(activeBtn && activeBtn.classList) activeBtn.classList.add('activo');

        // ocultar todo
        safeHide(visor);
        safeHide(listaPDFs);
        safeHide(listaFirmados);
        safeHide(adjuntar);
        safeHide(btnGuardar);
        safeHide(selectorBox);

        // mostrar según target
        if(target === 'pendientes' && listaPDFs) safeShow(listaPDFs);
        if(target === 'firmados' && listaFirmados) safeShow(listaFirmados);
        if(target === 'cargar'){
            if(esAdmin){
                safeShow(selectorBox);
            } else {
                safeShow(adjuntar);
                safeShow(visor, 'flex');
            }
        }
    }

    // Tab inicial seguro:
    // - Si es Admin, "pendientes" no existe. Elegimos "firmados".
    // - Si no es Admin, sí existe "pendientes".
    activarTab(esAdmin ? 'firmados' : 'pendientes');

    // listeners tabs
    tabs.forEach(tab => {
        if(!tab) return;
        tab.addEventListener('click', () => activarTab(tab.dataset.target));
    });

    // Admin: seleccionar destinatario
    if(esAdmin && btnOK && selector){
        btnOK.addEventListener('click', function(){
            const val = selector.value;
            if(!val){
                alert('Seleccioná un destinatario');
                return;
            }
            destinatario = val;

            fetch('guardar_destinatario.asp?user=' + encodeURIComponent(val))
                .then(r => r.text())
                .then(() => {
                    safeHide(selectorBox);
                    safeShow(adjuntar);
                    safeShow(visor, 'flex');
                })
                .catch(() => {
                    alert('No se pudo guardar el destinatario');
                });
        });
    }

    // No admin: evento firmar
    if(botonesFirmar.length){
        botonesFirmar.forEach(b => {
            if(!b) return;
            b.addEventListener('click', function(e){
                archivoSeleccionado = e.currentTarget.dataset.archivo || null;

                // Guardar en Session el nombre del archivo a firmar
                fetch('guardar_destinatario.asp?file=' + encodeURIComponent(archivoSeleccionado))
                    .then(r => r.text())
                    .then(() => {
                        alert('Vas a firmar: ' + archivoSeleccionado);
                        activarTab('cargar');
                    })
                    .catch(() => alert('No se pudo preparar la firma'));
            });
        });
    }

    // Drag & drop
    if(adjuntar){
        adjuntar.addEventListener('dragover', function(e){
            e.preventDefault();
            adjuntar.style.background = '#eef';
        });
        adjuntar.addEventListener('dragleave', function(){
            adjuntar.style.background = '';
        });
        adjuntar.addEventListener('drop', function(e){
            e.preventDefault();
            adjuntar.style.background = '';

            const file = e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0];
            if(file && file.type === 'application/pdf'){
                archivoPDF = file;
                const url = URL.createObjectURL(file);
                if(visor){
                    visor.innerHTML = `<iframe src="${url}" width="100%" height="600px"></iframe>`;
                    safeShow(visor, 'flex');
                }
                safeShow(btnGuardar, 'inline-block');
            } else {
                alert('Solo se aceptan archivos PDF');
            }
        });
    }

    // Guardar
    if(btnGuardar){
        btnGuardar.addEventListener('click', function(){
            if(!archivoPDF){
                alert('No hay archivo cargado');
                return;
            }
            const formData = new FormData();
            formData.append('archivoPDF', archivoPDF);
            if(archivoSeleccionado) formData.append('original', archivoSeleccionado);
            if(destinatario) formData.append('destinatario', destinatario);

            fetch('guardar_pdf.asp', { method: 'POST', body: formData })
                .then(res => res.text())
                .then(resp => { alert(resp); location.reload(); })
                .catch(err => alert('Error subiendo archivo: ' + err));
        });
    }

});
</script>

</body>
</html>
