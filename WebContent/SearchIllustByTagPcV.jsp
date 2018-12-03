<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);

SearchIllustByTagC cResults = new SearchIllustByTagC();
cResults.getParam(request);
cResults.SELECT_MAX_GALLERY = 36;
boolean bRtn = cResults.getResults(cCheckLogin);
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
boolean bSmartPhone = Util.isSmartPhone(request);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=Common.ToStringHtml(String.format(_TEX.T("SearchIllustByTag.Title.Desc"), cResults.m_strKeyword, cResults.m_nContentsNum))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=Common.ToStringHtml(String.format(_TEX.T("SearchIllustByTag.Title"), cResults.m_strKeyword))%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuSearch').addClass('Selected');
		});
		</script>

	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper ThumbList">
			<div class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px;">
				<i class="fas fa-hashtag"></i> <%=Common.ToStringHtml(cResults.m_strKeyword)%>
				<%if(!cCheckLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.m_bFollowing) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_TAG%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_TAG%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</div>

			<div id="IllustThumbList" class="IllustThumbList">
				<%if(!bSmartPhone) {%>
				<%@ include file="/inner/TAdPc300x250_top_right.jspf"%>
				<%}%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_PC, strEncodedKeyword, _TEX)%>
					<%if(nCnt==17) {%>
					<%@ include file="/inner/TAdPc300x250_bottom_right.jspf"%>
					<%}%>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/SearchIllustByTagPcV.jsp", String.format("&KWD=%s", strEncodedKeyword) , cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>