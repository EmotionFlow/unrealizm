<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<% boolean isApp = true; %>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if(!checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartPoipikuV.jsp").forward(request,response);
	}
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("ActivityList.Title")%></title>

		<script type="text/javascript">
			function UpdateActivityList(elm, info_type, user_id, content_id) {
				$.ajaxSingle({
					"type": "post",
					"data": {"TY":info_type, "ID":user_id, "TD":content_id},
					"url": "/api/UpdateActivityListF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result>=<%=Common.API_OK%>) {
							$(elm).addClass("HadRead");
							location.href="/IllustViewAppV.jsp?ID="+user_id+"&TD="+content_id;
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
	</head>
	<body>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>

		<article class="Wrapper ItemList">
			<div class="IllustItemList" style="min-height: 600px;">
				<div id="ActivityList" class="ActivityList">
				</div>
			</div>
		</article>
	</body>
</html>