<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(SP_REVIEW && !cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
	return;
}

SearchTagByKeywordC cResults = new SearchTagByKeywordC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=Common.ToStringHtml(cResults.m_strKeyword)%></title>
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
					"url": "/f/SearchTagByKeywordF.jsp",
					"success": function(data) {
						if(data) {
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
		<div class="Wrapper">

			<div id="IllustThumbList" class="IllustItemList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CTag cTag = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_SP, _TEX)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMid.jsp"%>
					<%}%>
				<%}%>
			</div>

		</div>
	</body>
</html>