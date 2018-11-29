<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

MyHomeC cResults = new MyHomeC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyHomePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<script>
			function DeleteContent(nUserId, nContentId) {
				if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
				DeleteContentBase(nUserId, nContentId);
				return false;
			}

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){if(!$(e.target).is(".MyUrl")){return false;}});
				});
			});
		</script>
		<style>
			body {padding-top: 83px !important;}
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>

		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem Selected" href="/MyHomePcV.jsp"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
				<a class="TabMenuItem" href="/MyHomeTagPcV.jsp"><%=_TEX.T("THeader.Menu.Home.FollowTag")%></a>
				<a class="TabMenuItem" href="/MyBookmarkListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Bookmark")%></a>
				<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
				<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
				<a class="TabMenuItem" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
				<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper ViewPc">
			<div id="IllustItemList" class="IllustItemList">

				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 150px 10px 50px 10px; text-align: center; box-sizing: border-box;">
					ポイピクへようこそ<br />
					<br />
					ポイピクはフォローしてもフォロー解除しても<br />
					相手に伝わりません。<br />
					とりあえず気になった人をフォローしてみましょう！<br />
					<br />
					<a class="BtnBase" href="/NewArrivalPcV.jsp">
						フォローする人を探す
					</a>
				</div>
				<%}%>

				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%= CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%if((nCnt+1)%5==0 && bSmartPhone) {%>
					<%@ include file="/inner/TAdMid.jspf"%>
					<%}%>
				<%}%>
			</div>

			<%if(!bSmartPhone) {%>
			<div class="PcSideBar" style="margin-top: 30px;">
				<div class="FixFrame">
					<div class="PcSideBarItem">
						<%@ include file="/inner/TAdPc300x250_top_right.jspf"%>
					</div>

					<div class="PcSideBarItem">
						<div class="PcSideBarItemTitle"><%=_TEX.T("Twitter.Share.MyUrl")%></div>
						<%
						String strTwitterUrl=String.format("https://twitter.com/share?url=%s&text=%s&hashtags=%s",
								URLEncoder.encode("https://poipiku.com/"+cCheckLogin.m_nUserId+"/", "UTF-8"),
								URLEncoder.encode(String.format("%s%s", cCheckLogin.m_strNickName, _TEX.T("Twitter.UserAddition")), "UTF-8"),
								URLEncoder.encode(_TEX.T("THeader.Title"), "UTF-8"));
						%>
						<div style="text-align: center;">
							<input id="MyUrl" class="MyUrl" type="text" value="https://poipiku.com/<%=cCheckLogin.m_nUserId%>/" onclick="this.select(); document.execCommand('copy');" style="box-sizing: border-box; width: 100%; padding: 5px; margin: 0 0 10px 0;" />
							<a class="BtnBase" href="javascript:void(0)" onclick="$('#MyUrl').select(); document.execCommand('Copy');"><i class="far fa-copy"></i> <%=_TEX.T("Twitter.Share.Copy.Btn")%></a>
							<a class="BtnBase" href="<%=strTwitterUrl%>" target="_blank"><i class="fab fa-twitter"></i> <%=_TEX.T("Twitter.Share.MyUrl.Btn")%></a>
						</div>
					</div>

					<div class="PcSideBarItem">
						<%@ include file="/inner/TAdPc300x250_bottom_right.jspf"%>
					</div>
				</div>
			</div>
			<%}%>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/MyHomePcV.jsp", "", cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>