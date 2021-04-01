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

int infoType = Util.toInt(request.getParameter("TY"));
if (infoType==-1) infoType = 1;

%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("ActivityList.Title")%></title>

		<script type="text/javascript">
			function UpdateActivityList(elm, info_type, user_id, content_id, request_id) {
				console.log("UpdateActivityList");
				$.ajax({
					"type": "post",
					"data": {"TY": info_type, "ID": user_id, "TD": content_id, "RID": request_id},
					"url": "/api/UpdateActivityListF.jsp",
					"dataType": "json",
				}).then(
					(data) => {
						if (data.result === <%=Common.API_OK%>) {
							$(elm).addClass("HadRead");
							location.href = data.to_url;
						} else {
							DispMsg('Connection error');
						}
					},
					(jqXHR, textStatus, errorThrown) => {
						DispMsg('Connection error');
					}
				)
			}

			$(function(){
				$.ajax({
					"type": "post",
					"data": {"TY":<%=infoType%>},
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