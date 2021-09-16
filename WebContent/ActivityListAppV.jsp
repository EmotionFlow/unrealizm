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
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=_TEX.T("ActivityList.Title")%></title>

		<script type="text/javascript">
			function UpdateActivityList(elm, info_type, user_id, content_id, request_id) {
				$.ajax({
					"type": "post",
					"data": {"TY": info_type, "ID": user_id, "TD": content_id, "RID": request_id},
					"url": "/api/UpdateActivityListF.jsp",
					"dataType": "json",
				}).then(
					(data) => {
						if (data.result === <%=Common.API_OK%>) {
							$(elm).addClass("HadRead");
							if (info_type === <%=Common.NOTIFICATION_TYPE_REQUEST%> && request_id < 0){
								swal.fire({
									html: `
								<p style="text-align: left">他のユーザーからあなた宛に「リクエストの受付を開始してほしい」という通知が来ました。
										ブラウザ版ポイピクの設定画面で「リクエストを募集する」をONにすると、受付を開始できます。</p>
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
								<li>ポイパスの設定はブラウザ版ポイピクの設定画面から確認できます</li>
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