<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%if(!g_isApp){%>

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
				<a class="BtnBase AnalogicoInfoRegistBtn" style="width:200px;" href="javascript:login_from_twitter_tfooterbase_00.submit()">
					<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Unrealizm.Info.Login")%>
				</a>
			</form>
		</div>
		<div class="AnalogicoInfoRegist">
			<a class="BtnBase AnalogicoInfoRegistBtn" style="width:200px;" href="/MyHomePcV.jsp">
				<span class="typcn typcn-mail"></span> <%=_TEX.T("Unrealizm.Info.Login.Mail")%>
			</a>
		</div>
	</article>
	<%}%>

	<nav class="FooterLink">
		<dl>
			<dt><i class="fas fa-globe"></i><%=_TEX.T("Footer.Link.Language")%></dt>
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
		<dl>
			<dt><%=_TEX.T("Footer.Link.Term")%></dt>
			<dd><a class="FooterHref" href="/RuleS.jsp"><%=_TEX.T("Footer.Term")%></a></dd>
			<dd><a class="FooterHref" href="/GuideLinePcV.jsp"><%=_TEX.T("Footer.GuideLine")%></a></dd>
			<dd><a class="FooterHref" href="/PrivacyPolicyS.jsp"><%=_TEX.T("Footer.PrivacyPolicy")%></a></dd>
		</dl>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Info")%></dt>

			<dd><a class="FooterHref" href="/2/" target="_blank"><%=_TEX.T("Footer.Information.Title")%></a></dd>
			<dd><a class="FooterHref" href="https://twitter.com/unrealizm2" target="_blank"><%=_TEX.T("Footer.Information")%></a></dd>
			<%
			StringBuilder sbFooterHref = new StringBuilder();
			String requestUrl = request.getRequestURL().toString();
			sbFooterHref.append("https").append(requestUrl.substring(requestUrl.indexOf("://")));
			if(request.getQueryString()!=null) {
				sbFooterHref.append("?").append(Util.toString(request.getQueryString()));
			}
			String retUrl = "";
			try{ retUrl = URLEncoder.encode(sbFooterHref.toString(), "UTF-8"); } catch (UnsupportedEncodingException e){ ; }
			%>
			<%if(checkLogin.m_bLogin){%>
			<dd><a class="FooterHref" href="/GoToInquiryPcV.jsp?RET=<%=retUrl%>"><%=_TEX.T("Footer.Inquiry")%></a></dd>
			<%}else{%>
			<dd><%=_TEX.T("Footer.Inquiry.NeedSignIn")%></dd>
			<%}%>
			<dd><a class="FooterHref" href="/LogoUsageGuideLinePcS.jsp"><%=_TEX.T("LogoUsageGuideLine.Title")%></a></dd>
		</dl>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Company")%></dt>
			<dd><a class="FooterHref" href="https://emotionflow.com/" target="_blank"><%=_TEX.T("Footer.Company")%></a></dd>
		</dl>
	</nav>

	<article class="FooterInfo" style="font-size: 10px; margin: 10px 0;">
		当サイトの各種技術・コンセプト・デザイン・商標等は特許法、著作権法、不正競争防止法等を始めとした各種法律により保護されています。<br />
		The technologies, concepts, designs, trademarks etc. of this site are protected by laws.
	</article>

	<div class="FooterCopy">
		Copyright(C) 2022 - by
		<a class="FooterHref" href="https://emotionflow.com/" target="_blank">EmotionFlow LLC.</a>
	</div>
</footer>

<%}	//if(!g_isApp)%>
