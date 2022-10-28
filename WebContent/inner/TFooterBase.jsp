<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<div style="clear: both;"></div>
<footer class="Footer">
	<%if(!checkLogin.m_bLogin) {%>
	<article class="AnalogicoInfo">
		<h1 class="AnalogicoInfoTitle">
			<%=_TEX.T("Catchphrase")%>
		</h1>
		<a class="AnalogicoMoreInfo" href="/">
			<%=_TEX.T("Unrealizm.Info.MoreInfo")%>
		</a>
		<div class="AnalogicoInfoRegist">
			<form method="post" name="login_from_twitter_tfooterbase_00" action="/LoginFormTwitter.jsp">
				<input id="login_from_twitter_tfooterbase_callback_00" type="hidden" name="CBPATH" value=""/>
				<script>{
					let s = document.URL.split("/");
					for(let i=0; i<3; i++){s.shift();}
					$('#login_from_twitter_tfooterbase_callback_00').val("/" + s.join("/"));
				}</script>
				<a class="BtnBase Rev AnalogicoInfoRegistBtn" style="width:200px;" href="javascript:login_from_twitter_tfooterbase_00.submit()">
					<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Unrealizm.Info.Login")%>
				</a>
			</form>
		</div>
		<div class="AnalogicoInfoRegist">
			<a class="BtnBase Rev AnalogicoInfoRegistBtn" style="width:200px;" href="/MyHomePcV.jsp">
				<span class="typcn typcn-mail"></span> <%=_TEX.T("Unrealizm.Info.Login.Mail")%>
			</a>
		</div>
	</article>
	<%}%>

<%--	<nav class="LinkApp">--%>
<%--		<a href="https://itunes.apple.com/jp/app/%E3%83%9D%E3%82%A4%E3%83%94%E3%82%AF/id1436433822?mt=8" target="_blank" style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg) no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; "></a>--%>
<%--		<%if(!Util.isIOS(request)){%>--%>
<%--		<a href="https://play.google.com/store/apps/details?id=jp.pipa.poipiku" target="_blank" style="display:inline-block;overflow:hidden; background:url('https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png') no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; background-size: 158px;"></a>--%>
<%--		<%}%>--%>
<%--	</nav>--%>

	<nav class="FooterLink">
		<dl>
			<dt><i class="fas fa-globe"></i><%=_TEX.T("Footer.Link.Language")%> <a class="FooterHref" style="font-weight: normal" href="/TranslationSuggestionPcV.jsp"><%=_TEX.T("TranslationSuggestionV.Title.Header")%></a></dt>
			<dd><a class="FooterHref" hreflang="en" onclick="ChLang('en', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">English</a></dd>
			<dd><a class="FooterHref" hreflang="es" onclick="ChLang('es', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">español</a></dd>
			<dd><a class="FooterHref" hreflang="vi" onclick="ChLang('vi', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">Tiếng Việt</a></dd>
			<dd><a class="FooterHref" hreflang="ko" onclick="ChLang('ko', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">한국</a></dd>
			<dd><a class="FooterHref" hreflang="zh-cmn-Hans" onclick="ChLang('zh_CN', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">简体中文</a></dd>
			<dd><a class="FooterHref" hreflang="zh-cmn-Hant" onclick="ChLang('zh_TW', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">繁體中文</a></dd>
			<dd><a class="FooterHref" hreflang="th" onclick="ChLang('th', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">ไทย</a></dd>
			<dd><a class="FooterHref" hreflang="ru" onclick="ChLang('ru', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">русский</a></dd>
			<dd><a class="FooterHref" hreflang="ja" onclick="ChLang('ja', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">日本語</a></dd>
		</dl>
