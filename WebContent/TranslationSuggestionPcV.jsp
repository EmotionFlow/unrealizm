<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>

<%
//login check
CheckLogin checkLogin = new CheckLogin(request, response);

if(!checkLogin.m_bLogin) {
	getServletContext().getRequestDispatcher("/LoginFormEmailPcV.jsp").forward(request,response);
	return;
}

boolean bSmartPhone = Util.isSmartPhone(request);
boolean isApp = false;

%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - <%=_TEX.T("MyEditSetting.Title.Setting")%></title>

		<script type="text/javascript">
			function sendTranslationSuggestion(){
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
						DispMsg("ご提案ありがとうございました！");
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
			.SettingListCmd {margin-bottom: 20px; text-align: center;}
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
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingPage">
				<div class="SettingBody">
					<div class="SettingList">
						<div class="SettingListItem" style="padding-bottom: 10px">
							<div class="SettingListTitle" style="text-align: center"><i class="fas fa-language" style="font-size: 20px;"></i> 翻訳の提案<br>translation suggestions</div>
							<div class="LangList">
								<a hreflang="en" onclick="ChLang('en', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">English</a>
								<a hreflang="ko" onclick="ChLang('ko', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">한국</a>
								<a hreflang="zh-cmn-Hans" onclick="ChLang('zh_CN', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">简体中文</a>
								<a hreflang="zh-cmn-Hant" onclick="ChLang('zh_TW', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">繁體中文</a>
								<a hreflang="th" onclick="ChLang('th', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">ไทย</a>
								<a hreflang="ru" onclick="ChLang('ru', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">русский</a>
								<a hreflang="vi" onclick="ChLang('vi', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">Tiếng Việt</a>
								<a hreflang="ja" onclick="ChLang('ja', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">日本語</a>
							</div>
							<div class="TranslationSuggestionIntro">
								<div class="SettingBody">
									<p>ポイピクのメニュー(例：こそフォロ)やカテゴリー(例：供養・尻を叩く)などの表記は、日本語を基準とし、他の７つの言語(表記)に翻訳されています。</p>
									<p>日本語から英語への翻訳についてはスタッフが簡単なチェックをしているのみで、またそれ以外の言語についてはほとんどが英語からの機械翻訳をそのまま採用しています。
									よって、日本語以外の言語を普段使われる方にとっては意味が分かりづらい表記が多くあります。</p>
									<p>そこで、「この言語ではこの表記・表現の方が良いと思います！」という提案がありましたら、ぜひこちらのページからお寄せください。
									いただいた提案はスタッフが検討したのち、順次サービスに反映してゆきます。</p>
								</div>
							</div>
						</div>

						<div class="SettingListItem" style="padding-bottom: 0">
							<div class="SettingListTitle">対象の単語や文章</div>
							<div class="SettingBody">
								<div class="SettingBodyCmd">
									<div class="RegistMessage">日本語または英語での入力が望ましいですが、他の言語でも構いません。</div>
								</div>
								<textarea id="EditOriginalTxt" class="SettingBodyTxt" rows="3" maxlength="1000"></textarea>
							</div>
						</div>

						<div class="SettingListItem">
							<div class="SettingListTitle">翻訳の提案</div>
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
							<div class="SettingListTitle">使われているシーン、画面URL</div>
							<div class="SettingBodyCmd">
								<div class="RegistMessage">画面キャプチャーがある場合はポイピクに投稿後URLを記入してください(公開範囲は非公開でも可)。</div>
							</div>
							<div class="SettingBody">
								<textarea id="EditSuggestionUsed" class="SettingBodyTxt" rows="3" maxlength="1000"></textarea>
							</div>
						</div>
						
						<div class="SettingListItem">
							<div class="SettingListTitle">提案の背景・理由・解説など</div>
							<div class="SettingBody">
								<textarea id="EditSuggestionDesc" class="SettingBodyTxt" rows="3" maxlength="1000"></textarea>
							</div>
						</div>

						<div class="SettingListCmd">
							<a class="BtnBase" href="javascript:void(0)" onclick="sendTranslationSuggestion();">
								翻訳を提案する
							</a>
						</div>

					</div>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooter.jsp"%>
	</body>
</html>
