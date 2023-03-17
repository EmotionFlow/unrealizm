<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
if(Util.isBot(request)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}
boolean bSmartPhone = Util.isSmartPhone(request);

IllustViewC results = new IllustViewC();
results.getParam(request);

if(!checkLogin.m_bLogin || checkLogin.m_nUserId!=results.m_nUserId){
	response.sendRedirect(String.format("https://unrealizm.com/%d/%d.html", results.m_nUserId, results.m_nContentId));
	return;
}

boolean bRet = results.getResults(checkLogin);
if(!bRet || (bRet&&results.m_cUser.m_nUserId!=checkLogin.m_nUserId)) {
	response.sendRedirect("/NotFoundPcV.jsp");
	return;
}

// R18によるアドの切り替え
g_nSafeFilter = results.m_cContent.getAdSwitchId();

results.m_cContent.setThumb();
final String strFileUrl = results.m_cContent.thumbImgUrl;
final boolean bHidden = results.m_cContent.isHideThumbImg;	// テキスト用カバー画像表示フラグ

String strDesc = Util.deleteCrLf(results.m_cContent.m_strDescription);
String strTitle = CTweet.generateState(results.m_cContent, _TEX) +  CTweet.generateFileNum(results.m_cContent, _TEX) + " " + Util.subStrNum(strDesc, 10) + " " + String.format(_TEX.T("Tweet.Title"), results.m_cContent.m_cUser.m_strNickName) + " | " + _TEX.T("THeader.Title");;
strDesc = Util.deleteCrLf(strDesc) + String.format(_TEX.T("Tweet.Title"), results.m_cContent.m_cUser.m_strNickName);
String strUrl = "https://unrealizm.com/"+results.m_cContent.m_nUserId+"/"+results.m_cContent.m_nContentId+".html";
ArrayList<String> vResult = Emoji.getDefaultEmoji(checkLogin.m_nUserId);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
<head>
	<%=isApp?"<!-- ":""%>
	<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
	<%=isApp?" -->":""%>
	<%=!isApp?"<!-- ":""%>
	<%@ include file="/inner/THeaderCommon.jsp"%>
	<%=!isApp?" -->":""%>

	<%@ include file="/inner/TCreditCard.jsp"%>
	<%@ include file="/inner/TSendEmoji.jsp"%>
	<%@ include file="/inner/TReplyEmoji.jsp"%>
	<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
	<meta name="twitter:card" content="summary_large_image" />
	<meta name="twitter:site" content="@pipajp" />
	<meta name="twitter:title" content="<%=CTweet.generateMetaTwitterTitle(results.m_cContent, _TEX)%>" />
	<meta name="twitter:description" content="<%=CTweet.generateMetaTwitterDesc(results.m_cContent, _TEX)%>" />
	<meta name="twitter:image" content="https://<%=Common.GetUrl(strFileUrl)%>" />
	<link rel="canonical" href="<%=strUrl%>" />
	<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
	<title><%=Util.toDescString(strTitle)%></title>
	<script type="application/ld+json">
		{
			"@context":"http://schema.org",
			"@type":"ItemList",
			"itemListElement":[
				{"@type":"ListItem", "position":1, "url":"<%=strUrl%>", "name": "<%=Util.toDescString(strTitle)%>", "image": "https:<%=Common.GetUrl(strFileUrl)%>"}
			]
		}
		</script>

	<script type="text/javascript">
		<%if(!isApp){%>
		$(function(){
			$('#MenuMe').addClass('Selected');
		});
		<%}%>
	</script>

	<script type="text/javascript">
		$(function(){
			<%if(!bHidden && results.m_cContent.m_nEditorId==Common.EDITOR_TEXT) {%>
			var frame_height = $('#IllustItemText_'+ <%=results.m_cContent.m_nContentId%> ).height();
			var text_height = $('#IllustItemText_'+ <%=results.m_cContent.m_nContentId%> + ' .IllustItemThumbText').height();
			if(frame_height>=text_height) {
				$('.IllustItemExpandBtn').hide();
			}
			<%}%>
		});
	</script>

	<%@ include file="/inner/TDeleteContent.jsp"%>

	<script type="text/javascript">
		var g_nPage = 0;
		var g_bAdding = false;
		function addContents() {
			if(g_bAdding) return;
			g_bAdding = true;
			var $objMessage = $("<div/>").addClass("Waiting");
			$("#IllustItemList").append($objMessage);
			$.ajax({
				"type": "post",
				"data": {
					"ID" : <%=results.m_cContent.m_nUserId%>,
					"TD" : <%=results.m_cContent.m_nContentId%>,
					"PG" : g_nPage,
					"MD" : <%=CCnv.MODE_PC%>,
					"ADF" : <%=results.m_cContent.m_nSafeFilter%>},
				"url": "/f/MyIllustView<%=isApp?"App":""%>F.jsp",
				"success": function(data) {
					if($.trim(data).length>0) {
						g_nPage++;
						$("#IllustItemList").append(data);
						$(".Waiting").remove();
						g_bAdding = false;
						if(g_nPage>0) {
							console.log(location.pathname+'/'+g_nPage+'.html');
							gtag('config', 'UA-125150180-1', {'page_location': location.pathname+'/'+g_nPage+'.html'});
						}
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
			addContents();
			$(window).bind("scroll.addContents", function() {
				$(window).height();
				if($("#IllustItemList").height() - $(window).height() - $(window).scrollTop() < 400) {
					addContents();
				}
			});
			$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Util.toStringHtml(results.m_cUser.m_strNickName), results.m_nContentsNumTotal)%>');
			<%if(!bSmartPhone) {%>
			$("#AnalogicoInfo .AnalogicoMoreInfo").html('<%=_TEX.T("Unrealizm.Info.RegistNow")%>');
			<%}%>
		});
	</script>

	<style>
		<%if(!results.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(results.m_cUser.m_strHeaderFileName)%>');}
		<%}%>
		<%if(!bSmartPhone) {%>
		.Wrapper.ViewPc {flex-flow: row-reverse wrap;}
		.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 81px;}
		.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
		.IllustItem.Password .IllustItemThumb {min-height: 240px;}
		<%}%>
	</style>
</head>

<body>

<%if(!isApp){%>
	<%@ include file="/inner/TMenuPc.jsp"%>
	<%if(bSmartPhone){%>
	<script>$(function () {
		$("#MenuSearch").hide();
		$("#MenuSettings").show();
	})</script>
	<%}%>
<%}else{%>
	<%@ include file="/inner/TMenuApp.jsp" %>
<%}%>

<article class="Wrapper ViewPc">

	<%if(!bSmartPhone && !isApp) {%>
	<aside class="PcSideBar" style="margin-top: 30px;">
		<div class="PcSideBarItem">
			<%@ include file="/inner/TAdPc300x250_top_right.jsp"%>
		</div>

		<div class="PcSideBarItem">
			<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>
		</div>

		<div class="FixFrame">
			<div class="PcSideBarItem">
				<%@ include file="/inner/TAdPc300x250_bottom_right.jsp"%>
			</div>
		</div>
	</aside>
	<%}%>

	<section id="IllustItemList" class="IllustItemList">
		<%if(isApp){%>
		<%=CCnv.MyContent2Html(results.m_cContent, checkLogin, CCnv.MODE_SP, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>
		<%}else{%>
		<%=CCnv.MyContent2Html(results.m_cContent, checkLogin, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW)%>
		<%}%>
	</section>

	<%if(isApp) {%>
	<%@ include file="/inner/TAdEvent_top_rightV.jsp"%>
	<%}else if(bSmartPhone){%>
	<%@ include file="/inner/TAdEvent_top_rightPcV.jsp"%>
	<%}%>
</article>

<%if(!isApp){%>
<%@ include file="/inner/TFooter.jsp"%>
<%}%>
</body>
</html>