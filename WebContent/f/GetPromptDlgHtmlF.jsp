<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
String referer = Util.toString(request.getHeader("Referer"));
if (!referer.contains("unrealizm")) {
    Log.d("おそらく不正アクセス Referer不一致 " + referer);
    return;
}

CheckLogin checkLogin = new CheckLogin(request, response);
GetPromptC cResults = new GetPromptC();
cResults.getParam(request);
boolean result = cResults.getResults(checkLogin);
if (!result) return;
%>
<style>
    .PromptDlgTitle{padding: 10px 0 0 0; color: #6d6965;}
    .PromptDlgInfo {
        width: 100%;
        font-size: 14px;
        text-align: left;
        font-family: serif
    }
    .PromptDlgInfo.Prompt {
        height: 150px;
    }
    .PromptDlgInfo.OtherParams {
        height: 70px;
    }
</style>
<div class="PromptDlg">
    <h2 class="PromptDlgTitle">Prompt</h2>
    <textarea readonly class="PromptDlgInfo Prompt" style="margin-top: 5px;"><%=cResults.prompt%></textarea>
    <h2 class="PromptDlgTitle" style="margin-top: 4px;">Params</h2>
    <textarea readonly class="PromptDlgInfo OtherParams" style="margin-top: 5px;"><%=cResults.otherParams%></textarea>
</div>
