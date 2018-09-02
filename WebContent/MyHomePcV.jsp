
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/MyHomeC.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

if(!cCheckLogin.m_bLogin) {
	response.sendRedirect("/");
	return;
}

MyHomeCParam cParam = new MyHomeCParam();
cParam.GetParam(request);
cParam.m_nAccessUserId = cCheckLogin.m_nUserId;

MyHomeC cResults = new MyHomeC();
boolean bRtn = cResults.GetResults(cParam);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyHomePc.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<script>
			function DeleteContent(nContentId) {
				if(!window.confirm('<%=_TEX.T("IllustListV.CheckDelete")%>')) return;
				DeleteContentBase(<%=cCheckLogin.m_nUserId%>, nContentId);
				return false;
			}
		</script>
	</head>

	<body>
		<div id="DispMsg"></div>

		<div class="TabMenu">
			<a class="TabMenuItem Selected" href="/"><%=_TEX.T("THeader.Menu.Home.Follow")%></a>
			<a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a>
			<a class="TabMenuItem" href="/PopularIllustListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Popular")%></a>
			<a class="TabMenuItem" href="/PopularTagListPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Tag")%></a>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper">
			<div id="IllustItemList" class="IllustItemList">
				<%if(cResults.m_vContentList.size()<=0) {%>
				<div id="InfoMsg" style="display:block; float: left; width: 100%; padding: 160px 0; text-align: center;">
					ポイピクへようこそ<br />
					<br />
					描くのに飽きたらポイポイ<br />
					ポイポイしたら誰かがきっと励ましてくれる<br />
					<br />
					<br />
					<a class="BtnBase" href="/NewArrivalPcV.jsp">
						フォローする人を探す
					</a>
				</div>
				<%}%>

				<%for(CContent cContent : cResults.m_vContentList) {%>
				<div class="IllustItem" id="IllustItem_<%=cContent.m_nContentId%>">
					<div class="IllustItemUser">
						<a class="IllustItemUserThumb" href="/IllustListPcV.jsp?ID=<%=cContent.m_nUserId%>">
							<img class="IllustItemUserThumbImg" src="<%=cContent.m_cUser.m_strFileName%>_120.jpg" />
						</a>
						<a class="IllustItemUserName" href="/IllustListPcV.jsp?ID=<%=cContent.m_nUserId%>">
							<%=Common.ToStringHtml(cContent.m_cUser.m_strNickName)%>
						</a>
					</div>

					<div class="IllustItemCommand">
						<span class="Category C<%=cContent.m_nCategoryId%>"><%=_TEX.T(String.format("Category.C%d", cContent.m_nCategoryId))%></span>
						<div class="IllustItemCommandSub">
							<%String strUrl = URLEncoder.encode("https://poipiku.com/"+cContent.m_nUserId+"/"+cContent.m_nContentId+".html", "UTF-8"); %>
							<a class="IllustItemCommandTweet fab fa-twitter-square" href="https://twitter.com/share?url=<%=strUrl%>"></a>
							<%if(cContent.m_nUserId==cCheckLogin.m_nUserId) {%>
							<a class="IllustItemCommandDelete far fa-trash-alt" href="javascript:void(0)" onclick="DeleteContent(<%=cContent.m_nContentId%>)"></a>
							<%} else {%>
							<a class="IllustItemCommandInfo fas fa-info-circle" href="/ReportFormPcV.jsp?TD=<%=cContent.m_nContentId%>"></a>
							<%}%>
						</div>
					</div>

					<%if(!cContent.m_strDescription.isEmpty()) {%>
					<div class="IllustItemDesc">
						<%=Common.AutoLinkPc(Common.ToStringHtml(cContent.m_strDescription))%>
					</div>
					<%}%>

					<a class="IllustItemThumb" href="/IllustDetailPcV.jsp?TD=<%=cContent.m_nContentId%>" target="_blank">
						<img class="IllustItemThumbImg" src="<%=Common.GetUrl(cContent.m_strFileName)%>_640.jpg" />
					</a>

					<div class="IllustItemResList">
						<div class="IllustItemResListTitle">
							<%if(cContent.m_vComment.size()<=0) {%>
							<%=_TEX.T("Common.IllustItemRes.Title.Init")%>
							<%} else {%>
							<%=String.format(_TEX.T("Common.IllustItemRes.Title"), cContent.m_vComment.size())%>
							<%}%>
						</div>
						<%for(CComment comment : cContent.m_vComment) {%>
						<span class="ResEmoji"><%=Common.ToStringHtml(comment.m_strDescription)%></span>
						<%}%>
						<span id="ResEmojiAdd_<%=cContent.m_nContentId%>" class="ResEmojiAdd"><span class="fas fa-plus-square"></span></span>
					</div>

					<div class="IllustItemResBtnList">
						<%for(String strEmoji : Common.CATEGORY_EMOJI[cContent.m_nCategoryId]) {%>
						<a class="ResEmojiBtn" onclick="SendComment(<%=cContent.m_nContentId%>, '<%=strEmoji%>', <%=cCheckLogin.m_nUserId%>)"><%=strEmoji%></a>
						<%}%>
					</div>
				</div>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/MyHomePcV.jsp", "", cParam.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>