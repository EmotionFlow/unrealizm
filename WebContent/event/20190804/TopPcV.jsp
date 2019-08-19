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
					<img id="MainImage" style="width: 100%;" usemap="#MapLinks" src="/event/20190804/seiza_20190819.png" />
					<map name="MapLinks">
						<area shape="circle" coords="51, 738, 40" onclick="$('html, body').animate({scrollTop:1020});">
						<area shape="circle" coords="138, 738, 40" onclick="$('html, body').animate({scrollTop:1560});">
						<area shape="circle" coords="225, 738, 40" onclick="$('html, body').animate({scrollTop:2100});">
						<area shape="circle" coords="311, 738, 40" onclick="$('html, body').animate({scrollTop:2640});">
						<area shape="circle" coords="51, 825, 40" onclick="$('html, body').animate({scrollTop:3180});">
						<area shape="circle" coords="138, 825, 40" onclick="$('html, body').animate({scrollTop:3718});">
						<area shape="circle" coords="225, 825, 40" onclick="$('html, body').animate({scrollTop:4255});">
						<area shape="circle" coords="311, 825, 40" onclick="$('html, body').animate({scrollTop:4795});">
						<area shape="circle" coords="51, 912, 40" onclick="$('html, body').animate({scrollTop:5335});">
						<area shape="circle" coords="138, 912, 40" onclick="$('html, body').animate({scrollTop:5872});">
						<area shape="circle" coords="225, 912, 40" onclick="$('html, body').animate({scrollTop:6410});">
						<area shape="circle" coords="311, 912, 40" onclick="$('html, body').animate({scrollTop:6950});">

						<area shape="rect" coords="10, 1500, 350, 1547" href="/event/20190804/pallete_20190819/pallete_ohithuji.png">
						<area shape="rect" coords="10, 2040, 350, 2087" href="/event/20190804/pallete_20190819/pallete_oushi.png">
						<area shape="rect" coords="10, 2580, 350, 2627" href="/event/20190804/pallete_20190819/pallete_futago.png">
						<area shape="rect" coords="10, 3120, 350, 3167" href="/event/20190804/pallete_20190819/pallete_kani.png">
						<area shape="rect" coords="10, 3660, 350, 3707" href="/event/20190804/pallete_20190819/pallete_shishi.png">
						<area shape="rect" coords="10, 4198, 350, 4245" href="/event/20190804/pallete_20190819/pallete_otome.png">
						<area shape="rect" coords="10, 4737, 350, 4784" href="/event/20190804/pallete_20190819/pallete_tenbin.png">
						<area shape="rect" coords="10, 5276, 350, 5323" href="/event/20190804/pallete_20190819/pallete_sasori.png">
						<area shape="rect" coords="10, 5815, 350, 5862" href="/event/20190804/pallete_20190819/pallete_ite.png">
						<area shape="rect" coords="10, 6353, 350, 6400" href="/event/20190804/pallete_20190819/pallete_yagi.png">
						<area shape="rect" coords="10, 6890, 350, 6937" href="/event/20190804/pallete_20190819/pallete_mizugame.png">
						<area shape="rect" coords="10, 7430, 350, 7475" href="/event/20190804/pallete_20190819/pallete_uo.png">


						<area shape="rect" coords="31, 7500, 330, 7550" onclick="$('html, body').animate({scrollTop:0});">
					</map>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>