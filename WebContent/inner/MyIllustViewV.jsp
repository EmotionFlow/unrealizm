<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
	CheckLogin cCheckLogin = new CheckLogin(request, response);
	boolean bSmartPhone = Util.isSmartPhone(request);

	IllustViewC cResults = new IllustViewC();
	cResults.getParam(request);

	if(!cCheckLogin.m_bLogin || cCheckLogin.m_nUserId!=cResults.m_nUserId){
		Log.d(String.format("https://poipiku.com/%d/%d.html", cResults.m_nUserId, cResults.m_nContentId));
		response.sendRedirect(String.format("https://poipiku.com/%d/%d.html", cResults.m_nUserId, cResults.m_nContentId));
		return;
	}

	boolean bRet = cResults.getResults(cCheckLogin);
	if(!bRet || Util.isBot(request.getHeader("user-agent")) || (bRet&&cResults.m_cUser.m_nUserId!=cCheckLogin.m_nUserId)) {
		response.sendRedirect("https://poipiku.com/NotFoundPcV.jsp");
		return;
	}

// R18によるアドの切り替え
	switch(cResults.m_cContent.m_nPublishId) {
		case Common.PUBLISH_ID_R18:
		case Common.PUBLISH_ID_R18G:
			g_nSafeFilter = Common.AD_ID_R18;
			break;
		default:
			g_nSafeFilter = Common.AD_ID_ALL;
			break;
	}

	String strFileUrl = "";
	switch(cResults.m_cContent.m_nPublishId) {
		case Common.PUBLISH_ID_R15:
		case Common.PUBLISH_ID_R18:
		case Common.PUBLISH_ID_R18G:
		case Common.PUBLISH_ID_PASS:
		case Common.PUBLISH_ID_LOGIN:
		case Common.PUBLISH_ID_FOLLOWER:
		case Common.PUBLISH_ID_T_FOLLOWER:
		case Common.PUBLISH_ID_T_FOLLOW:
		case Common.PUBLISH_ID_T_EACH:
		case Common.PUBLISH_ID_T_LIST:
			strFileUrl = Common.PUBLISH_ID_FILE[cResults.m_cContent.m_nPublishId];
			break;
		case Common.PUBLISH_ID_ALL:
		case Common.PUBLISH_ID_HIDDEN:
		default:
			strFileUrl = cResults.m_cContent.m_strFileName;
			break;
	}

	String strTitle = "";
	switch(cResults.m_cContent.m_nPublishId) {
		case Common.PUBLISH_ID_PASS:
			strTitle = _TEX.T("UploadFilePc.Option.Publish.Pass.Title");
			break;
		case Common.PUBLISH_ID_LOGIN:
			strTitle = _TEX.T("UploadFilePc.Option.Publish.Login");
			break;
		case Common.PUBLISH_ID_FOLLOWER:
			strTitle = _TEX.T("UploadFilePc.Option.Publish.Follower");
			break;
		case Common.PUBLISH_ID_T_FOLLOWER:
			strTitle = _TEX.T("UploadFilePc.Option.Publish.T_Follower");
			break;
		case Common.PUBLISH_ID_T_FOLLOW:
			strTitle = _TEX.T("UploadFilePc.Option.Publish.T_Follow");
			break;
		case Common.PUBLISH_ID_T_EACH:
			strTitle = _TEX.T("UploadFilePc.Option.Publish.T_Each");
			break;
		case Common.PUBLISH_ID_T_LIST:
			strTitle = _TEX.T("UploadFilePc.Option.Publish.T_List");
			break;
		case Common.PUBLISH_ID_HIDDEN:
			strTitle = _TEX.T("UploadFilePc.Option.Publish.Hidden");
			break;
		case Common.PUBLISH_ID_ALL:
		case Common.PUBLISH_ID_R15:
		case Common.PUBLISH_ID_R18:
		case Common.PUBLISH_ID_R18G:
		default:
			strTitle = "["+_TEX.T(String.format("Category.C%d", cResults.m_cContent.m_nCategoryId))+"] ";
			String[] strs = cResults.m_cContent.m_strDescription.split("¥n");
			if(strs.length>0 && strs[0].length()>0) {
				strTitle += strs[0];
			} else {
				strTitle += cResults.m_cContent.m_cUser.m_strNickName;
			}
			break;
	}
	strTitle = Util.subStrNum(strTitle, 25) + " | " + _TEX.T("THeader.Title");
	String strDesc = CTweet.generateIllustMsgBase(cResults.m_cContent, _TEX);
	strDesc = Util.deleteCrLf(strDesc) + String.format(_TEX.T("Tweet.Title"), cResults.m_cContent.m_cUser.m_strNickName);
	String strUrl = "https://poipiku.com/"+cResults.m_cContent.m_nUserId+"/"+cResults.m_cContent.m_nContentId+".html";
	ArrayList<String> vResult = Util.getDefaultEmoji(cCheckLogin.m_nUserId, Common.EMOJI_KEYBORD_MAX);
