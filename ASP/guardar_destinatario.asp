<%
Response.Expires = -1
Response.ContentType = "text/plain"

Dim userSel, fileSel
userSel = Request("user")
fileSel = Request("file")


If Len(Trim(userSel)) > 0 Then
    Session("destinatario") = userSel
    Session("file_name") = "" 
    Response.Write "OK - destinatario guardado en Session: " & Session("destinatario")


ElseIf Len(Trim(fileSel)) > 0 Then
    Session("file_name") = fileSel
    Response.Write "OK - file_name guardado en Session: " & Session("file_name")


Else
    Response.Write "ERROR - valor vacío"
End If
%>
