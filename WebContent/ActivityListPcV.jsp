<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("ActivityList.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuAct').addClass('Selected');
		});
		</script>

		<script type="text/javascript">
			function UpdateActivityList(elm, info_type, user_id, content_id) {
				console.log("UpdateActivityList");
				$.ajaxSingle({
					"type": "post",
					"data": {"TY":info_type, "ID":user_id, "TD":content_id},
					"url": "/api/UpdateActivityListF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result>=<%=Common.API_OK%>) {
							$(elm).addClass("HadRead");
							location.href="/"+user_id+"/"+content_id+".html";
						} else {
							DispMsg('Connection error');
						}
					}
				});
			}
			$(function(){
				$.ajax({
					"type": "post",
					"data": {},
					"url": "/f/ActivityListF.jsp",
					"dataType": "html",
					"success": function(data) {
						$('#ActivityList').html(data);
					}
				});
			});
		</script>

		<style>
			body {padding-top: 79px !important;}
		</style>
	</head>
	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/ActivityListPcV.jsp"><%=_TEX.T("THeader.Menu.Act.Reaction")%></a></li>
				<li><a class="TabMenuItem" href="/ActivityAnalyzePcV.jsp"><%=_TEX.T("THeader.Menu.Act.Analyze")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper ItemList">
			<div class="IllustItemList" style="min-height: 600px;">
				<div id="ActivityList" class="ActivityList">
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>