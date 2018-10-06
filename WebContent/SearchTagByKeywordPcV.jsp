<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);

SearchTagByKeywordC cResults = new SearchTagByKeywordC();
cResults.getParam(request);
boolean bRtn = cResults.getResults(cCheckLogin);
g_strSearchWord = cResults.m_strKeyword;
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchTagByKeyword.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuHome').addClass('Selected');
		});
		</script>

		<script>
			$(function(){
				$('#HeaderSearchWrapper').attr("action","/SearchTagByKeywordPcV.jsp");
				$('#HeaderSearchBtn').on('click', SearchTagByKeyword);
			});
		</script>

		<style>
			body {padding: 83px 0 51px 0 !important;}

			<%if(Util.isSmartPhone(request)) {%>
			#HeaderTitleWrapper {display: none;}
			#HeaderSearchWrapper {display: block;}
			<%}%>
		</style>
	</head>

	<body>
		<div class="TabMenuWrapper">
			<div class="TabMenu">
				<a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Illust")%></a>
				<a class="TabMenuItem Selected" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Tag")%></a>
				<a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.User")%></a>
			</div>
		</div>

		<%@ include file="/inner/TMenuPc.jspf"%>

		<div class="Wrapper ItemList">

			<div id="IllustThumbList" class="IllustItemList">
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CTag cTag = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toHtml(cTag, CCnv.MODE_PC, _TEX)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAdMidWide.jspf"%>
					<%}%>
				<%}%>
			</div>

			<div class="PageBar">
				<%=CPageBar.CreatePageBar("/SearchTagByKeywordPcV.jsp", "&KWD="+URLEncoder.encode(cResults.m_strKeyword, "UTF-8"), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</div>
		</div>

		<%@ include file="/inner/TFooter.jspf"%>
	</body>
</html>