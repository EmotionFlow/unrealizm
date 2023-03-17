<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
function _getRequestIntroductionHtml(){
	return `
<style>
	.RequestIntroDlg a {color: #545454; text-decoration: underline;}
	.RequestIntroDlgTitle{padding: 10px 0 0 0;}
	.RequestIntroDlgInfo{font-size: 13px; text-align: left;}
	.RequestIntroDlgInfo ul {padding-inline-start: 25px;}
	.RequestIntroDlgInfo ol {padding-inline-start: 25px;}
</style>
<div class="RequestIntroDlg">

<h2 class="RequestIntroDlgTitle"><%=_TEX.T("TRequestIntroduction.Intro")%></h2>
<div class="RequestIntroDlgInfo" style="margin-top: 11px;">
	<p style="text-align: center; color:#ff6b00"><i class="fas fa-bullhorn"></i><br> <%=_TEX.T("TRequestIntroduction.Intro01")%><br><%=_TEX.T("TRequestIntroduction.Intro02")%></p>
	<p><%=_TEX.T("TRequestIntroduction.Intro03")%></p>
</div>
<h2 class="RequestIntroDlgTitle"><%=_TEX.T("TRequestIntroduction.Features")%></h2>
<div class="RequestIntroDlgInfo">
<ul style="font-weight:400; color:#707070">
	<li><%=_TEX.T("TRequestIntroduction.Features01")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Features02")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Features03")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Features04")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Features05")%></li>
</ul>
</div>
<h2 class="RequestIntroDlgTitle"><%=_TEX.T("TRequestIntroduction.Flow")%></h2>
<div class="RequestIntroDlgInfo">
<ol>
	<li><%=_TEX.T("TRequestIntroduction.Flow01")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Flow02")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Flow03")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Flow04")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Flow05")%></li>
	<li><%=_TEX.T("TRequestIntroduction.Flow06")%></li>
</ol>
</div>

<%if(g_isApp){%>
<div class="RequestIntroDlgInfo" style="text-align: center;margin-top: 20px; padding: 2px;border: solid 2px;border-radius: 4px;">
<%=_TEX.T("TRequestIntroduction.Setup01")%>
</div>
<%}else{%>
<div class="RequestIntroDlgTitle" style="color: #ff6b00; text-align: center;">
<a style="color: #ff6b00;" href="/MyEditSettingPcV.jsp?MENUID=REQUEST"><%=_TEX.T("TRequestIntroduction.Setup02")%></a>
</div>
<%}%>

<div class="RequestIntroDlgInfo" style="margin-top: 22px; text-align: center;">
<a style="text-decoration: none;" href="/GuideLineRequestV.jsp"><%=_TEX.T("TRequestIntroduction.Setup03")%></a>
</div>

</div>
`;
}

function dispRequestIntroduction(){
	Swal.fire({
		html: _getRequestIntroductionHtml(),
		focusConfirm: false,
		showConfirmButton: false,
		showCloseButton: true,
	})
}
</script>
