<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
boolean bSmartPhone = Util.isSmartPhone(request);

RandomPickupC results = new RandomPickupC();
results.getParam(request);
results.SELECT_MAX_GALLERY = 45;
boolean bRtn = results.getResults(checkLogin);

boolean isApp = false;
ArrayList<String> emojiList = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
final int nSpMode = isApp ? CCnv.SP_MODE_APP : CCnv.SP_MODE_WVIEW;
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<%@ include file="/inner/ad/TAdGridPcHeader.jsp"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("RandomPickup.Title")%></title>

		<script type="text/javascript">
		$(function(){
			$('body, .Wrapper').each(function(index, element){
				$(element).on("drag dragstart",function(e){return false;});
			});
			$('#MenuNew').addClass('Selected');
			$('#MenuRandom').addClass('Selected');
		});
		</script>
		<style>
			body {padding-top: 51px !important;}
		</style>
	</head>

	<body>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<nav class="TabMenuWrapper">
			<ul class="TabMenu">
				<li><a class="TabMenuItem" href="/NewArrivalPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Recent")%></a></li>
				<li><a class="TabMenuItem Selected" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a></li>
			</ul>
		</nav>

		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>

		<article class="Wrapper GridList" style="padding-top: 28px">
			<section id="IllustThumbList" class="IllustItemList2Column">
				<%for(CContent cContent: results.contentList) {%>
					<%=CCnv.Content2Html2Column(cContent, checkLogin, bSmartPhone?CCnv.MODE_SP:CCnv.MODE_PC, _TEX, emojiList, CCnv.VIEW_DETAIL, nSpMode)%>
				<%}%>
			</section>
		</article>

		<div style="display: block; text-align: center; margin: 15px 0; width: 100%; float: left;">
			<a class="BtnBase" href="/RandomPickupPcV.jsp"><%=_TEX.T("THeader.Menu.Home.Random")%></a>
		</div>

		<%@ include file="/inner/TFooterSingleAd.jsp"%>
	</body>
</html>
