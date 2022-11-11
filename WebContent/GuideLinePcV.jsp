<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp" %>
	<title><%=Common.GetPageTitle2(_TEX, _TEX.T("Footer.GuideLine"))%></title>
	<style>
        table {
            width: 100%;
            border-collapse: collapse;
        }

        table td, table th {
            border: solid 1px #262626;
            vertical-align: middle;
            text-align: left;
        }

        table th {
            text-align: center;
        }
        .AnalogicoInfo {
            display: none;
        }

        .SettingList .SettingListItem {
            color: #000;
        }

        .Language {
			padding: 5px 10px;
			border: solid 2px #eefaff;
			border-radius: 5px;
		}

        .Language > a {
			text-decoration: underline;
			margin-right: 10px;
		}
	</style>
</head>

<body>
<%@ include file="/inner/TMenuPc.jsp"%>

<article class="Wrapper">
	<div class="SettingList">
		<div class="SettingListItem">
			<div class="SettingListTitle" style="text-align: center; font-size: 18px;">「unrealizm」ガイドライン</div>
			<div class="SettingBody Language">
				<%for(UserLocale userLocale: SupportedLocales.list){
					if (userLocale.id != 1) {
				%>
				<%=Common.getGoogleTransformLinkHtml("GuideLinePcV.jsp", "_self", userLocale.locale.toLanguageTag(), userLocale.label)%>
				<%}};%>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">1.序文</div>
			<div class="SettingBody">
				これは「unrealizm」を利用する利用者および運営するEmotionFlowが遵守すべきガイドラインです。<br/>
				法規法令、社会通念、利用実態に即し、EmotionFlowは利用者と共に、時代の変化に応じた形でこのガイドラインをより適切な形に維持します。<br/>
				法律の解釈は習慣や判例で変化するものであり、ガイドラインの遵守が違法性の否定にならないことに留意し、利用者自らが自身の正当性を証明をすることを怠らないようにして下さい。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">2.原則</div>
			<div class="SettingBody">
				投稿、閲覧、リアクション、タグ等全ての利用においては以下を原則とし、その上で時代の変化に応じた独自の倫理基準を運用するものとします。<br/>
				<ol>
					<li>日本国憲法および各種日本国法規法令を遵守する</li>
					<li><a href="/RulePcS.jsp">利用規約</a>を遵守する</li>
					<li>あらゆる国や地域の文化、風習、信仰を尊重する</li>
					<li>犯罪行為を肯定しない</li>
					<li>自殺、自傷、暴力、薬物の使用等を肯定しない</li>
					<li>反社会的勢力を肯定しない</li>
					<li>心体が不自由な方や社会的弱者を考慮する</li>
					<li>生命、死者を尊厳する</li>
					<li>権利や義務は自らに果たすものとし、他の利用者に強要しない</li>
				</ol>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">3.基本方針</div>
			<div class="SettingBody">
				未成年への影響や他の利用者の心情に対し常に配慮し、公開する作品の内容を十分吟味し、表示方法やタグを適切に設定するものとします。
				投稿できるコンテンツは12歳未満（小学生以下）が鑑賞できる内容に限ります。
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">4.投稿できる作品の形態</div>
			<div class="SettingBody">
				投稿できる作品の形態は以下ものとします。<br/>
				<ul>
					<li>AIにより生成されたコンテンツ、またはAIによる生成物を用いたコンテンツ</li>
				</ul>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">5.倫理基準</div>
			<div class="SettingBody">
				公開方法(パスワード・フォロワー限定など)はあらゆる目的で利用可能ですが、これら機能を利用し直接閲覧できない状態とする基準は以下の通りとします。<br/>
				<br/>

				<table>
					<tr>
						<th style="width: 35%;">種別</th>
						<th style="text-align: center;">基準</th>
					</tr>
					<tr>
						<td>
							投稿できないもの
						</td>
						<td>
							<ul>
								<li>原則に反しているもの</li>
								<li>白紙、単色</li>
								<li>利用規約に反するもの</li>
								<li>他者の作品</li>
								<li>他者のトレース</li>
								<li>12歳未満（小学生以下）による鑑賞に適さないもの。日本国内においてはR15+, R18+相当</li>
							</ul>
						</td>
					</tr>
				</table>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">6.その他推奨事項</div>
			<div class="SettingBody">
				閲覧される国や地域を考慮して、制作時やタグの設定時に以下の観点に対し配慮することを推奨します。<br/>
				<ul>
					<li>思想</li>
					<li>信条</li>
					<li>宗教</li>
					<li>人種</li>
					<li>肌や髪の毛の色などの身体的特徴</li>
					<li>戦争や紛争</li>
					<li>人命に係る事件・事故</li>
					<li>身体の適正な形状表現</li>
					<li>年齢</li>
					<li>性別</li>
					<li>未成年の肌の露出</li>
					<li>未成年の水着姿や下着姿</li>
					<li>親類ではない大人と子供の接触</li>
					<li>同性愛/性転換</li>
				</ul>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">7.言語</div>
			<div class="SettingBody">
				本ガイドラインは、日本語で作成し、他言語への機械翻訳ページへのリンクを提示しています。
				言語の間に矛盾抵触がある場合、日本語版が優先されます。
			</div>
		</div>

		<div class="SettingListItem Additional">
			<div class="SettingBody">
				(2022/10/26 制定)
			</div>
		</div>
	</div>
</article><!--Wrapper-->

<%@ include file="/inner/TFooterBase.jsp" %>
</body>
</html>