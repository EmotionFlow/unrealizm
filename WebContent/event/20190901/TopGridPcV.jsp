<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchIllustByTagGridC cResults = new SearchIllustByTagGridC();
cResults.getParam(request);
cResults.m_strKeyword = "お題ルーレット";
boolean bRtn = cResults.getResults(checkLogin);
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
String strTitle = String.format(_TEX.T("SearchIllustByTag.Title"), cResults.m_strKeyword) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), cResults.m_strKeyword, cResults.m_nContentsNum);
String strUrl = "https://poipiku.com/event/20190901/TopPcV.jsp";
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<link rel="canonical" href="<%=strUrl%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
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
			});
		</script>
		<style>
			.IllustItem .IllustItemCommand .IllustItemCommandSub .IllustItemCommandDelete {display: none;}
			.IllustThumbList .IllustThumbPane {width: 374px; float: left;}
		</style>

		<style>
			.SettingBody.Roulette {background: top center url('/event/20190901/odai_odai.png') no-repeat; background-size: 600px; height: 3058px;}
			.SlotFrame {display: flex; flex-flow: row nowrap; justify-content:space-between; position: absolute; width: 560px; left: 20px; top: 1948px; z-index: 1;}
			.SlotFrame .SlotItem {display: flex; flex-flow: column; align-items: center;}
			.SlotItem .RouletteFrame {}
			.SlotItem .RouletteFrame .Roulette {display: none; width: 272px; background-color: #fff; border-radius: 10px; overflow: hidden;}
			.SlotItem .RouletteFrame .Roulette img {display: block; width: 272px; height: 276px;}
			.SlotItem .StopBtn {display: block; width: 100px; height: 100px; margin: 27px 0 0 0; cursor: pointer;}
			.SlotCmdFrame {display: flex; flex-flow: column; align-items: center;  position: absolute; width: 570px; left: 15px; top: 2422px; z-index: 1;}
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
								<%for(int i=1; i<=97; i++) {%>
								<img src="/event/20190901/r1_odai01/<%=String.format("%02d", i)%>.png" />
								<%}%>
							</div>
						</div>
						<div class="StopBtn" onclick="$('#r1').roulette('stop');"></div>
					</div>
					<div class="SlotItem">
						<div class="RouletteFrame">
							<div id="r2" class="Roulette">
								<%for(int i=1; i<=70; i++) {%>
								<img src="/event/20190901/r1_odai02/<%=String.format("%02d", i)%>.png" />
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
				<h2 class="Keyword">#<%=Util.toStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!checkLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.m_bFollowing) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>')"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>')"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%@ include file="/inner/ad/TAdGridPc336x280_right_top.jsp"%>
				<div class="IllustThumbPane">
					<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt+=3) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%if(nCnt==6){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
						<%=CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%}%>
				</div>
				<div class="IllustThumbPane">
					<%for(int nCnt=1; nCnt<cResults.m_vContentList.size(); nCnt+=3) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%if(nCnt==16){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
						<%=CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%}%>
				</div>
				<div class="IllustThumbPane">
					<%for(int nCnt=2; nCnt<cResults.m_vContentList.size(); nCnt+=3) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%if(nCnt==23){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
						<%=CCnv.Content2Html(cContent, checkLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%}%>
				</div>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarPc("/SearchIllustByTagPcV.jsp", String.format("&KWD=%s", strEncodedKeyword), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
