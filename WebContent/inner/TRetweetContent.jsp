<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
	function DispRetweetMsg(respRetweetContentF) {
		if (respRetweetContentF.result === 1) {
			DispMsg("リツイートしました！");
		} else {
			DispMsg("リツイートできませんでした。<br>作者のツイートにアクセスできない、非公開ツイートである、自分のツイート数が上限に達しているなどの可能性があります。", 5000);
		}
	}

	function _getRetweetContentHtml(){
		return `
<style>
	.RetweetContentDlgTitle{padding: 10px 0 0 0; color: #3498db;font-weight: 500;}
	.RetweetContentDlgInfo{font-size: 14px; text-align: left;}
</style>
<div class="RetweetContentDlg">

<div class="RetweetContentDlgTitle"><i class="fab fa-twitter"></i> リツイート限定</div>

<div class="RetweetContentDlgInfo" style="margin: 15px 0 15px 0;">
作者による作品紹介ツイートをリツイートすると、つづきを見ることができます！
</div>

<div class="RetweetContentDlgInfo" style="text-align: center;">
<input id="NotDisplayFeature" name="NotDisplayFeature" type="checkbox">
<label for="NotDisplayFeature" class="RetweetContentDlgInfo">今後はこのダイアログを表示しない</label>
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
			confirmButtonText: "リツイートしてつづきを見る",
			preConfirm: () => {return {'NotDisplayFeature': $("#NotDisplayFeature").prop('checked')};},
		});
	}
</script>