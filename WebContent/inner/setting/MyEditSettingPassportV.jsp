<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
final PassportPayment payment = new PassportPayment(checkLogin);
final PassportSubscription subscription = new PassportSubscription(checkLogin);
final PoiTicket ticket = new PoiTicket(checkLogin);
%>
<%@ include file="../TCreditCard.jsp"%>
<script type="text/javascript">
	function BuyPassportAjax(passportInfo, nPassportAmount, agentInfo, cardInfo, elPassportNowPayment) {
		let amount = -1;
		if(nPassportAmount && nPassportAmount>0){amount = nPassportAmount;}

		$.ajax({
			"type": "post",
			"data": {
				"PID": passportInfo.passportId,
				"UID": passportInfo.userId,
				"AMT": amount,
				"AID": agentInfo == null ? '' :  agentInfo.agentId,
				"TKN": agentInfo == null ? '' : agentInfo.token,
				"EXP": cardInfo == null ? '' : cardInfo.expire,
				"SEC": cardInfo == null ? '' : cardInfo.securityCode,
			},
			"url": "/f/BuyPassportF.jsp",
			"dataType": "json",
		}).then( data => {
			cardInfo = null;
			if (data.result === 1) {
				if(nPassportAmount>0) {
					DispMsg("<%=_TEX.T("PassportDlg.Thanks")%>");
					if (elPassportNowPayment != null) {
						elPassportNowPayment.hide();
					}
				}
			} else {
				switch (data.error_code) {
					case -10:
						DispMsg("<%=_TEX.T("PassportDlg.Err.CardAuth")%>");
						break;
					case -20:
						alert("<%=_TEX.T("PassportDlg.Err.AuthCritical")%>");
						break;
					case -30:
						DispMsg("<%=_TEX.T("PassportDlg.Err.CardAuth")%>");
						break;
					case -99:
						DispMsg("<%=_TEX.T("PassportDlg.Err.AuthOther")%>");
						break;
				}
				if (elPassportNowPayment != null) {
					elPassportNowPayment.hide();
				}
			}
			setTimeout(()=>location.reload(), 5000);
			},
			error => {
				cardInfo = null;
				DispMsg("<%=_TEX.T("PassportDlg.Err.PoipikuSrv")%>");
				if (elPassportNowPayment != null) {
					elPassportNowPayment.hide();
				}
				setTimeout(()=>location.reload(), 5000);
			}
		);
	}

	// epsilonPayment - epsilonTrade間で受け渡しする変数。
	let g_epsilonInfo = {
		"passportInfo": null,
		"passportAmount": null,
		"cardInfo": null,
		"elPassportNowPayment": null,
	};

	function epsilonPayment(_passportInfo, _nPassportAmount, _cardInfo, _elPassportNowPayment){
		if(_cardInfo == null){ // カード登録済
			BuyPassportAjax(_passportInfo, _nPassportAmount, createAgentInfo(AGENT.EPSILON, null, null),
				null, _elPassportNowPayment);
		} else { // 初回
			g_epsilonInfo.passportInfo = _passportInfo;
			g_epsilonInfo.nPassportAmount = _nPassportAmount;
			g_epsilonInfo.cardInfo = _cardInfo;
			g_epsilonInfo.elPassportNowPayment = _elPassportNowPayment;

			const contructCode = "68968190";
			//let cardObj = {cardno: "411111111111111", expire: "202202", securitycode: "123", holdername: "POI PASS"};
			let cardObj = {
				"cardno": String(_cardInfo.number),
				"expire": String('20' + _cardInfo.expire.split('/')[1] +  _cardInfo.expire.split('/')[0]),
				"securitycode": String(_cardInfo.securityCode),
				// "holdername": "DUMMY",
			};

			EpsilonToken.init(contructCode);

			// epsilonTradeを無名関数で定義するとコールバックしてくれない。
			// global領域に関数を定義し、関数名を引数指定しないとダメ。
			EpsilonToken.getToken(cardObj , epsilonTrade);
		}
	}

	function epsilonTrade(response){
		// もう使うことはないので、カード番号を初期化する。
		if(g_epsilonInfo.cardInfo.number){
			g_epsilonInfo.cardInfo.number = null;
		}

		if( response.resultCode !== '000' ){
			window.alert("ポイパス加入処理中にエラーが発生しました");
			console.log(response.resultCode);
			g_epsilonInfo.elPassportNowPayment.hide();
		}else{
			const agentInfo = createAgentInfo(
				AGENT.EPSILON, response.tokenObject.token,
				response.tokenObject.toBeExpiredAt);
			BuyPassportAjax(g_epsilonInfo.passportInfo, g_epsilonInfo.nPassportAmount,
				agentInfo, g_epsilonInfo.cardInfo, g_epsilonInfo.elPassportNowPayment);
		}
	}

	function BuyPassport() {
		$(".BuyPassportButton").hide();
		const passportInfo = {
			"passportId": 1,
			"userId": <%=checkLogin.m_nUserId%>,
		};
		let cardInfo = {
			"number": null,
			"expire": null,
			"securityCode": null,
			"holderName": null,
		};
		let elPassportNowPayment = $('#PassportNowPayment');
		if(elPassportNowPayment.css('display') !== 'none'){
			alert("決済処理中です");
			return;
		}
		elPassportNowPayment.show();
		$('#PassportNowPayment2').show();
		$.ajax({
			"type": "get",
			"url": "/f/CheckCreditCardF.jsp",
			"dataType": "json",
		}).then(function (data) {
			const result = Number(data.result);
			const nPassportAmount = 300;
			if (typeof (result) === "undefined" || result == null || result === -1) {
				return false;
			} else if (result === 1) {
				console.log("epsilonPayment");
				if (confirm("登録済みのクレジットカードで毎月300円(税込)の課金を決済します。よろしいですか？")) {
					epsilonPayment(passportInfo, nPassportAmount, null, elPassportNowPayment);
				} else {
					elPassportNowPayment.hide();
					$('#PassportNowPayment2').hide();
					$(".BuyPassportButton").show();
				}
			} else if (result === 0) {
				const title = "ポイパス加入";
				const description = "クレジットカード情報を入力してください。入力されたカードから、<b>毎月300円</b>(税込)が課金されます。";
				<%// クレジットカード情報入力ダイアログを表示、%>
				<%// 入力内容を代理店に送信し、Tokenを取得する。%>
				Swal.fire({
					html: getRegistCreditCardDlgHtml(title, description),
					focusConfirm: false,
					showCloseButton: true,
					showCancelButton: true,
					preConfirm: verifyCardDlgInput,
				}).then(formValues => {
					<%// キャンセルボタンがクリックされた%>
					if (formValues.dismiss) {
						elPassportNowPayment.hide();
						$('#PassportNowPayment2').hide();
						$(".BuyPassportButton").show();
						return false;
					}

					cardInfo.number = String(formValues.value.cardNum);
					cardInfo.expire = String(formValues.value.cardExp);
					cardInfo.securityCode = String(formValues.value.cardSec);

					<%// 念のため不要になった変数を初期化%>
					formValues.value.cardNum = '';
					formValues.value.cardExp = '';
					formValues.value.cardSec = '';

					epsilonPayment(passportInfo, nPassportAmount, cardInfo, elPassportNowPayment);
				});

			} else {
				DispMsg("<%=_TEX.T("CardInfoDlg.Err.PoipikuSrv")%>");
			}
		});
	}

	function CancelPassport() {
		Swal.fire({
			title: 'ポイパス解約',
			text: 'ポイパスを解約してよろしいですか？現在プラスされている機能は解約月の翌月から使えなくなります。',
			focusConfirm: false,
			showCloseButton: true,
			showCancelButton: true,
			type: 'info',
		}).then(evt => {
			// キャンセルボタンがクリックされた
			if (evt.dismiss) {
				return false;
			}
			$("#CancelPassportButton").hide();
			$("#PassportNowCancelling").show();
			$.ajax({
				"type": "post",
				"data": {
					"PID": <%=checkLogin.m_nPassportId%>,
					"UID": <%=checkLogin.m_nUserId%>,
				},
				"url": "/f/CancelPassportF.jsp",
				"dataType": "json",
			}).then( data => {
					$("#PassportNowCancelling").hide();
					if (data.result === 1) {
						DispMsg("解約しました。これまでポイパスにご加入いただき、ありがとうございました！");
					} else {
						switch (data.error_code) {
							case -10:
								DispMsg("<%=_TEX.T("PassportDlg.Err.CardAuth")%>");
								break;
							case -20:
								alert("<%=_TEX.T("PassportDlg.Err.AuthCritical")%>");
								break;
							case -30:
								DispMsg("<%=_TEX.T("PassportDlg.Err.CardAuth")%>");
								break;
							case -99:
								DispMsg("<%=_TEX.T("PassportDlg.Err.AuthOther")%>");
								break;
						}
					}
					setTimeout(()=>location.reload(), 5000);
				},
				error => {
					DispMsg("<%=_TEX.T("PassportDlg.Err.PoipikuSrv")%>");
					setTimeout(()=>location.reload(), 5000);
				}
			);
		});
	}
