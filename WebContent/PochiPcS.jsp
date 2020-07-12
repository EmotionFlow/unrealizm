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
			.AnalogicoInfo {display: none;}
			.EntryButtonArea{
				position: relative;
				height: 26px;
				width: 100%;
				float:left;
				margin: 20px 0px;
			}
			.Button {
				display: block;
				border: 1px solid #5bd;
				padding:5px;
				width: 200px;
				height: 26px;
				top: 0;
				bottom: 0;
				left: 0;
				right: 0;
				position: absolute;
				margin: auto;
				text-align: center;
				background-color: #fff;
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
				font-size: 28px;
				text-align: center;
			}
			.SettingList .SettingListItem .SettingListTitle.Head {
				margin-top:40px; 
				margin-bottom:10px; 
				font-size: 24px;
				text-align: left;
			}
			.SettingList .SettingListItem .SettingBody {
				font-size: 18px;
				text-align: left;
			}
			.SettingList .SettingListItem .SettingBody.Left {
				text-align: left;
			}
			img.PochiBukuro {
				margin-left: 200px;
			}
			img.PochiImg {
				width: 600px;
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
還元率は様々な指標に基づいて計算し、概ね70%〜80%です。
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
売上金は月ごとに集計し、2ヶ月後に指定口座へ振り込みます。<br />
※現在準備中です。
					</div>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>