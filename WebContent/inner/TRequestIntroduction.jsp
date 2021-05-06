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

<h2 class="RequestIntroDlgTitle">リクエスト(β)とは？</h2>
<div class="RequestIntroDlgInfo" style="margin-top: 11px;">
	<p>ポイピクユーザー（クライアント）が投げ銭つきでお題を送り、受け取ったポイピクユーザー（クリエイター）がイラストやテキストを創作すると、投げ銭として報酬をもらうことができる仕組みです。</p>
</div>
<h2 class="RequestIntroDlgTitle">特徴</h2>
<div class="RequestIntroDlgInfo">
<ul style="font-weight:bold">
	<li>クリエイターには、リクエストにかかる手数料が一切発生しません。</li>
	<li>クライアントは、リクエスト時に創作物の用途範囲を明確に選択できます。</li>
	<li>クリエイターは、受け取ったリクエストから気に入ったもののみ承認できます。</li>
	<li>クライアントからの要求はリクエスト時のみ。それ以外はポイピク内外問わず、コミュニケーション禁止です。</li>
	<li>創作物の内容は、リクエスト内容・用途・金額から、クリエイターが判断します。</li>
</ul>
</div>
<h2 class="RequestIntroDlgTitle">利用の流れ</h2>
<div class="RequestIntroDlgInfo">
<ol>
	<li>クリエイターはリクエスト募集を開始します。</li>
	<li>クライアントはクリエイターのリクエストページから、リクエストを送信します。</li>
	<li>クリエイターは気に入ったリクエストを承認して、創作を始めます。この時点でクライアント側の支払いが決済されます。</li>
	<li>クリエイターは納期内に創作物を作成し、納品します。</li>
	<li>納品のタイミングで、報酬がポチ袋ポイントに加算されます。</li>
	<li>クライアントは納品物を非公開やXX限定設定でも閲覧でき、原寸画像をDLできます。</li>
	<li>ポチ袋ポイントは日本国内の銀行口座に入金できます。</li>
</ol>
</div>
<h2 class="RequestIntroDlgTitle">禁止・制限事項</h2>
<div class="RequestIntroDlgInfo">
<ul>
	<li>募集開始にはいくつか条件があります。条件に合致しない場合、リクエストの募集をお断りさせていただくことがあります。</li>
	<li>リクエスト機能を個人間の送金手段として使うことはできません。</li>
</ul>
</div>
<div class="RequestIntroDlgInfo" style="text-align: center;">
<a href="/GuideLineRequest<%=isApp?"App":"Pc"%>V.jsp">より詳しいガイドラインはこちら</a>
</div>

<%if(isApp){%>
<div class="RequestIntroDlgInfo" style="text-align: center;margin-top: 20px; padding: 2px;border: solid 2px;border-radius: 4px;">
リクエストの募集はブラウザ版のポイピク設定画面からはじめられます
</div>
<%}else{%>
<div class="RequestIntroDlgTitle" style="text-align: center;">
<a href="/MyEditSettingPcV.jsp?MENUID=REQUEST">リクエスト募集を設定する</a>
</div>
<%}%>

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
