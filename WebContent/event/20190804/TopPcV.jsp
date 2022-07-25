<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/event/20190804/TopGridPcV.jsp").forward(request,response);
	return;
}

SearchIllustByTagC cResults = new SearchIllustByTagC();
cResults.getParam(request);
cResults.keyword = "星座占い";
cResults.selectMaxGallery = 36;
boolean bRtn = cResults.getResults(checkLogin);
String strEncodedKeyword = URLEncoder.encode(cResults.keyword, "UTF-8");
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - ポイピク星座占い</title>
		<style>
			.AnalogicoInfo {display: none;}
			.IllustItem .IllustItemCommand .IllustItemCommandSub .IllustItemCommandDelete {display: none;}
		</style>

		<style>
			<% int SEIZA_TOP = 520;%>
			.SettingBody.Seiza {display: block; height:7374px; background: top center url('/event/20190804/seiza_20191004.png') no-repeat; background-size: 360px; position: relative;}
			.SettingBody {font-size: 20px;}
			.SeizaLinkList {display: flex; flex-flow: row wrap; width: 348px; margin: 0 6px; position: absolute; z-index: 1; top: <%=SEIZA_TOP%>px;}
			.SeizaLinkList .SeizaLink {display: block; width: 25%; height: 87px;}
			.temp_dl_btn {display: block; position: absolute; width: 342px; height: 46.5px; left: 9px; z-index: 1;}
			.SeizaCmdUp {display: block; position: absolute; width: 300px; height: 54px; left: 30px; z-index: 1;}
		</style>

		<script>
			$(function(){
				$('#MainImage').on('click', function(e){
					console.log(e.offsetX, e.offsetY);
				});
			})
		</script>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%String searchType = "Contents";%>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody Seiza">
					<div class="SeizaLinkList">
						<%
						int POS=SEIZA_TOP+315;
						int DIFF=524;
						int MARG=-60;
						%>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*0%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*1%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*2%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*3%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*4%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*5%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*6%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*7%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*8%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*9%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*10%>});"></a>
						<a class="SeizaLink" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:<%=POS+DIFF*11%>});"></a>
					</div>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*1+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_ohitsuji.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*2+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_oushi.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*3+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_futago.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*4+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_kani.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*5+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_shishi.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*6+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_otome.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*7+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_tenbin.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*8+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_sasori.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*9+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_ite.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*10+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_yagi.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*11+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_mizugame.png"></a>
					<a class="temp_dl_btn" style="top: <%=POS+DIFF*12+MARG%>px" href="/event/20190804/seiza_20191004/seiza_tenp_uo.png"></a>

					<a class="SeizaCmdUp" style="top: <%=POS+DIFF*12+10%>px" href="javascript:void(0);" onclick="$('html, body').animate({scrollTop:0});"></a>
				</div>
			</div>
		</article>

		<article class="Wrapper ThumbList">
			<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px;">
				<h2 class="Keyword">#<%=Util.toStringHtml(cResults.keyword)%></h2>
				<%if(!checkLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.following) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.keyword)%>')"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=checkLogin.m_nUserId%>, '<%=Util.toStringHtml(cResults.keyword)%>')"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%
					for(int nCnt=0; nCnt<cResults.contentList.size(); nCnt++) {
							CContent cContent = cResults.contentList.get(nCnt);
				%>
					<%=CCnv.toThumbHtml(cContent, checkLogin, CCnv.MODE_SP, CCnv.SP_MODE_WVIEW, _TEX)%>
					<%if(nCnt==17) {%>
					<%@ include file="/inner/TAd336x280_mid.jsp"%>
					<%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarSp("/SearchIllustByTagPcV.jsp", String.format("&KWD=%s", strEncodedKeyword) , cResults.page, cResults.contentsNum, cResults.selectMaxGallery)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>