<%
Response.Expires = -1
Response.ContentType = "text/plain"

Dim userSel
userSel = Request("user")

If Len(Trim(userSel)) > 0 Then
    Session("destinatario") = userSel
    Response.Write "OK - guardado en Session: " & Session("destinatario")
Else
    Response.Write "ERROR - valor vacío"
End If
%>
