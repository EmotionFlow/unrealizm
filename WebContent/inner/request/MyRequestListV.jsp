<%@ page import="jp.pipa.poipiku.Request" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<script type="application/javascript">
	let g_RequestProcessing = false;
	function getRequestsHtml(statusCode, pageNum, requestId) {
		$.ajax({
			"type": "POST",
			"url": "/<%=isApp?"api":"f"%>/MyRequestListF.jsp",
			"data": "CAT=<%=category%>&ST=" + statusCode + "&PG=" + pageNum,
		}).then((data)=>{
				$("#RequestList").html(data);
				if (requestId) {
					$("#RequestPane-"+requestId).get(0).scrollIntoView();
				} else {
					$("*").scrollTop(0);
					let jsp = location.href;
					jsp = jsp.split('/');
					jsp = jsp[jsp.length-1];
					jsp = jsp.split('?')[0];
					history.replaceState('','', jsp + '?MENUID=<%=category%>&ST=' + statusCode);
				}
			}
		);
	}

	function onClickMenuItem(selectedItem, statusCode, pageNum, requestId) {
		$(".TabMenuItem").removeClass('Selected');
		$(selectedItem).addClass('Selected');
		getRequestsHtml(statusCode, pageNum, requestId);
	}

	function acceptRequest(requestId) {
		if (g_RequestProcessing) return;
		g_RequestProcessing = true;
		DispMsgStatic("承認処理中");
		$.ajax({
			"type": "POST",
			"url": "/f/AcceptRequestF.jsp",
			"data": "ID=" + requestId,
			"dataType": "json",
		}).then((data)=>{
			HideMsgStatic(0);
			if(data.result === <%=Common.API_OK%>){
				DispMsg("依頼を承認しました");
				$("#RequestPane-"+requestId).addClass("RequestPaneAccepting");
				$("#RequestPane-"+requestId).toggle(800);
			}else{
				DispMsg("依頼承認時にエラーが発生しました(" + data.error_code + ")");
			}
			g_RequestProcessing = false;
		});
	}

	function cancelRequest(requestId) {
		if (g_RequestProcessing) return;
		g_RequestProcessing = true;
		$.ajax({
			"type": "POST",
			"url": "/f/CancelRequestF.jsp",
			"data": "ID=" + requestId,
			"dataType": "json",
		}).then((data)=>{
			if(data.result === <%=Common.API_OK%>){
				DispMsg("依頼をキャンセルしました");
				$("#RequestPane-"+requestId).addClass("RequestPaneDeleting");
				$("#RequestPane-"+requestId).toggle(800);
			}else{
				DispMsg("依頼キャンセル時にエラーが発生しました(" + data.error_code + ")");
			}
			g_RequestProcessing = false;
		});
	}

	function deliveryRequest(toUrl) {
		if (g_RequestProcessing) return;
		<%if(!isApp){%>
		location.href = toUrl;
		<%}else{%>
		alert("お手数ですが、お渡しはブラウザ版(https://unrealizm.com/)からお願いいたします。アプリからのお渡しは現在開発中です。");
		<%}%>
	}

	$(() => {
		$(document).on("click", "#FollowListPageBar .PageBarItem", (ev) => {
			const pageNum = $(ev.target).attr("data-page");
			getRequestsHtml(status, pageNum);
		});

		onClickMenuItem(
			$("#TabMenuItem-<%=statusCode%>"),
			<%=statusCode%>,
			0,
			<%=requestId>0 ? requestId : "null"%>
		);
	});
</script>

