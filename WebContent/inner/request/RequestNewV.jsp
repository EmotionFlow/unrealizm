<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/inner/Common.jsp" %>
<%
final CheckLogin checkLogin = new CheckLogin(request, response);

final RequestNewC results = new RequestNewC();
results.getParam(request);

if (!results.getResults(checkLogin)) {
	response.sendRedirect("/NotFoundV.jsp");
	return;
}
%>
<!DOCTYPE html>
<html lang="ja">
<head>
	<%@ include file="/inner/THeaderCommon.jsp"%>
	<%@ include file="/inner/TCreditCard.jsp"%>
	<%@ include file="../TRequestIntroduction.jsp"%>
	<title><%=_TEX.T("THeader.Title")%> - Request </title>

	<%if (!results.user.m_bRequestEnabled && checkLogin.m_nUserId != results.creatorUserId){%>
	<script>
		function requestToStartRequesting() {
			$.ajax({
				"type": "post",
				"data": {"CLIENT": <%=checkLogin.m_nUserId%>, "CREATOR": <%=results.creatorUserId%>},
				"url": "/f/RequestToStartRequestingF.jsp",
				"dataType": "json",
			}).then(
				data => {
					if (data.result === <%=Common.API_OK%>) {
						if (data.result_detail === <%=RequestToStartRequestingC.ResultDetail.Done.getCode()%>) {
							DispMsg("お願いを通知しました！");
						} else if (data.result_detail === <%=RequestToStartRequestingC.ResultDetail.AlreadyRequested.getCode()%>) {
							DispMsg("通知済みです");
						} else {
							DispMsg("通信中にエラーが発生しました");
						}
					}
				},
				error => {
					DispMsg("通信中にエラーが発生しました");
				}
			);
		}
	</script>
	<%} // if (!results.user.m_bRequestEnabled && checkLogin.m_nUserId != results.creatorUserId) %>


	<%if(results.user.m_bRequestEnabled){%>
	<script>
		function _validate() {
			const isPaidRequest = $("#OptionPaidRequest").prop("checked");

			if ($("#EditRequestText").val().length <= 10) {
				DispMsg("依頼本文が短すぎます");
				return false;
			}

			if (isPaidRequest) {
				const amount = parseInt($("#EditAmount").val(), 10);
				if (!amount) {
					DispMsg("金額を入力してください");
					return false;
				}
				if (amount < <%=results.requestCreator.amountMinimum%> ||
					amount > <%=RequestCreator.AMOUNT_LEFT_TO_ME_MAX%>){
					DispMsg("依頼金額が範囲外です");
					return false;
				}
			}
			return true;
		}

		function SendRequestAjax(requestInfo, agentInfo, cardInfo) {
			let postInfo = requestInfo;

			if (agentInfo) {
				postInfo["AID"] = agentInfo.agentId;
				if (agentInfo.token) {
					postInfo["TKN"] = agentInfo.token;
				}
			}

			if (cardInfo) {
				postInfo["EXP"] = cardInfo.expire;
			}

			$.ajax({
				"type": "post",
				"data": requestInfo,
				"url": "/f/SendRequestF.jsp",
				"dataType": "json",
			}).then( data => {
					cardInfo = null;
					HideMsgStatic();
					if (data.result === <%=Common.API_OK%>) {
						if (requestInfo.PAID_REQUEST>0) {
							DispMsg("依頼を送信しました！クリエイターがこの依頼を承認すると、指定した金額が決済されます。", 5000);
						} else {
							DispMsg("依頼を送りました！", 5000);
						}
						window.setTimeout(() => {
							<%if(g_isApp){%>
							location.href = "/IllustListAppV.jsp?ID=" + parseInt(requestInfo.CREATOR, 10);
							<%}else{%>
							location.href = "/" + parseInt(requestInfo.CREATOR, 10);
							<%}%>
						}, 5000);
					} else {
						switch (data.error_code) {
							case <%=Controller.ErrorKind.CardAuth.getCode()%>:
								DispMsg("クレジットカードの認証に失敗しました");
								break;
							case <%=Controller.ErrorKind.NeedInquiry.getCode()%>:
								alert("<%=_TEX.T("PassportDlg.Err.AuthCritical")%>");
								break;
							case <%=Controller.ErrorKind.DoRetry.getCode()%>:
								DispMsg("システムエラーが発生しました");
								break;
							case <%=Controller.ErrorKind.Unknown.getCode()%>:
								DispMsg("不明なエラーが発生しました");
								break;
							default:
								DispMsg("その他エラーが発生しました");
								break;
						}
					}
					// setTimeout(()=>location.reload(), 5000);
				},
				error => {
					cardInfo = null;
					DispMsg("<%=_TEX.T("PassportDlg.Err.UnrealizmSrv")%>");
				}
			);
		}

		let g_epsilonInfo = {
			"requestInfo": null,
			"cardInfo": null,
		};

		function epsilonPayment(_requestInfo, _cardInfo){
			$('#SendRequestBtn').addClass('Disabled').html('依頼送信中');
			DispMsgStatic('依頼送信中');

			if(_cardInfo == null){ // カード登録済
				SendRequestAjax(_requestInfo, createAgentInfo(AGENT.EPSILON, null, null), null);
			} else { // 初回
				g_epsilonInfo.requestInfo = _requestInfo;
				g_epsilonInfo.cardInfo = _cardInfo;

				const contructCode = "68968190";
				let cardObj = {
					"cardno": String(_cardInfo.number),
					"expire": String('20' + _cardInfo.expire.split('/')[1] +  _cardInfo.expire.split('/')[0]),
					"securitycode": String(_cardInfo.securityCode),
					// "holdername": "DUMMY",
				};

				EpsilonToken.init(contructCode);

				EpsilonToken.getToken(cardObj , epsilonTrade);
			}
		}

		function epsilonTrade(response){
			if(g_epsilonInfo.cardInfo.number){
				g_epsilonInfo.cardInfo.number = null;
			}

			if( response.resultCode !== '000' ){
				window.alert("依頼送信処理中にエラーが発生しました");
				console.log(response.resultCode);
				g_epsilonInfo.elPassportNowPayment.hide();
			}else{
				const agentInfo = createAgentInfo(
					AGENT.EPSILON, response.tokenObject.token,
					response.tokenObject.toBeExpiredAt);
				SendRequestAjax(g_epsilonInfo.requestInfo, agentInfo, g_epsilonInfo.cardInfo);
			}
		}
		function sendRequest() {
			if ($('#SendRequestBtn').hasClass('Disabled') || !_validate()) {
				return false;
			}
			let cardInfo = {
				"number": null,
				"expire": null,
				"securityCode": null,
				"holderName": null,
			};

			const paymentMethod = "CREDITCARD";
			const isPaidRequest = $("#OptionPaidRequest").prop("checked");
			const amount = isPaidRequest ? parseInt($("#EditAmount").val(), 10) : 0;
			const commission = isPaidRequest ? _calcCommission(amount, paymentMethod) : 0;
			const requestInfo = {
				"CLIENT": <%=checkLogin.m_nUserId%>,
				"CREATOR": <%=results.creatorUserId%>,
				"MEDIA": $("#OptionMedia").val(),
				"TEXT": $("#EditRequestText").val(),
				"CATEGORY": $("#OptionRequestCategory").prop("checked") ? 1 : 0,
				"ANONYMOUS": $("#OptionAnonymousRequest").prop("checked") ? 1 : 0,
				"LICENSE": $("#OptionLicense").val(),
				"PAID_REQUEST": isPaidRequest ? 1 : 0,
				"AMOUNT": amount,
				"COMMISSION": commission,
				"PAYMENT_METHOD": 1,
			}
			if (requestInfo.CLIENT === requestInfo.CREATOR) {
				alert('自分宛には依頼できません');
				return false;
			}

			if (requestInfo.PAID_REQUEST === 0) {
				SendRequestAjax(requestInfo, null, null);
				return false;
			}

			$.ajax({
				"type": "get",
				"url": "/f/CheckCreditCardF.jsp",
				"dataType": "json",
			}).then(function (data) {
				const result = Number(data.result);
				if (typeof (result) === "undefined" || result == null || result === -1) {
					return false;
				} else if (result === 1) {
					console.log("epsilonPayment");
					if (confirm("クリエイターがこの依頼を承認すると、登録済みのクレジットカードに"
						+ (requestInfo.AMOUNT + requestInfo.COMMISSION).toLocaleString() + "円が課金されます。" +
						"よろしいですか？")) {
						epsilonPayment(requestInfo, null);
					}
				} else if (result === 0) {
					const title = "依頼送信";
					const description = "クレジットカード情報を入力してください。" +
						"クリエイターがこの依頼を承認すると、入力されたカードに対し、" +
						"<b>" + (requestInfo.AMOUNT + requestInfo.COMMISSION) + "円</b>(税込)が課金されます。";
					<%// クレジットカード情報入力ダイアログを表示、%>
					<%// 入力内容を代理店に送信し、Tokenを取得する。%>
					Swal.fire({
						html: getRegistCreditCardDlgHtml(title, description),
						footer: '<%=_TEX.T("CardInfoDlg.Footer")%>',
						focusConfirm: false,
						showCloseButton: true,
						showCancelButton: true,
						preConfirm: verifyCardDlgInput,
					}).then(formValues => {
						<%// キャンセルボタンがクリックされた%>
						if (formValues.dismiss) {
							HideMsgStatic(0);
							$('#SendRequestBtn').removeClass('Disabled').html('依頼を送信する');
							return false;
						}

						cardInfo.number = String(formValues.value.cardNum);
						cardInfo.expire = String(formValues.value.cardExp);
						cardInfo.securityCode = String(formValues.value.cardSec);

						<%// 念のため不要になった変数を初期化%>
						formValues.value.cardNum = '';
						formValues.value.cardExp = '';
						formValues.value.cardSec = '';

						epsilonPayment(requestInfo, cardInfo);
					});
				}
			});

		}

		function dispRequestTextCharNum() {
			const nCharNum = 1000 - $("#EditRequestText").val().length;
			$("#RequestTextCharNum").html(nCharNum);
		}

		const COMMISSION_RATE = {
			"SYSTEM": <%=Request.SYSTEM_COMMISSION_RATE_PER_MIL%>,
			"AGENCY": {
				"CREDITCARD": <%=Request.AGENCY_COMMISSION_RATE_CREDITCARD_PER_MIL%>,
			},
		}

		function _calcCommission(amount, paymentMethod) {
			return Math.floor(parseInt(amount, 10) * (COMMISSION_RATE.SYSTEM + COMMISSION_RATE.AGENCY[paymentMethod]) / 1000);
		}

		function _calcAmountTotal(amount, paymentMethod) {
			return parseInt(amount, 10) + _calcCommission(amount, paymentMethod);
		}

		function dispCommission(){
			const paymentMethod = "CREDITCARD";
			const amount = parseInt($("#EditAmount").val());
			const commissionTotal = _calcCommission(amount, paymentMethod);
			$("#Commission").text(commissionTotal.toLocaleString());
			$("#AmountTotal").text((amount + commissionTotal).toLocaleString());
			$("#CommissionRateSystem").text(((COMMISSION_RATE.SYSTEM) / 10).toFixed(1));
			$("#CommissionRateAgency").text(((COMMISSION_RATE.AGENCY.CREDITCARD) / 10).toFixed(1));
		}

		function dispCommissionDetailDlg(){
			Swal.fire({
				html: `
				<div style="text-align: left; font-size: 0.9em">
					<p style="text-align: center; font-weight: 400;">依頼金額で指定した額が、そのままクリエイターの報酬になります。</p>
					<p>依頼手数料：依頼の仕組みを支えるための手数料です。</p>
					<p>トランザクション手数料：トランザクションを実行するための手数料です。</p>
				</div>
				`,
				showCloseButton: true,
				showConfirmButton: false,
			});
		}

		$(() => {
			$("#OptionLicense").change(()=>{
				const val = $("#OptionLicense").val();
				$(".RequestLicenseDetail").hide();
				$("#RequestLicenseDetail"+val).show();
			});
			dispRequestTextCharNum();
			dispCommission();
		});

	</script>
	<%} // if(results.user.m_bRequestEnabled)%>

	<style>
		<%if(!results.user.m_strHeaderFileName.isEmpty()){%>
				.UserInfo {background-image: url('<%=Common.GetUrl(results.user.m_strHeaderFileName)%>');}
		<%}%>

		<%if(results.user.m_nPassportId>=Common.PASSPORT_ON && !results.user.m_strBgFileName.isEmpty()) {%>
				body {
						background-image: url('<%=Common.GetUrl(results.user.m_strBgFileName)%>');
						background-repeat: repeat;
						background-position: 50% top;
						background-attachment: fixed;
				}
		.UploadFile {
						background-color: rgba(0,0,0,0.4);
		}
		<%}%>

		.RequestTitle {
						text-align: center;
						font-weight: bold;
						width: 100%;
						margin-top: 10px;
						margin-bottom: 10px;
						font-size: 16px;
		}
		.RequestRule {
						background-color: #f6fafd;
						color: #000;
						border-radius: 10px;
						margin: 4px;
						padding: 1px;
			font-size: 13px;
		}
		#EditAmount {
						text-align: right;
						width: 130px;
						padding-right: 2px;
		}
		.RequestAmountUnit {
						position: relative;
						top: 6px;
						margin-right: 3px;
		}
		.RequestLicenseDetail {
			padding: 0 5px;
		}
	</style>

