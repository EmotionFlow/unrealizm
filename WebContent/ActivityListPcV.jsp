<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);
if (!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailV.jsp").forward(request, response);
	return;
}

ActivityListC summaryResults = new ActivityListC();
summaryResults.getSummaryResults(checkLogin);

final HashMap<InfoList.InfoType, Integer> counts = summaryResults.activityCounts;
final boolean unreadReactionInfo =
	counts.containsKey(InfoList.InfoType.Emoji) ||
	counts.containsKey(InfoList.InfoType.EmojiReply);

final boolean unreadRequestInfo =
	counts.containsKey(InfoList.InfoType.Request);

int infoType = Util.toInt(request.getParameter("TY"));
if (infoType==-1) infoType = 1;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%@ include file="/inner/THeaderCommon.jsp" %>
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
						if (info_type === <%=InfoList.InfoType.Request.getCode()%> && request_id < 0){
							swal.fire({
								html: `
								<p style="text-align: left">他のユーザーからあなた宛に「エアスケブの受付を開始してほしい」という通知が来ました。
									<a style="color: #545454;text-decoration: underline;"
										href="https://unrealizm.com/MyEditSettingPcV.jsp?MENUID=REQUEST">
										設定画面で「エアスケブの依頼を受け付ける」をONにする</a>と、受付を開始できます。</p>
								`,
								showCloseButton: true,
								showConfirmButton: false,
							});
						} else if(info_type === <%=InfoList.InfoType.Gift.getCode()%>) {
							swal.fire({
								html: `
								<h2 style="color: #3498db;">他のユーザーからあなた宛に<br>ポイパスチケットのおふせが届きました。</h2>
								<ul style="font-size: 14px;
											text-align: left;
											margin-block-start: 0.5em;
											padding-inline-start: 20px;">
								<li>ポイパス未加入の方は、今月末までポイパスがONになります。翌月チケットのストックがなければ、自動でポイパスがOFFになります。</li>
								<li>おふせを受け取ったことにより請求や課金が発生することはありません。</li>
								<li>ポイパス定期購入中の方は、来月以降１ヶ月分、課金が0円になります。</li>
								<li>ポイパスの設定は設定画面から確認できます。</li>
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
</head>
<body>
<%@ include file="/inner/TMenuPc.jsp"%>

<nav class="TabMenuWrapper">
	<ul class="TabMenu">
		<li><a class="TabMenuItem <%if(infoType==1){%>Selected<%}%>" href="/ActivityListPcV.jsp?TY=1"><%=unreadReactionInfo ?"<span class=\"ActivityListBadge\"></span>":""%><%=_TEX.T("THeader.Menu.Act.Reaction")%>
		</a></li>
		<li><a class="TabMenuItem" href="/ActivityAnalyzePcV.jsp"><%=_TEX.T("THeader.Menu.Act.Analyze")%>
		</a></li>
	</ul>
</nav>

<article class="Wrapper ItemList" style="padding-top: 28px">
	<div class="IllustItemList" style="min-height: 600px;">
		<div id="ActivityList" class="ActivityList">
		</div>
	</div>
</article>

<%@ include file="/inner/TFooter.jsp" %>
</body>
</html>