<style>
	#RequestList{
        background: #3498da;
	}
	.RequestPane{
        background: #ffffff;
        padding: 10px 10px;
		margin: 3px 0;
        border-radius: 13px;
	}
    .RequestPaneDeleting{
        border: 3px solid #f09090;
        padding: 7px 7px;
    }
    .RequestPaneAccepting{
        border: 3px solid #90cdf0;
        padding: 7px 7px;
    }
	.RequestHeader{
        align-items: center;
        justify-content: space-between;
        display: flex;
	}
	.RequestAmount{
        background: #f5f5f5;
        padding: 4px 4px;
        border-radius: 8px;
	}
	.RequestLimits{
        display: flex;
        width: 100%;
        justify-content: flex-end;
	}
	.RequestTimeStamp{
		font-size: 12px;
        margin: 0 2px;
	}
	.RequestTimeStampLabel{
		background: #3498db;
		color: #6d6965f;
        border-radius: 4px 0 0 4px;
		padding: 3px;
	}
    .RequestTimeStampValue{
        border: solid 1px #3498db;
        border-radius: 0 4px 4px 0;
        padding: 2px 1px;
	}
	.RequestCmd{
        display: flex;
        width: 100%;
        margin-top: 17px;
        justify-content: space-evenly;
        align-content: center;
	}
    .RequestCmd > .RequestAgreeBtn{
        font-size: 12px;
	}
    .RequestCmd > .RequestCancelBtn{
		font-size: 12px;
        margin-left: 3px;
        color: #f09090;
        border: none;
    }
    .RequestCmd > .RequestCancelBtn:hover{
        color: #6d6965f;
		background: #f09090;
        border: none;
    }
	.RequestUser {
        display: flex;
		width: 100%;
        align-items: center;
	}
	.RequestUser > .RequestUserLink {
        color: #6d6965;
		font-size: 12px;
    }
	.RequestUserLink > .RequestUserLabel {
        background: #3498db;
        color: #6d6965f;
        border-radius: 4px 0 0 4px;
        padding: 3px 2px 3px 4px;
    }
    .RequestUserLink > .RequestUserNickname{
        border: solid 1px #3498db;
        border-radius: 0 4px 4px 0;
        padding: 2px 3px;
    }
    .RequestBody > .IllustThumbImg {
        display: block;
        height: 110px;
        background-position: 50% 50%;
        background-size: contain;
        background-repeat: no-repeat;
        margin: 10px auto;
    }

	.RequestLicense {
        color: #6d6965;
        font-size: 12px;
		margin-top: 4px;
	}
    .RequestLicense > .RequestLicenseLabel {
        background: #3498db;
        color: #6d6965f;
        border-radius: 4px 0 0 4px;
        padding: 3px 2px 3px 4px;
    }
    .RequestLicense > .RequestLicenseTitle {
        border: solid 1px #3498db;
        border-radius: 0 4px 4px 0;
        padding: 2px 3px;
    }
    .RequestLicense > .RequestLicenseTitle:hover {
        cursor: pointer;
    }

</style>

<div class="SettingList">
	<ul class="TabMenu">
		<li><a id="TabMenuItem-<%=Request.Status.WaitingApproval.getCode()%>"
			   class="TabMenuItem"
			   onclick="onClickMenuItem(this,<%=Request.Status.WaitingApproval.getCode()%>,0,null)"
			   href="#">
			<%=category.equals("SENT") ? "依頼中" : "依頼受付"%>
		</a></li>
		<li><a id="TabMenuItem-<%=Request.Status.InProgress.getCode()%>"
			   class="TabMenuItem"
			   onclick="onClickMenuItem(this,<%=Request.Status.InProgress.getCode()%>,0,null)"
			   href="#">作成中</a></li>
		<li><a id="TabMenuItem-<%=Request.Status.Done.getCode()%>"
			   class="TabMenuItem"
			   onclick="onClickMenuItem(this,<%=Request.Status.Done.getCode()%>,0,null)"
			   href="#">完了</a>
		</li>
		<li><a id="TabMenuItem-<%=Request.Status.Canceled.getCode()%>"
			   class="TabMenuItem"
			   onclick="onClickMenuItem(this,<%=Request.Status.Canceled.getCode()%>,0,null)"
			   href="#">キャンセル</a>
		</li>
		<%if(category.equals("SENT")){%>
		<li><a id="TabMenuItem-<%=Request.Status.Canceled.getCode()%>"
			   class="TabMenuItem"
			   onclick="onClickMenuItem(this,<%=Request.Status.SettlementError.getCode()%>,0,null)"
			   href="#">決済エラー</a>
		</li>
		<%}%>
	</ul>
	<div id="RequestList" class="IllustItemList">
	</div>
</div>
