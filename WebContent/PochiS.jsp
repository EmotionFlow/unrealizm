<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>ポチ袋</title>
		<style>
			body {
				background: #fff;
			}
			.SettingList .SettingListItem {
				display: block;
				float: left;
				width: 100%;
				box-sizing: border-box;
				margin: 0 0 10px 0;
				padding: 0 10px;
			}
			.SettingList .SettingListItem .SettingListTitle {
				display: block;
				float: left;
				width: 100%;
				box-sizing: border-box;
				margin: 5px 0;
			    font-size: 16px;
			}
			.SettingList .SettingListItem .SettingListTitle.Head {
				margin-top:20px;
				margin-bottom:10px;
				text-align: center;
			    font-size: 16px;
			}
			.SettingList .SettingListItem .SettingBody {
				text-align: left;
			}
			.SettingList .SettingListItem .SettingBody.Left {
				text-align: left;
			}
			img.PochiBukuro {
				margin-left: 80px;
			}
			img.PochiImg {
				width: 360px;
			}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>
		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingListItem">
					<div class="SettingListTitle">「ポチ袋」でクリエーターを応援しよう！</div>
					<img class="PochiBukuro" src="/img/pochi.png" />
					<div class="SettingListTitle Head">「ポチ袋」とは？</div>
					<div class="SettingBody">
ファンからクリエーターへの応援の気持ちを1口100円からポチッと送れるサービスです。<br /><br />

クリーエーターの方には「ポチ袋」の売上金が還元されます。<br />
還元率は直近の投稿枚数、絵文字送信数、Twitterからの閲覧数等に基づいて計算し、概ね70%〜80%です。
					</div>

					<div class="SettingListTitle Head">「ポチ袋」の送り方</div>
					<div class="SettingBody Left">
①	「ポチ袋」で絵文字を押します。<br />
<img class="PochiImg" src="/img/pochi01.png" /><br /><br />

②	金額を選択し、「ポチ袋をつける」を押します。<br />
<img class="PochiImg" src="/img/pochi02.png" /><br /><br />

③	初めて送る場合はお支払い情報を入力します。<br />
<img class="PochiImg" src="/img/pochi03.png" />
					</div>

					<div class="SettingListTitle Head">「ポチ袋」の受け取り方</div>
					<div class="SettingBody Left">
ポチ袋の売上金は月末に集計し、翌々月末に指定口座へ振り込みます。<br />
受け取りには日本の銀行の普通口座が必要です。
					</div>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>