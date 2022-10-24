<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(SP_REVIEW && !checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartUnrealizmAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartUnrealizmV.jsp").forward(request,response);
	}
	return;
}

SearchTagByKeywordC cResults = new SearchTagByKeywordC();
cResults.getParam(request);

if (cResults.m_strKeyword.indexOf("@") == 0) {
	response.sendRedirect("https://unrealizm.com/SearchUserByKeyword" + (isApp?"App":"Pc") + "V.jsp?KWD=" + URLEncoder.encode(cResults.m_strKeyword.replaceFirst("@", ""), StandardCharsets.UTF_8));
	return;
}

boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
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
					"data": {"PG" : g_nPage, "KWD" :  "<%=cResults.m_strKeyword%>"},
					"url": "/f/SearchTagByKeyword<%=isApp?"App":""%>F.jsp",
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
			<header class="SearchResultTitle">
				<h2 class="Keyword">#<%=Util.toStringHtml(cResults.m_strKeyword)%></h2>
			</header>
			<section id="IllustThumbList" class="IllustItemList">
				<%int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;%>
				<%for(int nCnt = 0; nCnt<cResults.tagList.size(); nCnt++) {
					CTag cTag = cResults.tagList.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX, nSpMode)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAd336x280_mid.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>
	</body>
</html>