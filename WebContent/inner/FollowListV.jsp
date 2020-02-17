<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/StartPoipikuV.jsp");
	return;
}

FollowListC cResults = new FollowListC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>follow</title>
		<script>
			var g_nPage = 1;
			var g_nMode = <%=cResults.m_nMode%>;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"MD" : g_nMode, "PG" : g_nPage},
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

			function changeCategory(elm, param) {
				g_nPage = 0;
				g_nMode = param;
				$("#IllustThumbList").empty();
				$('#CategoryMenu .CategoryBtn').removeClass('Selected');
				$(elm).addClass('Selected');
				updateCategoryMenuPos(300);
				g_bAdding = false;
				addContents();
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
		<article class="Wrapper">
			<div id="CategoryMenu" class="CategoryMenu">
				<a class="BtnBase CategoryBtn <%if(cResults.m_nMode==FollowListC.MODE_FOLLOW){%>Selected<%}%>" onclick="changeCategory(this, <%=FollowListC.MODE_FOLLOW%>)"><%=_TEX.T("IllustListV.Follow")%></a>
				<a class="BtnBase CategoryBtn <%if(cResults.m_nMode==FollowListC.MODE_BLOCK){%>Selected<%}%>" onclick="changeCategory(this, <%=FollowListC.MODE_BLOCK%>)"><%=_TEX.T("IllustListV.Block")%></a>
			</div>

			<div id="IllustThumbList" class="IllustItemList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CUser cUser = cResults.m_vContentList.get(nCnt);%>
					<%if(isApp){%>
						<%=CCnv.toHtml(cUser, CCnv.MODE_SP, _TEX, CCnv.SP_MODE_APP)%>
					<%}else{%>
						<%=CCnv.toHtml(cUser, CCnv.MODE_SP, _TEX)%>
					<%}%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMid.jsp"%>
					<%}%>
				<%}%>
			</div>
		</article>
	</body>
</html>