<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/StartUnrealizmAppV.jsp").forward(request,response);
	return;
}

FollowListC results = new FollowListC();
results.getParam(request);
boolean bRtn = results.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("IllustListV.Follow")%></title>
		<script>
			var g_nPage = 1;
			var g_nMode = <%=results.m_nMode%>;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"MD" : g_nMode, "PG" : g_nPage},
					"url": "/f/FollowListAppF.jsp",
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

	<body style="background: #fff;">
		<article class="Wrapper GridList">
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt = 0; nCnt<results.userList.size(); nCnt++) {
					CUser cUser = results.userList.get(nCnt);%>
					<%=CCnv.toHtmlUser(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAd336x280_mid.jsp"%>
					<%}%>
				<%}%>
			</div>
		</article>
	</body>
</html>