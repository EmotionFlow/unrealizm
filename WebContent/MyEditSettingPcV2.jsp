<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@include file="/inner/Common.jsp"%>
<%!
	static String getSettingMenuItem(String id, String title){
		StringBuilder sb = new StringBuilder();
		sb.append("<a data-to=\"").append(id).append("\" class=\"SettingMenuItemLink SettingChangePageLink\" >")
				.append("<span class=\"SettingMenuItemTitle\">")
				.append(title)
				.append("</span>")
				.append("<i class=\"SettingMenuItemArrow fas fa-angle-right\"></i>")
				.append("</a>");
		return sb.toString();
	}
	static String getSettingMenuHeader(String title){
		StringBuilder sb = new StringBuilder();
		sb.append("<div class=\"SettingMenuHeader\">\n")
				.append("<h2 class=\"SettinMenuTitle\">\n")
				.append("<i data-to=\"MENUROOT\" class=\"SettingChangePageLink fas fa-arrow-left\"></i>\n")
				.append(title)
				.append("</h2>\n")
				.append("</div>\n");
		return sb.toString();
	}
%>

<%
//login check
CheckLogin cCheckLogin = new CheckLogin(request, response);

if(!cCheckLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

boolean bSmartPhone = Util.isSmartPhone(request);

//パラメータの取得
//検索結果の取得
MyEditSettingC cResults = new MyEditSettingC();
cResults.GetParam(request);
cResults.GetResults(cCheckLogin);

HashMap<String, String> MENU = new HashMap<>();
MENU.put("FOLLOW", "ふぁぼ一覧");
MENU.put("BLOCK", "ブロック一覧");
MENU.put("PROFILE", "プロフィール");
MENU.put("MUTEKEYWORD", "ミュートキーワード");
MENU.put("REACTION", "リアクション");
MENU.put("TWITTER", "Twitter連携");
MENU.put("MAIL", "メールアドレス");
MENU.put("ACCOUNT", "アカウント");
MENU.put("INFO", "使い方/利用規約/公式Twitter");

%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyEditSetting.Title.Setting")%></title>

		<script type="text/javascript">
			$.ajaxSetup({
				cache: false,
			});

			function changePage(elFromPage, elToPage){
				elFromPage.hide();
				elToPage.show();
			}

			$(function(){
				<%if(Util.isSmartPhone(request)){%>
				$("#MenuMe").addClass("Selected");
				<%}else{%>
				$("#MenuSettings").addClass("Selected");
				<%}%>

				// DispDescCharNum();
				// DispMuteCharNum();
				// DispAutoTweetCharNum();

				<%if(cResults.m_strMessage.length()>0) {%>
				DispMsg("<%=Common.ToStringHtml(cResults.m_strMessage)%>");
				<%}%>

				$(".SettingChangePageLink").click((ev)=>{
					const el = $(ev.currentTarget);
					changePage(el.parents(".SettingPage"), $("#"+el.attr("data-to")));
				});

				<%if(cResults.m_strSelectedMenuId.isEmpty()){%>
				$("#MENUROOT").show();
				<%}else{%>
				$("#<%=cResults.m_strSelectedMenuId%>").show();
				<%}%>
			});
		</script>

		<style>
		<%if(bSmartPhone){%>
		.Wrapper.ItemList .IllustItemList {margin-top: 6px;}
		<%} else {%>
		.Wrapper.ItemList .IllustItemList {margin-top: 16px;}
		<%}%>

		.SettingMenuHeader{
			font-size: 18px;
			font-weight: 400;
			padding: 7px;
			background-color: white;
			border-bottom: 1px solid #555;
		}

		.SettingBody .SettingBodyCmdRegist {
			font-size: 14px;
		}

		.SettingMenuItemLink{
			background-color: #FFFFFF;
			min-height: calc(41.625px);
			width: 100%;
			display: block;
			line-height: 40px;
			border-bottom: calc(0.5px) solid #ccc;
		}

		.SettingMenuItem{
			width: 100%;
		}

		.SettingMenuItemTitle {
			margin-left: 8px;
		}
		.SettinMenuTitle .SettingChangePageLink {
			color: #5bd;
		}

			.SettingMenuItemArrow{
				display: inline-block;
				float: right;
				position: relative;
				top: 10px;
				padding: 0 9px;
			}

			.SettingMenuReturnArrow{
				color: #5bd;
			}
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div id="MENUROOT" class="SettingPage" style="display: none;">
				<div class="SettingMenuHeader">
					<h2 class="SettinMenuTitle">
						<%=cResults.m_cUser.m_strNickName%>の設定
					</h2>
				</div>
				<div class="SettingMenu">
					<%String[] menuOrder = {
							"FOLLOW",
							"BLOCK",
							"PROFILE",
							"MUTEKEYWORD",
							"REACTION",
							"TWITTER",
							"MAIL",
							"ACCOUNT",
							"INFO"
					}; %>
					<%for(String m : menuOrder){%>
						<%=getSettingMenuItem(m, MENU.get(m))%>
					<%}%>
				</div>
			</div>

			<%String strPageId = "";%>
			<%strPageId = "FOLLOW";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingFollowV.jsp"%>
				</div>
			</div>

			<%strPageId = "BLOCK";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingBlockV.jsp"%>
				</div>
			</div>

			<%strPageId = "PROFILE";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingProfileV.jsp"%>
				</div>
			</div>

			<%strPageId = "MUTEKEYWORD";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingMuteKeywordV.jsp"%>
				</div>
			</div>

			<%strPageId = "REACTION";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingReactionV.jsp"%>
				</div>
			</div>

			<%strPageId = "TWITTER";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingTwitterV.jsp"%>
				</div>
			</div>

			<%strPageId = "MAIL";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingMailV.jsp"%>
				</div>
			</div>

			<%strPageId = "ACCOUNT";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingAccountV.jsp"%>
				</div>
			</div>

			<%strPageId = "INFO";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId))%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingInfoV.jsp"%>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>