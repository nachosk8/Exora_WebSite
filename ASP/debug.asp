<%
sub verRs(rs)
       
        response.Write "<table width='450' border='0' cellspacing='1' cellpadding='0' bgcolor='silver'><tr><td>"
        response.Write "<div style=""width:100%;height:400px;overflow-y:scroll;""><table width='100%' cellspacing='1' cellpadding='2'>"
    color = "E9F2E1"
    cont = 0
    while not rs.EOF
        if cont = 0 then
            response.Write "<tr><td style='font-family:verdana;font-size:8pt;' colspan='100%' align='center' bgcolor='#ABC09B'>Registros : "& rs.recordcount &" Campos x Registro : " & rs.fields.count & "</td></tr>"
        end if
        response.Write "<tr><td style='font-family:Small Fonts;font-size:7pt;height:10px;' bgcolor='#E1E395' colspan='100%'>Registro Nro " & cont + 1 & "</td></tr>"
        response.Write "<tr><td style='font-family:Small Fonts;font-size:7pt;' align='center' bgcolor='#C4E3AC'>N</td><td style='font-family:Small Fonts;font-size:7pt;' align='center' bgcolor='#B8D99E'>Nombre Campo</td><td style='font-family:Small Fonts;font-size:7pt;' align='center' bgcolor='#C4E3AC'>Valor</td></tr>"
       
        for i=0 to rs.fields.count - 1
        if color="E9F2E1" then
            color = "EEF2EB"
        else
            color="E9F2E1"
        end if
       
        Response.Write "<tr style='font-family:verdana;font-size:8pt;' bgcolor='" & color & "'>"
            if isnull(rs.fields(i).value) then
                Response.Write "<td>" & i + 1 & "</td><td>" & rs.fields(i).name & "</td><td style='color:#FF0000;font-weight:bold;'>&lt;NULL&gt;</td>"
            else
                Response.Write "<td>" & i + 1 & "</td><td>" & rs.fields(i).name & "</td><td>" & rs.fields(i).value & "</td>"
            end if
        Response.Write "</tr>"
        next
        cont = cont + 1
    rs.movenext
    wend
    response.Write "</table></div>"
    response.Write "</td></tr></table>"
   
    Response.End
end sub
%>