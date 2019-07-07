<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - うまい棒40周年記念勝手企画</title>
		<style>
			body {background: #6e1b89; color: #fff;}
			a {color: #fff; text-decoration: underline; font-weight: bold;}
			.AnalogicoInfo {display: none;}
			.Footer {background: #6e1b89;}
			<%if(!Util.isSmartPhone(request)){%>
			.Wrapper {
				width: 800px;
				min-height: 60px;
				position: relative;
			}
			.SettingList {
				max-width: 800px;
			}
			.SettingBody {font-size: 20px;}
			<%}%>
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<div class="SettingBody">
			<img style="width: 100%;" src="/event/201906/umaibo_poipiku_05_190625.png" />
		</div>

		<article class="Wrapper">
			<div class="SettingList">

				<div class="SettingListItem">
					<div class="SettingListTitle" style="text-align: center; font-size: 24px; font-weight: bold;">うまい棒40周年記念勝手企画</div>
					<div class="SettingBody" style="text-align: center; font-weight: bold;">
						「願いよ届け！うまい棒めんたい味(のみ)7777本を1名様に強制プレゼント」
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingBody">
日本でいや、世界でいや、銀河系で一番売れている(きっと)駄菓子「うまい棒」。<br />
そんな全宇宙レベルの最強駄菓子うまい棒が40週年を迎えました。おめでとうございます！<br />
そこで、ポイピクでは七夕に<br />
「願いよ届け！うまい棒めんたい味(のみ)7777本を1名様に強制プレゼント」<br />
という企画を実施します。<br />
<br />
七夕で願うことと言えば、最もポピュラーなのは、そう<br />
「うまい棒めんたい味(のみ)を腹が裂けるまで食べたい！」<br />
ですね！(当社代表調べ)<br />
ポイピクがその夢を叶えます！<br />
<br />
ポイピクの<a href="https://twitter.com/pipajp">pipa.jp公式ツイッター(@pipajp)</a>にて実施！<br />
本企画関連の記事の合計RT数ぶんだけ「うまい棒めんたい味(のみ)」、最大7777本を1名様に強制的に送りつけ、、、いや、プレゼントいたします！<br />
置く場所も賞味期限も一切考えず一括で送りつけますので、覚悟してくRTしてくださいっ！<br />
<br />
1日100本くらいずつ食べ続ければ賞味期限に間に合います。多分。<br />
1日3500キロカロリーですが、うまい棒めんたい味はパーフェクトフードなので、ぜんぜん大丈夫です。きっと。<br />
<br />
RTいただく度にスタッフ総出で近所のコンビニを駆けずり回り、うまい棒めんたい味を買って参ります。<br />
その様子も合わせて<a href="https://twitter.com/pipajp">pipa.jp公式ツイッター</a>で随時報告させていただきますのでお楽しみに！<br />
(DMにてご連絡しますのでフォローしておいて頂けるとありがたいです。)<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingBody">
めんたい味じゃなくて他の味をお腹壊すまで食べたい！という方もご安心ください。
本企画は「クイズに答えるだけで、素敵な賞品がもらえちゃうPonQ」さんとの共同企画です。<br />
PonQさんでは他の味が当たります！<br />
他の味が食べたいという方はぜひ下記のPonQキャラクターのアカウントをフォローしてRTしてください！<br />
<ul>
<li>
<a href="https://twitter.com/godyamaru/" target="_blank">
【ごぢゃまる】とんかつソース味 @godyamaru
</a>
</li>
<li>
<a href="https://twitter.com/masyu_mari/" target="_blank">
【ましゅまり】シナモンアップルパイ味 @masyu_mari
</a>
</li>
<li>
<a href="https://twitter.com/banhel_pudding/" target="_blank">
【ばんへる】たこやき味 @banhel_pudding
</a>
</li>
<li>
<a href="https://twitter.com/itazurabrother3/" target="_blank">
【べりある】やさいサラダ味 @itazurabrother3
</a>
</li>
<li>
<a href="https://twitter.com/dolcechocosuki/" target="_blank">
【どるちぇ】チョコレート味 @dolcechocosuki
</a>
</li>
<li>
<a href="https://twitter.com/bokumiikan/" target="_blank">
【みぃかん】サラミ味 https://twitter.com/@bokumiikan
</a>
</li>
<li>
<a href="https://twitter.com/tosaka_prince/" target="_blank">
【とさかおうじ】やきとり味 @tosaka_prince
</a>
</li>
</ul>
<br />
当選者はponQで7/7 午後7時7分より放送する番組の中で発表させていただきます。<br />
<br />

<ul>
<li>
<a href="https://apps.apple.com/jp/app/ponq-%E3%81%BD%E3%82%93%E3%81%8D%E3%82%85%E3%83%BC/id1434815149" target="_blank">
ponQアプリ App Store
</a>
</li>
<li>
<a href="https://play.google.com/store/apps/details?id=jp.co.gochipon.live&hl=ja" target="_blank">
ponQアプリ Google Play
</a>
</li>
</ul>
					</div>
				</div>
			</div>
		</article>

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>