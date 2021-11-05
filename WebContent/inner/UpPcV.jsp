<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	function startMsg() {
		$('#UoloadCmdBtn').addClass('Disabled').html('<%=_TEX.T("EditIllustVCommon.Uploading")%>');
		DispMsgStatic("<%=_TEX.T("EditIllustVCommon.Uploading")%>");
	}

	function dateTimeEmptyMsg() {
		DispMsg('<%=_TEX.T("EditIllustVCommon.EditTimeLimited.EmptyError")%>');
	}

	function dateTimePastMsg() {
		DispMsg('<%=_TEX.T("EditIllustVCommon.EditTimeLimited.PastError")%>');
	}

	function dateTimeReverseMsg() {
		DispMsg('<%=_TEX.T("EditIllustVCommon.EditTimeLimited.ReverseError")%>');
	}

	function anyoneCanViewFirstErrMsg() {
		DispMsg("「最初の１枚目だけ公開する」オプションは複数枚投稿時のみ有効です");
	}

	function twtterListRateLimiteExceededMsg() {
		DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.T_List.RateLimiteExceeded")%>");
	}
	function twtterListInvalidTokenMsg() {
		DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.T_List.InvalidToken")%>");
	}
	function twitterListNotFoundMsg() {
		DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.T_List.NotFound")%>");
	}
	function twtterListOtherErrMsg(nErrCode) {
		DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.T_List.OtherErr")%>: " + nErrCode);
	}

	function twtterTweetInvalidTokenMsg() {
		DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.InvalidToken")%>");
	}
	function twtterTweetRateLimitMsg() {
		DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.RateLimiteExceeded")%>");
	}
	function twtterTweetTooMuchMsg() {
		DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.TooMuch")%>");
	}
	function twtterTweetOtherErrMsg(nErrCode) {
		DispMsg("<%=_TEX.T("UploadFilePc.Option.Publish.Tweet.OtherErr")%>: " + nErrCode);
	}

	function needTweetForRTLimitMsg() {
		DispMsg("リツイート限定で公開するときは同時ツイートをONにしてください");
	}

	function completeMsg() {
		DispMsg("<%=_TEX.T("EditIllustVCommon.Uploaded")%>");
	}

	function errorMsg(result) {
		$('#UoloadCmdBtn').removeClass('Disabled').html('<%=_TEX.T("UploadFilePc.UploadBtn")%>');

		if(result == <%=Common.UPLOAD_FILE_TOTAL_ERROR%>) {
			// file size error
			DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileSize")%>');
		} else if(result == <%=Common.UPLOAD_FILE_TYPE_ERROR%>) {
			// file type error
			DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error.FileType")%>');
		} else {
			DispMsg('<%=_TEX.T("EditIllustVCommon.Upload.Error")%><br />error code:#' + data.result);
		}
	}

	function showFineUploaderErrorDialog(errorName) {
		if (errorName === FINE_UPLOADER_ERROR.typeError) {
			DispMsg("<%=_TEX.T("FineUploader.TypeError")%>");
		} else if (errorName === FINE_UPLOADER_ERROR.tooManyItemsError) {
			showIntroductionPoipassDlgHtml(
				'<%=_TEX.T("FineUploader.TooManyItemsError")%>',
				'<%=_TEX.T("FineUploader.TooManyItemsError.PoipassAd")%>',
				'<%=_TEX.T("IntroductionPoipass.ShowButton")%>',
				'<%=_TEX.T("IntroductionPoipass.FooterHtml")%>'
			);
		} else if (errorName === FINE_UPLOADER_ERROR.totalSizeError || errorName === FINE_UPLOADER_ERROR.sizeError) {
			showIntroductionPoipassDlgHtml(
				'<%=_TEX.T("FineUploader.SizeError")%>',
				'<%=_TEX.T("FineUploader.SizeError.PoipassAd")%>',
				'<%=_TEX.T("IntroductionPoipass.ShowButton")%>',
				'<%=_TEX.T("IntroductionPoipass.FooterHtml")%>'
			);
		} else {
			alert(errorName);
		}
	}

	function DispDescCharNum() {
		var nCharNum = <%=Common.EDITOR_DESC_MAX[nEditorId][checkLogin.m_nPassportId]%> - $("#EditDescription").val().length;
		$("#DescriptionCharNum").html(nCharNum);
	}

	<%if(nEditorId==Common.EDITOR_TEXT){%>
	function DispTextCharNum() {
		var nCharNum = <%=Common.EDITOR_TEXT_MAX[nEditorId][checkLogin.m_nPassportId]%> - $("#EditTextBody").val().length;
		$("#TextBodyCharNum").html(nCharNum);
	}
	<%}%>
</script>