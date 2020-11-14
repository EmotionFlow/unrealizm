<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="SettingList">
		<div class="SettingListItem" style="margin-bottom: 15px; border-bottom: none;">
				<div class="SettingListTitle""><%=_TEX.T("HowTo.Title")%>/<%=_TEX.T("Footer.Term")%>/<%=_TEX.T("Footer.Information")%></div>
				<div class="SettingBody">
						<a href="/how_to/TopPcV.jsp" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("HowTo.Title")%></a><br />
						<a href="/RulePcS.jsp" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("Footer.Term")%></a><br />
						<a href="/GuideLinePcV.jsp" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("Footer.GuideLine")%></a><br />
						<a href="/PrivacyPolicyPcS.jsp" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("Footer.PrivacyPolicy")%></a><br />
						<a href="/1/" style="font-size: 14px; text-decoration: underline;"><%=_TEX.T("Footer.Information.Title")%></a><br />
						<a href="https://twitter.com/pipajp" style="font-size: 14px; text-decoration: underline;" target="_blank"><%=_TEX.T("Footer.Information")%></a><br />
						<form method="post" name="go_inquiry" action="https://cs.pipa.jp/InquiryPcV.jsp">
								<input type="hidden" name="SRV" value="Poipiku"/>
								<input type="hidden" name="EMAIL" value="<%=cResults.m_cUser.m_strEmail%>"/>
								<input type="hidden" name="NNAME" value="<%=cResults.m_cUser.m_strNickName%>"/>
								<input type="hidden" name="TWNAME" value="<%=cResults.m_cUser.m_strTwitterScreenName%>"/>
								<input type="hidden" name="UID" value="<%=cCheckLogin.m_nUserId%>"/>
								<input type="hidden" name="RET" value="/MyEditSettingPcV.jsp?MENUID=INFO"/>
								<a href="javascript:go_inquiry.submit()" style="font-size: 14px; text-decoration: underline;" ><%=_TEX.T("Inquiry.Title")%></a>
						</form>
				</div>
		</div>
</div>
