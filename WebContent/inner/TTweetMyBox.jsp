<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    StringBuilder sb = new StringBuilder();
    sb.append(Common.GetPoipikuUrl("/")).append(cResults.m_cUser.m_nUserId).append("/");
    String strMyBoxUrl = sb.toString();
    String strTwitterIntentURL = Util.getTwitterIntentURL(
            String.format(_TEX.T("MyIllustListV.TweetMyBox.Tweet.Msg"), cResults.m_cUser.m_strNickName),
            strMyBoxUrl
    );
%>

<script type="text/javascript" src="/js/jquery.qrcode.min.js"></script>
<style>
    .TweetMyBoxTitle {
        font-size: 18px;
        padding: 29px 0 9px 0;
    }
    .TweetMyBoxInfo {
        font-size: 13px;
        font-weight: 400;
        padding: 9px 0;
        color: #c76a6a;
    }
    .TweetMyBoxBtn {
        font-size: 14px;
        font-weight: 400;
        margin: 0 4px;
    }
    .TweetMyBoxHr {
        border: 1px solid #CCCCCC;
        margin-top: 37px;
    }
    .DownloadMyBoxQR {
        bottom: 8px;
        margin-left: 15px;
        position: relative;
    }
    #DownloadMyBoxQRBtn{
        font-size: 14px;
    }
</style>
<script type="text/javascript">
    $(function(){
        $('#MenuMe').addClass('Selected');
        updateCategoryMenuPos(0);
        $("#OpenTweetMyBoxDlgBtn").click(function(){
            var hMessages = {
                "TweetTitle": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Title")%>",
                "TweetInfo1": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Info1")%>",
                "TweetTweet": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Tweet")%>",
                "TweetInfo2": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Info2")%>",
                "ShareURLTitle": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareURL.Title")%>",
                "ShareURLCopy": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareURL.Copy")%>",
                "ShareURLCopied": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareURL.Copied")%>",
                "ShareQRTitle": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareQR.Title")%>",
                "ShareQRDownload": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareQR.Download")%>",
            };
            TweetMyBox("<%=strMyBoxUrl%>", "<%=strTwitterIntentURL%>", hMessages, <%=isApp%>);
        });
    });
</script>
