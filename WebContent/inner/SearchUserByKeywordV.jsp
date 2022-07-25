<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);

if(SP_REVIEW && !checkLogin.m_bLogin) {
	if(isApp){
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartPoipikuV.jsp").forward(request,response);
	}
	return;
}

if(!Util.isSmartPhone(request)) {
	getServletContext().getRequestDispatcher("/SearchUserByKeywordGridPcV.jsp").forward(request,response);
	return;
}

SearchUserByKeywordC cResults = new SearchUserByKeywordC();
cResults.getParam(request);
String strKeywordHan = Util.toSingle(cResults.m_strKeyword);
if(strKeywordHan.matches("^[0-9]+$")) {
	String strUrl = isApp ? "/IllustListAppV.jsp?ID=" : "/IllustListPcV.jsp?ID=";
	response.sendRedirect(Common.GetPoipikuUrl(strUrl + strKeywordHan));
	return;
}
boolean bRtn = cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(isApp){%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdSearchUserPcHeader.jsp"%>
		<script type="text/javascript">
			$(function(){
				$('#MenuNew').addClass('Selected');
			});
		</script>

		<script>
			$(function(){
				$('#HeaderSearchWrapper').attr("action","/SearchUserByKeywordPcV.jsp");
				$('#HeaderSearchBtn').on('click', SearchUserByKeyword);
			});
		</script>

		<style>
			body {padding-top: 79px !important;}
		</style>
		<%}%>

		<meta name="description" content="<%=Util.toStringHtml(String.format(_TEX.T("SearchUserByKeyword.Title.Desc"), cResults.m_strKeyword))%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("SearchUserByKeyword.Title")%></title>
		<script>
			var g_nPage = 1;
			var g_bAdding = false;
			function addContents() {
				if(g_bAdding) return;
				g_bAdding = true;
				var $objMessage = $("<div/>").addClass("Waiting");
				$("#IllustThumbList").append($objMessage);
				$.ajax({
					"type": "post",
					"data": {"PG" : g_nPage, "KWD" :  decodeURIComponent("<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>")},
					"url": "/f/SearchUserByKeyword<%=isApp?"App":""%>F.jsp",
					"success": function(data) {
						if($.trim(data).length>0) {
							g_nPage++;
							$('#InfoMsg').hide();
							$("#IllustThumbList").append(data);
							g_bAdding = false;
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						} else {
							$(window).unbind("scroll.addContents");
						}
						$(".Waiting").remove();
					},
					"error": function(req, stat, ex){
						DispMsg('Connection error');
					}
				});
			}

			$(function(){
				$(window).bind("scroll.addContents", function() {
					$(window).height();
					if($("#IllustThumbList").height() - $(window).height() - $(window).scrollTop() < 400) {
						addContents();
					}
				});
			});
		</script>
	</head>

	<body>
		<%if(isApp){%>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>
		<%}else{%>
		<%String searchType = "Contents";%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem Selected" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>
		<%}%>

		<article class="Wrapper GridList">
			<section id="IllustThumbList" class="IllustThumbList">
				<%int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CUser cUser = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toHtmlUserMini(cUser, CCnv.MODE_SP, _TEX, nSpMode)%>
					<%if((nCnt+1)%9==0) {%>
					<%@ include file="/inner/TAd336x280_mid.jsp"%>
					<%}%>
				<%}%>
			</section>
		</article>
	</body>
</html>