<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@include file="/inner/Common.jsp" %>
<%
	CheckLogin checkLogin = new CheckLogin(request, response);
%>
<!DOCTYPE html>
<html lang="ja">
<head>
	<%@ include file="/inner/THeaderCommonPc.jsp" %>
	<title><%=_TEX.T("THeader.Title")%> - 利用規約</title>
	<style>
        .AnalogicoInfo {
            display: none;
        }

        .SettingList .SettingListItem {
            color: #fff;
        }

        .Language {
            margin-bottom: 18px;
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
<div id="DispMsg"></div>
<%@ include file="/inner/TMenuPc.jsp"%>

<article class="Wrapper">
	<div class="SettingList">
		<div class="SettingListItem">
			<div class="SettingListTitle" style="text-align: center; font-size: 18px;">「ポイピク」利用規約</div>
			<div class="SettingBody Language">
				<%
					for (UserLocale userLocale : SupportedLocales.list) {
						if (userLocale.id != 1) {
				%>
				<%=Common.getGoogleTransformLinkHtml("RulePcS.jsp", "_self", userLocale.locale.toLanguageTag(), userLocale.label)%>
				<%
						}
					}
					;
				%>
			</div>

			<div class="SettingBody">
				したの きやくが わからない かたは、かならず ほごしゃの かたと いっしょに かくにんして ください。<br/>
				You have to confirm the following Terms and Conditions with your guardian, if necessary.
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第1条(規約の適用)</div>
			<div class="SettingBody">
				pipa.jpは、「ポイピク」(以下、本サービスという)において利用規約(以下、本規約)を定め、これにより本サービスを提供します。<br/>
				2.本規約は、pipa.jpと利用者との間の一切の関係に適用します。<br/>
				3.本サービスと競合する可能性のあるサービス運営者並びにその関係者は本サービスを利用できません。<br/>
				4.利用者は、本サービスを利用することにより、本規約内容について承諾したものとみなします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第2条(用語の定義)</div>
			<div class="SettingBody">
				本規約では以下の用語の意味を定め、本規約内で使用される用語については定められた意味とします。<br/>
				(1)「画像等データ」：本サービスが提供する手段を用いて投稿できるイラストデータやテキストデータ、写真データなどの情報<br/>
				(2)「登録ユーザ」：利用者のうち、所定の手続きで登録を申込み、登録が完了した利用者<br/>
				(3)「未登録ユーザ」：利用者のうち、登録ユーザではない利用者<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第3条(規約の変更)</div>
			<div class="SettingBody">
				pipa.jpは、本規約を利用者の承諾を得ることなく変更することがあります。この場合には、本サービスの提供条件は変更後の利用規約によります。<br/>
				2.本規約の変更後に利用者が本サービスを利用することにより、変更後の利用規約に同意したものとみなします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第4条(本サービスの提供内容)</div>
			<div class="SettingBody">
				pipa.jpは、本サービスに係る基本機能を次の通り提供します。<br/>
				(1)画像等データをアップロードする機能<br/>
				(2)画像等データを表示する機能<br/>
				(3)上記に付帯する機能<br/>
				2.pipa.jpは、未登録ユーザに対して本サービスに係る基本機能の一部を提供し、登録ユーザに対して全ての基本機能を提供します。<br/>
				3.pipa.jpが提供する基本機能は、利用者毎に異なることがあり、利用者は予めこれを異議なく承諾するものとします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第5条(本サービスの提供内容の変更)</div>
			<div class="SettingBody">
				pipa.jpは、本サービスの提供内容に対して利用者の承諾なしに変更できるものとします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第6条(本サービスの提供の中断と中止)</div>
			<div class="SettingBody">
				以下の場合には、pipa.jpは予告なく本サービスの一部または全部の提供を中断もしくは中止することがあります。<br/>
				(1)システムまたは関連の設備、ネットワーク等の保守または工事、過負荷、システムメンテナンスなどやむを得ない場合<br/>
				(2)本サービスと連携する外部のシステムが利用不可能な場合<br/>
				(3)システムやサービスの仕様変更する場合<br/>
				(4)天災、戦争、その他の非常事態により本サービスの提供が困難な場合<br/>
				(5)都合により本サービスの継続が困難になった場合<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第7条(料金)</div>
			<div class="SettingBody">
				本サービスの基本機能の利用は登録の有無に関わらず無料とします。<br/>
				2.本サービスの利用に必要なPCや通信費用、インターネットプロバイダ料金等の一切の費用は利用者の負担となります。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第8条(登録の申し込み)</div>
			<div class="SettingBody">
				本サービスの登録の申し込みに際しては、利用者が本規約に同意する事を以って、登録の申し込みを行うものとします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第9条(登録申し込みの承諾)</div>
			<div class="SettingBody">
				pipa.jpは、登録の申込に対して受け付けた順序に承諾します。ただし、承諾後に審査を行い、以下に該当する場合は遡って承諾を取り消すことがあります。<br/>
				(1)pipa.jpが、本サービスを提供することが困難と判断した場合<br/>
				(2)申し込みをした者が、本サービスならびにpipa.jpが提供する他のサービスにおいて利用を停止されている、または利用の解除を受けたことがある場合<br/>
				(3)申込み内容に虚偽がある場合<br/>
				(4)申し込みをした者が、第17条(遵守事項)、第18条(禁止事項)に違反して本サービスを利用する恐れがあるとpipa.jpが判断した場合<br/>
				(5)利用者が暴力団員による不当な行為の防止等に関する法律(平成3年法律第77号)で規定される暴力団及び暴力団員である場合、及び暴力団員でなくなった時から５年間を経過しない者、もしくはこれらに準ずる者、または暴力団もしくは暴力団員と密接な関係を有する者(以下、暴力団員等という)、あるいは暴力団員等の支配を受けていることが自覚の有無と関係なく認められる者である場合<br/>
				(6)その他、pipa.jpが運営上不適当であると判断した場合<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第10条(承諾取り消しの通知)</div>
			<div class="SettingBody">
				pipa.jpは登録申し込みの承諾を取り消した利用者に対し、一切の通知や予告なく登録を削除します。その際理由の一切について説明しません。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第11条(登録期間)</div>
			<div class="SettingBody">
				登録ユーザの登録期間は無期限とします。ただし、第6条(本サービスの提供の中断と中止)、第13条(登録解除)、第21条(pipa.jpによる利用の停止と登録の解除)の場合はこの限りではありません。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第12条(登録申し込み内容の変更)</div>
			<div class="SettingBody">
				登録ユーザは登録内容に変更があったときは、速やかに所定の手段で内容を変更するものとします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第13条(登録解除)</div>
			<div class="SettingBody">
				登録ユーザによる本サービスの登録解除の申し込みに際しては、アカウントの削除を以って、解除の申し込を行うものとします。<br/>
				2.登録解除後、pipa.jpは予告なく直ちにサーバから当該利用者の一切のデータ等を削除します。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第14条(アカウント)</div>
			<div class="SettingBody">
				利用者は必要に応じてアカウントを複数作成することができるものとします。<br/>
				2.利用者は以下の場合、作成したアカウントを商用利用できるものとします。<br/>
				(1)一切の他人の権利を侵害しない自らの著作物を販売する場合<br/>
				(2)自らの著作物を用いた展示会の入場券を販売する場合<br/>
				3.団体、法人によるアカウント作成は、その代表者を利用者とすることで作成することができるものとします。この場合、その代表者による適切なアカウント管理の元に複数の利用者による単一のアカウントの共有ができるものとします。<br/>
				4.団体、法人によるアカウント作成は、その法人格の有無や種類に関わらず、代表者が本規約の適用となり、全ての責務を負うこととします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第15条(使用権及び著作権)</div>
			<div class="SettingBody">
				利用者が本サービスを利用して投稿した画像等データ及びそれに付随する情報の著作権(著作権法第27条及び第28条の権利を含む全ての著作権者の権利をいう)及びその他一切の権利は利用者に帰属し、利用者はpipa.jpに対しサムネイルの表示等、本サービスを運営するに当たり必要となる最小限の改変と使用を承諾するものとします。<br/>
				2.登録申し込みの承諾はpipa.jpが利用者へ本サービスの基本機能の使用を承諾するものであり、利用者に本サービスそのものもしくはその一部、及び著作権等の一切の権利を譲渡するものではありません。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第16条(利用者の責務)</div>
			<div class="SettingBody">
				利用者は、利用者ならびに利用者の関係者が本サービスを通じて自身及び第三者に損害を与えた場合についてその全ての責を負うものとし、自らの責任と負担において問題を解決するものとします。<br/>
				2.利用者が本サービスを利用して投稿した画像等データに関する品質、正確性、完全性、適合性、有効性、利用可能性、時刻一致性、安全性、取得方法、プライバシー等の非侵害、第三者の著作権知的財産権等の非侵害及び法令に対する非抵触の証明は利用者自らが行うものとし、これに起因する責任は、全て利用者自身が負うものとします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第17条(遵守事項)</div>
			<div class="SettingBody">
				利用者は以下の事項を遵守する必要があります。<br/>
				(1)利用者が権利を有しない画像等データの著作権等各種権利自体の取り扱いは、自己の判断に依らず権利保有者の規約を必ず確認した後にそれに準じること<br/>
				(2)ID、パスワード等のアカウント情報は第三者に知られることのないよう、自己の責任において適切に管理すること<br/>
				(3)ID、パスワード等のアカウント情報は他人から推測されにくい情報を使用すること<br/>
				(4)投稿した画像等データ対して、自己の責任において適切なフィルタを行うこと<br/>
				(5)第三者等によるコメント等の書き込み内容等についても、自己の責任において適切に管理すること<br/>
				(6)本サービスを利用し、維持管理するために必要な諸環境の整備は自己の責任と負担において適切に行うこと<br/>
				(7)不正アクセスからの防御やコンピュータウイルス の感染からの防御、情報漏洩の抑止等のために十分な対策を講じること<br/>
				(8)利用者およびpipa.jpによって規定された<a href="/GuideLinePcV.jsp">ガイドラン</a>に従うこと<br/>
				(9)その他、pipa.jpが必要と判断し、行った要請に無条件で従うこと<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第18条(禁止事項)</div>
			<div class="SettingBody">
				利用者の以下の事項を禁止します。<br/>
				(1)著作権、意匠権、プライバシー、肖像権、秘密事項その他の第三者の権利を侵害し、または侵害する恐れのある行為<br/>
				(2)利用者が権利を保有していない画像等データを、権利保有者の許諾なく転載する行為及びそのような行為を薦める行為<br/>
				(3)本サービスの提供を受ける権利や契約の一部もしくは全部の譲渡及び貸与<br/>
				(4)商用、非商用を問わず第三者の依頼による本サービスの利用<br/>
				(5)ID、パスワードの第三者への公開<br/>
				(6)他者のID、パスワードの盗用<br/>
				(7)本サービスのシステムや設備に不法に侵入、あるいは侵入を試みる行為<br/>
				(8)本サービスを円滑に提供することを妨げる行為<br/>
				(9)本サービスの信用を毀損する行為<br/>
				(10)他の利用者及び第三者への迷惑行為<br/>
				(11)他の利用者及び第三者、もしくは画像等データの信用を毀損する行為<br/>
				(12)他の利用者及び第三者、もしくは画像等データへの誹謗中傷行為<br/>
				(13)他の利用者及び第三者、もしくは画像等データへの迷惑行為<br/>
				(14)いじめ、差別及びハラスメント行為及びこれら行為を連想、想起させる行為とそれらを助長する行為<br/>
				(15)自らの著作物を含まない外部サイトへの誘導<br/>
				(16)詐称行為<br/>
				(17)犯罪行為及び犯罪を助長する行為<br/>
				(18)法令及び条例に反するわいせつ、児童ポルノ等の画像等データの投稿<br/>
				(19)法令及び条例に反する画像等データの直接的、及び間接的販売<br/>
				(20)暴力、自傷行為、薬物乱用を助長する行為<br/>
				(21)公序良俗またはその他の法令に反し、または反する恐れのある態様での利用<br/>
				(22)本サービスのシステムや関連の設備に対して過大な負荷を与えるような行為及びそのような行為を勧める行為<br/>
				(23)未成年に悪影響を及ぼす全ての行為<br/>
				(24)その他、pipa.jpが不適切であると判断した行為<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第19条(個人情報の取り扱い)</div>
			<div class="SettingBody">
				pipa.jpは、pipa.jpが定める「プライバシーポリシー」に従い、本サービスのために利用者の個人情報を適切に収集・利用・管理します。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第20条(守秘義務)</div>
			<div class="SettingBody">
				pipa.jpは、本サービスで知り得た通信内容に関して守秘の義務を負い、利用者の保護を最優先するものとします。<br/>
				2.以下の各号に定める場合に､pipa.jpは利用者の同意なく通信内容を第三者に開示することができるものとします｡なお､pipa.jpは､この開示により利用者に生じたいかなる損害についても､一切責任を負わないものとします｡<br/>
				(1)刑事訴訟法第218条(令状による差押え･捜索･検証)及び、その他法令の定めに基づく強制の処分が行なわれた場合<br/>
				(2)特定電気通信役務提供者の損害賠償責任の制限及び発信者情報の開示に関する法律第4条(発信者情報の開示請求等)に基づく開示請求の要件が社会通念上十分に満たされているとpipa.jpが判断した場合<br/>
				(3)裁判所や警察等の公的機関から､法令に基づく命令を受けた場合<br/>
				(4)心身または財産を保護するために必要があるとpipa.jpが判断した場合<br/>
				(5)本規約に違反する行為又はその恐れのある行為が行われていないことを確認する場合<br/>
				(6)本サービスの不具合の原因究明に必要な場合<br/>
				(7)本サービスの利用者をサポートするために必要な場合<br/>
				(8)その他本サービスを適切に運営するために必要が生じた場合<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第21条(pipa.jpによる利用の停止と登録の解除)</div>
			<div class="SettingBody">
				pipa.jpは、利用者が以下のいずれかに該当する場合は、何らの催促及び自己の債務の履行の提供をしないで、画像等データの一部または全部の変更及び削除、あるいは本サービスの利用停止、もしくは登録の解除を行うことができます。<br/>
				(1)登録申し込み内容に虚偽があったことが判明した場合<br/>
				(2)第17条(遵守事項)、第18条(禁止事項)に違反した場合<br/>
				(3)利用者が暴力団、暴力団員、暴力団員等、あるいは暴力団員等の支配を受けていることが自覚の有無と関係なく認められる者であることが判明した場合<br/>
				(4)各省庁や地方自治体や教育委員会等の公的機関もしくは弁護士等専門家から、画像等データに対して、何らかの指摘があった場合<br/>
				(5)画像等データに対して権利主張があった場合<br/>
				(6)画像等データが第三者の権利を侵害する恐れがあると断定できた場合<br/>
				(7)画像等データが公序良俗に反するとpipa.jpが判断した場合<br/>
				(8)その他、pipa.jpの業務上不適当であるとpipa.jpが判断した場合<br/>
				2.pipa.jpは、利用者から前項各号に該当する可能性のある利用者もしくは画像等データに関する報告があった場合、24時間以内を基準としてその判断および対応を行います。その際の判断過程、判断結果および対処内容の一切について説明しません。<br/>
				3.前項及び前々項において、判断及び対処までに要する間、当該利用者もしくは画像等データが表示されることがあります。ただし、表示を以って許容を示すものではありません。<br/>
				4.登録解除後、pipa.jpは予告なく直ちにサーバから当該利用者の一切のデータ等を削除します。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第22条(免責事項)</div>
			<div class="SettingBody">
				pipa.jpは、本サービスの利用および本規約に起因する損害について、その予測可能性に関わらず一切の責を負わないものとします。<br/>
				2.pipa.jpは、データの一部または全部が消失した場合について、その責を負わないものとします。<br/>
				3.pipa.jpは、本サービスが提供する情報の品質、正確性、完全性、適合性、有効性、利用可能性、時刻一致性、安全性、取得方法、知的財産権等の非侵害性及び法令による責任を何ら保証しないものとします。<br/>
				4.利用者、ならびに利用者の関係者が本サービスを通じて第三者に損害を与えた場合についてその責を負わないものとし、当該利用者は、自らの責任において問題を解決するものとします。<br/>
				5.pipa.jpは、利用者の利用環境について一切関与せず、また一切の責任を負いません。<br/>
				6.pipa.jpが何かしらの対処を行わないことを以って本規約に抵触していないことを保証するものではありません。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第23条(損害賠償)</div>
			<div class="SettingBody">
				利用者が本規約に反した行為、または不正もしくは違法な行為によってpipa.jpに損害を与えた場合、pipa.jpは利用者に対してこの損害及び弁護士費用を含む一切の費用の賠償を請求することができ、利用者は、当該請求に直ちに応じなければならないものとします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第24条(準拠法)</div>
			<div class="SettingBody">
				本サービスの利用、契約の成立、効力、解釈及び履行については、日本国法に準拠するものとします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第25条(紛争の解決)</div>
			<div class="SettingBody">
				本サービスの利用について利用者とpipa.jpの間で問題が生じたときは、利用者とpipa.jpで誠意を持って協議し解決するものとします。<br/>
				2.協議による解決を図る事ができない場合、横浜地方裁判所を第一審の専属管轄裁判所とします。<br/>
			</div>
		</div>

		<div class="SettingListItem">
			<div class="SettingListTitle">第26条(言語)</div>
			<div class="SettingBody">
				本規約は、日本語で作成し、他言語への機械翻訳ページへのリンクを提示しています。
				言語の間に矛盾抵触がある場合、日本語版が優先されます。
			</div>
		</div>

		<div class="SettingListItem Additional">
			<div class="SettingBody">
				(2022/5/31 20条(守秘義務)誤字修正)<br/>
				(2022/1/6 26条(言語)を追加・翻訳リンク追加)<br/>
				(2018/9/30) ガイドラインへのリンクを追加<br/>
				(2018/9/26 制定)
			</div>
		</div>
	</div>
</article><!--Wrapper-->

<%@ include file="/inner/TFooterBase.jsp" %>
</body>
</html>