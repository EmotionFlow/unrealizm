<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!-- for EPSILON -->
<script src='https://secure.epsilon.jp/js/token.js' async></script>
<%--<script src='https://beta.epsilon.jp/js/token.js'></script>--%>
<script>
	const AGENT = {
		"VERITRANS": 1,
		"EPSILON": 2,
	};

	function getAmountDlgHtml(emojiImgTag){
		return <%=_TEX.T("CheerDlg.Text")%>;
	}

	function getRegistCreditCardDlgHtml(strTitle, strDescription){
		return `
<style>
	.CardInfoDlgTitle{padding: 10px 0 0 0;}
	.CardInfoDlgInfo{font-size: 12px; text-align: left;}
	.CardInfoDlgInputItem{margin: 4px;}
	.CardInfoDlgInputLabel{font-size: 16px;}
	.CardInfoDlgInfoCheckList{text-align: left; font-size: 16px;}
	.swal2-popup .CardInfoDlgInputItem .swal2-input{margin-top: 4px; font-size: 1.1em; height: 1.825em;}
	.swal2-popup .CardInfoDlgInputItem .swal2-input::placeholder{font-style: italic;}
</style>
<h2 class="CardInfoDlgTitle">
` + strTitle + `
</h2>
<div class="CardInfoDlgInfo">
	<p>` + strDescription + `</p>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel"><%=_TEX.T("CardInfoDlg.CardNumber")%></div>
	<span>
	<img src="/img/credit_card_logo_visa.png" height="30px" style="padding-top: 4px;"/>
	<img src="/img/credit_card_logo_master.gif" height="30px" style="padding-top: 4px;"/>
	<img src="/img/credit_card_logo_jcb.gif" height="30px" style="padding-top: 4px;"/>
	<img src="/img/credit_card_logo_ae.gif" height="30px" style="padding-top: 4px;"/>
	<img src="/img/credit_card_logo_diners.gif" height="30px" style="padding-top: 4px;"/>
	</span>
	<input id="card_number" class="swal2-input" autocomplete="off"　style="margin-top: 4px;" maxlength="16" placeholder="4111111111111111"/>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel"><%=_TEX.T("CardInfoDlg.CardExpire")%></div>
	<input id="cc_exp" class="swal2-input" style="margin-top: 4px;" maxlength="5" placeholder="01/23"/>
</div>
<div class="CardInfoDlgInputItem">
	<div class="CardInfoDlgInputLabel"><%=_TEX.T("CardInfoDlg.CardSecCode")%><div/>
	<input id="cc_csc" class="swal2-input" style="margin-top: 4px;" maxlength="4" placeholder="012"/>
</div>
`;
	}

	function createAgentInfo(agent, token, tokenExpire){
		return {
			"agentId": agent,
			"token": token,
			"tokenExpire": tokenExpire,
		};
	}

	function verifyCardDlgInput(){
		// 入力内容の検証
		const vals = {
			cardNum: $("#card_number").val(),
			cardExp: $("#cc_exp").val(),
			cardSec: $("#cc_csc").val(),
		}

		// カード番号
		if (vals.cardNum === '') {
			return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardNumber.Empty")%>');
		}
		const validateCreditCardResult = $("#card_number").validateCreditCard(
			{ accept: [
					'visa', 'mastercard', 'diners_club_international', 'jcb', 'amex',
				] });
		if(!validateCreditCardResult.valid){
			return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardNumber.Invalid")%>');
		}
		if (vals.cardExp === '') {
			return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardExp.Empty")%>');
		}

		// 有効期限 use dayjs
		const MM = Number(vals.cardExp.split('/')[0]);
		const YY = Number(vals.cardExp.split('/')[1]);
		const expDay = dayjs("20" + YY + "-" + MM + "-01");
		if(isNaN(MM)||isNaN(YY)||!expDay){
			return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardExp.FormatErr")%>');
		}
		const now = dayjs();
		const limit = now.add(60, 'day');
		if(limit>expDay){
			return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardExp.Invalid")%>');
		}

		// セキュリティーコード
		if (vals.cardSec === ''){
			return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardSecCode.Empty")%>');
		}
		if (/^\d+$/.exec(vals.cardSec) == null){
			return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardSecCode.CharKindErr")%>');
		}
		if (vals.cardSec.length < 3){
			return Swal.showValidationMessage('<%=_TEX.T("CardInfoDlg.Validation.CardSecCode.LengthErr")%>');
		}
		return vals;
	}
</script>
