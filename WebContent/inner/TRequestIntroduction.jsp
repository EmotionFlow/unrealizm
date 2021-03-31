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
<h2 class="RequestIntroDlgTitle"><i class="fas fa-info-circle"></i>
` + "リクエストとは？" + `
</h2>
<div class="RequestIntroDlgInfo">
	<p>` + "ポイピクユーザー（クライアント）がお題を送り、受け取ったユーザー（クリエイター）がそのリクエストに応じたイラストやテキストを創作すると、投げ銭として報酬をもらうことができる機能です。" + `</p>
	<p>事前打ち合わせやリテイクは一切なしとし、気に入ったリクエストを気軽に創作する環境を目指しています。</p>
</div>
<h2 class="RequestIntroDlgTitle">
` + "特徴" + `
</h2>
<div class="RequestIntroDlgInfo">
<ul>
<li>クリエイターは、受け取ったリクエストから気に入ったもののみ承認することができます。</li>
<li>クライアントからの要求はリクエスト時のみ。ポイピク内外問わず、それ以外のクリエイターとのコミュニケーションは禁止です。</li>
<li>報酬はリクエストを承認した時点で運営にてお預かりします。</li>
</ul>
</div>
<h2 class="RequestIntroDlgTitle">
` + "利用の流れ" + `
</h2>
<div class="RequestIntroDlgInfo">
<ol>
<li>クリエイターはリクエスト募集を開始します。</li>
<li>クライアントはクリエイターのページから、リクエストを送信します。</li>
<li>クリエイターは気に入ったリクエストを承認して、創作を始めます。この時点でクライアント側の支払いが決済されます。</li>
<li>創作物が出来上がったら納品します。</li>
<li>納品のタイミングで、報酬がポチ袋ポイントに加算されます。</li>
<li>クライアントは納品物を見ることができます。非公開やXX限定設定でも閲覧でき、原寸画像をDLできます。</li>
<li>クリエイターはポチ袋ポイントを指定口座に入金することができます。</li>
</ol>
</div>
<h2 class="RequestIntroDlgTitle">
` + "禁止・制限事項" + `
</h2>
<div class="RequestIntroDlgInfo">
<ul>
<li>資金決済法に基づく制限やマネーロンダリング防止のため、リクエスト機能を個人間の送金手段として使うことはできません。</li>
<li>リクエストの募集にはポイピクとtwitterをある程度利用している必要があります。総合的に判断し、リクエストの募集をお断りさせていただくことがあります。</li>
<li>最終的に、報酬は日本国内の銀行口座へ振り込ませていただきます。口座のご用意をお願いいたします。</li>
</ul>
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
