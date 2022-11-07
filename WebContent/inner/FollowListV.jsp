<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartUnrealizmAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartUnrealizmV.jsp").forward(request,response);
	}
	return;
}

FollowListC cResults = new FollowListC();
cResults.getParam(request);
cResults.m_nMode = followMode;
boolean bRtn = cResults.getResults(checkLogin);

final String title;
if (cResults.m_nMode == FollowListC.MODE_FOLLOWING) {
	title = _TEX.T("FollowListV.Title");
} else {
	title = _TEX.T("FollowerListV.Title");
}
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}%>
		<title>follow</title>
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
					"data": {"ID": <%=cResults.userId%> ,"MD" : <%=cResults.m_nMode%>, "PG" : g_nPage},
					"url": "/f/FollowList<%=isApp?"App":""%>F.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							//$(window).unbind("scroll.addContents");
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
					if(g_bAdding) return;
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
			});
		</script>
	</head>

	<body>
		<%if(!isApp){%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%}%>
		<article class="Wrapper GridList">
			<div class="FollowListHeader">
				<h2 class="FollowListTitle">
					<i class="FollowListBackLink fas fa-arrow-left"></i><%=title%></h2>
			</div>
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt = 0; nCnt<cResults.userList.size(); nCnt++) {
					CUser cUser = cResults.userList.get(nCnt);%>
					<%if(isApp){%>
						<%=CCnv.toHtmlUserMini(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
					<%}else{%>
						<%=CCnv.toHtmlUserMini(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_WVIEW)%>
					<%}%>
<%--					<%if((nCnt+1)%9==0) {%>--%>
<%--					<%@ include file="/inner/TAd336x280_mid.jsp"%>--%>
<%--					<%}%>--%>
				<%}%>
			</div>
		</article>
		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>