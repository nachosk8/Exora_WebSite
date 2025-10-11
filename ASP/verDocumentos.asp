<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<!--#include file="debug.asp" -->
<%
Const tipoVarChar = 200
Const parametroEntrada = 1
Const tipoProcedimientoAlmacenado = 4

' --- valores dinámicos de ejemplo ---
dim NombreApellido, comandoSQL
faltasPorAprobar = 0
diasDeVacaciones = 14
diasAlFeriado = 30
esCEO = "no"
NombreApellido = Session("nombre")

' --- Manejo de PDFs ---
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

' ============================================================
' 🚀 LLAMADA A SP PARA PENDIENTES (E)
' ============================================================
Dim cmd, rs, palabrasPendientes, tmpListaE
tmpListaE = ""

Set cmd = Server.CreateObject("ADODB.Command")
Set cmd.ActiveConnection = conn
cmd.CommandText = "Get_Archivos"
cmd.CommandType = tipoProcedimientoAlmacenado
cmd.Parameters.Append cmd.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
cmd.Parameters.Append cmd.CreateParameter("@Enviado_Recibido", tipoVarChar, parametroEntrada, 1, "E")
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
' 🚀 LLAMADA A SP PARA FIRMADOS (R)
' ============================================================
Dim cmd2, rs2, palabrasFirmados, tmpListaR
tmpListaR = ""

Set cmd2 = Server.CreateObject("ADODB.Command")
Set cmd2.ActiveConnection = conn
cmd2.CommandText = "Get_Archivos"
cmd2.CommandType = tipoProcedimientoAlmacenado
cmd2.Parameters.Append cmd2.CreateParameter("@usuario", tipoVarChar, parametroEntrada, 20, usuarioPrincipal)
cmd2.Parameters.Append cmd2.CreateParameter("@Enviado_Recibido", tipoVarChar, parametroEntrada, 1, "R")
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


' ============================================================
' 📂 RECORRIDO DE ARCHIVOS LOCALES (PENDIENTES)
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
                listaPDFs = listaPDFs & "<li><a href='../Uploads/" & archivo.Name & "' target='_blank'>" & archivo.Name & "</a></li>"
            End If
        End If
    Next

    ' ============================================================
    ' 📂 RECORRIDO DE ARCHIVOS LOCALES (FIRMADOS)
    ' ============================================================
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

Set carpeta = Nothing
Set sistemaArchivos = Nothing
conn.Close
Set conn = Nothing
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
        #listaPDFs, #listaFirmados {
            display: none;
            margin-top: 10px;
        }
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
            <button class="tab" data-target="cargar" type="button">Cargar PDF</button>
        </div>

        <div class="lista-tarjetas">
            <div class="tarjeta" data-grupo="pendientes">
                <ul id="listaPDFs">
                    <%=listaPDFs%>
                </ul>
            </div>

            <div class="tarjeta" data-grupo="firmados">
                <ul id="listaFirmados">
                    <%=listaFirmados%>
                </ul>
            </div>
        </div>
    </main>

    <div id="visorPDF"></div>
    <div id="adjuntar" style="display:none;">Arrastra y suelta un PDF aquí</div>
    <button id="btnGuardar" style="display:none;">Guardar PDF</button>
</div>

<script>
document.addEventListener('DOMContentLoaded', function(){
    const tabs = document.querySelectorAll('.tab');
    const visor = document.getElementById("visorPDF");
    const listaPDFs = document.getElementById("listaPDFs");
    const listaFirmados = document.getElementById("listaFirmados");
    const adjuntar = document.getElementById("adjuntar");
    const btnGuardar = document.getElementById("btnGuardar");

    let archivoPDF = null;

    function activarTab(target) {
        tabs.forEach(t => t.classList.remove("activo"));
        document.querySelector(`.tab[data-target="${target}"]`).classList.add("activo");

        visor.style.display = "none";
        listaPDFs.style.display = "none";
        listaFirmados.style.display = "none";
        adjuntar.style.display = "none";
        btnGuardar.style.display = "none";

        if(target === "pendientes") listaPDFs.style.display = "block";
        if(target === "firmados") listaFirmados.style.display = "block";
        if(target === "cargar") {
            adjuntar.style.display = "block";
            visor.style.display = "flex";
        }
    }

    activarTab("pendientes");

    tabs.forEach(tab => {
        tab.addEventListener("click", () => activarTab(tab.dataset.target));
    });

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

    btnGuardar.addEventListener("click", function(){
        if(!archivoPDF) return alert("No hay archivo cargado");
        const formData = new FormData();
        formData.append("archivoPDF", archivoPDF);
        fetch("guardar_pdf.asp", {
            method: "POST",
            body: formData
        }).then(res => res.text()).then(resp => {
            alert(resp);
            location.reload();
        }).catch(err => alert("Error subiendo archivo: " + err));
    });
});
</script>
</body>
</html>
