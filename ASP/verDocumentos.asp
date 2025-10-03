
<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<!--#include file="debug.asp" -->
<%

' --- valores dinámicos de ejemplo ---
documentosPorFirmar = 2
faltasPorAprobar = 0
diasDeVacaciones = 14
diasAlFeriado = 30
esCEO = "no"

' Ruta donde están los PDFs
Dim carpetaUploads, sistemaArchivos, carpeta, archivo, listaPDFs
carpetaUploads = "C:\PRASP\Exora_WebSite\Uploads"

Set sistemaArchivos = Server.CreateObject("Scripting.FileSystemObject")

listaPDFs = ""
If sistemaArchivos.FolderExists(carpetaUploads) Then
    Set carpeta = sistemaArchivos.GetFolder(carpetaUploads)
    For Each archivo In carpeta.Files
        If LCase(sistemaArchivos.GetExtensionName(archivo.Name)) = "pdf" Then
            listaPDFs = listaPDFs & "<li><a href='../Uploads/" & archivo.Name & "' target='_blank'>" & archivo.Name & "</a></li>"
        End If
    Next
    ' For Each archivo In carpeta.Files
    ' ' 🔹 Solo archivos PDF que tengan "archivo_subido" en el nombre
    ' If LCase(sistemaArchivos.GetExtensionName(archivo.Name)) = "pdf" And InStr(LCase(archivo.Name), "archivo_subido") > 0 Then
    '     listaPDFs = listaPDFs & "<li><a href='../Uploads/" & archivo.Name & "' target='_blank'>" & archivo.Name & "</a></li>"
    ' End If
' Next

End If

Set carpeta = Nothing
Set sistemaArchivos = Nothing
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
        #listaPDFs {
            display: none;
            margin-top: 10px;
        }
    </style>
</head>
<body>
<header class="barra-superior">
    <div class="usuario">JUAN IGNACIO SKREKA IVANESEVIC</div>
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
            <button class="tab activo" data-target="pendientes" type="button">Pendientes <span class="badge"><%=documentosPorFirmar%></span></button>
            <button class="tab" data-target="firmados" type="button">Firmados</button>
            <button class="tab" data-target="cargar" type="button">Cargar PDF</button>
        </div>

        <div class="lista-tarjetas">
            <div class="tarjeta" data-grupo="pendientes">
                <ul id="listaPDFs">
                    <%=listaPDFs%>
                </ul>
            </div>
        </div>
    </main>

    <!-- Visor PDF -->
    <div id="visorPDF"></div>

    <!-- Área Drag & Drop -->
    <div id="adjuntar" style="display:none;">Arrastra y suelta un PDF aquí</div>
    <button id="btnGuardar" style="display:none;">Guardar PDF</button>
</div>

<script>
document.addEventListener('DOMContentLoaded', function(){
    const tabs = document.querySelectorAll('.tab');
    const visor = document.getElementById("visorPDF");
    const listaPDFs = document.getElementById("listaPDFs");
    const adjuntar = document.getElementById("adjuntar");
    const btnGuardar = document.getElementById("btnGuardar");

    let archivoPDF = null;

    function activarTab(target) {
        tabs.forEach(t => t.classList.remove("activo"));
        document.querySelector(`.tab[data-target="${target}"]`).classList.add("activo");

        visor.style.display = "none";
        listaPDFs.style.display = "none";
        adjuntar.style.display = "none";
        btnGuardar.style.display = "none";

        if(target === "pendientes") {
            listaPDFs.style.display = "block";
        }
        if(target === "cargar") {
            adjuntar.style.display = "block";
            visor.style.display = "flex";
        }
    }

    activarTab("pendientes");

    tabs.forEach(tab => {
        tab.addEventListener("click", () => {
            activarTab(tab.dataset.target);
        });
    });

    adjuntar.addEventListener("dragover", (e) => {
        e.preventDefault();
        adjuntar.style.background = "#eef";
    });

    adjuntar.addEventListener("dragleave", () => {
        adjuntar.style.background = "";
    });

    adjuntar.addEventListener("drop", (e) => {
        e.preventDefault();
        adjuntar.style.background = "";

        const file = e.dataTransfer.files[0];
        if(file && file.type === "application/pdf"){
            archivoPDF = file;
            const url = URL.createObjectURL(file);
            visor.innerHTML = `<iframe src="${url}" width="100%" height="600px"></iframe>`;
            visor.style.display = "flex";
            btnGuardar.style.display = "inline-block";
        } else {
            alert("Solo se aceptan archivos PDF");
        }
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
            location.reload(); // recarga para mostrar nuevos PDFs
        }).catch(err => {
            alert("Error subiendo archivo: " + err);
        });
    });
});
</script>
</body>
</html>
