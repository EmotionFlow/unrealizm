<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/SearchIllustByGenreGridPcV.jsp").forward(request,response);
	return;
}

SearchIllustByGenreC results = new SearchIllustByGenreC();
results.getParam(request);
results.SELECT_MAX_GALLERY = 45;
boolean bRtn = results.getResults(checkLogin);
String strTitle = String.format(_TEX.T("SearchIllustByGenre.Title"), results.genre.genreName) + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("SearchIllustByGenre.Title.Desc"), results.genre.genreName, results.contentsNum);
String strUrl = "https://ai.poipiku.com/SearchIllustByGenrePcV.jsp?GD="+results.genreId;
String strFileUrl = results.repFileName;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdHomePcHeader.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuGenre').addClass('Selected');
		});
		</script>

		<script type="text/javascript" src="/js/showmore.js"></script>
		<script>
		$(function() {
			$('.showmore').showMore({
				speedDown : 300,
				speedUp : 300,
				//height : '50px',
				showText : '<i class="fas fa-chevron-down"></i>',
				hideText : '<i class="fas fa-chevron-up"></i>'
			});
		});
		</script>
		<style>
			.showmore {height: 60px; position: relative;}
			.showmore_content { position:relative;overflow: hidden;}
			.showmore_trigger { width:100%; height:20px; padding: 40px 0 0 0; line-height:20px; cursor:pointer;text-align: center; font-size: 20px; position: absolute; bottom: 0; left: 0; z-index: 999; background: linear-gradient(to bottom,rgba(255,255,255,0) 0%,rgba(255,255,255,1.0) 100%);}
			.showmore_trigger span { display:block;}
		</style>
		<%if(!results.genre.genreImageBg.isEmpty()) {%>
		<style>
			.SearchGenreFrame {background-image:url('<%=Common.GetUrl(results.genre.genreImageBg)%>');}
		</style>
		<%}%>

	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<header class="SearchGenreFrame">
			<div class="SearchGenre">
				<div class="SearchEdit">
					<a class="SearchEditCmd PoiPassInline" href="/EditGenreInfoPcV.jsp?ID=<%=checkLogin.m_nUserId%>&GD=-1"><i class="fas fa-pencil-alt"></i><%=_TEX.T("SearchIllustByGenre.New")%></a>
					<a class="SearchEditCmd PoiPassInline" href="/EditGenreInfoPcV.jsp?ID=<%=checkLogin.m_nUserId%>&GD=<%=results.genre.genreId%>"><i class="fas fa-pencil-alt"></i> <%=_TEX.T("SearchIllustByGenre.Edit")%></a>
				</div>
				<div class="SearchGenreMeta">
					<div class="SearchGenreTitle">
						<span class="GenreImage" style="background-image: url('<%=Common.GetUrl(results.genre.genreImage)%>');" ></span>
						<h2 class="GenreNameOrg"><%=Util.toStringHtml(results.genre.genreName)%></h2>
					</div>
					<div class="SearchGenreDesc"><%=Util.toStringHtml(results.genre.genreDesc)%></div>
				</div>
				<div class="SearchGenreCmd">
					<%if(!checkLogin.m_bLogin) {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
					<%} else if(!results.following) {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowGenre(<%=checkLogin.m_nUserId%>, <%=results.genreId%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
					<%} else {%>
					<a class="CmdBtn BtnBase Rev TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowGenre(<%=checkLogin.m_nUserId%>, <%=results.genreId%>)"><i class="fa fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
					<%}%>
				</div>
			</div>
			<div class="SearchGenreDetail showmore"><%=Common.AutoLinkHtml(Util.toStringHtml(results.genre.genreDetail), CCnv.SP_MODE_WVIEW)%></div>
		</header>

		<article class="Wrapper ThumbList">

			<%if(checkLogin.m_nPassportId==Common.PASSPORT_OFF && g_bShowAd) {%>
			<span style="display: flex; flex-flow: row nowrap; justify-content: space-around; align-items: center; float: left; width: 100%; margin: 12px 0 0 0;">
				<%@ include file="/inner/ad/TAdHomeSp300x100_top.jsp"%>
			</span>
			<%}%>

			<section id="IllustThumbList" class="IllustThumbList">
				<%for(int nCnt=0; nCnt<results.contentList.size(); nCnt++) {
					CContent cContent = results.contentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%if(nCnt==14 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_1.jsp"%><%}%>
					<%if(nCnt==29 && bSmartPhone) {%><%@ include file="/inner/ad/TAdHomeSp336x280_mid_2.jsp"%><%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchIllustByGenrePcV.jsp", String.format("&GD=%d", results.genreId) , results.page, results.contentsNum, results.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
