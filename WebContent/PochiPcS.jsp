<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>ポチ袋</title>
		<style>
			<%if(bSmartPhone){%>
			body {background: #fff;}
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
			.SettingList .SettingListItem .SettingBody {text-align: left;}
			.SettingList .SettingListItem .SettingBody.Left {text-align: left;}
			img.PochiBukuro {margin-left: 80px;}
			img.PochiImg {width: 360px;}

			<%}else{%>
			body {background: #fff;}
			.AnalogicoInfo {display: none;}
			.EntryButtonArea{
				position: relative;
				height: 26px;
				width: 100%;
				float:left;
				margin: 20px 0px;
			}
			.Button {
				display: block;
				border: 1px solid #3498db;
				padding:5px;
				width: 200px;
				height: 26px;
				top: 0;
				bottom: 0;
				left: 0;
				right: 0;
				position: absolute;
				margin: auto;
				text-align: center;
				background-color: #fff;
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
				font-size: 28px;
				text-align: center;
			}
			.SettingList .SettingListItem .SettingListTitle.Head {
				margin-top:40px;
				margin-bottom:10px;
				font-size: 24px;
				text-align: left;
			}
			.SettingList .SettingListItem .SettingBody {font-size: 18px;text-align: left;}
			.SettingList .SettingListItem .SettingBody.Left {text-align: left;}
			img.PochiBukuro {margin-left: 200px;}
			img.PochiImg {width: 600px;}
			<%}%>
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%@ include file="/inner/PochiS.jsp"%>
		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>