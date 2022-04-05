<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
	.SettingListItem dd {
        margin: 0;
	}
	.SettingListItem dd > a {
        background-color: #fff;
        min-height: calc(41.625px);
        width: 100%;
        display: block;
        line-height: 40px;
        border-bottom: 1px solid #ccc;
        color: #6d6965;
	}
	.SettingListItem dt {
		text-align: center;
        border-bottom: 1px solid #ccc;
        min-height: calc(41.625px);
        line-height: 40px;
	}
</style>
<div class="SettingList">
	<div class="SettingListItem" style="margin-bottom: 15px; border-bottom: none;">
		<dl>
			<dt><%=_TEX.T("Footer.Link.Language")%></dt>
			<dd><a hreflang="en" onclick="ChLang('en', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">English</a></dd>
			<dd><a hreflang="vi" onclick="ChLang('vi', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">Tiếng Việt</a></dd>
			<dd><a hreflang="ko" onclick="ChLang('ko', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">한국</a></dd>
			<dd><a hreflang="zh-cmn-Hans" onclick="ChLang('zh_CN', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">简体中文</a></dd>
			<dd><a hreflang="zh-cmn-Hant" onclick="ChLang('zh_TW', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">繁體中文</a></dd>
			<dd><a hreflang="th" onclick="ChLang('th', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">ไทย</a></dd>
			<dd><a hreflang="ru" onclick="ChLang('ru', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">русский</a></dd>
			<dd><a hreflang="ja" onclick="ChLang('ja', <%=checkLogin.m_bLogin%>)" href="javascript:void(0);">日本語</a></dd>
		</dl>
	</div>
</div>
