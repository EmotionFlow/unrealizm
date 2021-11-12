<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
function _getTwitterFollowerLimitInfoHtml(){
	return `
<style>
.TwitterFollowerLimitInfoDlgTitle{padding: 10px 0 0 0; color: #3498db;font-weight: 500;}
.TwitterFollowerLimitInfoDlgInfo{font-size: 14px; text-align: left;}
</style>
<div class="TwitterFollowerLimitInfoDlg">
<div class="TwitterFollowerLimitInfoDlgTitle"><i class="fab fa-twitter"></i> <%=_TEX.T("TTwitterFollowerLimitInfo.Dlg.Title")%></div>
<div class="TwitterFollowerLimitInfoDlgInfo" style="margin: 15px 0 15px 0;">
<p style="font-weight: 400; text-align: center;"><%=_TEX.T("TTwitterFollowerLimitInfo.Msg01")%></p>
<p><i class="far fa-check-square"></i> <%=_TEX.T("TTwitterFollowerLimitInfo.Msg02")%></p>
<p><i class="far fa-check-square"></i> <%=_TEX.T("TTwitterFollowerLimitInfo.Msg03")%></p>
<p><%=_TEX.T("TTwitterFollowerLimitInfo.Msg04")%></p>
<p style="font-size: 12px"><%=_TEX.T("TTwitterFollowerLimitInfo.Msg05")%></p>
</div>
</div>
`;
	}

function showTwitterFollowerLimitInfoDlg() {
	return Swal.fire({
		html: _getTwitterFollowerLimitInfoHtml(),
		focusConfirm: true,
		showCloseButton: true,
		showCancelButton: false,
		preConfirm: () => {return {'NotDisplayFeature': $("#NotDisplayFeature").prop('checked')};},
	});
}
</script>