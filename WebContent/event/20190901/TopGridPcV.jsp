<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchIllustByTagGridC cResults = new SearchIllustByTagGridC();
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
			.SettingBody.Roulette {background: top center url('/event/20190901/odai_odai.png') no-repeat; background-size: 600px; height: 3058px;}
			.SlotFrame {display: flex; flex-flow: row nowrap; justify-content:space-between; position: absolute; width: 560px; left: 20px; top: 2138px; z-index: 1;}
			.SlotFrame .SlotItem {display: flex; flex-flow: column; align-items: center;}
			.SlotItem .RouletteFrame {}
			.SlotItem .RouletteFrame .Roulette {display: none; width: 272px; background-color: #fff; border-radius: 10px; overflow: hidden;}
			.SlotItem .RouletteFrame .Roulette img {display: block; width: 272px; height: 276px;}
			.SlotItem .StopBtn {display: block; width: 100px; height: 100px; margin: 27px 0 0 0; cursor: pointer;}
			.SlotCmdFrame {display: flex; flex-flow: column; align-items: center;  position: absolute; width: 570px; left: 15px; top: 2610px; z-index: 1;}
			.SlotCmdFrame .SlotCmdBtnDownload {display: block; width: 570px; height: 110px; cursor: pointer;}
			.SlotCmdFrame .SlotCmdBtnStart {display: block; width: 280px; height: 110px; margin-top: 25px; cursor: pointer;}
		</style>
		<script type="text/javascript" src="/event/20190901/js/roulette_02.js"></script>
		<script>
			$(function() {
				var option = {
					speed : 20,
					duration : 100,
					stopImageNumber : -1,
				}
				$('#r1').roulette(option);
				$('#r2').roulette(option);
				StartRoulette();
			});
			function StartRoulette() {
				$('#r1').roulette('start');
				$('#r2').roulette('start');
			}
			function DownloadRouletteFile() {
				$('#r1').roulette('stop');
				$('#r2').roulette('stop');
				var option = {stopImageNumber : -1};
				$('#r1').roulette('get_pos', option);
				var r1 = option.stopImageNumber+1;
				$('#r2').roulette('get_pos', option);
				var r2 = option.stopImageNumber+1;
				location.href = "/DownloadRouletteFile02?R1="+r1+"&R2="+r2;
			}
		</script>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody">
					<img id="MainImage" style="width: 100%;" usemap="#MapLinks" src="/event/20190901/odai_odai.png" />
				</div>
				<div class="SlotFrame">
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r1" class="Roulette">
								<%for(int i=1; i<=40; i++) {%>
								<img src="/event/20190901/r1_spring/<%=String.format("%02d", i)%>.png" />
								<%}%>
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r1').roulette('stop');"></div>
					</div>
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r2" class="Roulette">
								<%for(int i=1; i<=39; i++) {%>
								<img src="/event/20190901/r2_spring/<%=String.format("%02d", i)%>.png" />
								<%}%>
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r2').roulette('stop');"></div>
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