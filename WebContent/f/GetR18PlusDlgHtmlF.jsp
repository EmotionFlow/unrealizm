<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<style>
    .R18PlusIntroDlgTitle{padding: 10px 0 0 0; color: #3498db;}
    .R18PlusIntroDlgInfo{font-size: 13px; text-align: left;}
    .R18PlusIntroDlgInfo ul {padding-inline-start: 25px;}
    .R18PlusIntroDlgInfo ul > li {margin-top: 2px;}
    .swal2-popup .swal2-footer {font-size: 0.75em;}
    .swal2-popup .swal2-actions {margin-top: 0}
</style>
<div class="R18PlusIntroDlg">
	<h2 class="R18PlusIntroDlgTitle"><%=_TEX.T("R18Plus.Dlg.Title")%></h2>
	<div class="R18PlusIntroDlgInfo" style="margin-top: 11px;">
		<p style="text-align:center; font-weight: normal; font-size:17px; color: #3498db;"><%=_TEX.T("R18Plus.Dlg.Description")%></p>
	</div>
	<div class="R18PlusIntroDlgInfo">
		<p><%=_TEX.T("R18Plus.Dlg.List02")%></p>
		<p><%=_TEX.T("R18Plus.Dlg.List01")%></p>
	</div>
	<hr style="border: 1px solid lightgray;">
	<div class="R18PlusIntroDlgInfo" style="font-size: 11px">
		<ul>
			<li><%=_TEX.T("R18Plus.Dlg.List03")%></li>
			<li><%=_TEX.T("R18Plus.Dlg.List04")%></li>
		</ul>
	</div>
</div>
