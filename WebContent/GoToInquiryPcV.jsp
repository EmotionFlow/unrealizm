<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
    CheckLogin cCheckLogin = new CheckLogin(request, response);
    GoToInquiryC cResults = new GoToInquiryC();
    if(cCheckLogin.m_bLogin){
        cResults.GetParam(request);
        cResults.GetResults(cCheckLogin);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/inner/THeaderCommonNoindexPc.jsp"%>
    <title></title>
    <script>
        $(function () {
            setTimeout(function () {
                <%if(cCheckLogin.m_bLogin){%>
                go_inquiry.submit();
                <%}else{%>
                location.href = "<%=Common.GetPoipikuUrl("/")%>";
                <%}%>
            }, 2000);
        })
    </script>
</head>

<body>
<%@ include file="/inner/TMenuPc.jsp"%>
<article class="Wrapper" style="min-height: 400px; text-align: center;">
    <%if(cCheckLogin.m_bLogin){%>
    <div class="SettingList" style="margin: 50px 0;">
        <%=_TEX.T("GoToInquiry.Info")%>
    </div>
    <form method="post" name="go_inquiry" action="https://cs.pipa.jp/InquiryPcV.jsp">
        <input type="hidden" name="SRV" value="Poipiku"/>
        <input type="hidden" name="EMAIL" value="<%=cResults.m_cUser.m_strEmail%>"/>
        <input type="hidden" name="NNAME" value="<%=cResults.m_cUser.m_strNickName%>"/>
        <input type="hidden" name="TWNAME" value="<%=cResults.m_cUser.m_strTwitterScreenName%>"/>
        <input type="hidden" name="UID" value="<%=cCheckLogin.m_nUserId%>"/>
        <input type="hidden" name="RET" value="<%=cResults.m_strReturnUrl%>" />
        <a class="BtnBase" href="javascript:go_inquiry.submit()" style="font-size: 14px; padding: 10px 20px;" ><%=_TEX.T("Inquiry.Title")%></a>
    </form>
    <%}else{%>
    <div class="SettingList" style="margin: 50px 0;">
        <%=_TEX.T("GoToInquiry.NeedSignIn")%>
    </div>
    <%}%>
</article>

<%@ include file="/inner/TFooterBase.jsp"%>
</body>
</html>