</head>
<body>

<%@ include file="/inner/TMenuPc.jsp"%>

<article class="Wrapper">
	<div class="UserInfo Float">
		<span id="UserInfoCmdBlock"
				class="BtnBase UserInfoCmdBlock Selected"
				style="text-shadow: none;"
				onclick="dispRequestIntroduction()">
			<i class="fas fa-info-circle" style="font-size: 15px; margin-right: 4px;"></i><span id="UserInfoCmdBlockLabel" style="top:-1px">エアスケブとは</span>
		</span>

		<div class="UserInfoBg"></div>
		<section class="UserInfoUser">
			<a class="UserInfoUserThumb" style="background-image: url('<%=Common.GetUrl(results.user.m_strFileName)%>')" href="/<%=results.user.m_nUserId%>/"></a>
			<h2 class="UserInfoUserName"><a href="/<%=results.user.m_nUserId%>/"><%=results.user.m_strNickName%></a></h2>
			<%if(results.requestCreator.profile.isEmpty()){%>
			<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(results.user.m_strProfile), results.user.m_nUserId, CCnv.MODE_PC)%></h3>
			<%}else{%>
			<h3 class="UserInfoProfile"><%=Common.AutoLink(Util.toStringHtml(results.requestCreator.profile), results.user.m_nUserId, CCnv.MODE_PC)%></h3>
			<%}%>
		</section>
	</div>

	<div class="UploadFile" style="padding-bottom: 100px;">
		<div class="RequestTitle">
			<%if(results.isBlocking || results.isBlocked){%>
			<%=results.isBlocking ? "ブロック中です。" : "ブロックされています。"%>
			<%}else{%>
				<%if(results.user.m_bRequestEnabled){%>

				<%if(results.isReachedLimit){%>
				<div style="color: #0008db; font-size: 12px; margin: 20px auto;">
					送信できる依頼数の制限に達しているため、<br>
					ただいまエアスケブの依頼を送ることができません。<br>
					しばらく間をあけてからご依頼ください。
				</div>
				<%}%>

				<%=results.user.m_strNickName%>さんへのエアスケブ依頼
					<%if(!checkLogin.m_bLogin){%>
					<div style="text-align: center; font-size: 12px; font-weight: normal">ログインすると依頼を送信できます</div>
					<%}%>
				<%}else{%>
				現在、依頼を受け付けていません
				<div>
					<%if(checkLogin.m_bLogin){%>
					<div style="margin: 13px 12px; font-size: 12px; font-weight: normal">このクリエイターにエアスケブ受付を始めてほしい気持ちを通知できます(匿名)</div>
					<a class="BtnBase" style="" href="javascript: void(0);" onclick="requestToStartRequesting()">
						<span class="RequestEnabled">お願いする</span>
					</a>
					<%}else{%>
					<div style="margin: 13px 12px; font-size: 12px; font-weight: normal">ログインすると、このクリエイターにエアスケブ受付を始めてほしい気持ちを通知できます。</div>
					<%}%>
				</div>
				<%}%>
			<%}%>
		</div>

		<%if(results.user.m_bRequestEnabled && !results.isBlocking && !results.isBlocked){%>
		<div class="UoloadCmdOption">
			<div class="OptionItem">
				<div class="OptionLabel">メディア</div>
				<div class="OptionPublish">
					<select id="OptionMedia">
						<%if(results.requestCreator.allowIllust()){%>
						<option value="1">イラスト</option>
						<%}%>
						<%if(results.requestCreator.allowNovel()){%>
						<option value="10">小説</option>
						<%}%>
					</select>
				</div>
			</div>
		</div>
		<div class="TextBody">
			依頼メッセージ
			<div class="TextBodyCharNum" style="text-align: left;">クリエイターの意向を尊重してお伝えください</div>
			<textarea id="EditRequestText" class="EditTextBody"
						maxlength="1000"
						onkeyup="dispRequestTextCharNum()"></textarea>
			<div id="RequestTextCharNum" class="TextBodyCharNum">1</div>
		</div>

		<div class="UoloadCmdOption">
			<div class="OptionItem">
				<div class="OptionLabel">NSFW（ワンクッション・R18相当）</div>
				<div class="onoffswitch OnOff <%=results.requestCreator.allowSensitive() ? "" : "disabled"%> ">
					<input type="checkbox" class="onoffswitch-checkbox"
							name="OptionRecent"
							id="OptionRequestCategory"
							value="0"
							<%=results.requestCreator.allowSensitive() ? "" : "onclick=\"return false;\""%>
					/>
					<label class="onoffswitch-label" for="OptionRequestCategory">
						<span class="onoffswitch-inner"></span>
						<span class="onoffswitch-switch"></span>
					</label>
				</div>
			</div>
			<div class="OptionNotify">
				<%if (results.requestCreator.allowSensitive()) {%>
				依頼内容がセンシティブなときは必ずON
				<%}else{%>
				センシティブな内容を受け付けません
				<%}%>
			</div>

			<div class="OptionItem">
				<div class="OptionLabel">匿名で依頼</div>
				<div class="onoffswitch OnOff <%=results.requestCreator.allowAnonymous() ? "" : "disabled"%> ">
					<input type="checkbox" class="onoffswitch-checkbox"
							name="OptionRecent"
							id="OptionAnonymousRequest"
							value="0"
							<%=results.requestCreator.allowAnonymous() ? "" : "onclick=\"return false;\""%>
					/>
					<label class="onoffswitch-label" for="OptionAnonymousRequest">
						<span class="onoffswitch-inner"></span>
						<span class="onoffswitch-switch"></span>
					</label>
				</div>
			</div>
			<div class="OptionNotify" style="margin-bottom: 30px">
				<%if (!results.requestCreator.allowAnonymous()) {%>
				匿名依頼を受け付けません
				<%}%>
			</div>

			<div class="UoloadCmdOption" style="margin-bottom: 0;">
				<div class="OptionItem">
					<div class="OptionLabel" style="flex: 0">利用範囲</div>
					<div class="OptionPublish">
						<select id="OptionLicense">
							<%for(int id : Request.LICENSE_IDS){%>
							<option value="<%=id%>"><%=_TEX.T(String.format("Request.License.%d.title",id))%></option>
							<%}%>
						</select>
					</div>
				</div>
			</div>
			<div class="TextBody" style="margin-bottom: 10px">
				<div class="RequestRule">
					<%for(int id : Request.LICENSE_IDS){%>
					<p id="RequestLicenseDetail<%=id%>" class="RequestLicenseDetail" style="display: <%=id==Request.LICENSE_IDS.get(0)?"block":"none"%>" >
						<%=Util.toStringHtml(_TEX.T(String.format("Request.License.%d.txt",id)))%>
					</p>
					<%}%>
				</div>
			</div>

			<%if(results.requestCreator.allowPaidRequest &&  results.requestCreator.allowFreeRequest){%>
			<div class="OptionItem">
				<div class="OptionLabel">有償で依頼する</div>
				<div class="onoffswitch OnOff ">
					<input type="checkbox" class="onoffswitch-checkbox"
							name="OptionPaidRequest"
							id="OptionPaidRequest"
							value="0"
							checked="checked"
							onclick="$('#PaidOptionArea').toggle()"
					/>
					<label class="onoffswitch-label" for="OptionPaidRequest">
						<span class="onoffswitch-inner"></span>
						<span class="onoffswitch-switch"></span>
					</label>
				</div>
			</div>
			<%}else{%>
				<input
					type="hidden"
					id="OptionPaidRequest"
					<%=results.requestCreator.allowPaidRequest ? "checked=\"checked\"" : ""%>
				/>
			<%}%>

			<%if(results.requestCreator.allowPaidRequest){%>
			<div id="PaidOptionArea" class="UoloadCmdOption">
				<div id="ItemAmount" class="OptionItem">
					<div class="OptionLabel">依頼金額</div>
					<div class="OptionPublish">
						<span class="RequestAmountUnit">¥</span><input id="EditAmount" class="EditPassword" type="number" maxlength="6"
								value="<%=results.requestCreator.amountLeftToMe%>"
								placeholder="おまかせ<%=results.requestCreator.amountLeftToMe%>円"
								onkeyup="dispCommission()"/>
					</div>
				</div>
				<div class="OptionNotify" style="margin-bottom: 8px;">
					¥<%=String.format("%,d", results.requestCreator.amountMinimum)%>〜¥<%=String.format("%,d", RequestCreator.AMOUNT_MINIMUM_MAX)%>
				</div>

				<div id="ItemCommission" class="OptionItem">
					<div class="OptionLabel">手数料</div>
					<div class="OptionPublish" style="font-size: 13px">
						¥<span id="Commission"></span>
					</div>
				</div>
				<div class="OptionNotify" style="margin-bottom: 8px; text-align: right;">
					依頼手数料<span id="CommissionRateSystem"></span>%
					+トランザクション手数料<span id="CommissionRateAgency"></span>%<br>
					詳しくは<a style="text-decoration: underline;" href="javascript:void(0);" onclick="dispCommissionDetailDlg()">こちら</a>
				</div>

				<div id="ItemAmountTotal" class="OptionItem" style="margin-bottom: 40px;">
					<div class="OptionLabel">支払総額</div>
					<div class="OptionPublish">
						¥<span id="AmountTotal"></span>
					</div>
				</div>
				<div class="OptionItem">
					<div class="OptionLabel">返答期限</div>
					<div class="OptionPublish">依頼から<%=results.requestCreator.returnPeriod%>日後</div>
				</div>
				<div class="OptionItem">
					<div class="OptionLabel">お渡し期限</div>
					<div class="OptionPublish">依頼から<%=results.requestCreator.deliveryPeriod%>日後</div>
				</div>
				<div class="OptionNotify">期限を過ぎると自動でキャンセルされます</div>
			</div>
			<%}%>

		</div>

		<div class="TextBody" style="text-align: center; margin-bottom: 10px;">
			<a style="text-align: center; text-decoration: underline;" href="/GuideLineRequestPcV.jsp">送信前にこちらのガイドラインをご一読ください</a>
		</div>

		<div class="TextBody" style="margin-bottom: 10px">
			<div class="RequestRule">
				<ol style="padding-inline-start: 25px;">
					<li>依頼本文以外での連絡はできません。</li>
					<li>打ち合わせ・リテイクはできません。</li>
					<li>クリエイターへの嫌がらせや中傷など、依頼と無関係なメッセージは不正行為とみなします。</li>
				</ol>
				<%if(results.requestCreator.allowPaidRequest){%>
				(有償依頼の場合)
				<ol style="padding-inline-start: 25px;">
					<li>金額の見積もりはできません。</li>
					<li>依頼送信時点で与信確保されます。</li>
					<li>依頼承認時点で決済されます。</li>
					<li>納品期限内に納品されなかった場合は、カード会社を通して返金されます。</li>
					<li>個人間の送金手段としては使用できません。</li>
				</ol>
				<%}%>
			</div>
		</div>

		<%if(checkLogin.m_bLogin){%>
			<%if(results.isReachedLimit){%>
			<div style="color: #0008db; font-size: 12px; margin: 20px auto; text-align: center">
				送信できる依頼数の制限に達しているため、<br>
				ただいまエアスケブの依頼を送ることができません。<br>
				しばらく間をあけてからご依頼ください。
			</div>
			<%}else{%>
			<div class="UoloadCmd">
				<a id="SendRequestBtn" class="BtnBase UoloadCmdBtn" href="javascript:void(0)" onclick="sendRequest();">ガイドラインに同意して依頼する</a>
			</div>
			<%}%>
		<%}else{%>
		<div style="text-align: center;">ログインすると依頼できます</div>
		<%}%>

		<%} // if(results.user.m_bRequestEnabled)%>
	</div>
</article>
</body>
</html>
