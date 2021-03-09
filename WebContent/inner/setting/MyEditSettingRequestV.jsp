<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
	RequestCreator requestCreator = new RequestCreator(checkLogin);
%>
<script type="text/javascript">
	function _updateRequestSetting(attribute, variable){
		$.ajax({
			"type": "post",
			"data": {"ID":<%=checkLogin.m_nUserId%>, "ATTR":attribute, "VAL":variable},
			"url": "/f/UpdateSettingRequestF.jsp",
			"dataType": "json"
		})
		.then(
			(data) => {DispMsg("更新しました！");},
			(error) => {DispMsg("<%=_TEX.T("EditIllustVCommon.Upload.Error")%>");}
		);
		return false;
	}

	function updateRequestEnabled(){
		_updateRequestSetting("RequestEnabled", $("#RequestEnabled").prop("checked") ? 1 : 0);
	}
	function updateRequestMedia(){
		const allowIllust = $("#RequestMediaIllust").prop("checked") ? 1 : 0;
		const allowNovel = $("#RequestMediaNovel").prop("checked") ? 1 : 0;
		if (!allowIllust && !allowNovel) {
			DispMsg("１つ以上チェックしてください");
		}
		_updateRequestSetting("RequestMedia", String(allowIllust) + "," + String(allowNovel));
	}
	function updateAllowSensitive(){
		_updateRequestSetting("AllowSensitive", $("#AllowSensitive").prop("checked") ? 1 : 0);
	}

	function _validationRange(min, max, value) {
		if (value < min || value > max) {
			DispMsg(String(min) + "から" + String(max) + "の範囲で入力してください");
			return false;
		}
		return true;
	}
	function updateReturnPeriod(){
		const returnPeriod = parseInt($("#ReturnPeriod").val(), 10);
		if (_validationRange(
				<%=RequestCreator.RETURN_PERIOD_MIN%>,
				<%=RequestCreator.RETURN_PERIOD_MAX%>,
				returnPeriod
			)){
			_updateRequestSetting("ReturnPeriod", returnPeriod);
		}
	}
	function updateDeliveryPeriod(){
		const deliveryPeriod = parseInt($("#DeliveryPeriod").val(), 10);
		if (deliveryPeriod < parseInt($("#ReturnPeriod").val(), 10)) {
			DispMsg("返答締切日数より大きな日数を指定してください");
		}
		if (_validationRange(
			<%=RequestCreator.DELIVERY_PERIOD_MIN%>,
			<%=RequestCreator.DELIVERY_PERIOD_MAX%>,
			deliveryPeriod
		)){
			_updateRequestSetting("DeliveryPeriod", deliveryPeriod);
		}
	}
	function updateAmountLeftToMe(){
		const amountLeftToMe = parseInt($("#AmountLeftToMe").val(), 10);
		if (_validationRange(
			<%=RequestCreator.AMOUNT_LEFT_TO_ME_MIN%>,
			<%=RequestCreator.AMOUNT_LEFT_TO_ME_MAX%>,
			amountLeftToMe
		)){
			_updateRequestSetting("AmountLeftToMe", amountLeftToMe);
		}
	}
	function updateAmountMinimum(){
		const amountMinimum = parseInt($("#AmountMinimum").val(), 10);
		if (_validationRange(
			<%=RequestCreator.AMOUNT_MINIMUM_MIN%>,
			<%=RequestCreator.AMOUNT_MINIMUM_MAX%>,
			amountMinimum
		)){
			_updateRequestSetting("AmountMinimum(", amountMinimum);
		}

	}
	function updateCommercialTransactionLawTxt(){
		const lawTxt = $("#CommercialTransactionLaw").val();
		_updateRequestSetting("CommercialTransactionLaw", lawTxt);
	}

</script>
<style>
	.RequestVarUnit {font-size: 18px;line-height: 28px;}
</style>

