<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin();
cCheckLogin.GetResults2(request, response);
%>
<!DOCTYPE html>
<html style="height: 100%;">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jspf"%>
		<meta name="description" content="<%=_TEX.T("THeader.Title.Desc")%>" />
		<title><%=_TEX.T("THeader.Title")%></title>
		<style>
		body {padding: 0;}
		.Wrapper {width: 844px; color: #5bd; height: auto; display: flex; flex-flow: row wrap; margin: 0 auto;}
		.AnalogicoDesc {display: block;width: 100%; padding: 30px 0 0 0; box-sizing: border-box; text-align: center; font-size: 16px; line-height: 28px; color: #fff; font-weight: normal;}
		.AnalogicoLogin {margin: 0 0 10px 0;}
		.AnalogicoTerm {display: block;width: 100%; padding: 0; box-sizing: border-box; text-align: center; font-size: 13px; line-height: 28px; color: #fff; font-weight: normal; text-decoration: underline;}
		.AnalogicoStart {text-align: center; margin: 30px 0 0 0; padding: 0 0 30px 0;}
		.IllustThumb .IllustThumbImg {width: 100%; height: 100%;}
		.AnalogicoInfo {display: none;}
		.FooterAd {display: none;}

		.PoipikuInfoTitle {display: block;width: 100%; margin: 0 auto; padding: 30px 0 30px 0; font-size: 24px; font-weight: bold; text-align: center;}
		.PoipikuInfo {width: 340px; padding: 40px; background-color: #fff; color: #5bd; border: solid 1px #fff;}
		.poipikuDesc {display: block;width: 340px; height: auto; margin: 0 auto; font-size: 15px; line-height: 25px;}
		.poipikuDesc.TextOnly {height: auto;}
		.poipikuDesc .DescImg {display: block; width: 340px; background-color: #fff; margin: 10px 0; text-align: center; font-size: 0; border: solid 1px #5bd; overflow: hidden; box-sizing: border-box;}
		.poipikuDesc .DescImg img {background-color: #fff; max-width: 340px; max-height: 340px;}
		.poipikuDesc .DescTitle {font-size: 18px; font-weight: bold;}
		/*
		.PoipikuInfo:nth-child(4n+1), .PoipikuInfo:nth-child(4n+4) {background-color: #5bd; color: #fff;}
		*/
		.PoipikuInfo:nth-child(2n+1) {border-color: #fff #5bd #5bd #fff;}
		.PoipikuInfo:nth-child(2n+2) {border-color: #fff #fff #5bd #fff;}
		.PoipikuInfo:nth-child(1) {border-color: #5bd #5bd #5bd #fff;}
		.PoipikuInfo:nth-child(2) {border-color: #5bd #fff #5bd #fff;}

		.TopBanner {display: block; width: 350px; margin: 0 auto 20px auto;}

		<%if(Common.isSmartPhone(request)) {%>
		<%} else {%>
		.TopBanner {display: block; width: 600px; margin: 0 auto 30px auto;}
		<%}%>
		</style>
	</head>

	<body>
		<div class="Wrapper">
			<div class="PoipikuInfoTitle">
			イラストポイポイSNS「ポイピク」ってこんなに楽しくて便利！
			</div>
		</div>

		<div class="Wrapper">
			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						放置絵、練習絵、ボツ絵、作業進捗、らくがき等々なんでもポイポイ！
					</div>
					<div class="DescImg" style="position: relative; height: 340px;">
						<img src="/img/PoipikuInfo/01.png" style="position: absolute; width: 300px; left: 0;" />
						<img src="/img/PoipikuInfo/02.png" style="position: absolute; width: 150px; right: 0; bottom: 0; padding: 15px 0 0 15px;" />
					</div>
					専用カテゴリが選べるから他人の目を気にせず超お気軽投稿
				</div>
			</div>

			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						評価をやめておやつをあげよう！
					</div>
					<div class="DescImg">
						<img src="/img/PoipikuInfo/03_1.png" style="width: 340px; left: 0;" />
					</div>
					ブクマなし。ハートなし。スターなし。絵文字を使っておやつをあげてみませんか？感情豊かな899種類の共感を伝えてみよう
				</div>
			</div>

			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						まとめもワンクッションも漫画も200枚一気にポイポイ！
					</div>
					<div class="DescImg">
						<img src="/img/PoipikuInfo/04_1.png" />
					</div>
					最大200枚まとめ投稿 ＆ 2枚目以降はクリック後表示 ＆ 漫画が読みやすい縦表示
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						コメント無し！フォローもフォロワーも他人には見られない！
					</div>
					<div class="DescImg" style="height: 240px;">
						<img src="/img/PoipikuInfo/05.png" />
					</div>
					ブクマもハートも無しでさらにコメントも無し。リアクションも匿名でフォローしていることは相手にしか伝わりません
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						新着よけでもっとパーソナル！
					</div>
					<div class="DescImg">
						<img src="/img/PoipikuInfo/10.png" />
					</div>
					もっともっと他の人の目を気にしたくない！と言う時は新着よけを使ってみよう
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						転載対策もOK！
					</div>
					<div class="DescImg" style="height: 290px;">
						<img src="/img/PoipikuInfo/06.png" />
					</div>
					転載禁止表示と右クリック禁止対策済み
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						見たくないものをシャットアウト！
					</div>
					<div class="DescImg" style="height: 246px;">
						<img src="/img/PoipikuInfo/07.png" />
					</div>
					ミュートキーワードを指定するとリアルタイムで見たくないものを非表示に
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						見たくない＆見せたくない人もブロック！
					</div>
					<div class="DescImg" style="height: 304px;">
						<img src="/img/PoipikuInfo/08.png" />
					</div>
					ユーザブロックすれば見えなくなるだけじゃなく、相手からも見えなくなります
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						Twitterでもキレイに見せたい！
					</div>
					<div class="DescImg" style="height: 251px;">
						<img src="/img/PoipikuInfo/09_1.png" />
					</div>
					PCからのアップロードは元データをそのまま無劣化保存して原寸表示。Twitterにも同時ツイート。
					同時ツイートは画像の有り/無しを選べるから、ツイッターのメディア欄を埋めたくない！と言う時にも便利
				</div>
			</div>
			<div class="PoipikuInfo">
			</div>
		</div>

		<div class="Wrapper">
			<div class="PoipikuInfoTitle">
				他にも。。。
			</div>
		</div>

		<div class="Wrapper">
			<div class="PoipikuInfo">
				<div class="poipikuDesc TextOnly">
					<div class="DescTitle">
						動くイラストもOK！
					</div>
					アニメーションGIFにもフル規格で対応。フレームレートが途中で変わるような特殊なGIFも大丈夫
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc TextOnly">
					<div class="DescTitle">
						ポイピクの活動をTwitterで定期お知らせ！
					</div>
					週1回もしくは毎日の時間指定で定期ツイートできる ＆ 古い定期ツイートを自動削除するからTwitterの画像一覧が定期ツイートで埋まらない
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc TextOnly">
					<div class="DescTitle">
						表示が速い！
					</div>
					月間2億PVを支える手書きブログのテクノロジを投入。独自の高速プラットフォームで可能な限りサーバ側で処理して端末に負荷をかけないから、古いスマホやPCでも高速表示
				</div>
			</div>
		</div>
	</body>
</html>