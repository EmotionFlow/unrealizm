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
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp" %>
	<%@ include file="/inner/TSweetAlert.jsp"%>
	<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("ActivityList.Title")%>
	</title>

	<script type="text/javascript">
		$(function () {
			$('#MenuAct').addClass('Selected');
		});
	</script>
	<script type="text/javascript">
		function UpdateActivityList(elm, info_type, user_id, content_id, request_id) {
			$.ajax({
				"type": "post",
				"data": {"TY": info_type, "ID": user_id, "TD": content_id, "RID": request_id},
				"url": "/f/UpdateActivityListF.jsp",
				"dataType": "json",
			}).then(
				(data) => {
					if (data.result === <%=Common.API_OK%>) {
						$(elm).addClass("HadRead");
						if (info_type === <%=Common.NOTIFICATION_TYPE_REQUEST%> && request_id < 0){
							swal.fire({
								html: `
								<p style="text-align: left">他のユーザーからあなた宛に「リクエストの受付を開始してほしい」という通知が来ました。
									<a style="color: #545454;text-decoration: underline;"
										href="https://poipiku.com/MyEditSettingPcV.jsp?MENUID=REQUEST">
										設定画面で「リクエストを募集する」をONにする</a>と、受付を開始できます。</p>
								`,
								showCloseButton: true,
								showConfirmButton: false,
							});
						} else if(info_type === <%=Common.NOTIFICATION_TYPE_GIFT%>) {
							swal.fire({
								html: `
								<h2 style="color: #3498db;">他のユーザーからあなた宛に<br>ポイパスチケットが届きました。</h2>
								<ul style="font-size: 14px;
											text-align: left;
											margin-block-start: 0.5em;
											padding-inline-start: 20px;">
								<li>ポイパス未加入の方は、今月末までポイパスがONになります</li>
								<li>ポイパス定期購入中の方は、来月以降１ヶ月分、課金が0円になります</li>
								<li>ポイパスの設定は設定画面から確認できます</li>
								</ul>
								`,
								showCloseButton: true,
								showConfirmButton: false,
							});
						} else if(data.to_url) {
							location.href = data.to_url;
						}
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
		<li><a class="TabMenuItem <%if(infoType==3){%>Selected<%}%>" href="/ActivityListPcV.jsp?TY=3"><%=_TEX.T("THeader.Menu.Act.Request")%>
		</a></li>
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