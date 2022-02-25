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
	<p>ポイピクユーザー（依頼主）がお題を依頼し、受け取ったポイピクユーザー（クリエイター）がイラストやテキストを創作する仕組みです。</p>
	<p style="text-align: center"><span style="color:#ff0000">new!</span> 無償依頼にも対応しました！
</div>
<h2 class="RequestIntroDlgTitle">特徴</h2>
<div class="RequestIntroDlgInfo">
<ul style="font-weight:bold">
	<li>依頼主は、依頼時に創作物の用途範囲を明確に選択します。</li>
	<li>クリエイターは、受け取ったリクエストから気に入ったもののみ、自分のペースに合わせて承認できます。</li>
	<li>依頼主からの要求は依頼時のみ。それ以外はポイピク内外問わず、コミュニケーション禁止です。</li>
	<li>創作物の内容は、依頼内容・用途・金額から、クリエイターが判断します。</li>
	<li>(有償依頼の場合)クリエイター側にはリクエストにかかる手数料が一切発生しません。</li>
</ul>
</div>
<h2 class="RequestIntroDlgTitle">利用の流れ</h2>
<div class="RequestIntroDlgInfo">
<ol>
	<li>クリエイターはエアスケブ受付を開始します。</li>
	<li>依頼主はクリエイターのエアスケブ受付ページから、依頼を送信します。</li>
	<li>クリエイターは気に入った依頼を承認して、創作を始めます。</li>
	<li>クリエイターは期限内に創作物を作成し、依頼主に渡します。</li>
	<li>創作物はお渡し後もクリエイターのマイボックスにあり、公開設定を変更できます。</li>
	<li>依頼者は、創作物が非公開やXX限定設定でも閲覧できます。また原寸画像をDLできます。</li>
</ol>
(有償リクエストの場合)
<ol>
	<li>クリエイターによる依頼承認の時点で依頼主側の支払いが決済されます。</li>
	<li>納品のタイミングで、報酬がポイピクのポイントに加算されます。</li>
	<li>ポイピクのポイントは日本国内の銀行口座に入金できます。</li>
</ol>
</div>
<h2 class="RequestIntroDlgTitle">禁止・制限事項</h2>
<div class="RequestIntroDlgInfo">
<ul>
	<li>開始にはいくつか条件があります。条件に合致しない場合、エアスケブ受付の開始をお断りさせていただくことがあります。</li>
	<li>(有償リクエストの場合)エアスケブ機能を個人間の送金手段として使うことはできません。</li>
</ul>
</div>
<div class="RequestIntroDlgInfo" style="text-align: center;">
<a href="/GuideLineRequest<%=isApp?"App":"Pc"%>V.jsp">より詳しいガイドラインはこちら</a>
</div>

<%if(isApp){%>
<div class="RequestIntroDlgInfo" style="text-align: center;margin-top: 20px; padding: 2px;border: solid 2px;border-radius: 4px;">
エアスケブはブラウザ版のポイピク設定画面からはじめられます
</div>
<%}else{%>
<div class="RequestIntroDlgTitle" style="text-align: center;">
<a href="/MyEditSettingPcV.jsp?MENUID=REQUEST">エアスケブの受付をはじめる</a>
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
