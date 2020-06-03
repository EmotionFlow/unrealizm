<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("https://poipiku.com/StartPoipikuV.jsp");
	return;
}

MyHomeC cResults = new MyHomeC();
cResults.getParam(request);
//cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<title>home</title>

		<%@ include file="/inner/TDeleteContent.jsp"%>

		<script>
		var g_nEndId = <%=cResults.m_nEndId%>;
		var g_bAdding = false;
		function addContents() {
			if(g_bAdding) return;
			g_bAdding = true;
			var $objMessage = $("<div/>").addClass("Waiting");
			$("#IllustItemList").append($objMessage);
			$.ajax({
				"type": "post",
				"data": {"SD" : g_nEndId, "MD" : <%=CCnv.MODE_SP%>, "VD" : <%=CCnv.VIEW_DETAIL%>},
				"dataType": "json",
				"url": "/f/MyHomeF.jsp",
				"success": function(data) {
					if(data.end_id>0) {
						g_nEndId = data.end_id;
						$("#IllustItemList").append(data.html);
						$(".Waiting").remove();
						if(vg)vg.vgrefresh();
						g_bAdding = false;
						console.log(location.pathname+'/'+g_nEndId+'.html');
						gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nEndId+'.html'});
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

		function MoveTab() {
			sendObjectMessage("moveTabNewArrival")
		}

		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("contextmenu drag dragstart copy",function(e){return false;});
			});
			$(window).bind("scroll.addContents", function() {
				$(window).height();
				if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 400) {
					addContents();
				}
			});
		});
		</script>
		<style>
			.EventItemList {display: block; float: left; width: 100%; margin: 10px 0 0 0;}
			.EventItemList .EventItem {display: block; margin: 0 20px 10px 20px;}
			.EventItemList .EventItem .EventBanner {width: 320px; display: block;}
			.EventItemList .EventItem.Updated {position: relative;}
			.EventItemList .EventItem.Updated:after {display: block; content: ''; position: absolute; width: 50px; height: 46px; background-image: url('/img/upodate_jp.png'); background-size: contain; top: 5px; right: 0px;}
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<%if(Util.needUpdate(cResults.n_nVersion)) {%>
			<div class="UpdateInfo">
				<div class="UpdateInfoMsg"><%=_TEX.T("UpdateInfo.Msg")%></div>
				<%if(Util.isIOS(request)){%>
				<a href="https://itunes.apple.com/jp/app/%E3%83%9D%E3%82%A4%E3%83%94%E3%82%AF/id1436433822?mt=8" target="_blank" style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg) no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; "></a>
				<%}else{%>
				<a href="https://play.google.com/store/apps/details?id=jp.pipa.poipiku" target="_blank" style="display:inline-block;overflow:hidden; background:url('https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png') no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; background-size: 158px;"></a>
				<%}%>
			</div>
			<%}%>
			<section class="EventItemList">
				<!--
				<a class="EventItem" href="https://poipiku.com/2/1783042.html">
					<img class="EventBanner" src="/img/maintenance.png" />
				</a>
				-->
				<a class="EventItem" href="/event/20200414_mangaMovie/TopV.jsp">
					<img class="EventBanner" src="/event/20200414_mangaMovie/ppmc_award.png" />
				</a>
				<a class="EventItem" href="/event/20190901/TopV.jsp">
					<img class="EventBanner" src="/event/20190901/banner_spring.png" />
				</a>
				<a class="EventItem" href="/event/20191001/TopV.jsp">
					<img class="EventBanner" src="/event/20191001/banner_karapare.png" />
				</a>
			</section>
			<%if(cResults.m_vContentList.size()<=0) {%>
			<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 150px 10px 50px 10px; text-align: center; box-sizing: border-box;">
				<%=_TEX.T("MyHome.FirstMsg")%>
				<br />
				<a class="BtnBase" href="/NewArrivalAppV.jsp"><%=_TEX.T("MyHome.FirstMsg.FindPeople")%></a>
				<br />
				<br />
				<a class="BtnBase" href="/how_to/TopV.jsp"><%=_TEX.T("HowTo.Title")%></a>
			</div>
			<%}%>
			<section id="IllustItemList" class="IllustItemList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%= CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult, CCnv.VIEW_DETAIL)%>
					<%if((nCnt+1)%5==0) {%>
					<%@ include file="/inner/TAdMid.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>
	</body>
</html>