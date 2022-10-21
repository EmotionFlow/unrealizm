<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/inner/Common.jsp"%>
<%CheckLogin checkLogin = new CheckLogin(request, response);%>
<!DOCTYPE html>
<html lang="ja">
	<head>
		<%@ include file="/inner/THeaderCommon.jsp"%>
		<title>特定商取引法に基づく表記</title>
		<style>
			.SettingList .SettingListItem {color: #fff;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingListItem">
					<div class="SettingListTitle" style="text-align: center; font-size: 18px;">特定商取引法に基づく表記</div>
				</div>
				<div class="SettingListItem">
					<div class="SettingListTitle">販売業者</div>
					<div class="SettingBody">
						株式会社pipa.jp<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">運営統括責任者名</div>
					<div class="SettingBody">
						川合和寛<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">郵便番号</div>
					<div class="SettingBody">
						〒160ｰ0004<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">住所</div>
					<div class="SettingBody">
						東京都新宿区四谷１丁目２２番地<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">商品代金以外の料金の説明</div>
					<div class="SettingBody">
						なし<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">引渡し時期</div>
					<div class="SettingBody">
						オンラインによる即時<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">お支払い方法</div>
					<div class="SettingBody">
						クレジットカード(VISA/MASTER/JCB/AMEX/DINERS)<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">お支払期限</div>
					<div class="SettingBody">
						ご利用のカード会社ごとに異なります。<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">返品期限</div>
					<div class="SettingBody">
						オンライン商品のため返品不可<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">返品送料</div>
					<div class="SettingBody">
						不要<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">資格・免許</div>
					<div class="SettingBody">
						販売管理者名：川合和寛<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">屋号またはサービス名</div>
					<div class="SettingBody">
						unrealizm<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">電話番号</div>
					<div class="SettingBody">
						03-6869-5600<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">メールアドレス</div>
					<div class="SettingBody">
						cs@pipa.jp<br />
					</div>
				</div>

				<div class="SettingListItem Additional">
					<div class="SettingBody">
						(最終更新日 2021/1/4)
					</div>
				</div>
			</div>
		</article><!--Wrapper-->
	</body>
</html>
