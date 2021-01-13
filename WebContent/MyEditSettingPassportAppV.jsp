<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="oauth.signpost.OAuthConsumer"%>
<%@page import="oauth.signpost.OAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthProvider"%>
<%@page import="oauth.signpost.basic.DefaultOAuthConsumer"%>
<%@include file="/inner/Common.jsp"%>
<%
String strDebug = "";

//login check
CheckLogin checkLogin = new CheckLogin(request, response);
MyEditSettingC cResults = new MyEditSettingC();
cResults.getParam(request);
cResults.getResults(checkLogin);
%>
<!DOCTYPE html>
<html>
	<head>
		<%@ include file="/inner/THeaderCommon.jsp" %>
		<title><%=_TEX.T("MyEditSettingPassportV.Title")%></title>
		<style>
			.PoiPassLoading {
				width: 20px;
				height: 20px;
				display: inline-block;
				background: no-repeat url(/img/loading.gif);
				background-size: cover;
				position: relative;
				top: 4px;
				margin: 0 2px 0 4px;
			}
			.PoipikuPassportLogoFrame {display: block; float: left; width: 100%;}
			.PoipikuPassportLogoFrame .PoipikuPassportLogo {display: block; height: 45px;}
			.BenefitTable {
						width: 100%;
						text-align: center;
						border-collapse: collapse;
				}
				.BenefitTable td {height: 100px;}
				.BenefitTable td, table th {
						border: solid 1px #ddd;
						padding: 5px 8px;
						vertical-align: middle;
				}
				.BenefitTable .ListCell {background: #eee;}
				.BenefitTable td {height: 100px;}
				.BenefitTable .NormalCell {color: #aaaaaa;}
				.BenefitTable .BenefitCell {color: #464441;}
				.BenefitTable .BenefitDetail {
						font-size: 0.85em;
						color: #62605c;
				}
		</style>
	</head>

	<body>
		<div id="DispMsg"></div>

		<article class="Wrapper">
			<div class="SettingList" style="background: #fff;">
				<div class="SettingListItem">
					<div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Title")%></div>
					<%{Passport.Status passportStatus = cResults.m_cPassport.m_status;%>
					<div class="SettingBody">
						<%if(passportStatus == Passport.Status.NotMember) {%>
						<%//_TEX.T("MyEditSettingPassportV.Text")%>
						<div style="float: left; width: 100%; border-bottom: 1px solid #6d6965; padding: 0 0 5px 0; margin: 0 0 5px 0; font-size: 12px;">
						平素よりポイピクをご愛顧頂き誠にありがとうございます。
						サーバの過負荷状態が続きサービス継続に支障が出ていたため、一部機能の提供を中止し皆様にはご迷惑をおかけいたしました。申し訳ございません。
						検討した結果、この度「ポイピクパスポート(通称ポイパス)」というサブスクリプション形式で負荷が高くサーバ費用負担が大きい機能を提供させていただくことといたしました。
						また「可能であればイラストと一緒に広告を表示したくない」というポイピクチームの強い思いで、ポイパスにご加入頂くと広告を表示しないようにいたしました。
						iPhone版、Android版の各アプリでも加入後広告が表示されなくなり、パスポートの機能が有効となります。
						高負荷機能＋広告表示無し＋ちょっとした遊び心の機能で月額300円と、出来る限りの低価格で提供させていただきます。
						収益はポイピクサービスの維持・発展に使用させていただきます。
						ぜひポイパスへのご加入をご検討いただけますと幸いです。
						(2020年12月 株式会社pipa.jp代表 川合和寛)
						</div>
						<%}%>

						<%if(passportStatus == Passport.Status.NotMember) {%>
						<div class="SettingBodyCmd">
							<div class="RegistMessage"></div>
							現在ポイパスはWebブラウザ版からのみお申し込みいただけます。
						</div>
						<%}%>

						<div class="SettingBodyCmd" style="font-size: 1.2em">
							<%if(passportStatus == Passport.Status.NotMember) {%>
							ポイパスでプラスされる機能
							<%}else{%>
							ポイパスでプラスされている機能
							<%}%>
						</div>
						<div class="SettingBodyCmd">
							<table class="BenefitTable">
								<tbody>
								<tr class="ListCell">
									<th style="width: 20%"></th>
									<th class="NormalCell" style="width: 30%">ポイパスなし</th>
									<th class="BenefitCell" style="width: 30%">ポイパスあり</th>
								</tr>
								<tr>
									<td class="ListCell"><span style="color: red; font-size: 9px; font-weight: bold;">new!!</span><br />複数枚投稿時のTwitter同時投稿の画像</td>
									<td class="NormalCell">複数枚を1枚に合成して投稿(最初の4枚)</td>
									<td class="BenefitCell">同時投稿した全ての画像を1枚に合成して投稿<br />
									</td>
								</tr>
								<tr>
									<td class="ListCell">投稿時のキャプション文字数</td>
									<td class="NormalCell">200文字<br /></td>
									<td class="BenefitCell">500文字</td>
								</tr>
								<tr>
									<td class="ListCell">文章投稿時の文字数</td>
									<td class="NormalCell">1万文字<br /></td>
									<td class="BenefitCell">10万文字<br />
										<span class="BenefitDetail">
											(本機能はWeb版でβテスト中の機能です。アプリからの文章投稿機能は今暫くお待ち下さい)
										</span></td>
								</tr>
								<tr>
									<td class="ListCell">自分のページの背景設定</td>
									<td class="NormalCell">なし</td>
									<td class="BenefitCell">自由な画像ファイルを設定可能</td>
								</tr>
								<tr>
									<td class="ListCell">広告表示</td>
									<td class="NormalCell">あり</td>
									<td class="BenefitCell">なし<br />
										<span class="BenefitDetail">
											広告表示スクリプト自体が出力されなくなるので全体の表示速度も上がります
										</span>
									</td>
								</tr>
								<tr>
									<td class="ListCell">自分のページの広告表示</td>
									<td class="NormalCell">あり</td>
									<td class="BenefitCell">あり/なし設定可能<br />
										<span class="BenefitDetail">
											(デフォルトは表示なし)
										</span>
									</td>
								</tr>
								<tr>
									<td class="ListCell">ダウンロードの許可</td>
									<td class="NormalCell">不許可</td>
									<td class="BenefitCell">許可/不許可設定可能<br />
										<span class="BenefitDetail">
											(デフォルトは不許可)
										</span>
									</td>
								</tr>
								<tr>
									<td class="ListCell">ミュートキーワード</td>
									<td class="NormalCell">なし</td>
									<td class="BenefitCell">あり<br />
										<span class="BenefitDetail">
											避けたいコンテンツをキーワード指定して検索結果などから省くことができます。
										</span>
									</td>
								</tr>
								<tr>
									<td class="ListCell">定期ツイート<br />(前ツイート自動削除つき)</td>
									<td class="NormalCell">なし</td>
									<td class="BenefitCell">あり<br />
										<span class="BenefitDetail">
											最近の自分のコンテンツを１画像にまとめて自動ツイートできます。<br />
											一つ前のツイートは自動削除できるので、TLをスッキリ保てます！<br />
										</span></td>
								</tr>
								<tr>
									<td class="ListCell">送れる絵文字の数</td>
									<td class="NormalCell">1作品あたり10個/日</td>
									<td class="BenefitCell">1作品あたり100個/日<br />
								</tr>
								<tr>
									<td class="ListCell">もらった絵文字解析</td>
									<td class="NormalCell">過去一週間分</td>
									<td class="BenefitCell">過去30日分、全期間も対応<br />
								</tr>
								</tbody>
							</table>
						</div>
						<%if(passportStatus == Passport.Status.NotMember) {%>
						<div class="SettingBodyCmd">
							<div class="RegistMessage"></div>
							現在ポイパスはWebブラウザ版からのみお申し込みいただけます。
						</div>
						<%}%>
					</div>
					<%}%>
				</div>
			</div>
		</article><!--Wrapper-->
	</body>
</html>