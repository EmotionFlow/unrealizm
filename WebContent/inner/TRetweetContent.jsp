<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
	function DispRetweetMsg(respRetweetContentF) {
		if (respRetweetContentF.result === <%=Common.API_OK%>) {
			DispMsg("<%=_TEX.T("TRetweetContent.Msg.Done")%>");
		} else if(respRetweetContentF.result === <%=CTweet.RETWEET_ALREADY%>) {
			// pass
		} else {
			if (respRetweetContentF.error_detail_code === <%=RetweetContentC.ErrorDetail.NotSignedIn.getCode()%>) {
				DispMsg("<%=_TEX.T("TRetweetContent.Msg.Error.NeedSignIn")%>>", 4000);
			} else {
				DispMsg("<%=_TEX.T("TRetweetContent.Msg.Error")%>", 5000);
			}
		}
	}

	function _getRetweetContentHtml(){
		return `
<style>
	.RetweetContentDlgTitle{padding: 10px 0 0 0; color: #000000;font-weight: 500;}
	.RetweetContentDlgInfo{font-size: 14px; text-align: left;}
</style>
<div class="RetweetContentDlg">

<div class="RetweetContentDlgTitle"><i class="fab fa-twitter"></i> <%=_TEX.T("TRetweetContent.Dlg.Title")%></div>

<div class="RetweetContentDlgInfo" style="margin: 15px 0 15px 0;">
<%=_TEX.T("TRetweetContent.Dlg.Info")%>
</div>

<div class="RetweetContentDlgInfo" style="text-align: center;">
<input id="NotDisplayFeature" name="NotDisplayFeature" type="checkbox">
<label for="NotDisplayFeature" class="RetweetContentDlgInfo"><%=_TEX.T("TRetweetContent.Dlg.NotDisplayFeature")%></label>
<div>

</div>
`;
	}

	function showRetweetContentDlg() {
		return Swal.fire({
			html: _getRetweetContentHtml(),
			focusConfirm: false,
			showCloseButton: true,
			showCancelButton: false,
			confirmButtonText: "<%=_TEX.T("TRetweetContent.Dlg.Confirm")%>",
			preConfirm: () => {return {'NotDisplayFeature': $("#NotDisplayFeature").prop('checked')};},
		});
	}
</script>