%>
<!DOCTYPE html>
<html>
<head>
	<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
	<%@ include file="/inner/TSweetAlert.jsp"%>
	<meta name="description" content="<%=Util.toDescString(strDesc)%>" />
	<meta name="twitter:card" content="summary" />
	<meta name="twitter:site" content="@pipajp" />
	<meta name="twitter:title" content="<%=Util.toDescString(strTitle)%>" />
	<meta name="twitter:description" content="<%=Util.toDescString(strDesc)%>" />
	<meta name="twitter:image" content="<%=Common.GetPoipikuUrl(strFileUrl)%>_360.jpg" />
	<link rel="canonical" href="<%=strUrl%>" />
	<link rel="alternate" media="only screen and (max-width: 640px)" href="<%=strUrl%>" />
	<title><%=Util.toDescString(strTitle)%></title>
	<script type="application/ld+json">
		{
			"@context":"http://schema.org",
			"@type":"ItemList",
			"itemListElement":[
				{"@type":"ListItem", "position":1, "url":"<%=strUrl%>", "name": "<%=Util.toDescString(strTitle)%>", "image": "<%=Common.GetPoipikuUrl(strFileUrl)%>_640.jpg"}
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
					"ID" : <%=cResults.m_cContent.m_nUserId%>,
					"TD" : <%=cResults.m_cContent.m_nContentId%>,
					"PG" : g_nPage,
					"MD" : <%=CCnv.MODE_PC%>,
					"ADF" : <%=cResults.m_cContent.m_nSafeFilter%>},
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
			$("#AnalogicoInfo .AnalogicoInfoSubTitle").html('<%=String.format(_TEX.T("IllustListPc.Title.Desc"), Common.ToStringHtml(cResults.m_cUser.m_strNickName), cResults.m_nContentsNumTotal)%>');
			<%if(!bSmartPhone) {%>
			$("#AnalogicoInfo .AnalogicoMoreInfo").html('<%=_TEX.T("Poipiku.Info.RegistNow")%>');
			<%}%>
		});
	</script>
	<style>
		<%if(!cResults.m_cUser.m_strHeaderFileName.isEmpty()){%>
		.UserInfo {background-image: url('<%=Common.GetUrl(cResults.m_cUser.m_strHeaderFileName)%>');}
		<%}%>

		<%if(!bSmartPhone) {%>
		.Wrapper.ViewPc .PcSideBar .FixFrame {position: sticky; top: 81px;}
		.Wrapper.ViewPc .PcSideBar .PcSideBarItem:last-child {position: static;}
		.IllustItem.Password .IllustItemThumb {min-height: 240px;}
		<%}%>
	</style>
</head>

<body>

<%if(!isApp){%>
	<%@ include file="/inner/TMenuPc.jsp" %>
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
	<section id="IllustItemList" class="IllustItemList">
		<%if(isApp){%>
		<%=CCnv.MyContent2Html(cResults.m_cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_APP)%>
		<%}else{%>
		<%=CCnv.MyContent2Html(cResults.m_cContent, cCheckLogin.m_nUserId, CCnv.MODE_PC, _TEX, vResult, CCnv.VIEW_DETAIL, CCnv.SP_MODE_WVIEW)%>
		<%}%>
	</section>

	<%if(!bSmartPhone&&!isApp) {%>
	<aside class="PcSideBar" style="margin-top: 30px;">
		<div class="FixFrame">
			<div class="PcSideBarItem">
				<%@ include file="/inner/TAdPc300x250_top_right.jsp"%>
			</div>
		</div>
	</aside>
	<%}%>
</article>

<%@ include file="/inner/TFooter.jsp"%>
</body>
</html>