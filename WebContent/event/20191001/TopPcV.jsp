<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/event/20191001/TopGridPcV.jsp").forward(request,response);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - カラパレコスメ。</title>

		<style>
			.SettingBody {display: block; width: 100%; position: relative;}
			.Mainmage {display: block; width: 100%;}
			.LinkList {display: flex; flex-flow: row nowrap; justify-content: space-between; box-sizing: border-box; width: 100%; padding: 0 53px 0 53px; position: absolute; top: 292px; z-index: 1;}
			.LinkItem {display: block; width: 76px; height: 76px;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="Mainmage" src="/event/20191001/karaparekosume_sumaho_2.png" />
				<div class="LinkList">
					<a class="LinkItem" href="/event/20191001/karapare_temple_3color_2.png"></a>
					<a class="LinkItem" href="/event/20191001/karapare_temple_4color_2.png"></a>
					<a class="LinkItem" href="/event/20191001/karapare_temple_5color_2.png"></a>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>