</script>

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
		.BenefitTable .NormalCell {}
		.BenefitTable .BenefitCell {font-weight: bold;}
		.BenefitTable .BenefitDetail {
				font-size: 0.85em;
				color: #62605c;
		}
</style>

<div class="SettingList">
	<div class="SettingListItem">
		<div class="SettingListTitle"><%=_TEX.T("MyEditSettingPassportV.Title")%></div>
		<%{
			Passport.Status passportStatus = cResults.m_cPassport.status;
			boolean isNotMember = passportStatus == Passport.Status.NotYet || passportStatus == Passport.Status.InActive;
		%>
		<div class="SettingBody">
			<%if(passportStatus == Passport.Status.Cancelling){%>
			ポイパスの定期購入の解除を承りました。今まで継続いただき誠にありがとうございました。
			なお、ポイパスでプラスされている機能は今月末までお使いいただけます。
			また、システムの都合上、今月中はカード情報の削除ができません。ご了承くださいませ。
			<%}else if(isNotMember) {%>
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
			ポイピクパスポート（ポイパス）に加入すると、ポイピクをより楽しく便利にお使いいただけます！
			<%}else{%>
			現在、ポイパス加入中です！
			<%}%>

			<%if(isNotMember) {%>
			<div class="SettingBodyCmd">
				<div class="RegistMessage"></div>
				<a class="BtnBase SettingBodyCmdRegist BuyPassportButton" href="javascript:void(0)" onclick="BuyPassport(this)">
					ポイパスを定期購入する
				</a>
			</div>
			<div id="PassportNowPayment" style="display:none">
				<span class="PoiPassLoading"></span><span>加入処理中</span>
			</div>
			<%}%>
		</div>
	</div>

	<div class="SettingListItem">
		<div class="SettingListTitle">チケット: <%=ticket.exists?ticket.amount:0%>枚</div>
		チケットは他の方からの匿名の差し入れでストックされ、1枚で1ヶ月分、ポイパスがONになります。（初回は月末まで）
		<ul>
			<li>毎月1日に自動でチケットが使用されます。(表示は6時頃に更新)</li>
			<li>ポイパス定期購入済みの場合、チケット使用が優先され、その間は課金がストップします。</li>
		</ul>
	</div>

	<%if(!isNotMember){%>
	<div class="SettingListItem">
		<div class="SettingListTitle">今月分の支払い</div>
		<%if(payment.exists){%>
			<%if(payment.by == PassportPayment.By.Ticket){%>
			ストックされていたチケットが使用されました。
				<%if(subscription.getStatus() == PassportSubscription.Status.UnderContraction){%>
				クレジットカードへ課金はありません。
				<%}%>
			<%}else if(payment.by == PassportPayment.By.CreditCard){%>
			25日に指定されているクレジットカードに課金されます。
			<%}else{%>
			処理中です。(毎月1日6時頃更新)
			<%}%>
		<%}else{%>
		処理中です。(毎月1日6時頃更新)
		<%}%>
	</div>
	<%}%>

	<div class="SettingListItem">
		<div class="SettingListTitle">ポイパスでプラスされる機能</div>
			<div class="SettingBody">
				<div class="SettingBodyCmd">
					<table class="BenefitTable">
						<tbody>
						<tr class="ListCell">
							<th style="width: 20%"></th>
							<th class="NormalCell" style="width: 30%">ポイパスなし</th>
							<th class="BenefitCell" style="width: 30%">ポイパスあり</th>
						</tr>
						<tr>
							<td class="ListCell"><span style="color: red; font-size: 9px; font-weight: bold;">new!!</span><br />同時投稿枚数</td>
							<td class="NormalCell">200枚、合計50MByteまで</td>
							<td class="BenefitCell">400枚、合計100MByteまで<br />
							</td>
						</tr>
						<tr>
							<td class="ListCell">複数枚投稿時のTwitter同時投稿の画像</td>
							<td class="NormalCell">複数枚を1枚に集約して投稿(最初の4枚)</td>
							<td class="BenefitCell">同時投稿した全ての画像を1枚に集約して投稿<br />
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

				<%if(isNotMember) {%>
				<div class="SettingBodyCmd">
					<div class="RegistMessage"></div>
					<a class="BtnBase SettingBodyCmdRegist BuyPassportButton" href="javascript:void(0)" onclick="BuyPassport(this)">
						ポイパスを定期購入する
					</a>
				</div>
				<div class="SettingBodyCmd" style="border: solid 1px #999999; border-radius: 6px;">
					<ul style="list-style-type: circle;">
						<li>加入は一ヶ月単位です。（初回は加入日から月末まで、以降毎月1日に確定）</li>
						<li>課金日は初回は加入日、以降毎月25日です（代行業者の都合で変更する場合あり）</li>
						<li>解約に制限はありません。いつでもできます。</li>
						<li>ポイパス加入で追加された機能は、解約した月の末日までお使いいただけます。</li>
					</ul>
				</div>
				<div id="PassportNowPayment2" style="display:none">
					<span class="PoiPassLoading"></span><span>加入処理中</span>
				</div>
				<%}%>
				<%if(subscription.getStatus() == PassportSubscription.Status.UnderContraction) {%>
				<div class="SettingBodyCmd">
					<a id="CancelPassportButton" class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="CancelPassport()">
						ポイパス定期購入を解約する
					</a>
					<div id="PassportNowCancelling" style="display:none">
						<span class="PoiPassLoading"></span><span>解約処理中</span>
					</div>
				</div>
				<%}%>
			</div>
		<%}//Passport.Status passportStatus = cResults.m_cPassport.m_status;%>
	</div>
</div>
