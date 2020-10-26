<%@page import="jp.pipa.poipiku.util.Util"%>
<%@page import="jp.pipa.poipiku.Common"%>
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
	.TweetMyBox {
		text-align: center;
		margin: 20px 0 10px 0;
	}
	.TweetMyBoxTitle {
		font-size: 18px;
		padding: 20px 0 9px 0;
	}
	.TweetMyBoxSubTitle{
		font-size: 16px;
		padding: 13px 0 0 0;
		text-align: left;
	}
	.TweetMyBoxInfo {
		font-size: 13px;
		font-weight: 400;
		padding: 9px 0;
		color: #999;
	}
	.TweetMyBoxInfoStep2{
		font-size: 13px;
		font-weight: 400;
		padding: 9px 0;
		text-align: left;
		margin: 0px 10px;
	}
	.TweetMyBoxBtn {
		font-size: 14px;
		font-weight: 400;
		width: 200px;
		margin: 1px auto 2px auto;
		padding: 7px 0;
		display: block;
	}
	.TweetMyBoxPinLink a{
		font-size: 14px;
		font-weight: 400;
		text-decoration: underline;
		color: #5bd;
	}
	.TweetMyBoxHr {
		border: 1px solid #dddddd;
		margin-top: 20px;
	}
	.DownloadMyBoxQR {
		bottom: 8px;
		margin-left: 15px;
		position: relative;
	}
	#CopyMyBoxUrlBtn{
		margin-left: 5px;
		font-size: 14px;
	}
	#DownloadMyBoxQRBtn{
		font-size: 14px;
		position: relative;
		top: -18px;
		left: 12px;
	}

	element.style {
		display: flex;
	}
	.swal2-popup .swal2-close {
		color: #88b9ca;
	}
</style>
<script type="text/javascript">
		$(function(){
				$('#MenuMe').addClass('Selected');
				updateCategoryMenuPos(0);
				$("#OpenTweetMyBoxDlgBtn").click(function(){
						var hMessages = {
								"TweetTitle": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Title")%>",
								"TweetStep1": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Step1")%>",
								"TweetStep2": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Step2")%>",
								"TweetInfo1": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Info1")%>",
								"TweetInfo2": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Info2")%>",
								"TweetHowToPin": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.HowToPin")%>",
								"TweetTweet": "<%=_TEX.T("MyIllustListV.TweetMyBox.Tweet.Tweet")%>",
								"ShareURLTitle": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareURL.Title")%>",
								"ShareURLCopy": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareURL.Copy")%>",
								"ShareURLCopied": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareURL.Copied")%>",
								"ShareQRTitle": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareQR.Title")%>",
								"ShareQRDownload": "<%=_TEX.T("MyIllustListV.TweetMyBox.ShareQR.Download")%>",
						};
						TweetMyBox("<%=strMyBoxUrl%>", "<%=strTwitterIntentURL%>", hMessages, <%=Util.isSmartPhone(request)%>);
				});
		});
</script>
