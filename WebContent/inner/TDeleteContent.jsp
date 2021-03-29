<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<script>
	function DeleteContent(nUserId, nContentId, bPreviousTweetExist) {
		$.ajax({
			"type": "post",
			"data": {"CID": nContentId},
			"url": "/f/CheckRequestStatusF.jsp",
			"dataType": "json"
		}).then( (data) => {
			if (data.error_code === 0){
				if (data.exist === 1){
					DispMsg("リクエスト納品物は削除できません");
				} else {
					DeleteContentInteractive(
						nUserId, nContentId, bPreviousTweetExist,
						'<%=_TEX.T("IllustListV.CheckDelete")%>',
						'<%=_TEX.T("IllustListV.CheckDelete.Yes")%>',
						'<%=_TEX.T("IllustListV.CheckDelete.No")%>',
						'<%=_TEX.T("IllustListV.CheckDeleteTweet")%>',
						'<%=_TEX.T("IllustListV.CheckDeleteTweet.Yes")%>',
						'<%=_TEX.T("IllustListV.CheckDeleteTweet.No")%>'
					);
				}
			} else {
				DispMsg("サーバーとの通信に失敗しました");
			}
		});
	}
</script>
