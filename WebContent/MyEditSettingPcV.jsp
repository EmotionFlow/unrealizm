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
	static String getSettingMenuHeader(String title, boolean bSmartPhone){
		StringBuilder sb = new StringBuilder();
		sb.append("<div class=\"SettingMenuHeader\">\n")
				.append("<h2 class=\"SettinMenuTitle\">\n");
		if(bSmartPhone){
			sb.append("<i data-to=\"MENUROOT\" class=\"SettingChangePageLink fas fa-arrow-left\"></i>\n");
		}
		sb.append(title)
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
MENU.put("FOLLOW", _TEX.T("EditSettingV.FavoList"));
MENU.put("BLOCK", _TEX.T("EditSettingV.BlockList"));
MENU.put("PROFILE", _TEX.T("EditSettingV.Profile"));
MENU.put("MUTEKEYWORD", _TEX.T("EditSettingV.MuteKeyowrd"));
MENU.put("REACTION", _TEX.T("EditSettingV.Reaction"));
MENU.put("TWITTER", _TEX.T("EditSettingV.Twitter"));
MENU.put("MAIL", _TEX.T("EditSettingV.Email.Address"));
MENU.put("ACCOUNT", _TEX.T("EditSettingV.Account"));
MENU.put("INFO", _TEX.T("EditSettingV.Usage"));

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

			function changePage(elCurrentTarget, elFromPage, elToPage){
				<%if(bSmartPhone){%>
					elFromPage.hide();
					elToPage.show();
					$("*").scrollTop(0);
				<%}else{%>
					var contents = $("#SettingContent > .SettingPage:visible");
					if(elToPage.attr("id")!==$(contents[0]).attr("id")) {
						$(contents[0]).hide();
						elToPage.show();
					}

					var selected = $("#MENUROOT>.SettingMenu .Selected")[0];
					if(selected) {
						$(selected).removeClass("Selected");
					}
					$(elCurrentTarget).addClass("Selected");

					$("*").scrollTop(0);
				<%}%>
			}

			$(function(){
				<%if(bSmartPhone){%>
					$("#MenuMe").addClass("Selected");
				<%}else{%>
					$("#MenuSettings").addClass("Selected");
				<%}%>

				<%if(cResults.m_strMessage.length()>0) {%>
					DispMsg("<%=Common.ToStringHtml(cResults.m_strMessage)%>");
				<%}%>

				$(".SettingChangePageLink").click((ev)=>{
					const el = $(ev.currentTarget);
					changePage(ev.currentTarget, el.parents(".SettingPage"), $("#"+el.attr("data-to")));
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
			height: 27px;
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

		<%if(!bSmartPhone){%>
		.Wrapper{
			width: 850px;
		}
		#MENUROOT{
			width: 249px;
			display: inline-block;
			float: left;
			border-left: calc(0.5px) solid #ccc;
		}
		#SettingContent{
			display: inline-block;
			background: #fff;
			width: 599px;
			min-height: 420px;
			border: calc(0.5px) solid #ccc;
			border-top: 0;
		}
		.SettingMenuItemLink.Selected{
			color: #000;
			background-color: #f3f3f3;
		}
		<%}%>
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
							"PROFILE",
							"FOLLOW",
							"BLOCK",
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

			<%if(!bSmartPhone){%>
			<div id="SettingContent">
			<%}%>

			<%String strPageId = "";%>

			<%strPageId = "PROFILE";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingProfileV.jsp"%>
				</div>
			</div>

			<%strPageId = "FOLLOW";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingFollowV.jsp"%>
				</div>
			</div>

			<%strPageId = "BLOCK";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingBlockV.jsp"%>
				</div>
			</div>

			<%strPageId = "MUTEKEYWORD";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingMuteKeywordV.jsp"%>
				</div>
			</div>

			<%strPageId = "REACTION";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingReactionV.jsp"%>
				</div>
			</div>

			<%strPageId = "TWITTER";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingTwitterV.jsp"%>
				</div>
			</div>

			<%strPageId = "MAIL";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingMailV.jsp"%>
				</div>
			</div>

			<%strPageId = "ACCOUNT";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingAccountV.jsp"%>
				</div>
			</div>

			<%strPageId = "INFO";%>
			<div id="<%=strPageId%>" class="SettingPage" style="display: none;">
				<%=getSettingMenuHeader(MENU.get(strPageId), bSmartPhone)%>
				<div class="SettingBody">
					<%@include file="/inner/setting/MyEditSettingInfoV.jsp"%>
				</div>
			</div>

			<%if(!bSmartPhone){%>
			</div>
			<%}%>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>