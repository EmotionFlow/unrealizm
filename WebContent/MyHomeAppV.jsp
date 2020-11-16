<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	return;
}

MyHomeC cResults = new MyHomeC();
cResults.getParam(request);
//cCheckLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(cCheckLogin);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Emoji.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
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

		<link href="/js/slick/slick-theme.css" rel="stylesheet" type="text/css">
		<link href="/js/slick/slick.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="/js/slick/slick.min.js"></script>
		<script>
		$(function(){
			$('.EventItemList').slick({
				autoplay:true,
				autoplaySpeed:3000,
				dots:true,
				infinite: true,
				slidesToShow: 1,
				variableWidth: true,
				centerMode: true,
				centerPadding: '10px',
			});
			$('.EventItemList').css({'opacity': '1'});
		});
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper">

			<%if(cResults.m_cSystemInfo!=null) {%>
			<div class="SystemInfo" id="SystemInfo_<%=cResults.m_cSystemInfo.m_nContentId%>">
				<a class="SystemInfoTitle" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><i class="fas fa-bullhorn"></i></a>
				<a class="SystemInfoDate" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><%=(new SimpleDateFormat("YYYY MM/dd")).format(cResults.m_cSystemInfo.m_timeUploadDate)%></a>
				<a class="SystemInfoDesc" href="/2/<%=cResults.m_cSystemInfo.m_nContentId%>.html"><%=Util.toStringHtml(cResults.m_cSystemInfo.m_strDescription)%></a>
				<a class="SystemInfoClose" href="javascript:void(0)" onclick="$('#SystemInfo_<%=cResults.m_cSystemInfo.m_nContentId%>').hide();setCookie('<%=Common.POIPIKU_INFO%>', '<%=cResults.m_cSystemInfo.m_nContentId%>')"><i class="fas fa-times"></i></a>
			</div>
			<%}%>

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

			<%@ include file="/inner/TAdEvent_top_rightV.jsp"%>

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
					<%= CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_SP, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>
					<%if((nCnt+1)%5==0) {%>
					<%@ include file="/inner/TAd336x280_mid.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>
	</body>
</html>