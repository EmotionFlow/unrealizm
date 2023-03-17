<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);
boolean isApp = true;

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/StartUnrealizmAppV.jsp").forward(request,response);
	return;
}

MyHomeC results = new MyHomeC();
results.getParam(request);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;

boolean bRtn = results.getResults(checkLogin);
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<%@ include file="/inner/TReplyEmoji.jsp"%>
		<title>home</title>

		<%@ include file="/inner/TDeleteContent.jsp"%>
		<%@ include file="/inner/TDispRequestTextDlg.jsp"%>
		<%@ include file="/inner/TRetweetContent.jsp"%>
		<%@ include file="/inner/TTwitterFollowerLimitInfo.jsp"%>

		<script>
		var g_nEndId = <%=results.lastContentId%>;
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
				"url": "/f/MyHomeAppF.jsp",
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
				$(element).on("drag dragstart",function(e){return false;});
			});
			$(window).bind("scroll.addContents", function() {
				$(window).height();
				if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 400) {
					addContents();
				}
			});
		});
		</script>
	</head>

	<body>
		<article class="Wrapper">

			<%if(results.systemInfo !=null) {%>
			<div class="SystemInfo" id="SystemInfo_<%=results.systemInfo.m_nContentId%>">
				<a class="SystemInfoTitle" href="/IllustViewAppV.jsp?ID=2&TD=<%=results.systemInfo.m_nContentId%>"><i class="fas fa-bullhorn"></i></a>
				<a class="SystemInfoDate" href="/IllustViewAppV.jsp?ID=2&TD=<%=results.systemInfo.m_nContentId%>"><%=(new SimpleDateFormat("YYYY MM/dd")).format(results.systemInfo.m_timeUploadDate)%></a>
				<a class="SystemInfoDesc" href="/IllustViewAppV.jsp?ID=2&TD=<%=results.systemInfo.m_nContentId%>"><%=Util.toStringHtml(results.systemInfo.m_strDescription)%></a>
				<a class="SystemInfoClose" href="javascript:void(0)" onclick="$('#SystemInfo_<%=results.systemInfo.m_nContentId%>').hide();setCookie('<%=Common.UNREALIZM_INFO%>', '<%=results.systemInfo.m_nContentId%>')"><i class="fas fa-times"></i></a>
			</div>
			<%}%>

			<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>

			<%if(Util.needUpdate(results.version)) {%>
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

			<%if(results.contentList.size()<=0) {%>
			<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 50px 10px 50px 10px; text-align: center; box-sizing: border-box;">
				<%=_TEX.T("MyHome.FirstMsg")%>
				<br />
				<a class="BtnBase" href="/how_to/TopV.jsp"><%=_TEX.T("HowTo.Title")%></a>
			</div>
			<%}%>
			<section id="IllustItemList" class="IllustItemList">
				<%	int nCnt;
					for(nCnt=0; nCnt<results.contentList.size(); nCnt++) {
						CContent cContent = results.contentList.get(nCnt);%>
						<%=CCnv.Content2Html(cContent, checkLogin, CCnv.MODE_SP, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>

						<%if(nCnt==7 && results.recommendedRequestCreatorList !=null && !results.recommendedRequestCreatorList.isEmpty()) {%>
						<h2 class="IllustItemListRecommendedTitle"><%=_TEX.T("MyHome.Recommended.RequestCreators")%></h2>
						<%for (CUser recommendedUser: results.recommendedRequestCreatorList){%>
						<%=CCnv.toHtmlUserMini(recommendedUser, 1, _TEX, CCnv.SP_MODE_APP)%>
						<%}%>
						<%}%>

						<%if(nCnt==6 && results.recommendedUserList !=null && !results.recommendedUserList.isEmpty()) {%>
						<h2 class="IllustItemListRecommendedTitle"><%=_TEX.T("MyHome.Recommended.Users")%></h2>
						<%for (CUser recommendedUser: results.recommendedUserList){%>
						<%=CCnv.toHtmlUserMini(recommendedUser, 1, _TEX, CCnv.SP_MODE_APP)%>
						<%}%>
						<%}%>

						<%if((nCnt+1)%5==0) {%>
							<%@ include file="/inner/TAd336x280_mid.jsp"%>
						<%}%>
				<%}%>

				<%if(nCnt<=7 && results.recommendedRequestCreatorList !=null && !results.recommendedRequestCreatorList.isEmpty()) {%>
				<h2 class="IllustItemListRecommendedTitle"><%=_TEX.T("MyHome.Recommended.RequestCreators")%></h2>
				<%for (CUser recommendedUser: results.recommendedRequestCreatorList){%>
				<%=CCnv.toHtmlUserMini(recommendedUser, 1, _TEX, CCnv.SP_MODE_APP)%>
				<%}%>
				<%}%>

				<%if(nCnt<=6 && results.recommendedUserList !=null && !results.recommendedUserList.isEmpty()) {%>
				<h2 class="IllustItemListRecommendedTitle"><%=_TEX.T("MyHome.Recommended.Users")%></h2>
				<%for (CUser recommendedUser: results.recommendedUserList){%>
				<%=CCnv.toHtmlUserMini(recommendedUser, 1, _TEX, CCnv.SP_MODE_APP)%>
				<%}%>
				<%}%>

			</section>
		</article>
		<%@ include file="/inner/TShowDetail.jsp"%>
	</body>
</html>