<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - カラパレコスメ。</title>

		<style>
			.Wrapper {width: 990px;}
			.SettingBody {display: block; width: 100%; position: relative;}
			.MainImage {display: block; width: 100%;}
			.PalleteLinkList {display: flex; flex-flow: row nowrap; justify-content: space-between; box-sizing: border-box; width: 100%; padding: 0 187px 0 197px; position: absolute; top: 749px; z-index: 1;}
			.PalleteLinkItem {display: block; width: 179px; height: 179px;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%String searchType = "Contents";%>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingBody">
				<img class="MainImage" src="/event/20191001/karaparekosume_pc-5.png" />
				<div class="PalleteLinkList">
					<a class="PalleteLinkItem" href="/event/20191001/karapare_temple_3color-5.png"></a>
					<a class="PalleteLinkItem" href="/event/20191001/karapare_temple_4color-5.png"></a>
					<a class="PalleteLinkItem" href="/event/20191001/karapare_temple_5color-5.png"></a>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>