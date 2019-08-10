<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - お題ルーレット</title>
		<style>
			.Wrapper {position: relative;}
			.SettingListItem a {color: #fff; text-decoration: underline; font-weight: bold;}
			.SettingListItem a:hover {color: #5db;}
			.AnalogicoInfo {display: none;}
			.SettingList .SettingListItem .SettingListTitle {text-align: center; font-size: 20x; font-weight: bold; margin: 20px 0 0 0;}
			.SettingList .SettingListItem {margin: 0 0 20px 0;}
			.SlotFrame {display: flex; flex-flow: row nowrap; justify-content:space-between; position: absolute; width: 330px; left: 15px; top: 1318px; }
			.SlotFrame .SlotItem {display: flex; flex-flow: column; align-items: center;}
			.SlotItem .RouletteFrame {}
			.SlotItem .RouletteFrame .Roulette {display: none; width: 100px; background-color: #fff; border-radius: 25px; overflow: hidden;}
			.SlotItem .RouletteFrame .Roulette img {display: block; width: 100px;}
			.SlotItem .StopBtn {display: block; width: 50px; height: 50px; margin: 10px 0 0 0; background-image: url('/event/20190803/button.png'); background-size: contain;}
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
		<script type="text/javascript" src="/event/20190803/js/roulette.min.js"></script>
		<script>
			$(function() {
				var option = {
					speed : 10,
					duration : 100
				}
				$('#r1').roulette(option);
				$('#r2').roulette(option);
				$('#r3').roulette(option);
				$('#r1').roulette('start');
				$('#r2').roulette('start');
				$('#r3').roulette('start');
			});
		</script>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody">
					<img id="MainImage" style="width: 100%;" usemap="#MapLinks" src="/event/20190803/main.png" />
				</div>
				<div class="SlotFrame">
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r1" class="Roulette">
								<img src="/event/20190803/r1/r1-01.png" />
								<img src="/event/20190803/r1/r1-02.png" />
								<img src="/event/20190803/r1/r1-03.png" />
								<img src="/event/20190803/r1/r1-04.png" />
								<img src="/event/20190803/r1/r1-05.png" />
								<img src="/event/20190803/r1/r1-06.png" />
								<img src="/event/20190803/r1/r1-07.png" />
								<img src="/event/20190803/r1/r1-08.png" />
								<img src="/event/20190803/r1/r1-09.png" />
								<img src="/event/20190803/r1/r1-10.png" />
								<img src="/event/20190803/r1/r1-11.png" />
								<img src="/event/20190803/r1/r1-12.png" />
								<img src="/event/20190803/r1/r1-13.png" />
								<img src="/event/20190803/r1/r1-14.png" />
								<img src="/event/20190803/r1/r1-15.png" />
								<img src="/event/20190803/r1/r1-16.png" />
								<img src="/event/20190803/r1/r1-17.png" />
								<img src="/event/20190803/r1/r1-18.png" />
								<img src="/event/20190803/r1/r1-19.png" />
								<img src="/event/20190803/r1/r1-20.png" />
								<img src="/event/20190803/r1/r1-21.png" />
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r1').roulette('stop');"></div>
					</div>
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r2" class="Roulette">
								<img src="/event/20190803/r2/r2-01.png" />
								<img src="/event/20190803/r2/r2-02.png" />
								<img src="/event/20190803/r2/r2-03.png" />
								<img src="/event/20190803/r2/r2-04.png" />
								<img src="/event/20190803/r2/r2-05.png" />
								<img src="/event/20190803/r2/r2-06.png" />
								<img src="/event/20190803/r2/r2-07.png" />
								<img src="/event/20190803/r2/r2-08.png" />
								<img src="/event/20190803/r2/r2-09.png" />
								<img src="/event/20190803/r2/r2-10.png" />
								<img src="/event/20190803/r2/r2-11.png" />
								<img src="/event/20190803/r2/r2-12.png" />
								<img src="/event/20190803/r2/r2-13.png" />
								<img src="/event/20190803/r2/r2-14.png" />
								<img src="/event/20190803/r2/r2-15.png" />
								<img src="/event/20190803/r2/r2-16.png" />
								<img src="/event/20190803/r2/r2-17.png" />
								<img src="/event/20190803/r2/r2-18.png" />
								<img src="/event/20190803/r2/r2-19.png" />
								<img src="/event/20190803/r2/r2-20.png" />
								<img src="/event/20190803/r2/r2-21.png" />
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r2').roulette('stop');"></div>
					</div>
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r3" class="Roulette">
								<img src="/event/20190803/r3/r3-01.png" />
								<img src="/event/20190803/r3/r3-02.png" />
								<img src="/event/20190803/r3/r3-03.png" />
								<img src="/event/20190803/r3/r3-04.png" />
								<img src="/event/20190803/r3/r3-05.png" />
								<img src="/event/20190803/r3/r3-06.png" />
								<img src="/event/20190803/r3/r3-07.png" />
								<img src="/event/20190803/r3/r3-08.png" />
								<img src="/event/20190803/r3/r3-09.png" />
								<img src="/event/20190803/r3/r3-10.png" />
								<img src="/event/20190803/r3/r3-11.png" />
								<img src="/event/20190803/r3/r3-12.png" />
								<img src="/event/20190803/r3/r3-13.png" />
								<img src="/event/20190803/r3/r3-14.png" />
								<img src="/event/20190803/r3/r3-15.png" />
								<img src="/event/20190803/r3/r3-16.png" />
								<img src="/event/20190803/r3/r3-17.png" />
								<img src="/event/20190803/r3/r3-18.png" />
								<img src="/event/20190803/r3/r3-19.png" />
								<img src="/event/20190803/r3/r3-20.png" />
								<img src="/event/20190803/r3/r3-21.png" />
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r3').roulette('stop');"></div>
					</div>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>