<div class="SettingList">
	<div class="SettingListItem">
		<div class="SettingListTitle">リクエストの募集を受け付ける</div>
		<div class="SettingBody">
			クリエイターとしてポイピクユーザーからのリクエストを受け付けます。
			リクエスト報酬を受け取るには、メールアドレスの確認と日本の銀行口座が必要です。
			<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
				<div class="RegistMessage" >
					<div class="onoffswitch OnOff">
						<input type="checkbox"
							   name="onoffswitch"
							   class="onoffswitch-checkbox"
							   id="RequestEnabled"
							   value="0"
							   <%if(requestCreator.status==RequestCreator.Status.Enabled){%>checked="checked"<%}%> />
						<label class="onoffswitch-label" for="RequestEnabled">
							<span class="onoffswitch-inner"></span>
							<span class="onoffswitch-switch"></span>
						</label>
					</div>
				</div>
				<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateRequestEnabled()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
			</div>
		</div>

		<div id="RequestSettingItems">
			<div class="SettingListItem">
				<div class="SettingListTitle">メディア</div>
				リクエストを受け付けるメディアを設定します。
				<div class="SettingBody">
					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
						<div class="RegistMessage">
						<label>
							<input id="RequestMediaIllust" type="checkbox" <%if(requestCreator.allowIllust()){%>checked="checked"<%}%> >イラスト
						</label>
						<label>
							<input id="RequestMediaNovel" type="checkbox" <%if(requestCreator.allowNovel()){%>checked="checked"<%}%> >小説
						</label>
						</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateRequestMedia()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">ワンクッション・R18リクエスト</div>
				<div class="SettingBody">
					センシティブな内容のリクエストを許可します
					<div class="SettingBodyCmd" style="margin: 5px 0 5px 0;">
						<div class="RegistMessage">
							<div class="onoffswitch OnOff">
								<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="AllowSensitive" value="0" <%if(requestCreator.allowSensitive()){%>checked="checked"<%}%> />
								<label class="onoffswitch-label" for="AllowSensitive">
									<span class="onoffswitch-inner"></span>
									<span class="onoffswitch-switch"></span>
								</label>
							</div>
						</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAllowSensitive()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">返答締切日数</div>
				<div class="SettingBody">
					<div>
						<input id="ReturnPeriod" type="number" placeholder="30" value="<%=requestCreator.returnPeriod%>" maxlength="3" />
						<span class="RequestVarUnit">日</span>
					</div>
					<div class="RegistMessage" >リクエストの返答期限を設定します。<%=RequestCreator.RETURN_PERIOD_MIN%>日から<%=RequestCreator.RETURN_PERIOD_MAX%>日の間で設定できます。</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateReturnPeriod()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">納品締切日数</div>
				<div class="SettingBody">
					<div>
						<input id="DeliveryPeriod" type="number" placeholder="60" value="<%=requestCreator.deliveryPeriod%>" maxlength="3" />
						<span class="RequestVarUnit">日</span>
					</div>
					<div class="RegistMessage">リクエストを得た日からの納品期限を設定します。<%=RequestCreator.DELIVERY_PERIOD_MIN%>日から<%=RequestCreator.DELIVERY_PERIOD_MAX%>日の間で設定できます。返答締切日数より短くすることはできません。</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateDeliveryPeriod()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">おまかせ金額</div>
				<div class="SettingBody">
					<div>
						<span class="RequestVarUnit">¥</span>
						<input id="AmountLeftToMe" type="number" placeholder="60" value="<%=requestCreator.amountLeftToMe%>" maxlength="5" />
					</div>
					<div class="RegistMessage">
						おまかせでリクエストされた時の金額を設定します。
						¥<%=RequestCreator.AMOUNT_LEFT_TO_ME_MIN%>〜<%=RequestCreator.AMOUNT_LEFT_TO_ME_MAX%>の間で設定できます。
					</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAmountLeftToMe()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">最低金額</div>
				<div class="SettingBody">
					<div>
						<span class="RequestVarUnit">¥</span>
						<input id="AmountMinimum" type="number" placeholder="60" value="<%=requestCreator.amountMinimum%>" maxlength="16" />
					</div>
					<div class="RegistMessage">
						リクエスト最低金額を設定します。
						¥<%=RequestCreator.AMOUNT_MINIMUM_MIN%>〜<%=RequestCreator.AMOUNT_MINIMUM_MAX%>の間で設定できます。
					</div>
					<div class="SettingBodyCmd">
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateAmountMinimum()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
			<div class="SettingListItem">
				<div class="SettingListTitle">特定商取引法に基づく表記</div>
				特定商取引法で定められた内容を記載してください。特定商取引法に基づく表記を設定するべきかどうかはクリエイターガイドラインを確認してください。
				<div class="SettingBody">
					<textarea id="CommercialTransactionLaw" class="SettingBodyTxt" rows="6" onkeyup="dispLawTxtNum()" maxlength="1000"><%=Util.toStringHtmlTextarea(requestCreator.commercialTransactionLaw)%></textarea>
					<div class="SettingBodyCmd">
						<div id="ProfileTextMessage" class="RegistMessage">1000</div>
						<a class="BtnBase SettingBodyCmdRegist" href="javascript:void(0)" onclick="updateCommercialTransactionLawTxt()"><%=_TEX.T("EditSettingV.Button.Update")%></a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
