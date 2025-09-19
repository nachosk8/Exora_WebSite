<%@ Language="VBScript" %>
<%
' --- ejemplo de valores dinámicos (reemplazá con tus queries / lógica) ---
docPendientes = 2
ausenciasPendientes = 0
vacacionesDisponibles = 14
diasProximoFeriado = 30
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Inicio</title>
    <link rel="stylesheet" href="estilo_principa.css">
</head>
<body>
    <div class="layout">
        <!-- Barra lateral -->
        <aside class="sidebar">
            <div class="logo">EXORA</div>
            <nav>
                <ul>
                    <li><a href="#">📄 Documentos</a></li><br>
                    <li><a href="#">📅 Calendario</a></li><br>
                    <li><a href="#">👜 Vacaciones</a></li><br>
                    <li><a href="#">❓ Ayuda</a></li>
                </ul>
            </nav>
        </aside>

        <!-- Contenido principal -->
        <main class="content">
            <!-- GRID de tarjetas (Documentos / Ausencias / Vacaciones / Próximo feriado) -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-left">
                        <div class="stat-icon">📄</div>
                        <div class="stat-text">
                            <div class="stat-title">Documentos</div>
                            <div class="stat-sub">PENDIENTES POR FIRMAR</div>
                        </div>
                    </div>
                    <div class="stat-value"><%= docPendientes %></div>
                </div>

                <div class="stat-card">
                    <div class="stat-left">
                        <div class="stat-icon">📥</div>
                        <div class="stat-text">
                            <div class="stat-title">Ausencias</div>
                            <div class="stat-sub">PENDIENTES DE APROBACIÓN</div>
                        </div>
                    </div>
                    <div class="stat-value"><%= ausenciasPendientes %></div>
                </div>

                <div class="stat-card">
                    <div class="stat-left">
                        <div class="stat-icon">🏖️</div>
                        <div class="stat-text">
                            <div class="stat-title">Vacaciones</div>
                            <div class="stat-sub">DÍAS DISPONIBLES</div>
                        </div>
                    </div>
                    <div class="stat-value"><%= vacacionesDisponibles %></div>
                </div>

                <div class="stat-card">
                    <div class="stat-left">
                        <div class="stat-icon">🌴</div>
                        <div class="stat-text">
                            <div class="stat-title">Próximo feriado</div>
                            <div class="stat-sub">DÍA DE LA</div>
                        </div>
                    </div>
                    <div class="stat-value"><%= diasProximoFeriado %> <span class="small">DÍAS</span></div>
                </div>
            </div>

            <!-- Feed de publicaciones (igual que antes) -->
            <div class="post">
                <div class="post-header">
                    <div class="post-author">Tecnosoftware</div>
                    <div class="post-date">sept 12</div>
                </div>
                <div class="post-body">
                    <h3>¡Se vienen las Tecno Talks!</h3>
                    <p>Un espacio para compartir ideas, tendencias y casos de éxito.</p>
                </div>
            </div>

            <div class="post">
                <div class="post-header">
                    <div class="post-author">Tecnosoftware</div>
                    <div class="post-date">feb 17</div>
                </div>
                <div class="post-body">
                    <h3>Novedades: Swiss Medical Group</h3>
                    <p>Con Swity podrás recibir atención personalizada...</p>
                </div>
            </div>
            
        </main>
    </div>
</body>
</html>
