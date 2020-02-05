<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin cCheckLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title>株式会社pipa.jp スタッフ募集のお知らせ</title>
		<style>
			.AnalogicoInfo {display: none;}
			.EntryButtonArea{
					position: relative;
					height: 26px;
					width: 100%;
					float:left;
					margin: 20px 0px;
			}
			.EntryButton{
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
				font-size: 18px;
			}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingListItem">
					<div class="SettingListTitle" style="text-align: center; font-size: 18px;">株式会社pipa.jp スタッフ募集のお知らせ</div>
					<div class="SettingBody">
						株式会社pipa.jpが提供する各種サービスの運営業務を担って頂ける人材を募集します。<br/>
						イラストを始めとする創作活動の支援や、インターネットサービスの仕事を通して共に成長したい方はぜひご応募ください。<br/><br/>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">雇用形態</div>
					<div class="SettingBody">
					アルバイト
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">必要スキル・経験</div>
					<div class="SettingBody">
						<ul>
							<li>基本的なPCスキル（メール、Word/Excel、インターネット）</li>
							<li>PCによる簡単なイラスト制作</li>
						</ul>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">主な業務内容</div>
					<div class="SettingBody">
						<ul>
							<li>ユーザから寄せられる各種問い合わせへの対応</li>
							<li>文書やWebサイト用イラスト素材の作成</li>
							<li>サイト内イベントの企画、運営</li>
						</ul>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">時給</div>
					<div class="SettingBody">
					1,100円～2,000円
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">勤務地</div>
					<div class="SettingBody">
					東京都新宿区四谷1-22-5 WESTALL四谷ビル 1F
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">アクセス</div>
					<div class="SettingBody">
					JR・東京メトロ各線「四ツ谷駅」徒歩5分
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">待遇・条件・その他</div>
					<div class="SettingBody">
						<ul>
							<li>社会保険（関東ITソフトウェア健康保険組合）/ 雇用保険 / 厚生年金 / 労災保険</li>
							<li>通勤手当（月上限2万）</li>
							<li>書籍購入手当</li>
							<li>部活動補助</li>
							<li>フリードリンク</li>
							<li>単月ごとのインセンティブ査定有り</li>
							<li>単月ごとの昇給・昇格の査定有り</li>
						</ul>
						■ 休日/休暇
						<ul>
							<li>完全週休2日制（土・日）</li>
							<li>祝日</li>
							<li>年次有給休暇</li>
							<li>特別休暇（産休育休、看護休暇、等）</li>
						</ul>
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">選考の流れ</div>
					<div class="SettingBody">
1. 応募<br/>
「応募する」よりエントリーしてください。<br/>
採用については親会社のレアゾン・ホールディングスが一括で行っており、<br>
応募フォームはレアゾン・ホールディングスのものになります。
<div class="Notice">
<ul>
	<li>※1:「希望職種」は「イラストレーター」をお選びください。</li>
	<li>※2:「希望雇用形態」は「アルバイト」をお選びください。</li>
	<li>※3:「伝達事項」に「pipa.jpへのエントリー」とご記入ください。</li>
</ul>
</div>

2. 面談、スキルテスト<br/>
履歴書等をご準備の上、面談にお越しいただきます。会場は東京です。<br/>
面談後、職種によりスキルテストを実施させて頂く場合がございます。<br/>
<br/>

3. 内定<br/>
ご希望の勤務開始時期に応じて入社予定日をご相談させていただきます。
					</div>
				</div>

				<div class="EntryButtonArea">
					<a class="EntryButton" href="https://reazon.jp/recruit/apply/">応募する</a>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>