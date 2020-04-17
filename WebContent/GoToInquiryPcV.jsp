<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
    CheckLogin cCheckLogin = new CheckLogin(request, response);
    GoToInquiryC cResults = new GoToInquiryC();
    cResults.GetParam(request);
    cResults.GetResults(cCheckLogin);
%>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
    <title></title>
    <script>
        $(function () {
            setTimeout(function () {
                go_inquiry.submit();
            }, 2000);
        })
    </script>
</head>

<body>
<%@ include file="/inner/TMenuPc.jsp"%>
<article class="Wrapper" style="min-height: 400px; text-align: center;">
    <div class="SettingList" style="margin-top: 50px;">
        問い合わせサイトに移動します。自動で移動しない場合は、下のボタンをクリックしてください。
    </div>
    <form method="post" name="go_inquiry" action="https://cs.pipa.jp/InquiryPcV.jsp">
        <input type="hidden" name="SRV" value="Poipiku"/>
        <input type="hidden" name="EMAIL" value="<%=cResults.m_cUser.m_strEmail%>"/>
        <input type="hidden" name="NNAME" value="<%=cResults.m_cUser.m_strNickName%>"/>
        <input type="hidden" name="TWNAME" value="<%=cResults.m_cUser.m_strTwitterScreenName%>"/>
        <input type="hidden" name="UID" value="<%=cCheckLogin.m_nUserId%>"/>
        <input type="hidden" name="RET" value="<%=cResults.m_strReturnUrl%>" />
        <a href="javascript:go_inquiry.submit()" style="font-size: 14px; text-decoration: underline;" ><%=_TEX.T("Inquiry.Title")%></a>
    </form>
</article>

<%@ include file="/inner/TFooterBase.jsp"%>
</body>
</html>
