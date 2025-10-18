<%@ Language="VBScript" %>
<%
Option Explicit

' ----------------------------
' Conexión (pegada directamente)
' ----------------------------
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")

' Capturamos errores para mostrar si falla la conexión
On Error Resume Next
conn.Open "Provider=SQLOLEDB;" & _
          "Data Source=DESKTOP-OOTIKMN\SQLEXPRESS;" & _
          "Initial Catalog=Exora;" & _
          "User ID=miAspUser;" & _
          "Password=2002;" & _
          "Encrypt=False;TrustServerCertificate=True;"

If Err.Number <> 0 Then
    Response.Write "❌ Error de conexión: " & Err.Description
    ' Limpiamos y terminamos
    Err.Clear
    Set conn = Nothing
    Response.End
End If
On Error GoTo 0

' ----------------------------
' Variables y carpeta de guardado
' ----------------------------
Dim UploadDir, fso, objStream, FileName, path, cmd
UploadDir = "C:\PRASP\Exora_WebSite\Uploads"

Set fso = Server.CreateObject("Scripting.FileSystemObject")
If Not fso.FolderExists(UploadDir) Then
    On Error Resume Next
    fso.CreateFolder(UploadDir)
    If Err.Number <> 0 Then
        Response.Write "❌ No se pudo crear carpeta: " & Err.Description
        Err.Clear
        conn.Close
        Set conn = Nothing
        Set fso = Nothing
        Response.End
    End If
    On Error GoTo 0
End If

' ----------------------------
' Recibo y guardo el archivo
' ----------------------------
If Request.TotalBytes > 0 Then
    Dim binData
    binData = Request.BinaryRead(Request.TotalBytes)

    ' Generar nombre único
    FileName = "archivo_" & Replace(Replace(Replace(Now(), ":", "-"), " ", "_"), "/", "-") & ".pdf"
    path = UploadDir & "\" & FileName

    ' Guardar archivo binario
    On Error Resume Next
    Set objStream = Server.CreateObject("ADODB.Stream")
    objStream.Type = 1 ' binary
    objStream.Open
    objStream.Write binData
    objStream.SaveToFile path, 2 ' 2 = overwrite
    objStream.Close
    Set objStream = Nothing

    If Err.Number <> 0 Then
        Response.Write "❌ Error guardando archivo: " & Err.Description
        Err.Clear
        ' cerramos recursos
        conn.Close
        Set conn = Nothing
        Set fso = Nothing
        Response.End
    Else
        Response.Write "✅ Archivo guardado correctamente: " & FileName & "<br>"
    End If
    On Error GoTo 0

    ' ----------------------------
    ' Llamada al stored procedure
    ' ----------------------------
    On Error Resume Next
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandType = 4 ' adCmdStoredProc
    cmd.CommandText = "Carga_Firma_Archivos"

    ' Parámetros hardcodeados por ahora (luego sustituir por Session / Request.Form)
    cmd.Parameters.Append cmd.CreateParameter("@remitente", 200, 1, 20, "juanperez")    ' adVarChar = 200
    cmd.Parameters.Append cmd.CreateParameter("@destinatario", 200, 1, 20, "marcos")
    cmd.Parameters.Append cmd.CreateParameter("@path", 200, 1, 50, FileName)
    cmd.Parameters.Append cmd.CreateParameter("@firma", 200, 1, 1, "N")

    cmd.Execute

    If Err.Number <> 0 Then
        Response.Write "⚠️ Error ejecutando SP: " & Err.Description & "<br>"
        Err.Clear
    Else
        Response.Write "📦 Registro insertado correctamente en la base de datos.<br>"
    End If
    On Error GoTo 0

    ' Liberar cmd
    If Not cmd Is Nothing Then
        Set cmd = Nothing
    End If

Else
    Response.Write "⚠️ No se recibió archivo."
End If

' ----------------------------
' Limpieza final
' ----------------------------
If Not conn Is Nothing Then
    On Error Resume Next
    conn.Close
    Set conn = Nothing
    On Error GoTo 0
End If

Set fso = Nothing
%>
