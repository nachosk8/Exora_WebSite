<%
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
    Response.Write "Error de conexion: " & Err.Description
    Response.End
End If
%>
