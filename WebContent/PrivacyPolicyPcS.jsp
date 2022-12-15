<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@include file="/inner/Common.jsp"%>
<%
CheckLogin checkLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html lang="ja">
	<head>
		<%@ include file="/inner/THeaderCommonPc.jsp"%>
		<title><%=_TEX.T("THeader.Title")%> - プライバシーポリシー</title>
		<style>
			.AnalogicoInfo {display: none;}
			.SettingList .SettingListItem {color: #000;}
		</style>
	</head>
	<body>
		<div id="DispMsg"></div>
		<%@ include file="/inner/TMenuPc.jsp"%>

		<article class="Wrapper">
			<div class="SettingList">
				<div class="SettingListItem">
					<div class="SettingListTitle" style="text-align: center; font-size: 18px;">「unrealizm」プライバシーポリシー</div>
					<div class="SettingBody">
						EmotionFlowは、個人情報の保護のため法令を遵守するとともに、このプライバシーポリシーを公開し、これに従うことを宣言いたします。<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">1.個人情報の取得</div>
					<div class="SettingBody">
EmotionFlowがサービスを提供するために必要な範囲でのみユーザーの個人情報 (氏名、住所、電話番号等の情報を単一または複数組み合わせることにより特定の個人を識別できる情報)を取得いたします。<br />
個人情報を不正な手段により取得いたしません。<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">2.個人情報の利用</div>
					<div class="SettingBody">
取得したお客様の個人情報は、複数のサービス等において相互に利用することがあります。<br />
保有する個人情報について、利用目的 の達成に必要な範囲を超えて取扱いいたしません。<br />
利用目的 の達成を超える範囲で個人情報を取り扱う場合は、あらかじめ本人の同意を得るものとします。<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">3.個人情報の利用の例外</div>
					<div class="SettingBody">
法令に基づく場合、生命・身体または財産の保護のために必要がある場合、児童の健全な育成の推進のために必要がある場合、公的な機関またはその委託を受けた者に協力する必要がある場合、緊急の事態においてユーザの安全性を保護する必要がある場合は例外として本人の同意を得ずに個人情報を取り扱うことがあります。					</div><br />
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">4.個人情報を利用したデータの公開</div>
					<div class="SettingBody">
取得したユーザーの個人情報をもとに統計データなどのデータを作成する場合、個人を識別できないように加工いたします。<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">5.個人情報の利用の免責</div>
					<div class="SettingBody">
ユーザーが自ら第三者に個人情報を明らかにした場合、ユーザーが入力した情報等により、個人が識別できてしまった場合の責任は負いません。<br />
					</div>
				</div>

				<div class="SettingListItem">
					<div class="SettingListTitle">6.プライバシーポリシーの改定</div>
					<div class="SettingBody">
個人情報を保護するために予告無くプライバシーポリシーを改訂することがあります。<br />
					</div>
				</div>

				<div class="SettingListItem Additional">
					<div class="SettingBody">
						(最終更新日 2022/11/17)
					</div>
				</div>
			</div>
		</article><!--Wrapper-->

		<%@ include file="/inner/TFooterBase.jsp"%>
	</body>
</html>