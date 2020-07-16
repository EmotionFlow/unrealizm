<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchIllustByTagC cResults = new SearchIllustByTagC();
cResults.getParam(request);
cResults.m_strKeyword = "お題ルーレット";
cResults.SELECT_MAX_GALLERY = 36;
boolean bRtn = cResults.getResults(cCheckLogin);
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Emoji.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - お題ルーレット</title>
		<script>
			var g_nPage = 1;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"PG" : g_nPage, "KWD" : decodeURIComponent("<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"), "MD" : <%=CCnv.MODE_PC%>},
					"dataType": "json",
					"url": "/f/SearchIllustByTagGridF.jsp",
					"success": function(data) {
						if(data.end_id>0) {
							g_nPage++;
							$("#IllustThumbList").append(data.html);
							$(".Waiting").remove();
							if(vg)vg.vgrefresh();
							g_bAdding = false;
							console.log(location.pathname+'/'+g_nPage+'.html');
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							$(window).unbind("scroll.addContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function UpdateFollow(nUserId, nFollowUserId) {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": nUserId, "IID": nFollowUserId },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('.UserInfoCmdFollow_'+nFollowUserId).addClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Following")%>");
						} else if(data.result==2) {
							$('.UserInfoCmdFollow_'+nFollowUserId).removeClass('Selected');
							$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Follow")%>");
						} else {
							DispMsg('フォローできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 600) {
						addContents();
					}
				});
			});
		</script>
		<style>
			.IllustItem .IllustItemCommand .IllustItemCommandSub .IllustItemCommandDelete {display: none;}
		</style>

		<script type="text/javascript" src="/js/jquery.easing.1.3.js"></script>
		<script type="text/javascript" src="/js/jquery.vgrid.min.js"></script>
		<script>
		//setup
		$(function() {
			vg = $("#IllustThumbList").vgrid({
				easing: "easeOutQuint",
				useLoadImageEvent: true,
				useFontSizeListener: true,
				time: 1,
				delay: 1,
				wait: 1,
				fadeIn: {
					time: 1,
					delay: 1
				},
				onStart: function(){
					$("#message1")
						.css("visibility", "visible")
						.fadeOut("slow",function(){
							$(this).show().css("visibility", "hidden");
						});
				},
				onFinish: function(){
					$("#message2")
						.css("visibility", "visible")
						.fadeOut("slow",function(){
							$(this).show().css("visibility", "hidden");
						});
				}
			});

			//$(window).load(function(e){
				$("#IllustThumbList").css('opacity', 1);
				//vg.vgrefresh();
			//});
		});
		</script>
		<style>
			.Wrapper {position: relative;}
			.SettingListItem a {color: #fff; text-decoration: underline; font-weight: bold;}
			.SettingListItem a:hover {color: #5db;}
			.AnalogicoInfo {display: none;}
			.SettingList .SettingListItem .SettingListTitle {text-align: center; font-size: 20x; font-weight: bold; margin: 20px 0 0 0;}
			.SettingList .SettingListItem {margin: 0 0 20px 0;}
			.SlotFrame {display: flex; flex-flow: row nowrap; justify-content:space-between; position: absolute; width: 338px; left: 12px; top: 1319px; z-index: 1;}
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
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody">
					<img id="MainImage" style="width: 100%;" usemap="#MapLinks" src="/event/20190803/odai_2.png" />
				</div>
				<div class="SlotFrame">
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r1" class="Roulette">
								<img src="/event/20190803/r1_03/01.png" />
								<img src="/event/20190803/r1_03/02.png" />
								<img src="/event/20190803/r1_03/03.png" />
								<img src="/event/20190803/r1_03/04.png" />
								<img src="/event/20190803/r1_03/05.png" />
								<img src="/event/20190803/r1_03/06.png" />
								<img src="/event/20190803/r1_03/07.png" />
								<img src="/event/20190803/r1_03/08.png" />
								<img src="/event/20190803/r1_03/09.png" />
								<img src="/event/20190803/r1_03/10.png" />
								<img src="/event/20190803/r1_03/11.png" />
								<img src="/event/20190803/r1_03/12.png" />
								<img src="/event/20190803/r1_03/13.png" />
								<img src="/event/20190803/r1_03/14.png" />
								<img src="/event/20190803/r1_03/15.png" />
								<img src="/event/20190803/r1_03/16.png" />
								<img src="/event/20190803/r1_03/17.png" />
								<img src="/event/20190803/r1_03/18.png" />
								<img src="/event/20190803/r1_03/19.png" />
								<img src="/event/20190803/r1_03/20.png" />
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r1').roulette('stop');"></div>
					</div>
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r2" class="Roulette">
								<img src="/event/20190803/r2_03/01.png" />
								<img src="/event/20190803/r2_03/02.png" />
								<img src="/event/20190803/r2_03/03.png" />
								<img src="/event/20190803/r2_03/04.png" />
								<img src="/event/20190803/r2_03/05.png" />
								<img src="/event/20190803/r2_03/06.png" />
								<img src="/event/20190803/r2_03/07.png" />
								<img src="/event/20190803/r2_03/08.png" />
								<img src="/event/20190803/r2_03/09.png" />
								<img src="/event/20190803/r2_03/10.png" />
								<img src="/event/20190803/r2_03/11.png" />
								<img src="/event/20190803/r2_03/12.png" />
								<img src="/event/20190803/r2_03/13.png" />
								<img src="/event/20190803/r2_03/14.png" />
								<img src="/event/20190803/r2_03/15.png" />
								<img src="/event/20190803/r2_03/16.png" />
								<img src="/event/20190803/r2_03/17.png" />
								<img src="/event/20190803/r2_03/18.png" />
								<img src="/event/20190803/r2_03/19.png" />
								<img src="/event/20190803/r2_03/20.png" />
								<img src="/event/20190803/r2_03/21.png" />
								<img src="/event/20190803/r2_03/22.png" />
								<img src="/event/20190803/r2_03/23.png" />
								<img src="/event/20190803/r2_03/24.png" />
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r2').roulette('stop');"></div>
					</div>
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r3" class="Roulette">
								<img src="/event/20190803/r3_03/01.png" />
								<img src="/event/20190803/r3_03/02.png" />
								<img src="/event/20190803/r3_03/03.png" />
								<img src="/event/20190803/r3_03/04.png" />
								<img src="/event/20190803/r3_03/05.png" />
								<img src="/event/20190803/r3_03/06.png" />
								<img src="/event/20190803/r3_03/07.png" />
								<img src="/event/20190803/r3_03/08.png" />
								<img src="/event/20190803/r3_03/09.png" />
								<img src="/event/20190803/r3_03/10.png" />
								<img src="/event/20190803/r3_03/11.png" />
								<img src="/event/20190803/r3_03/12.png" />
								<img src="/event/20190803/r3_03/13.png" />
								<img src="/event/20190803/r3_03/14.png" />
								<img src="/event/20190803/r3_03/15.png" />
								<img src="/event/20190803/r3_03/16.png" />
								<img src="/event/20190803/r3_03/17.png" />
								<img src="/event/20190803/r3_03/18.png" />
								<img src="/event/20190803/r3_03/19.png" />
								<img src="/event/20190803/r3_03/20.png" />
								<img src="/event/20190803/r3_03/21.png" />
								<img src="/event/20190803/r3_03/22.png" />
								<img src="/event/20190803/r3_03/23.png" />
								<img src="/event/20190803/r3_03/24.png" />
								<img src="/event/20190803/r3_03/25.png" />
								<img src="/event/20190803/r3_03/26.png" />
								<img src="/event/20190803/r3_03/27.png" />
								<img src="/event/20190803/r3_03/28.png" />
								<img src="/event/20190803/r3_03/29.png" />
								<img src="/event/20190803/r3_03/30.png" />
								<img src="/event/20190803/r3_03/31.png" />
								<img src="/event/20190803/r3_03/32.png" />
								<img src="/event/20190803/r3_03/33.png" />
								<img src="/event/20190803/r3_03/34.png" />
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

		<article class="Wrapper GridList">
			<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px; float: none;">
				<h2 class="Keyword">#<%=Common.ToStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!cCheckLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.m_bFollowing) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_TAG%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_TAG%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%if(nCnt==1) {%>
					<%@ include file="/inner/TAdPc336x280_right_top.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>