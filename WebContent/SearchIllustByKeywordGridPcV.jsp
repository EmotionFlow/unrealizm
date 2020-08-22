<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

SearchIllustByKeywordGridC cResults = new SearchIllustByKeywordGridC();
cResults.getParam(request);
String strKeywordHan = Util.toSingle(cResults.m_strKeyword);
if(strKeywordHan.matches("^[0-9]+$")) {
	String strUrl = "/";
	response.sendRedirect("/" + strKeywordHan + "/");
	return;
}
boolean bRtn = cResults.getResults(cCheckLogin);
g_strSearchWord = cResults.m_strKeyword;
String strEncodedKeyword = URLEncoder.encode(cResults.m_strKeyword, "UTF-8");
String strTitle = cResults.m_strKeyword + " | " + _TEX.T("THeader.Title");
String strDesc = String.format(_TEX.T("SearchIllustByTag.Title.Desc"), cResults.m_strKeyword, cResults.m_nContentsNum);
String strUrl = "https://poipiku.com/SearchIllustByTagPcV.jsp?KWD="+strEncodedKeyword;
String strFileUrl = cResults.m_strRepFileName;
ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Emoji.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<%@ include file="/inner/TSweetAlert.jsp"%>
		<%@ include file="/inner/TSendEmoji.jsp"%>
		<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
		<meta name="twitter:site" content="@pipajp" />
		<meta property="og:url" content="<%=strUrl%>" />
		<meta property="og:title" content="<%=Util.toDescString(strTitle)%>" />
		<meta property="og:description" content="<%=Util.toDescString(strDesc)%>" />
		<link rel="canonical" href="<%=strUrl%>" />
		<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
		<title><%=Util.toDescString(strTitle)%></title>

		<script type="text/javascript">
		$(function(){
			$('#MenuNew').addClass('Selected');
			$('#HeaderSearchWrapper').attr("action","/SearchIllustByKeywordPcV.jsp");
			$('#HeaderSearchBtn').on('click', SearchIllustByKeyword);
		});
		</script>
		<script type="text/javascript">
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

			$(function(){
				$('body, .Wrapper').each(function(index, element){
					$(element).on("contextmenu drag dragstart copy",function(e){return false;});
				});
			});
		</script>
		<style>
			body {padding-top: 83px !important;}
			.IllustItem .IllustItemCommand .IllustItemCommandSub .IllustItemCommandDelete {display: none;}
			.IllustThumbList .IllustThumbPane {width: 374px; float: left;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem Selected" href="/SearchIllustByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Illust")%></a></li>
				<li><a class="TabMenuItem" href="/SearchTagByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.Tag")%></a></li>
				<li><a class="TabMenuItem" href="/SearchUserByKeywordPcV.jsp?KWD=<%=URLEncoder.encode(cResults.m_strKeyword, "UTF-8")%>"><%=_TEX.T("Search.Cat.User")%></a></li>
			</ul>
		</nav>

		<article class="Wrapper GridList">
			<header class="SearchResultTitle" style="box-sizing: border-box; padding: 0 5px; float: none;">
				<h2 class="Keyword"><i class="fas fa-search"></i> <%=Common.ToStringHtml(cResults.m_strKeyword)%></h2>
				<%if(!cCheckLogin.m_bLogin) {%>
				<a class="BtnBase TitleCmdFollow" href="/"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else if(!cResults.m_bFollowing) {%>
				<a class="BtnBase TitleCmdFollow" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_SEARCH%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%} else {%>
				<a class="BtnBase TitleCmdFollow Selected" href="javascript:void(0)" onclick="UpdateFollowTag(<%=cCheckLogin.m_nUserId%>, '<%=Common.ToStringHtml(cResults.m_strKeyword)%>', <%=Common.FOVO_KEYWORD_TYPE_SEARCH%>)"><i class="fas fa-star"></i> <%=_TEX.T("IllustV.Favo")%></a>
				<%}%>
			</header>

			<section id="IllustThumbList" class="IllustThumbList">
				<%@ include file="/inner/ad/TAdGridPc336x280_right_top.jsp"%>
				<div class="IllustThumbPane">
					<%for(int nCnt=0; nCnt<cResults.m_vContentList.size(); nCnt+=3) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%if(nCnt==6){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_1.jsp"%><%}%>
						<%=CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%}%>
				</div>
				<div class="IllustThumbPane">
					<%for(int nCnt=1; nCnt<cResults.m_vContentList.size(); nCnt+=3) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%if(nCnt==16){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_2.jsp"%><%}%>
						<%=CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%}%>
				</div>
				<div class="IllustThumbPane">
					<%for(int nCnt=2; nCnt<cResults.m_vContentList.size(); nCnt+=3) {
						CContent cContent = cResults.m_vContentList.get(nCnt);%>
						<%if(nCnt==23){%><%@ include file="/inner/ad/TAdGridPc336x280_mid_3.jsp"%><%}%>
						<%=CCnv.Content2Html(cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult)%>
					<%}%>
				</div>
			</section>

			<nav class="PageBar">
				<%=CPageBar.CreatePageBarPc("/SearchIllustByKeywordPcV.jsp", String.format("&KWD=%s", strEncodedKeyword), cResults.m_nPage, cResults.m_nContentsNum, cResults.SELECT_MAX_GALLERY)%>
			</nav>
		</article>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>