<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/IllustListC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustListCParam cParam = new IllustListCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;
if(cParam.m_nUserId==-1) {
	cParam.m_nUserId = cCheckLogin.m_nUserId;
}

IllustListC cResults = new IllustListC();
if(!cResults.GetResults(cParam)) {
	if(!cCheckLogin.m_bLogin) {
		response.sendRedirect("/StartPoipikuV.jsp");
	} else {
		response.sendRedirect("/NotFoundV.jsp");
	}
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title><%=cResults.m_cUser.m_strNickName%></title>
		<script>
			var g_nNextId = -1;
			function addContents(nStartId) {
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajaxSingle({
					"type": "post",
					"data": {
						"ID" : <%=cResults.m_cUser.m_nUserId%>,
						"SID" : nStartId
						},
					"url": "/f/IllustListF.jsp",
					"dataType": "json",
					"success": function(data) {
						g_nNextId = data.end_id;
						for(var nCnt=0; nCnt<data.result_num; nCnt++) {
							$("#IllustThumbList").append(CreateIllustThumb(data.result[nCnt]));
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function UpdateFollow() {
				var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cUser.m_nUserId%>, "CHK": (bFollow)?0:1 },
					"url": "/f/UpdateFollowF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('#UserInfoCmdFollow').addClass('Selected');
							$('#UserInfoCmdFollow').html("フォロー中");
						} else if(data.result==2) {
							$('#UserInfoCmdFollow').removeClass('Selected');
							$('#UserInfoCmdFollow').html("フォローする");
						} else {
							DispMsg('フォローできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			function UpdateBlock() {
				var bBlocked = $("#UserInfoCmdBlock").hasClass('Selected');
				$.ajaxSingle({
					"type": "post",
					"data": { "UID": <%=cCheckLogin.m_nUserId%>, "IID": <%=cResults.m_cUser.m_nUserId%>, "CHK": (bBlocked)?0:1 },
					"url": "/f/UpdateBlockF.jsp",
					"dataType": "json",
					"success": function(data) {
						if(data.result==1) {
							$('#UserInfoCmdBlock').addClass('Selected');
							$('#UserInfoCmdFollow').removeClass('Selected');
							$('#UserInfoCmdFollow').html("フォローする");
							$('#UserInfoCmdFollow').hide();
						} else if(data.result==2) {
							$('#UserInfoCmdBlock').removeClass('Selected');
							$('#UserInfoCmdFollow').removeClass('Selected');
							$('#UserInfoCmdFollow').html("フォローする");
							$('#UserInfoCmdFollow').show();
						} else {
							DispMsg('ブロックできませんでした');
						}
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				<%if(!cResults.m_bBlocking && !cResults.m_bBlocked){%>
				addContents(g_nNextId);
				<%}%>
			});

			$(document).ready(function() {
				<%if(!cResults.m_bBlocking && !cResults.m_bBlocked){%>
				$(window).bind("scroll", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 100) {
						addContents(g_nNextId);
					}
				});
				<%}%>
			});
		</script>
	</head>

	<body>
		<div class="Wrapper" style="background-size: 360px auto; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strBgFileName)%>')">
			<div class="UserInfo" style="background-size: 360px auto; background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>')">
				<div class="UserInfoBg"></div>
				<div class="UserInfoUser">
					<span class="UserInfoUserThumb">
						<img class="UserInfoUserThumbImg" src="<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>" />
					</span>
					<span class="UserInfoUserName"><%=cResults.m_cUser.m_strNickName%></span>
					<%if(!cResults.m_cUser.m_strProfile.equals("")) {%>
					<span class="UserInfoProgile"><%=Common.ToStringHtml(cResults.m_cUser.m_strProfile)%></span>
					<%}%>
				</div>
				<span class="UserInfoCmd">
					<%if(cResults.m_bOwner) {%>
					<a class="BtnBase UserInfoCmdFollow" href="/MyEditSettingV.jsp"><span class="typcn typcn-cog-outline"></span>設定</a>
					<%} else if(cResults.m_bBlocking){%>
					<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" style="display: none;" onclick="UpdateFollow()">フォローする</span>
					<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected" onclick="UpdateBlock()"></span>
					<%} else if(cResults.m_bBlocked){%>
					<%} else if(cResults.m_bFollow){%>
					<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow Selected" onclick="UpdateFollow()">フォロー中</span>
					<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock " onclick="UpdateBlock()"></span>
					<%} else {%>
					<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" onclick="UpdateFollow()">フォローする</span>
					<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" onclick="UpdateBlock()"></span>
					<%}%>
					<%
					String strTwitterUrl="https://twitter.com/share?url=" + URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8");
					%>
					<span class="IllustItemCommandSub">
						<a class="social-icon Twitter" href="<%=strTwitterUrl%>">&#229;</a>
					</span>
				</span>
				<%if(cResults.m_bOwner) {%>
				<span class="UserInfoState">
					<a class="UserInfoStateItem" href="/FollowListV.jsp">
						<span class="UserInfoStateItemTitle">フォロー</span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowNum%></span>
					</a>
					<a class="UserInfoStateItem" href="/FollowerListV.jsp">
						<span class="UserInfoStateItemTitle">フォロワー</span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowerNum%></span>
					</a>
				</span>
				<%}%>
			</div>

			<div id="IllustThumbList" class="IllustThumbList">
			</div>
		</div>
	</body>
</html>