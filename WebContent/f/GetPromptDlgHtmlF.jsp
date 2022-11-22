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
    .PromptDlgTitle{
        padding: 35px 0 1px 0;
        color: #000000;
        font-size: 0.9em;
    }
    .PromptDlgTitle:first-child{
        padding-top: 10px;
    }
    .PromptDlgInfo {
        width: 100%;
        font-size: 12px;
        text-align: left;
        font-family: serif
    }
    .PromptDlgInfo.Prompt {
        height: 90px;
    }
    .PromptDlgInfo.NegativePrompt {
        height: 45px;
    }
    .PromptDlgInfo.OtherParams {
        height: 45px;
    }
    .PromptDlgModelName {
        font-size: 14px;
    }
    .PromptDlgCopyBtn{
        font-size: 12px;
    }
    .PromptDlgGo {
        margin-top: 4px;
        font-size: 14px;
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        justify-content: center;
    }
    .PromptDlgTitle > i {
        font-size: 12px;
    }
    .PromptDlgGo > a {
        border: solid 1px #aeaeae;
        border-radius: 7px;
        padding: 1px 10px;
        margin: 8px 4px;
        line-height: 30px;
    }
</style>
<div class="PromptDlg">
    <h2 class="PromptDlgTitle"><%=_TEX.T("PromptDlg.Model")%> :
    <span class="PromptDlgModelName"><%=_TEX.T(String.format("Category.C%d", cResults.categoryId))%></span>
    </h2>

    <h2 class="PromptDlgTitle"><%=_TEX.T("PromptDlg.Prompt")%></h2>
    <textarea readonly id="PromptDlgPrompt" class="PromptDlgInfo Prompt" style="margin-top: 5px;"><%=cResults.prompt%></textarea>
    <span id="PromptDlgCopyPromptBtn" class="PromptDlgCopyBtn" onclick="copyAiParam(<%=cResults.ownerUserId%>, <%=cResults.contentId%>, 'PromptDlgPrompt', this, null)"><i class="far fa-clone"></i> <%=_TEX.T("PromptDlg.CopyPrompt")%> </span>

    <h2 class="PromptDlgTitle"><%=_TEX.T("PromptDlg.NegativePrompt")%></h2>
    <textarea readonly id="PromptDlgNegativePrompt" class="PromptDlgInfo NegativePrompt" style="margin-top: 5px;"><%=cResults.negativePrompt%></textarea>
    <span id="PromptDlgCopyNegativePromptBtn" class="PromptDlgCopyBtn" onclick="copyAiParam(<%=cResults.ownerUserId%>, <%=cResults.contentId%>, 'PromptDlgNegativePrompt', this, null)"><i class="far fa-clone"></i> <%=_TEX.T("PromptDlg.CopyNegativePrompt")%> </span>

    <h2 class="PromptDlgTitle" style="margin-top: 4px;"><%=_TEX.T("PromptDlg.Params")%></h2>
    <textarea readonly id="PromptDlgParams" class="PromptDlgInfo OtherParams" style="margin-top: 5px;"><%=cResults.otherParams%></textarea>
    <span id="PromptDlgCopyParamBtn" class="PromptDlgCopyBtn" onclick="copyAiParam(<%=cResults.ownerUserId%>, <%=cResults.contentId%>, 'PromptDlgParams', this, null)"><i class="far fa-clone"></i> <%=_TEX.T("PromptDlg.CopyParams")%> </span>

    <h2 class="PromptDlgTitle" style="margin-top: 4px;"><%=_TEX.T("PromptDlg.Generate")%> <i class="fas fa-external-link-alt"></i></h2>
    <div class="PromptDlgGo">
        <%for (int i=0; i<Common.CATEGORY_ID.length; i++) {
            if (Common.CATEGORY_ID[i] == Common.CATEGORY_ID_OTHER) continue;
        %>
        <a onclick="copyAiParam(<%=cResults.ownerUserId%>, <%=cResults.contentId%>, 'PromptDlgPrompt', this, '<%=Common.CATEGORY_SITE[Common.CATEGORY_ID[i]]%>')" href="javascript: void(0)"><%=_TEX.T("Category.C" + Common.CATEGORY_ID[i])%></a>
        <%}%>
    </div>
</div>
