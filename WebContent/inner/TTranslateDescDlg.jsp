<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	function showTransDescMsg() {
		Swal.fire({
			footer: '<%=_TEX.T("TTranslateDescDlg.Footer")%>',
			text: '<%=_TEX.T("TTranslateDescDlg.Info")%>',
			showConfirmButton: true,
			focusConfirm: true,
			showCloseButton: true,
		});
	}
</script>