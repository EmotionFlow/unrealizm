<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div style="clear: both;"></div>
<footer class="Footer">
	<%if(!cCheckLogin.m_bLogin) {%>
	<article class="AnalogicoInfo" style="background: none;">
		<h1 class="AnalogicoInfoTitle">
			<%=_TEX.T("Poipiku.Info.Message")%>
		</h1>
		<a class="AnalogicoMoreInfo" href="/">
			<%=_TEX.T("Poipiku.Info.MoreInfo")%>
		</a>
		<div class="AnalogicoInfoRegist">
			<a class="BtnBase Rev AnalogicoInfoRegistBtn" href="/LoginFormTwitterPc.jsp">
				<span class="typcn typcn-social-twitter"></span> <%=_TEX.T("Poipiku.Info.Login")%>
			</a>
		</div>
		<div class="AnalogicoInfoRegist">
			<a class="BtnBase Rev AnalogicoInfoRegistBtn" href="/MyHomePcV.jsp">
				<span class="typcn typcn-mail"></span> <%=_TEX.T("Poipiku.Info.Login.Mail")%>
			</a>
		</div>
	</article>
	<%}%>

	<nav class="LinkApp">
		<a href="https://itunes.apple.com/jp/app/%E3%83%9D%E3%82%A4%E3%83%94%E3%82%AF/id1436433822?mt=8" target="_blank" style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg) no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; "></a>
		<a href="https://play.google.com/store/apps/details?id=jp.pipa.poipiku" target="_blank" style="display:inline-block;overflow:hidden; background:url('https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png') no-repeat 50% 50%;width:135px;height:40px; margin: 0 10px; background-size: 158px;"></a>
	</nav>



	<nav class="FooterLink">
		<dl>
			<dt><%=_TEX.T("Footer.Link.Language")%></dt>
			<dd><a class="FooterHref" onclick="ChLang('ja')" href="javascript:void(0);">日本語</a></dd>
			<dd><a class="FooterHref" onclick="ChLang('en')" href="javascript:void(0);">English</a></dd>
		</dl>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Usage")%></dt>
			<dd><a class="FooterHref" href="/StartPoipikuPcV.jsp"><%=_TEX.T("Footer.Whats")%></a></dd>
			<dd><a class="FooterHref" href="/RulePcS.jsp"><%=_TEX.T("Footer.Term")%></a></dd>
			<dd><a class="FooterHref" href="/GuideLinePcV.jsp"><%=_TEX.T("Footer.GuideLine")%></a></dd>
			<dd><a class="FooterHref" href="/PrivacyPolicyPcS.jsp"><%=_TEX.T("Footer.PrivacyPolicy")%></a></dd>
		</dl>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Info")%></dt>
			<dd><a class="FooterHref" href="https://twitter.com/pipajp" target="_blank"><%=_TEX.T("Footer.Information")%></a></dd>
		</dl>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Company")%></dt>
			<dd><a class="FooterHref" href="http://www.pipa.jp/" target="_blank"><%=_TEX.T("Footer.Company")%></a></dd>
		</dl>
		<dl>
			<dt><%=_TEX.T("Footer.Link.Service")%></dt>
			<dd><a class="FooterHref" href="https://tegaki.pipa.jp/" target="_blank"><%=_TEX.T("Footer.Link.Service.Tegaki")%></a></dd>
			<dd><a class="FooterHref" href="https://galleria.emotionflow.com/" target="_blank"><%=_TEX.T("Footer.Link.Service.Galleria")%></a></dd>
			<dd><a class="FooterHref" href="https://poipiku.com/" target="_blank"><%=_TEX.T("Footer.Link.Service.Poipiku")%></a></dd>
		</dl>
	</nav>

	<article class="FooterInfo" style="font-size: 10px; margin: 10px 0;">
		異工程混在表示方式およびカテゴリタグ(マイタグ)・コマンドタグ等各種機能は特許出願中です。
		当サイトの各種技術・コンセプト・デザイン・商標等は特許法、著作権法、不正競争防止法等を始めとした各種法律により保護されています。<br />
		Various functions including 'Mixed process display system', 'Category tag' etc. are patent pending.The technologies, concepts, designs, trademarks etc. of this site are protected by laws.
	</article>

	<div class="FooterCopy">
		Copyright(C) 2017 -
		based on <a class="FooterHref" href="https://analogico.pipa.jp/" target="_blank">analogico</a> by
		<a class="FooterHref" href="http://www.pipa.jp/" target="_blank">Pipa.jp Ltd.</a>
	</div>
</footer>
