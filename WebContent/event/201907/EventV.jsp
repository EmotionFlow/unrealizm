<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html lang="<%=_TEX.getLangStr()%>">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>うまい棒40周年記念勝手企画</title>
		<style>
			body {background-color:#feadb4; color: #fff;}
			.SettingListItem a {color: #fff; text-decoration: underline; font-weight: bold;}
			.SettingListItem a:hover {color: #5db;}
			.AnalogicoInfo {display: none;}
			.SettingList .SettingListItem .SettingListTitle {text-align: center; font-size: 20x; font-weight: bold; margin: 20px 0 0 0;}
			.SettingList .SettingListItem {margin: 0 0 20px 0;}
			.cs_table {display: flex; width: 100%; box-sizing: border-box; padding: 0; border-collapse: collapse; border: none; flex-flow: column; margin: 10px 0;}
			.cs_table .cs_tr {display: flex; width: 100%; margin: 5px 0; padding: 5px; box-sizing: border-box; border-radius: 10px; background: #fff; color: #feadb4; flex-flow: row; overflow: hidden; align-items: center;}
			.cs_table .cs_tr:hover {background-color: #3498db; color: #fff;}
			.cs_table .cs_tr .ch_imag_frame {display:block; flex: 0 0 110px;}
			.cs_table .cs_tr .ch_imag_frame a {display: block;}
			.cs_table .cs_tr .ch_img {display: block; width: 100px; text-decoration: none;}
			.cs_table .cs_tr .ch_desc_frame {display:block; flex: 0 0 220px;}
			.warn {font-size: 12px;}
			<%if(!Util.isSmartPhone(request)){%>
			.Wrapper {
				width: 800px;
				min-height: 60px;
				position: relative;
			}
			.SettingList {
				max-width: 800px;
			}
			.SettingList .SettingListItem .SettingListTitle {font-size: 24px;}
			.SettingBody {font-size: 20px;}
			.cs_table .cs_tr {margin: 10px 0; padding: 15px;}
			.cs_table .cs_tr .ch_imag_frame {flex: 0 0 180px;}
			.cs_table .cs_tr .ch_img {display: block; width: 150px;}
			.ch_img {width: 150px;}
			.cs_table .cs_tr .ch_desc_frame {flex: 0 0 580px;}
			.warn {font-size: 14px;}
			<%}%>
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>

		<div class="SettingBody" style="padding: 10px 0 0 0px; text-align: center;">
			<img style="width: 100%; max-width: 1440px;" src="/event/201907/190703.png" />
		</div>

		<article class="Wrapper">
			<div class="SettingList">

				<div class="SettingListItem">
					<div class="SettingListTitle">
						PonQのキャラクターを書いて色々な味のうまい棒をゲットしよう！</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingBody">
「PonQ」はクイズに答えるだけで、素敵な賞品がもらえちゃうライブクイズアプリ。
ポイピク連動企画としてPonQアプリ内で7月7日(日) 午後7時7分から始まるクイズに正解すると大量のうまい棒が当たります！<br />
<br />
そしてさらに！<br />
PonQのキャラクタを描いてポイピクに投稿した方の中から、PonQの番組内で投稿作品が紹介された方全員にうまい棒100本がもらえる企画も行います！
キャラクターごとにもらえるうまい棒の味が違うので、好きなキャラクターを描いて「#PonQ」タグを付けて投稿してください。<br />
ネタでも、ラフでも、擬人化でも、漫画でもなんでもOK。
各キャラのプロフィールはキャラそれぞれのTwitterで確認して下さい！<br />
今すぐPonQキャラクターを描いて投稿しよう！<br />
<div class="cs_table">
	<a class="cs_tr" href="https://twitter.com/godyamaru/" target="_blank">
		<span class="ch_imag_frame">
			<img class="ch_img" src="/event/201907/poi_1.png" />
		</span>
		<span class="ch_desc_frame">
			【ごぢゃまる】<br /><br />
			とんかつソース味が当たるよ！<br />
			自己紹介：@godyamaru<br />
		</span>
	</a>
	<a class="cs_tr" href="https://twitter.com/masyu_mari/" target="_blank">
		<span class="ch_imag_frame">
			<img class="ch_img" src="/event/201907/poi_2.png" />
		</span>
		<span class="ch_desc_frame">
			【ましゅまり】<br /><br />
			シナモンアップルパイ味が当たるよ♡<br />
			自己紹介：@masyu_mari<br />
		</span>
	</a>
	<a class="cs_tr" href="https://twitter.com/banhel_pudding/" target="_blank">
		<span class="ch_imag_frame">
			<img class="ch_img" src="/event/201907/poi_3.png" />
		</span>
		<span class="ch_desc_frame">
			【ばんへる】<br /><br />
			たこやき味が当たるぜ！<br />
			自己紹介：@banhel_pudding<br />
		</span>
	</a>
	<a class="cs_tr" href="https://twitter.com/itazurabrother3/" target="_blank">
		<span class="ch_imag_frame">
			<img class="ch_img" src="/event/201907/poi_4.png" />
		</span>
		<span class="ch_desc_frame">
			【べりある】<br /><br />
			やさいサラダ味が当たるぜっ！<br />
			自己紹介：@itazurabrother3<br />
		</span>
	</a>
	<a class="cs_tr" href="https://twitter.com/dolcechocosuki/" target="_blank">
		<span class="ch_imag_frame">
			<img class="ch_img" src="/event/201907/poi_5.png" />
		</span>
		<span class="ch_desc_frame">
			【どるちぇ】<br /><br />
			チョコレート味が当たるぜ～！<br />
			自己紹介：@dolcechocosuki<br />
		</span>
	</a>
	<a class="cs_tr" href="https://twitter.com/bokumiikan/" target="_blank">
		<span class="ch_imag_frame">
			<img class="ch_img" src="/event/201907/poi_6.png" />
		</span>
		<span class="ch_desc_frame">
			【みぃかん】<br /><br />
			サラミ味が当たるぜぃ！<br />
			自己紹介：@bokumiikan<br />
		</span>
	</a>
	<a class="cs_tr" href="https://twitter.com/tosaka_prince/" target="_blank">
		<span class="ch_imag_frame">
			<img class="ch_img" src="/event/201907/poi_7.png" />
		</span>
		<span class="ch_desc_frame">
			【とさかおうじ】<br /><br />
			やきとり味が当たるっつーの★<br />
			自己紹介：@tosaka_prince<br />
		</span>
	</a>
</div>
「#PonQ」タグを付けるのをお忘れなく！ 当選者はponQで7/7 午後7時7分より放送する番組の中でイラストを紹介させていただきます。<br />
楽しいイラストお待ちしております！<br />
<div class="warn">
※全体公開の状態で投稿して下さい。<br />
※ワンクションが入るものは対象になりません。<br />
※イラストが放送内で紹介されますのであらがじめご了承下さい。
</div>
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
	</body>
</html>