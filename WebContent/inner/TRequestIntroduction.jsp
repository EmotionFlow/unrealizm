<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
function _getRequestIntroductionHtml(){
	return `
<style>
	.RequestIntroDlg a {color: #545454; text-decoration: underline;}
	.RequestIntroDlgTitle{padding: 10px 0 0 0;}
	.RequestIntroDlgInfo{font-size: 13px; text-align: left;}
	.RequestIntroDlgInfo ul {padding-inline-start: 25px;}
	.RequestIntroDlgInfo ol {padding-inline-start: 25px;}
</style>
<div class="RequestIntroDlg">

<h2 class="RequestIntroDlgTitle">エアスケブ(β)とは？</h2>
<div class="RequestIntroDlgInfo" style="margin-top: 11px;">
	<p style="text-align: center; color:#ff6b00"><i class="fas fa-bullhorn"></i><br> リクエスト(β)→エアスケブ(β)<br>無償依頼にも対応しました！</p>
	<p>ポイピクユーザー（依頼主）がお題を依頼し、受け取ったポイピクユーザー（クリエイター）がイラストやテキストを創作してお渡しする仕組みです。</p>
</div>
<h2 class="RequestIntroDlgTitle">特徴</h2>
<div class="RequestIntroDlgInfo">
<ul style="font-weight:400; color:#707070">
	<li>創作物の用途範囲を選択して依頼します。</li>
	<li>クリエイターは受け取った依頼から気に入ったもののみ、自分のペースに合わせて承認できます。</li>
	<li>創作の内容は、依頼内容・用途・有償の場合は金額から、クリエイターが判断します。</li>
	<li>無償依頼：手数料は不要です。</li>
	<li>有償依頼：クリエイター側には依頼にかかる手数料は発生しません。</li>
</ul>
</div>
<h2 class="RequestIntroDlgTitle">利用の流れ</h2>
<div class="RequestIntroDlgInfo">
<ol>
	<li>クリエイター：エアスケブ受付を開始します。</li>
	<li>依頼主：エアスケブ受付ページから依頼を送信します。</li>
	<li>クリエイター：受けられそうな依頼を承認し、創作を始めます。</li>
	<li>クリエイター：できあがったら依頼主にお渡します。</li>
	<li>作品はお渡し後もクリエイターのマイボックスにあります。（更新や削除は不可）</li>
	<li>依頼者はマイスケブ画面にて、いただいた作品を閲覧できます。また原寸画像をDLできます。</li>
</ol>
</div>

<%if(isApp){%>
<div class="RequestIntroDlgInfo" style="text-align: center;margin-top: 20px; padding: 2px;border: solid 2px;border-radius: 4px;">
エアスケブはブラウザ版のポイピク設定画面からはじめられます
</div>
<%}else{%>
<div class="RequestIntroDlgTitle" style="color: #ff6b00; text-align: center;">
<a style="color: #ff6b00;" href="/MyEditSettingPcV.jsp?MENUID=REQUEST">エアスケブの受付をはじめる</a>
</div>
<%}%>

<div class="RequestIntroDlgInfo" style="margin-top: 22px; text-align: center;">
<a style="text-decoration: none;" href="/GuideLineRequest<%=isApp?"App":"Pc"%>V.jsp">より詳しいガイドラインはこちら</a>
</div>

</div>
`;
}

function dispRequestIntroduction(){
	Swal.fire({
		html: _getRequestIntroductionHtml(),
		focusConfirm: false,
		showConfirmButton: false,
		showCloseButton: true,
	})
}
</script>
