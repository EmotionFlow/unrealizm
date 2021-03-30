<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	//login check
	CheckLogin checkLogin = new CheckLogin(request, response);
	if (!checkLogin.m_bLogin) {
		getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request, response);
		return;
	}

	int infoType = Util.toInt(request.getParameter("TY"));
	if (infoType==-1) infoType = 1;

%>
<!DOCTYPE html>
<html>
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp" %>
	<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("ActivityList.Title")%>
	</title>

	<script type="text/javascript">
		$(function () {
			$('#MenuAct').addClass('Selected');
		});
	</script>
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

		$(function () {
			$.ajax({
				"type": "post",
				"data": {"TY":<%=infoType%>},
				"url": "/f/ActivityListF.jsp",
				"dataType": "html",
				"success": function (data) {
					$('#ActivityList').html(data);
				}
			});
		});
	</script>

	<style>
        body {
            padding-top: 79px !important;
        }
	</style>
</head>
<body>
<%@ include file="/inner/TMenuPc.jsp" %>

<nav class="TabMenuWrapper">
	<ul class="TabMenu">
		<li><a class="TabMenuItem <%if(infoType==1){%>Selected<%}%>" href="/ActivityListPcV.jsp?TY=1"><%=_TEX.T("THeader.Menu.Act.Reaction")%>
		</a></li>
		<%if(checkLogin.isStaff()){%>
		<li><a class="TabMenuItem <%if(infoType==3){%>Selected<%}%>" href="/ActivityListPcV.jsp?TY=3"><%=_TEX.T("THeader.Menu.Act.Request")%>
		</a></li>
		<%}%>
		<li><a class="TabMenuItem" href="/ActivityAnalyzePcV.jsp"><%=_TEX.T("THeader.Menu.Act.Analyze")%>
		</a></li>
	</ul>
</nav>

<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp" %>

<article class="Wrapper ItemList">
	<div class="IllustItemList" style="min-height: 600px;">
		<div id="ActivityList" class="ActivityList">
		</div>
	</div>
</article>

<%@ include file="/inner/TFooter.jsp" %>
</body>
</html>