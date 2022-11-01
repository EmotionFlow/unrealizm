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
        padding: 10px 0 1px 0; color: #6d6965;
    }
    .PromptDlgInfo {
        width: 100%;
        font-size: 12px;
        text-align: left;
        font-family: serif
    }
    .PromptDlgInfo.Prompt {
        height: 100px;
    }
    .PromptDlgInfo.OtherParams {
        height: 50px;
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
    }
    .PromptDlgTitle > i {
        font-size: 12px;
    }
    .PromptDlgGo > a {
        border: solid 1px #aeaeae;
        border-radius: 2px;
        padding: 2px 4px;
        margin: 8px 4px;
        line-height: 30px;
        word-break: keep-all;
    }
</style>
<div class="PromptDlg">
    <h2 class="PromptDlgTitle">Model :
    <span class="PromptDlgModelName"><%=_TEX.T(String.format("Category.C%d", cResults.categoryId))%></span>
    </h2>

    <h2 class="PromptDlgTitle">Prompt</h2>
    <textarea readonly id="PromptDlgPrompt" class="PromptDlgInfo Prompt" style="margin-top: 5px;"><%=cResults.prompt%></textarea>
    <span id="PromptDlgCopyPromptBtn" class="PromptDlgCopyBtn" onclick="copyTxtToClipBoard('PromptDlgPrompt', this)"><i class="fas fa-clipboard"></i> Copy Prompt </span>

    <h2 class="PromptDlgTitle" style="margin-top: 4px;">Params</h2>
    <textarea readonly id="PromptDlgParams" class="PromptDlgInfo OtherParams" style="margin-top: 5px;"><%=cResults.otherParams%></textarea>
    <span id="PromptDlgCopyParamBtn" class="PromptDlgCopyBtn" onclick="copyTxtToClipBoard('PromptDlgParams', this)"><i class="fas fa-clipboard"></i> Copy Params </span>

    <h2 class="PromptDlgTitle" style="margin-top: 4px;">Generate Image! <i class="fas fa-external-link-alt"></i></h2>
    <div class="PromptDlgGo">
        <a href="https://huggingface.co/spaces/stabilityai/stable-diffusion" target="_blank">Stable Diffusion Demo </a>
        <a href="https://www.mage.space/" target="_blank">mage.space</a>
        <a href="https://novelai.net/" target="_blank">NovelAI</a>
        <a href="https://www.midjourney.com/home/" target="_blank">Midjourney</a>
        <a href="https://openai.com/dall-e-2/" target="_blank">DALL-E 2</a>
        <a href="https://apps.apple.com/jp/app/ai%E3%83%94%E3%82%AB%E3%82%BD-ai%E3%81%8A%E7%B5%B5%E6%8F%8F%E3%81%8D%E3%82%A2%E3%83%97%E3%83%AA/id1642181654" target="_blank">AIピカソ</a>
        <a href="https://illustmimic.com/" target="_blank">mimic</a>
    </div>
</div>
