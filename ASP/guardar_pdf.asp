<%@ Language="VBScript" %>
<%
Option Explicit
Dim conn
Set conn = Server.CreateObject("ADODB.Connection")


On Error Resume Next
conn.Open "Provider=SQLOLEDB;" & _
          "Data Source=DESKTOP-OOTIKMN\SQLEXPRESS;" & _
          "Initial Catalog=Exora;" & _
          "User ID=miAspUser;" & _
          "Password=2002;" & _
          "Encrypt=False;TrustServerCertificate=True;"

If Err.Number <> 0 Then
    Response.Write "❌ Error de conexión: " & Err.Description

    Err.Clear
    Set conn = Nothing
    Response.End
End If
On Error GoTo 0

Dim UploadDir, fso, objStream, FileName, path, cmd, usuarioPrincipal, usuarioDestino, Firmar
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
If Request.TotalBytes > 0 Then
    Dim binData
    binData = Request.BinaryRead(Request.TotalBytes)


    Firmar = "S"
    usuarioDestino = Session("destinatario")
    usuarioPrincipal = Session("usuario")
    FileName = session("file_name")

    if FileName = "" then
        Firmar = "N"
        FileName = "archivo_"&usuarioPrincipal&"_" & Replace(Replace(Replace(Now(), ":", "-"), " ", "_"), "/", "-") & ".pdf"
    else 
        FileName = "FIRMADO_" + FileName 
    end if 
    path = UploadDir & "\" & FileName


    On Error Resume Next
    Set objStream = Server.CreateObject("ADODB.Stream")
    objStream.Type = 1 
    objStream.Open
    objStream.Write binData
    objStream.SaveToFile path, 2 
    objStream.Close
    Set objStream = Nothing

    If Err.Number <> 0 Then
        Response.Write "❌ Error guardando archivo: " & Err.Description
        Err.Clear
        
        conn.Close
        Set conn = Nothing
        Set fso = Nothing
        Response.End
    Else
        Response.Write "✅ Archivo guardado correctamente: " & FileName & "<br>"
    End If
    On Error GoTo 0

    On Error Resume Next
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandType = 4 
    cmd.CommandText = "Carga_Firma_Archivos"


    
    cmd.Parameters.Append cmd.CreateParameter("@remitente", 200, 1, 20, usuarioPrincipal)    ' adVarChar = 200
    cmd.Parameters.Append cmd.CreateParameter("@destinatario", 200, 1, 20, usuarioDestino)
    cmd.Parameters.Append cmd.CreateParameter("@path", 200, 1, 50, FileName)
    cmd.Parameters.Append cmd.CreateParameter("@firma", 200, 1, 1, Firmar)

    cmd.Execute

    
    
    Err.Clear

    On Error GoTo 0

    ' Liberar cmd
    If Not cmd Is Nothing Then
        Set cmd = Nothing
    End If

Else
    Response.Write "⚠️ No se recibió archivo."
End If

If Not conn Is Nothing Then
    On Error Resume Next
    conn.Close
    Set conn = Nothing
    On Error GoTo 0
End If

Set fso = Nothing
%>
