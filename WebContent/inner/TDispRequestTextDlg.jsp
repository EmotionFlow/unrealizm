<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<script type="text/javascript">
	function dispRequestDlg(requestId) {
		$.ajax({
			"type": "post",
			"data": { "ID": requestId },
			"url": "/f/GetRequestF.jsp",
			"dataType": "json",
		})
		.then(
			data => {
				swal.fire({
					html: "<h2><%=_TEX.T("Request.Text")%></h2><pre style='text-align:left;font-size:13px;white-space:pre-wrap;'>" + data.text + "</pre>",
					showConfirmButton: false,
					showCloseButton: true,
				});
			},
			error => {
				console.log(error);
			}
		);
	}
</script>
