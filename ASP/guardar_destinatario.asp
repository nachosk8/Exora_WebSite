<%
Response.Expires = -1
Response.ContentType = "text/plain"

Dim userSel, fileSel
userSel = Request("user")
fileSel = Request("file")

' Si llega el usuario destinatario, lo guardamos en Session
If Len(Trim(userSel)) > 0 Then
    Session("destinatario") = userSel
    Session("file_name") = "" 
    Response.Write "OK - destinatario guardado en Session: " & Session("destinatario")

' Si llega el nombre del archivo (path o nombre)
ElseIf Len(Trim(fileSel)) > 0 Then
    Session("file_name") = fileSel
    Response.Write "OK - file_name guardado en Session: " & Session("file_name")

' Si no llega ninguno, devolvemos error
Else
    Response.Write "ERROR - valor vacío"
End If
%>
