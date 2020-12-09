<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(SP_REVIEW && !checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartPoipikuV.jsp").forward(request,response);
	}
	return;
}

checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
SearchIllustByKeywordC cResults = new SearchIllustByKeywordC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 45;
String strKeywordHan = Util.toSingle(cResults.m_strKeyword);
if(strKeywordHan.matches("^[0-9]+$")) {
	String strUrl = isApp ? "/IllustListAppV.jsp?ID=" : "/IllustListPcV.jsp?ID=";
	response.sendRedirect(Common.GetPoipikuUrl(strUrl + strKeywordHan));
	return;
}
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=Util.toStringHtml(cResults.m_strKeyword)%></title>
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
					"data": {"PG" : g_nPage, "KWD" :  decodeURIComponent("<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>")},
					"url": "/f/SearchIllustByKeyword<%=isApp?"App":""%>F.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
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

			$(function(){
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
			});
		</script>
	</head>

	<body>
		<article class="Wrapper">
			<header class="SearchResultTitle" style="box-sizing: border-box; margin: 10px 0; padding: 0 5px;">
				<h2 class="Keyword"><i class="fas fa-search"></i> <%=Util.toStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!checkLogin.m_bLogin) {%>
				<!--
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				-->
				<%} else if(!cResults.m_bFollowing) {%>
				<!--
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_SEARCH%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				-->
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_SEARCH%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, URLEncoder.encode(cResults.m_strKeyword, "UTF-8"), _TEX, nSpMode)%>
					<%if(nCnt==14) {%><%@ include file="/inner/TAd336x280_mid.jsp"%><%}%>
					<%if(nCnt==29) {%><%@ include file="/inner/TAd336x280_mid.jsp"%><%}%>
				<%}%>
			</section>
		</article>
	</body>
</html>
