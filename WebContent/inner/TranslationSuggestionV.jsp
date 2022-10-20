<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>

<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	if (!isApp) {
		getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	} else {
		getServletContext().getRequestDispatcher("/StartPoipikuAppV.jsp").forward(request,response);
	}
	return;
}

boolean bSmartPhone = Util.isSmartPhone(request);

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%if(!isApp){%>
		<%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
		<%}else{%>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<%}%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("TranslationSuggestionV.Title.Header")%></title>

		<script type="text/javascript">
			function sendTranslationSuggestion(){
				if ($("#EditOriginalTxt").val().trim().length === 0 || $("#EditSuggestionTxt").val().trim().length === 0) {
					return false;
				}
				$.ajax({
					"type": "post",
					"data": {
						"UID": <%=checkLogin.m_nUserId%>,
						"EditOriginalTxt": $("#EditOriginalTxt").val(),
						"EditTransLang": $("#EditTransLang").val(),
						"EditSuggestionTxt": $("#EditSuggestionTxt").val(),
						"EditSuggestionUsed": $("#EditSuggestionUsed").val(),
						"EditSuggestionDesc": $("#EditSuggestionDesc").val(),
					},
					"url": "/f/SendTranslationSuggestionF.jsp",
					"dataType": "json"
				})
				.then(
					data => {
						DispMsg("<%=_TEX.T("TranslationSuggestionV.Thanks")%>");
						$("#EditOriginalTxt").val('');
						$("#EditSuggestionTxt").val('');
						$("#EditSuggestionUsed").val('');
						$("#EditSuggestionDesc").val('');
						return false;
					},
					error => {
						DispMsg("error.");
						return false;
					}
				);
			}
		</script>

		<style>
			.SettingBody {display: block; float: left; width: 100%; background: #fff; color: #6d6965;}
			.SettingBody > .SettingList {max-width: unset;}
			.SettingListItem {color: #6d6965;}
			.SettingListItem a {color: #6d6965;}
			.SettingBody .SettingBodyCmdRegist {font-size: 14px;}
			.TranslationSuggestionIntro {margin: 0 <%=bSmartPhone?"5":"20"%>px;}
            .SettingList .SettingListItem .SettingBody .RegistMessage {margin: 0}
            .LangList {font-size: 13px; text-align: center;}
            .LangList > a {text-decoration: underline; margin: 0 3px;}
			.SettingListCmd {margin-bottom: 20px; text-align: center; <%=isApp?"padding-bottom: 100px;":""%>}
			<%if(!bSmartPhone){%>
			.Wrapper{
				width: 850px;
			}
			.SettingListItem {
				color: #6d6965;
			}
			.SettingListItem a {
				color: #6d6965;
			}
			<%}%>
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>
		<%if(!isApp){%>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<%@ include file="/inner/TAdPoiPassHeaderPcV.jsp"%>
		<script>$(function () {
			$("#MenuSearch").show();
			$("#MenuUpload").hide();
			$("#MenuSettings").hide();
			// $("#MenuSwitchUser").hide();
		})</script>
		<%}else{%>
		<%@ include file="/inner/TMenuApp.jsp" %>
		<%@ include file="/inner/TAdPoiPassHeaderAppV.jsp"%>
		<%}%>

		<article class="Wrapper">
			<div class="SettingPage">
				<div class="SettingBody">
					<div class="SettingList">
						<div class="SettingListItem" style="padding-bottom: 10px">
							<div class="SettingListTitle" style="text-align: center"><i class="fas fa-language" style="font-size: 20px;"></i> <%=_TEX.T("TranslationSuggestionV.Title")%></div>
							<div class="LangList">
								<a hreflang="en" onclick="ChLang('en', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">English</a>
								<a hreflang="es" onclick="ChLang('es', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">español</a>
								<a hreflang="ko" onclick="ChLang('ko', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">한국</a>
								<a hreflang="zh-cmn-Hans" onclick="ChLang('zh_CN', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">简体中文</a>
								<a hreflang="zh-cmn-Hant" onclick="ChLang('zh_TW', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">繁體中文</a>
								<a hreflang="th" onclick="ChLang('th', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">ไทย</a>
								<a hreflang="ru" onclick="ChLang('ru', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">русский</a>
								<a hreflang="vi" onclick="ChLang('vi', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">Tiếng Việt</a>
								<a hreflang="ja" onclick="ChLang('ja', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">日本語</a>
							</div>
							<div class="TranslationSuggestionIntro">
								<div class="SettingBody" style="font-size: <%=isApp?"12":"14"%>px">
									<p><%=_TEX.T("TranslationSuggestionV.Desc01")%></p>
									<p><%=_TEX.T("TranslationSuggestionV.Desc02")%></p>
									<p><%=_TEX.T("TranslationSuggestionV.Desc03")%></p>
									<p style="font-size: 12px"><%=_TEX.T("TranslationSuggestionV.Desc04")%></p>
								</div>
							</div>
						</div>

						<div class="SettingListItem" style="padding-bottom: 0">
							<div class="SettingListTitle"><%=_TEX.T("TranslationSuggestionV.Target")%></div>
							<div class="SettingBody">
								<div class="SettingBodyCmd">
									<div class="RegistMessage"><%=_TEX.T("TranslationSuggestionV.Target.Info")%></div>
								</div>
								<textarea id="EditOriginalTxt" class="SettingBodyTxt" rows="3" maxlength="1000"></textarea>
							</div>
						</div>

						<div class="SettingListItem">
							<div class="SettingListTitle"><%=_TEX.T("TranslationSuggestionV.Suggestion")%></div>
							<span class="SelectTransLang">
								<i class="fas fa-globe" style="margin: 5px -2px 0 6px;font-size: 17px;"></i>
								<select id="EditTransLang" style="font-size: 12px;">
									<%for(UserLocale userLocale: SupportedLocales.list) {%>
									<%if(userLocale.locale==Locale.JAPANESE) continue; %>
									<option value="<%=userLocale.label%>"><%=userLocale.label%></option>
									<%}%>
								</select>
							</span>
							<div class="SettingBody">
								<textarea id="EditSuggestionTxt" class="SettingBodyTxt" rows="3" maxlength="1000"></textarea>
							</div>
						</div>

						<div class="SettingListItem">
							<div class="SettingListTitle"><%=_TEX.T("TranslationSuggestionV.Used")%></div>
							<div class="SettingBodyCmd">
								<div class="RegistMessage"><%=_TEX.T("TranslationSuggestionV.Used.Info")%></div>
							</div>
							<div class="SettingBody">
								<textarea id="EditSuggestionUsed" class="SettingBodyTxt" rows="3" maxlength="1000"></textarea>
							</div>
						</div>
						
						<div class="SettingListItem">
							<div class="SettingListTitle"><%=_TEX.T("TranslationSuggestionV.SuggestionDesc")%></div>
							<div class="SettingBody">
								<textarea id="EditSuggestionDesc" class="SettingBodyTxt" rows="3" maxlength="1000"></textarea>
							</div>
						</div>

						<div class="SettingListCmd">
							<a class="BtnBase" href="javascript:void(0)" onclick="sendTranslationSuggestion();">
								<%=_TEX.T("TranslationSuggestionV.Submit")%>
							</a>
						</div>

					</div>
				</div>
			</div>
		</article><!--Wrapper-->

		<%if(!isApp){%>
		<%@ include file="/inner/TFooterSingleAd.jsp"%>
		<%}%>
	</body>
</html>
