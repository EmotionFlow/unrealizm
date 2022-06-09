<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
	function showTransDescMsg() {
		Swal.fire({
			footer: 'キャプション翻訳(β)',
			text: '[デフォルト]以外の言語でキャプションを設定すると、その言語で閲覧している方に自動で切り替えて表示されます。',
			showConfirmButton: true,
			focusConfirm: true,
			showCloseButton: true,
		});
	}
</script>