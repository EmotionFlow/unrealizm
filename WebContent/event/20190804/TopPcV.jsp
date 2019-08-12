<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - ポイピク星座占い</title>
		<style>
			.SettingListItem a {color: #fff; text-decoration: underline; font-weight: bold;}
			.SettingListItem a:hover {color: #5db;}
			.AnalogicoInfo {display: none;}
			.SettingList .SettingListItem .SettingListTitle {text-align: center; font-size: 20x; font-weight: bold; margin: 20px 0 0 0;}
			.SettingList .SettingListItem {margin: 0 0 20px 0;}
			<%if(!Util.isSmartPhone(request)){%>
			.Wrapper {
				width: 360px;
				min-height: 60px;
				position: relative;
			}
			.SettingList {
				max-width: 360px;
			}
			.SettingList .SettingListItem .SettingListTitle {font-size: 24px;}
			.SettingBody {font-size: 20px;}
			<%}%>
		</style>
		<script>
			$(function(){
				$('#MainImage').on('click', function(e){
					console.log(e.offsetX, e.offsetY);
				});
			})
		</script>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody">
					<img id="MainImage" style="width: 100%;" usemap="#MapLinks" src="/event/20190804/main.png" />
					<map name="MapLinks">
						<area shape="circle" coords="51, 738, 40" onclick="$('html, body').animate({scrollTop:1020});">
						<area shape="circle" coords="138, 738, 40" onclick="$('html, body').animate({scrollTop:1515});">
						<area shape="circle" coords="225, 738, 40" onclick="$('html, body').animate({scrollTop:2010});">
						<area shape="circle" coords="311, 738, 40" onclick="$('html, body').animate({scrollTop:2505});">
						<area shape="circle" coords="51, 825, 40" onclick="$('html, body').animate({scrollTop:3005});">
						<area shape="circle" coords="138, 825, 40" onclick="$('html, body').animate({scrollTop:3503});">
						<area shape="circle" coords="225, 825, 40" onclick="$('html, body').animate({scrollTop:4000});">
						<area shape="circle" coords="311, 825, 40" onclick="$('html, body').animate({scrollTop:4495});">
						<area shape="circle" coords="51, 912, 40" onclick="$('html, body').animate({scrollTop:4990});">
						<area shape="circle" coords="138, 912, 40" onclick="$('html, body').animate({scrollTop:5482});">
						<area shape="circle" coords="225, 912, 40" onclick="$('html, body').animate({scrollTop:5975});">
						<area shape="circle" coords="311, 912, 40" onclick="$('html, body').animate({scrollTop:6467});">

						<area shape="rect" coords="31, 6965, 330, 7015" onclick="$('html, body').animate({scrollTop:0});">
					</map>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>