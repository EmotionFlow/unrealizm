<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script>
function getRequestIntroductionHtml(){
	return `
<style>
	.RequestIntroDlgTitle{padding: 10px 0 0 0;}
	.RequestIntroDlgInfo{font-size: 13px; text-align: left;}
	.RequestIntroDlgInfo ul {padding-inline-start: 25px;}
	.RequestIntroDlgInfo ol {padding-inline-start: 25px;}
</style>
<h2 class="RequestIntroDlgTitle">リクエスト(β)とは？</h2>
<div class="RequestIntroDlgInfo" style="margin-top: 11px;">
	<p>ポイピクユーザー（クライアント）がお題を送り、受け取ったユーザー（クリエイター）がそのリクエストに応じたイラストやテキストを創作すると、投げ銭として報酬をもらうことができる仕組みです。</p>
	<p>事前打ち合わせやリテイクは一切なしとし、クライアントは気軽にリクエストを送信し、クリエイターは気に入ったリクエストを気軽に創作する環境を目指しています。</p>
</div>
<h2 class="RequestIntroDlgTitle">特徴</h2>
<div class="RequestIntroDlgInfo">
<ul>
	<li>クリエイターは、受け取ったリクエストから気に入ったもののみ承認できます。</li>
	<li>クライアントからの要求はリクエスト時のみ。ポイピク内外問わず、それ以外のクリエイターとのコミュニケーションは禁止です。</li>
	<li>創作物の内容は、リクエスト内容と金額から、クリエイターが判断します。</li>
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
</ol>
</div>
<h2 class="RequestIntroDlgTitle">禁止・制限事項</h2>
<div class="RequestIntroDlgInfo">
<ul>
	<li>募集開始にはいくつか条件があります。条件に合致しない場合、リクエストの募集をお断りさせていただくことがあります。</li>
	<li>リクエスト機能を個人間の送金手段として使うことはできません。</li>
	<li>ポチ袋ポイントは日本国内の銀行口座に限り入金できます。</li>
</ul>
</div>
<h2 class="RequestIntroDlgTitle">ガイドライン</h2>
<div class="RequestIntroDlgInfo">
<a style="color: #545454; text-decoration: underline;" href="/GuideLineRequestPcV.jsp">より詳しいガイドラインはこちらをご覧ください</a>
</div>
`;
	}

function dispRequestIntroduction(){
	Swal.fire({
		html: getRequestIntroductionHtml(),
		focusConfirm: true,
		showConfirmButton: true,
	})
}
</script>
