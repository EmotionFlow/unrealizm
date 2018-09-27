<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

IllustListC cResults = new IllustListC();
cResults.getParam(request);
if(cResults.m_nUserId==-1) {
	cResults.m_nUserId = cCheckLogin.m_nUserId;
}
if(!cResults.getResults(cCheckLogin)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNum)%>" />
		<meta name="twitter:card" content="gallery" />
		<meta name="twitter:site" content="@pipajp" />
		<meta name="twitter:title" content="<%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName))%>" />
		<meta name="twitter:description" content="<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNum)%>" />
		<%
		for(int nCnt=0; nCnt<cResults.m_vContentList.size() && nCnt<4; nCnt++) {
			CContent cContent = cResults.m_vContentList.get(nCnt);
		%>
		<meta name="twitter:image<%=nCnt%>" content="<%=Common.GetUrl(cContent.m_strFileName)%>_360.jpg">
		<%}%>
		<title><%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(String.format(_TEX.T("IllustListPc.Title"), cResults.m_cUser.m_strNickName))%></title>

		<script type="text/javascript">
		$(function(){
			<%if(cResults.m_bOwner) {%>
			$('#MenuMe').addClass('Selected');
			<%} else {%>
			$('#MenuHome').addClass('Selected');
			<%}%>
		});
		</script>

		<script>
		function UpdateFollow(nUserId, nFollowUserId) {
			var bFollow = $("#UserInfoCmdFollow").hasClass('Selected');
			$.ajaxSingle({
				"type": "post",
				"data": { "UID": nUserId, "IID": nFollowUserId },
				"url": "/f/UpdateFollowF.jsp",
				"dataType": "json",
				"success": function(data) {
					if(data.result==1) {
						$('.UserInfoCmdFollow_'+nFollowUserId).addClass('Selected');
						$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Following")%>");
					} else if(data.result==2) {
						$('.UserInfoCmdFollow_'+nFollowUserId).removeClass('Selected');
						$('.UserInfoCmdFollow_'+nFollowUserId).html("<%=_TEX.T("IllustV.Follow")%>");
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
						$('#UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
						$('#UserInfoCmdFollow').hide();
					} else if(data.result==2) {
						$('#UserInfoCmdBlock').removeClass('Selected');
						$('#UserInfoCmdFollow').removeClass('Selected');
						$('#UserInfoCmdFollow').html("<%=_TEX.T("IllustV.Follow")%>");
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
		</script>
		<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper" style="width: 100%;">
			<div class="UserInfo">
				<div class="UserInfoBg"></div>
				<div class="UserInfoUser">
					<span class="UserInfoUserThumb">
						<%if(!cResults.m_cUser.m_strFileName.isEmpty()) {%>
						<img class="UserInfoUserThumbImg" src="<%=Common.GetUrl(cResults.m_cUser.m_strFileName)%>" />
						<%}%>
					</span>
					<span class="UserInfoUserName"><%=cResults.m_cUser.m_strNickName%></span>
					<%if(!cResults.m_cUser.m_strProfile.isEmpty()) {%>
					<span class="UserInfoProgile"><%=Common.ToStringHtml(cResults.m_cUser.m_strProfile)%></span>
					<%}%>
				</div>
				<span class="UserInfoCmd">
					<%
					String strTwitterUrl=String.format("https://twitter.com/share?url=%s&text=%s&hashtags=%s",
							URLEncoder.encode("https://poipiku.com/"+cResults.m_cUser.m_nUserId+"/", "UTF-8"),
							URLEncoder.encode(String.format("%s%s", cResults.m_cUser.m_strNickName, _TEX.T("Twitter.UserAddition")), "UTF-8"),
							URLEncoder.encode(_TEX.T("THeader.Title"), "UTF-8"));
					%>
					<%if(!cCheckLogin.m_bLogin) {%>
					<a id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow" href="/"><%=_TEX.T("IllustV.Follow")%></a>
					<a id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" href="/"></a>
					<%} else if(cResults.m_bOwner) {%>
					<a class="BtnBase UserInfoCmdFollow" href="/MyEditSettingPcV.jsp"><i class="fas fa-cog"></i> <%=_TEX.T("MyEditSetting.Title.Setting")%></a>
					<a class="BtnBase UserInfoCmdFollow" href="<%=strTwitterUrl%>" target="_blank"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.ShareBtn")%></a>
					<%} else if(cResults.m_bBlocking){%>
					<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" style="display: none;" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
					<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock Selected" onclick="UpdateBlock()"></span>
					<%} else if(cResults.m_bBlocked){%>
					<%} else if(cResults.m_bFollow){%>
					<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%> Selected" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Following")%></span>
					<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock " onclick="UpdateBlock()"></span>
					<%} else {%>
					<span id="UserInfoCmdFollow" class="BtnBase UserInfoCmdFollow UserInfoCmdFollow_<%=cResults.m_cUser.m_nUserId%>" onclick="UpdateFollow(<%=cCheckLogin.m_nUserId%>, <%=cResults.m_cUser.m_nUserId%>)"><%=_TEX.T("IllustV.Follow")%></span>
					<span id="UserInfoCmdBlock" class="typcn typcn-cancel BtnBase UserInfoCmdBlock" onclick="UpdateBlock()"></span>
					<%}%>
					<%if(!cResults.m_bOwner) {%>
					<span class="IllustItemCommandSub">
						<a class="IllustItemCommandTweet fab fa-twitter-square" href="<%=strTwitterUrl%>" target="_blank"></a>
					</span>
					<%}%>
				</span>
				<%if(cResults.m_bOwner) {%>
				<span class="UserInfoState">
					<a class="UserInfoStateItem" href="/FollowListPcV.jsp">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follow")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowNum%></span>
					</a>
					<a class="UserInfoStateItem" href="/FollowerListPcV.jsp">
						<span class="UserInfoStateItemTitle"><%=_TEX.T("IllustListV.Follower")%></span>
						<span class="UserInfoStateItemNum"><%=cResults.m_cUser.m_nFollowerNum%></span>
					</a>
				</span>
				<%}%>
			</div>
		</div>

		<div class="Wrapper">
			<div id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_PC, _TEX)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMid.jspf"%>
					<%}%>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/IllustListPcV.jsp", "&ID="+cResults.m_nUserId, cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>