<%--		<dl>--%>
<%--			<dt><%=_TEX.T("Footer.Link.Usage")%></dt>--%>
<%--			<dd><a class="FooterHref" href="/StartUnrealizmPcV.jsp"><%=_TEX.T("Footer.Whats")%></a></dd>--%>
<%--			<dd><a class="FooterHref" href="/how_to/TopPcV.jsp"><%=_TEX.T("HowTo.Title")%></a></dd>--%>
<%--		</dl>--%>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Term")%></dt>
			<dd><a class="FooterHref" href="/RulePcS.jsp"><%=_TEX.T("Footer.Term")%></a></dd>
			<dd><a class="FooterHref" href="/GuideLinePcV.jsp"><%=_TEX.T("Footer.GuideLine")%></a></dd>
			<dd><a class="FooterHref" href="/PrivacyPolicyPcS.jsp"><%=_TEX.T("Footer.PrivacyPolicy")%></a></dd>
<%--			<dd><a class="FooterHref" href="/TransactionLawPcS.jsp"><%=_TEX.T("Footer.TransactionLaw")%></a></dd>--%>
		</dl>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Info")%></dt>

			<dd><a class="FooterHref" href="/2/" target="_blank"><%=_TEX.T("Footer.Information.Title")%></a></dd>
			<dd><a class="FooterHref" href="https://twitter.com/pipajp" target="_blank"><%=_TEX.T("Footer.Information")%></a></dd>
			<%
			StringBuilder sbFooterHref = new StringBuilder();
			sbFooterHref.append(request.getRequestURL().toString().replaceFirst(Common.GetUnrealizmUrl(""), ""));
			if(request.getQueryString()!=null) {
				sbFooterHref.append("?").append(Util.toString(request.getQueryString()));
			}
			String retUrl = "";
			try{ retUrl = URLEncoder.encode(sbFooterHref.toString(), "UTF-8"); } catch (UnsupportedEncodingException e){ ; }
			%>
			<%if(checkLogin.m_bLogin){%>
			<dd><a class="FooterHref" href="/GoToInquiryPcV.jsp?RET=<%=retUrl%>"><%=_TEX.T("Footer.Inquiry")%></a></dd>
			<%}else{%>
			<dd><a class="FooterHref" href="/LoginFormEmailPcV.jsp?INQUIRY=1&RET=<%=retUrl%>"><%=_TEX.T("Footer.Inquiry.NeedSignIn")%></a></dd>
			<%}%>
			<dd><a class="FooterHref" href="/LogoUsageGuideLinePcS.jsp"><%=_TEX.T("LogoUsageGuideLine.Title")%></a></dd>
		</dl>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Company")%></dt>
			<dd><a class="FooterHref" href="https://emotionflow.com/" target="_blank"><%=_TEX.T("Footer.Company")%></a></dd>
		</dl>
<%--		<dl>--%>
<%--			<dt><%=_TEX.T("Footer.Link.Service")%></dt>--%>
<%--			<dd><a class="FooterHref" href="https://tegaki.pipa.jp/" target="_blank"><%=_TEX.T("Footer.Link.Service.Tegaki")%></a></dd>--%>
<%--			<dd><a class="FooterHref" href="https://galleria.emotionflow.com/" target="_blank"><%=_TEX.T("Footer.Link.Service.Galleria")%></a></dd>--%>
<%--			<dd><a class="FooterHref" href="https://unrealizm.com/" target="_blank"><%=_TEX.T("Footer.Link.Service.Unrealizm")%></a></dd>--%>
<%--		</dl>--%>
	</nav>

	<article class="FooterInfo" style="font-size: 10px; margin: 10px 0;">
		異工程混在表示方式およびカテゴリタグ(マイタグ)・コマンドタグ等各種機能は特許出願中です。
		当サイトの各種技術・コンセプト・デザイン・商標等は特許法、著作権法、不正競争防止法等を始めとした各種法律により保護されています。<br />
		Various functions including 'Mixed process display system', 'Category tag' etc. are patent pending.The technologies, concepts, designs, trademarks etc. of this site are protected by laws.
	</article>

	<div class="FooterCopy">
		Copyright(C) 2022 - by
		<a class="FooterHref" href="https://emotionflow.com/" target="_blank">EmotionFlow LLC.</a>
	</div>
</footer>
