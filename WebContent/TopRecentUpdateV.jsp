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
			ポイピク直近アップデートまとめ(9/26 - 9/30)
			</div>
		</div>

		<div class="Wrapper">
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
						Twitterのメディア欄を節約！
					</div>
					<div class="DescImg" style="height: 251px;">
						<img src="/img/PoipikuInfo/09_1.png" />
					</div>
					同時ツイートで画像の有り/無しを選べる用になりました。
					画像無しでもTwitter公式クライアントであれば埋め込みの形で画像が表示されるから、メディア欄を埋めたくない！と言う時も便利
				</div>
			</div>

			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						おやつをあげよう！
					</div>
					<div class="DescImg">
						<img src="/img/PoipikuInfo/03_1.png" style="width: 340px; left: 0;" />
					</div>
					差し入れに絵文字を使っておやつをあげてみよう
					（合わせて絵文字一覧をオンデマンド読み込みすることで高速軽量化する機能を導入しました）
				</div>
			</div>

			<div class="PoipikuInfo">
				<div class="poipikuDesc">
					<div class="DescTitle">
						フォローに惑わされない！
					</div>
					<div class="DescImg">
						<img src="/img/PoipikuInfo/11.png" />
					</div>
					自分のフォロワーが見えないのがデフォルトになりました
				</div>
			</div>

			<div class="PoipikuInfo">
				<div class="poipikuDesc TextOnly">
					<div class="DescTitle">
						ガイドライン制定
					</div>
					ガイドラインを制定しました。基本的にギャレリアと同じですが、ワンクッションを用いた運用を想定しています
				</div>
			</div>
			<div class="PoipikuInfo">
				<div class="poipikuDesc TextOnly">
					<div class="DescTitle">
						アップロードサイズを大きく
					</div>
					アップロードできる１ファイルのサイズ上限を10Mにしました
				</div>
			</div>
		</div>
	</body>
</html>