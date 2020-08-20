<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
		function DeleteContent(nUserId, nContentId, bPreviousTweetExist) {
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
</script>
