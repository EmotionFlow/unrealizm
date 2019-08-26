<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

if(!bSmartPhone) {
	getServletContext().getRequestDispatcher("/event/20190804/TopGridPcV.jsp").forward(request,response);
	return;
}

SearchIllustByTagC cResults = new SearchIllustByTagC();
cResults.getParam(request);
cResults.m_strKeyword = "星座占い";
cResults.SELECT_MAX_GALLERY = 36;
boolean bRtn = cResults.getResults(cCheckLogin);
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - ポイピク星座占い</title>
		<style>
			.SettingListItem a {color: #fff; text-decoration: underline; font-weight: bold;}
			.SettingListItem a:hover {color: #5db;}
			.AnalogicoInfo {display: none;}
			.SettingList .SettingListItem .SettingListTitle {text-align: center; font-size: 20x; font-weight: bold; margin: 20px 0 0 0;}
			.SettingList .SettingListItem {margin: 0 0 20px 0;}
			<%if(!Util.isSmartPhone(request)){%>
			.Wrapper {
				width: 360px;
				min-height: 60px;
				position: relative;
			}
			.SettingList {
				max-width: 360px;
			}
			.SettingList .SettingListItem .SettingListTitle {font-size: 24px;}
			.SettingBody {font-size: 20px;}
			<%}%>
			.SettingBody {position: relative;}
			.temp_dl_btn {display: block; position: absolute; width: 340px; height: 47px; left: 10px; z-index: 1;}
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
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingBody">
					<img id="MainImage" style="width: 100%;" usemap="#MapLinks" src="/event/20190804/seiza_20190826.png" />
					<map name="MapLinks">
						<area shape="circle" coords="51, 738, 40" onclick="$('html, body').animate({scrollTop:1020});">
						<area shape="circle" coords="138, 738, 40" onclick="$('html, body').animate({scrollTop:1560});">
						<area shape="circle" coords="225, 738, 40" onclick="$('html, body').animate({scrollTop:2100});">
						<area shape="circle" coords="311, 738, 40" onclick="$('html, body').animate({scrollTop:2640});">
						<area shape="circle" coords="51, 825, 40" onclick="$('html, body').animate({scrollTop:3180});">
						<area shape="circle" coords="138, 825, 40" onclick="$('html, body').animate({scrollTop:3718});">
						<area shape="circle" coords="225, 825, 40" onclick="$('html, body').animate({scrollTop:4255});">
						<area shape="circle" coords="311, 825, 40" onclick="$('html, body').animate({scrollTop:4795});">
						<area shape="circle" coords="51, 912, 40" onclick="$('html, body').animate({scrollTop:5335});">
						<area shape="circle" coords="138, 912, 40" onclick="$('html, body').animate({scrollTop:5872});">
						<area shape="circle" coords="225, 912, 40" onclick="$('html, body').animate({scrollTop:6410});">
						<area shape="circle" coords="311, 912, 40" onclick="$('html, body').animate({scrollTop:6950});">

						<area shape="rect" coords="31, 7500, 330, 7550" onclick="$('html, body').animate({scrollTop:0});">
					</map>
					<a class="temp_dl_btn" style="top: 1500px" href="/event/20190804/seiza__20190826/seiza_tenp_ohitsuji.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 2040px" href="/event/20190804/seiza__20190826/seiza_tenp_oushi.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 2580px" href="/event/20190804/seiza__20190826/seiza_tenp_futago.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 3120px" href="/event/20190804/seiza__20190826/seiza_tenp_kani.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 3660px" href="/event/20190804/seiza__20190826/seiza_tenp_shishi.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 4198px" href="/event/20190804/seiza__20190826/seiza_tenp_otome.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 4737px" href="/event/20190804/seiza__20190826/seiza_tenp_tenbin.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 5276px" href="/event/20190804/seiza__20190826/seiza_tenp_sasori.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 5815px" href="/event/20190804/seiza__20190826/seiza_tenp_ite.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 6353px" href="/event/20190804/seiza__20190826/seiza_tenp_yagi.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 6890px" href="/event/20190804/seiza__20190826/seiza_tenp_mizugame.png" download="template.png"></a>
					<a class="temp_dl_btn" style="top: 7430px" href="/event/20190804/seiza__20190826/seiza_tenp_uo.png" download="template.png"></a>
				</div>
			</div>
		</article>

		<article class="Wrapper ThumbList">
			<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px;">
				<h2 class="Keyword">#<%=Common.ToStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!cCheckLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.m_bFollowing) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_TAG%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_TAG%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%if(!bSmartPhone) {%>
				<%@ include file="/inner/TAdPc300x250_top_right.jsp"%>
				<%}%>
				<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt++) {
					CContent cContent = cResults.m_vContentList.get(nCnt);%>
					<%=CCnv.toThumbHtml(cContent, CCnv.TYPE_USER_ILLUST, CCnv.MODE_PC, strEncodedKeyword, _TEX)%>
					<%if(nCnt==17) {%>
					<%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
					<%}%>
				<%}%>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBar("/SearchIllustByTagPcV.jsp", String.format("&KWD=%s", strEncodedKeyword) , cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>