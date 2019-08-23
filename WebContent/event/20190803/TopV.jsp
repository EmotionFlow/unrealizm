<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - お題ルーレット</title>
		<style>
			.Wrapper {position: relative;}
			.SettingListItem a {color: #fff; text-decoration: underline; font-weight: bold;}
			.SettingListItem a:hover {color: #5db;}
			.AnalogicoInfo {display: none;}
			.SettingList .SettingListItem .SettingListTitle {text-align: center; font-size: 20x; font-weight: bold; margin: 20px 0 0 0;}
			.SettingList .SettingListItem {margin: 0 0 20px 0;}
			.SlotFrame {display: flex; flex-flow: row nowrap; justify-content:space-between; position: absolute; width: 338px; left: 12px; top: 1319px; }
			.SlotFrame .SlotItem {display: flex; flex-flow: column; align-items: center;}
			.SlotItem .RouletteFrame {}
			.SlotItem .RouletteFrame .Roulette {display: none; width: 107px; background-color: #fff; border-radius: 10px; overflow: hidden;}
			.SlotItem .RouletteFrame .Roulette img {display: block; width: 107px;}
			.SlotItem .StopBtn {display: block; width: 60px; height: 60px; margin: 10px 0 0 0; background-image: url('/event/20190803/button.png'); background-size: contain; cursor: pointer;}
			.SlotCmdFrame {display: flex; flex-flow: column; align-items: center;  position: absolute; width: 340px; left: 10px; top: 1587px; z-index: 1;}
			.SlotCmdFrame .SlotCmdBtnDownload {display: block; width: 340px; height: 66px; cursor: pointer;}
			.SlotCmdFrame .SlotCmdBtnStart {display: block; width: 170px; height: 66px; margin-top: 29px; cursor: pointer;}
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
		<script type="text/javascript" src="/event/20190803/js/roulette_02.js"></script>
		<script>
			$(function() {
				var option = {
					speed : 10,
					duration : 100,
					stopImageNumber : -1,
				}
				$('#r1').roulette(option);
				$('#r2').roulette(option);
				$('#r3').roulette(option);
				StartRoulette();
			});
			function StartRoulette() {
				$('#r1').roulette('start');
				$('#r2').roulette('start');
				$('#r3').roulette('start');
			}
			function DownloadRouletteFile() {
				$('#r1').roulette('stop');
				$('#r2').roulette('stop');
				$('#r3').roulette('stop');
				var option = {stopImageNumber : -1};
				$('#r1').roulette('get_pos', option);
				var r1 = option.stopImageNumber+1;
				$('#r2').roulette('get_pos', option);
				var r2 = option.stopImageNumber+1;
				$('#r3').roulette('get_pos', option);
				var r3 = option.stopImageNumber+1;
				location.href = "/DownloadRouletteFile?R1="+r1+"&R2="+r2+"&R3="+r3;
			}
		</script>
	</head>
	<body>
		<div id="DispMsg"></div>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody">
					<img id="MainImage" style="width: 100%;" usemap="#MapLinks" src="/event/20190803/odai_2.png" />
				</div>
				<div class="SlotFrame">
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r1" class="Roulette">
								<img src="/event/20190803/r1/01.png" />
								<img src="/event/20190803/r1/02.png" />
								<img src="/event/20190803/r1/03.png" />
								<img src="/event/20190803/r1/04.png" />
								<img src="/event/20190803/r1/05.png" />
								<img src="/event/20190803/r1/06.png" />
								<img src="/event/20190803/r1/07.png" />
								<img src="/event/20190803/r1/08.png" />
								<img src="/event/20190803/r1/09.png" />
								<img src="/event/20190803/r1/10.png" />
								<img src="/event/20190803/r1/11.png" />
								<img src="/event/20190803/r1/12.png" />
								<img src="/event/20190803/r1/13.png" />
								<img src="/event/20190803/r1/14.png" />
								<img src="/event/20190803/r1/15.png" />
								<img src="/event/20190803/r1/16.png" />
								<img src="/event/20190803/r1/17.png" />
								<img src="/event/20190803/r1/18.png" />
								<img src="/event/20190803/r1/19.png" />
								<img src="/event/20190803/r1/20.png" />
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r1').roulette('stop');"></div>
					</div>
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r2" class="Roulette">
								<img src="/event/20190803/r2/01.png" />
								<img src="/event/20190803/r2/02.png" />
								<img src="/event/20190803/r2/03.png" />
								<img src="/event/20190803/r2/04.png" />
								<img src="/event/20190803/r2/05.png" />
								<img src="/event/20190803/r2/06.png" />
								<img src="/event/20190803/r2/07.png" />
								<img src="/event/20190803/r2/08.png" />
								<img src="/event/20190803/r2/09.png" />
								<img src="/event/20190803/r2/10.png" />
								<img src="/event/20190803/r2/11.png" />
								<img src="/event/20190803/r2/12.png" />
								<img src="/event/20190803/r2/13.png" />
								<img src="/event/20190803/r2/14.png" />
								<img src="/event/20190803/r2/15.png" />
								<img src="/event/20190803/r2/16.png" />
								<img src="/event/20190803/r2/17.png" />
								<img src="/event/20190803/r2/18.png" />
								<img src="/event/20190803/r2/19.png" />
								<img src="/event/20190803/r2/20.png" />
								<img src="/event/20190803/r2/21.png" />
								<img src="/event/20190803/r2/22.png" />
								<img src="/event/20190803/r2/23.png" />
								<img src="/event/20190803/r2/24.png" />
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r2').roulette('stop');"></div>
					</div>
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r3" class="Roulette">
								<img src="/event/20190803/r3/01.png" />
								<img src="/event/20190803/r3/02.png" />
								<img src="/event/20190803/r3/03.png" />
								<img src="/event/20190803/r3/04.png" />
								<img src="/event/20190803/r3/05.png" />
								<img src="/event/20190803/r3/06.png" />
								<img src="/event/20190803/r3/07.png" />
								<img src="/event/20190803/r3/08.png" />
								<img src="/event/20190803/r3/09.png" />
								<img src="/event/20190803/r3/10.png" />
								<img src="/event/20190803/r3/11.png" />
								<img src="/event/20190803/r3/12.png" />
								<img src="/event/20190803/r3/13.png" />
								<img src="/event/20190803/r3/14.png" />
								<img src="/event/20190803/r3/15.png" />
								<img src="/event/20190803/r3/16.png" />
								<img src="/event/20190803/r3/17.png" />
								<img src="/event/20190803/r3/18.png" />
								<img src="/event/20190803/r3/19.png" />
								<img src="/event/20190803/r3/20.png" />
								<img src="/event/20190803/r3/21.png" />
								<img src="/event/20190803/r3/22.png" />
								<img src="/event/20190803/r3/23.png" />
								<img src="/event/20190803/r3/24.png" />
								<img src="/event/20190803/r3/25.png" />
								<img src="/event/20190803/r3/26.png" />
								<img src="/event/20190803/r3/27.png" />
								<img src="/event/20190803/r3/28.png" />
								<img src="/event/20190803/r3/29.png" />
								<img src="/event/20190803/r3/30.png" />
								<img src="/event/20190803/r3/31.png" />
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r3').roulette('stop');"></div>
					</div>
				</div>
				<div class="SlotCmdFrame">
					<div class="SlotCmdBtnDownload" onclick="DownloadRouletteFile()"></div>
					<div class="SlotCmdBtnStart" onclick="StartRoulette()"></div>
				</div>
			</div>
		</article>
	</body>
</html>