<%@page import="jp.pipa.poipiku.controller.*"%>
<%@ page import="jp.pipa.poipiku.Request" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%if(checkLogin.isStaff()){%>

<script type="application/javascript">
	let g_RequestProcessing = false;
	function getRequestsHtml(statusCode, pageNum, requestId) {
		$.ajax({
			"type": "POST",
			"url": "/f/MyRequestListF.jsp",
			"data": "CAT=<%=category%>&ST=" + statusCode + "&PG=" + pageNum,
		}).then((data)=>{
				$("#RequestList").html(data);
				if (requestId) {
					$("#RequestPane-"+requestId).get(0).scrollIntoView();
				} else {
					$("*").scrollTop(0);
					history.replaceState('','','MyRequestListPcV.jsp?MENUID=<%=category%>&ST=' + statusCode);
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
				DispMsg("リクエストを承認しました");
				$("#RequestPane-"+requestId).addClass("RequestPaneAccepting");
				$("#RequestPane-"+requestId).toggle(800);
			}else{
				DispMsg("リクエスト承認時にエラーが発生しました(" + data.error_code + ")");
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
				DispMsg("リクエストをキャンセルしました");
				$("#RequestPane-"+requestId).addClass("RequestPaneDeleting");
				$("#RequestPane-"+requestId).toggle(800);
			}else{
				DispMsg("リクエストキャンセル時にエラーが発生しました(" + data.error_code + ")");
			}
			g_RequestProcessing = false;
		});
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
		color: #ffffff;
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
        justify-content: flex-end;
	}
    .RequestCmd > .RequestAgreeBtn{

	}
    .RequestCmd > .RequestCancelBtn{
        margin-left: 20px;
        color: #f09090;
        border-color: #f09090;
    }
    .RequestCmd > .RequestCancelBtn:hover{
        margin-left: 20px;
        color: #ffffff;
		background: #f09090;
        border-color: #f09090;
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
        color: #ffffff;
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


</style>

<div class="SettingList">
	<ul class="TabMenu">
		<li><a id="TabMenuItem-<%=Request.Status.WaitingAppoval.getCode()%>"
			   class="TabMenuItem"
			   onclick="onClickMenuItem(this,<%=Request.Status.WaitingAppoval.getCode()%>,0,null)"
			   href="#">承認待ち</a>
		</li>
		<li><a id="TabMenuItem-<%=Request.Status.InProgress.getCode()%>"
			   class="TabMenuItem"
			   onclick="onClickMenuItem(this,<%=Request.Status.InProgress.getCode()%>,0,null)"
			   href="#">作業中</a></li>
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

<%}//if(checkLogin.isStaff()){%%>
