<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
if (Util.isBot(request)) return;

CheckLogin checkLogin = new CheckLogin(request, response);

if(SP_REVIEW && !checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/StartPoipiku" + (isApp?"App":"") +"V.jsp").forward(request,response);
	return;
}

checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
SearchIllustByKeywordC cResults = new SearchIllustByKeywordC();
cResults.getParam(request);

if (cResults.keyword.indexOf("#") == 0) {
	response.sendRedirect("/SearchTagByKeyword" + (isApp?"App":"Pc") + "V.jsp?KWD=" +  cResults.encodedKeyword);
	return;
} else if (cResults.keyword.indexOf("@") == 0) {
	response.sendRedirect("/SearchUserByKeyword" + (isApp?"App":"Pc") + "V.jsp?KWD=" +  cResults.encodedKeyword);
	return;
}

cResults.selectMaxGallery = 45;
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=Util.toStringHtml(cResults.keyword)%></title>
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
					"data": {"PG" : g_nPage, "KWD" : "<%=cResults.keyword%>"},
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
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>

		<article class="Wrapper">
			<header class="SearchResultTitle" style="box-sizing: border-box; margin: 10px 0; padding: 0 5px;">
				<h2 class="Keyword"><i class="fas fa-search"></i> <%=Util.toStringHtml(cResults.keyword)%></h2>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;%>
				<%for(int nCnt = 0; nCnt<cResults.contentList.size(); nCnt++) {
					CContent cContent = cResults.contentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, nSpMode, _TEX)%>
					<%if(nCnt==14) {%><%@ include file="/inner/TAd336x280_mid.jsp"%><%}%>
					<%if(nCnt==29) {%><%@ include file="/inner/TAd336x280_mid.jsp"%><%}%>
				<%}%>
			</section>
		</article>
	</body>
</html>
