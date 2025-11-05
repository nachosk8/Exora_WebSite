<%@ Language="VBScript" %>
<!--#include file="conexion.asp"-->
<%
Response.ContentType = "application/json"

Dim Admin
Admin = Session("admin")

If Admin <> "S" Then
    Response.Write "{""ok"":false,""msg"":""No autorizado""}"
    Response.End
End If

Dim usuarioSolic, licencia, desde, hasta, dias, motivo, aprobacion

usuarioSolic = Request("usuario_solicitante")
licencia = Request("licencia")
desde = Request("desde")
hasta = Request("hasta")
dias = Request("dias")
motivo = Request("motivo")
aprobacion = Request("aprobacion")

If usuarioSolic = "" Or licencia = "" Or desde = "" Or hasta = "" Or dias = "" Or aprobacion = "" Then
    Response.Write "{""ok"":false,""msg"":""Faltan parámetros""}"
    Response.End
End If

On Error Resume Next
Dim cmd
Set cmd = Server.CreateObject("ADODB.Command")
With cmd
    .ActiveConnection = conn
    .CommandText = "Aprobar_Rechazar_Licencia"
    .CommandType = 4
    .Parameters.Append .CreateParameter("@usuario_solicitante", 200, 1, 20, usuarioSolic)
    .Parameters.Append .CreateParameter("@licencia", 200, 1, 50, licencia)
    .Parameters.Append .CreateParameter("@desde", 7, 1, , desde)
    .Parameters.Append .CreateParameter("@hasta", 7, 1, , hasta)
    .Parameters.Append .CreateParameter("@DiasTotales", 3, 1, , CLng(dias))
    .Parameters.Append .CreateParameter("@Motivo", 200, 1, 500, motivo)
    .Parameters.Append .CreateParameter("@Aprobacion", 200, 1, 20, aprobacion)
    .Execute
End With

If Err.Number <> 0 Then
    Response.Write "{""ok"":false,""msg"":""Error al ejecutar SP: " & Replace(Err.Description, """", "'") & """}"
Else
    Response.Write "{""ok"":true,""msg"":""Licencia " & aprobacion & " correctamente""}"
End If

Set cmd = Nothing
If Not conn Is Nothing Then conn.Close
%>
