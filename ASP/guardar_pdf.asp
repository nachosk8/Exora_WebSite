<%@ Language="VBScript" %>
<%
Option Explicit

Dim UploadDir, fso, objStream, FileName, path

' Carpeta destino (ya creada y con permisos correctos)
UploadDir = "C:\PRASP\Exora_WebSite\Uploads"

Set fso = Server.CreateObject("Scripting.FileSystemObject")
If Not fso.FolderExists(UploadDir) Then fso.CreateFolder(UploadDir)

On Error Resume Next

If Request.TotalBytes > 0 Then
    Dim binData
    binData = Request.BinaryRead(Request.TotalBytes)

    ' Generar nombre único con fecha/hora
    FileName = "archivo_" & Replace(Replace(Replace(Now, ":", "-"), " ", "_"), "/", "-") & ".pdf"
    path = UploadDir & "\" & FileName

    ' Guardar archivo
    Set objStream = Server.CreateObject("ADODB.Stream")
    objStream.Type = 1 ' Binary
    objStream.Open
    objStream.Write binData
    objStream.SaveToFile path, 2 ' 2 = overwrite
    objStream.Close
    Set objStream = Nothing

    If Err.Number <> 0 Then
        Response.Write "Error guardando archivo: " & Err.Description
    Else
        Response.Write "✅ Archivo guardado correctamente: " & FileName
    End If
Else
    Response.Write "No se recibió archivo."
End If

Set fso = Nothing
%>
