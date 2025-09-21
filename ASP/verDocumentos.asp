<%@ Language="VBScript" %>
<%
' --- valores dinámicos de ejemplo ---
docsPorFirmar =2
faltasPorAprobar = 0
diasDeVacaciones = 14
diasAlFeriado = 30
CEO = "no"  'simulo ser empleado
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Inicio</title>
    <link rel="stylesheet" href="../css/estilo_verDocs.css">
</head>
<body>
    <header class="barra-superior">
        <div class="usuario">
             JUAN IGNACIO SKREKA IVANESEVIC

        </div><img src= "../imagenes/ndea.png" class="foto-de-perfil"/>
        <div class="espacio"></div>
        <div class="deslogin"><a class="link-deslog" href="http://localhost/Exora_WebSite/ASP/form.asp">Salir</a></div>

    </header>


    <div class="pantalla">
        <!-- Menú lateral -->
        <aside class="menu-lateral">
            <img src= "../imagenes/logo.png" class="img-logo"/>
            <nav>
                <ul>          
                    <li><a href="http://localhost/Exora_WebSite/ASP/principal.asp">⬅ MENU PRINCIPAL</a></li><br>
                    <% IF CEO <> "si" then%>
                    <li><a href="http://localhost/Exora_WebSite/ASP">📅 CALENDARIO</a></li><br>
                    <li><a href="#">🏖️ VACACIONES</a></li><br>
                    <% end if %>
                </ul>
            </nav>
        </aside>

<!-- Pegar DENTRO de tu página (ej: reemplazar el <main> actual) -->
<main class="contenido-principal">

  <style>
    /* estilo local para probar (va después del link CSS para que sobreescriba) */
    :root{ --color--barra--izq: #003cff; }

    .contenido-principal .tabs{ display:flex; gap:8px; margin-bottom:16px; border-bottom:1px solid #e6e6e6; align-items:flex-end; }
    .contenido-principal .tabs .tab{
      -webkit-appearance:none; appearance:none; -moz-appearance:none;
      background:#f4f4f4; border:1px solid #ddd; border-bottom:none;
      padding:8px 12px; font-weight:600; cursor:pointer;
      border-top-left-radius:8px; border-top-right-radius:8px;
      display:inline-flex; align-items:center; gap:8px;
    }
    .contenido-principal .tabs .tab:focus{ outline:2px solid rgba(0,0,0,0.06); outline-offset:2px; }
    .contenido-principal .tabs .tab.activo{ background:#fff; color:var(--color--barra--izq); border-color:#ddd; border-bottom:1px solid #fff; }
    .contenido-principal .badge{ background:var(--color--barra--izq); color:#fff; padding:2px 8px; border-radius:999px; font-size:12px; margin-left:6px; }

    .lista-tarjetas{ margin-top:12px; display:flex; flex-direction:column; gap:12px; max-width:760px; }
    .tarjeta{ background:#fff; padding:12px; border-radius:8px; border:1px solid #eaeaea; box-shadow:0 2px 6px rgba(0,0,0,0.04); }
    .tarjeta-header{ display:flex; justify-content:space-between; font-weight:700; }
    .fecha{ color:#777; font-weight:500; font-size:13px; }
    .tarjeta-estado{ margin-top:8px; display:inline-block; padding:6px 10px; border-radius:6px; font-weight:700; font-size:13px; }
    .tarjeta-estado.pendiente{ background:#e6f0ff; color:#0066cc; }
    .tarjeta-estado.bloqueado{ background:#f0f0f0; color:#444; }

    .hidden{ display:none !important; }
  </style>

  <div class="tabs" role="tablist">
    <button class="tab activo" data-target="pendientes" type="button">Pendientes <span class="badge">2</span></button>
    <button class="tab" data-target="firmados" type="button">Firmados</button>
    <button class="tab" data-target="cargar" type="button">Cargar PDF</button>
  </div>

  <div class="lista-tarjetas">
    <div class="tarjeta" data-group="pendientes">
      <div class="tarjeta-header">Recibos-MENSUAL <span class="fecha">07/2025</span></div>
      <div class="tarjeta-estado pendiente">PENDIENTE</div>
    </div>

    <div class="tarjeta hidden" data-group="firmados">
      <div class="tarjeta-header">Recibos-MENSUAL <span class="fecha">08/2025</span></div>
      <div class="tarjeta-estado bloqueado">BLOQUEADO</div>
    </div>
  </div>

</main>
<div id="visor-pdf" style="flex:1; border:1px solid #ddd; display:flex; justify-content:center; align-items:center;">
  <p>Suelta un PDF aquí o haz clic en un documento pendiente.</p>
</div>

<!-- Área drag & drop -->
<div id="adjuntar" style="display:none; margin-top:12px; padding:20px; border:2px dashed #aaa; text-align:center; cursor:pointer;">
  Arrastra y suelta un PDF aquí
</div>

<script>
  // JS simple para alternar pestañas
  document.addEventListener('DOMContentLoaded', function(){
    const tabs = document.querySelectorAll('.contenido-principal .tab');
    const cards = document.querySelectorAll('.contenido-principal .lista-tarjetas .tarjeta');

function activate(target) {
  // pestañas activas/inactivas
  tabs.forEach(t => t.classList.toggle('activo', t.dataset.target === target));
  cards.forEach(c => c.classList.toggle('hidden', c.dataset.group !== target));

  // mostrar/ocultar dropzone
  if (target === "cargar") {
    adjuntar.style.display = "block";
  } else {
    adjuntar.style.display = "none";
  }
}

    activate('pendientes'); // estado inicial

    tabs.forEach(tab => tab.addEventListener('click', () => activate(tab.dataset.target)));
  });

  const adjuntar = document.getElementById("adjuntar");
  const visor = document.getElementById("visor-pdf");
  let pdfMap = {}; // asociar nombre → url del PDF

  // Drag & Drop
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
      const url = URL.createObjectURL(file);
      // aquí podés usar el nombre de la tarjeta como key
      pdfMap["pendiente1"] = url;
      visor.innerHTML = `<iframe src="${url}" width="100%" height="600px"></iframe>`;
    } else {
      alert("Solo se aceptan archivos PDF");
    }
  });

  // Simulación: al hacer click en la tarjeta pendiente → abre el PDF
  document.querySelectorAll(".tarjeta").forEach(card => {
    card.addEventListener("click", () => {
      const id = card.dataset.group + card.innerText.trim(); // ej. clave
      if(pdfMap["pendiente1"]){
        visor.innerHTML = `<iframe src="${pdfMap["pendiente1"]}" width="100%" height="600px"></iframe>`;
      } else {
        visor.innerHTML = `<p>No hay PDF cargado aún para este documento.</p>`;
      }
    });
  });

</script>
    
 </div>
    </div>
</body>..
</html>
