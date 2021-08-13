<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>ポチ袋</title>
		<style>
			body {
				background: #fff;
			}
			.SettingList .SettingListItem {
				display: block;
				float: left;
				width: 100%;
				box-sizing: border-box;
				margin: 0 0 10px 0;
				padding: 0 10px;
			}
			.SettingList .SettingListItem .SettingListTitle {
				display: block;
				float: left;
				width: 100%;
				box-sizing: border-box;
				margin: 5px 0;
			    font-size: 16px;
			}
			.SettingList .SettingListItem .SettingListTitle.Head {
				margin-top:20px;
				margin-bottom:10px;
				text-align: center;
			    font-size: 16px;
			}
			.SettingList .SettingListItem .SettingBody {
				text-align: left;
			}
			.SettingList .SettingListItem .SettingBody.Left {
				text-align: left;
			}
			img.PochiBukuro {
				margin-left: 80px;
			}
			img.PochiImg {
				width: 360px;
			}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuApp.jsp"%>
		<%@ include file="/inner/PochiS.jsp"%>
		<div style="display: block; float: left; width: 100%; height: 100px;"></div>
	</body>
</html>