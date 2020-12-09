<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
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

PopularIllustListC cResults = new PopularIllustListC();
cResults.getParam(request);
checkLogin.m_nSafeFilter = Common.SAFE_FILTER_R15;
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>popular</title>
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
					"data": {"PG" : g_nPage},
					"url": "/f/PopularIllustList<%=isApp?"App":""%>F.jsp",
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
			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%if(isApp){%>
						<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
					<%}else{%>
						<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_SP, _TEX)%>
					<%}%>
					<%if(nCnt==17) {%>
					<%@ include file="/inner/TAd336x280_mid.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>
	</body>
</html>
