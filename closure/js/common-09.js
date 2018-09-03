function setCookie(key, val, tmp) {
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	tmp += "expires=Tue, 31-Dec-2030 23:59:59; ";
	document.cookie = tmp;
}

function setCookieOneTime(key, val, tmp) {
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	document.cookie = tmp;
}

function setCookieWeek(key, val, tmp) {
	dateExp = new Date();
	dateExp.setTime(dateExp.getTime()+(7*1000*60*60*24));
	tmp = key + "=" + encodeURIComponent(val) + "; ";
	tmp += "path=/; ";
	tmp += "expires="+dateExp.toGMTString();
	document.cookie = tmp;
}

function getCookie(key) {
	var cookieName = key + '=';
	var allcookies = document.cookie;
	var position = allcookies.indexOf(cookieName);

	if(position<0) return null;

	var startIndex = position + cookieName.length;
	var endIndex = allcookies.indexOf(';', startIndex);
	if( endIndex == -1 ) endIndex = allcookies.length;

	return decodeURIComponent(allcookies.substring(startIndex, endIndex));
}

function deleteCookie(key, tmp) {
	dTime = new Date();
	dTime.setTime(0);
	tmp = key + "=" + encodeURIComponent("0") + "; ";
	tmp += "path=/; ";
	tmp += "expires=" + dTime.toGMTString() + "; ";
	document.cookie = tmp;
}

function ChLang(l){
	if(l.length>0) {
		setCookie('MK_LANG',l);
	} else {
		deleteCookie('MK_LANG');
	}
	var nLangId = (l=="ja")?1:0;
	$.ajaxSingle({
		"type": "post",
		"data": { "LD":nLangId },
		"url": "/FUpdateLanguage.jsp",
		"success": function(data) {
			location.reload(true);
		}
	});
}

function SearchIllustByKeyword() {
	var keyword = $('#HeaderSearchBox').val();
	location.href="/SearchIllustByKeywordPcV.jsp?KWD="+encodeURIComponent(keyword);
}

function SearchTagByKeyword() {
	var keyword = $('#HeaderSearchBox').val();
	location.href="/SearchTagByKeywordPcV.jsp?KWD="+encodeURIComponent(keyword);
}

function SearchUserByKeyword() {
	var keyword = $('#HeaderSearchBox').val();
	location.href="/SearchUserByKeywordPcV.jsp?KWD="+encodeURIComponent(keyword);
}

var sendObjectMessage = function(parameters) {
	var iframe = document.createElement('iframe');
	iframe.setAttribute('src', "myurlscheme://"+parameters);
	document.documentElement.appendChild(iframe);
	iframe.parentNode.removeChild(iframe);
	iframe = null;
}

$.fn.autoLink = function(nMode){
	// nMode : 0-app, 1-pc & smart phone
	var SEARCH_TAG = (nMode==0)?"/SearchIllustByTagV.jsp":"/SearchIllustByTagPcV.jsp";

	return this.each(function(){
		var srcText = this.innerHTML;
		//this.innerHTML = srcText.replace(/(#)([\w|[\u2E80-\u2E99\u2E9B-\u2EF3\u2F00-\u2FD5\u3005\u3007\u3021-\u3029\u3038-\u303B\u3400-\u4DB5\u4E00-\u9FCC\uF900-\uFA6D\uFA70-\uFAD9]|[\uD840-\uD868][\uDC00-\uDFFF]|\uD869[\uDC00-\uDED6\uDF00-\uDFFF]|[\uD86A-\uD86C][\uDC00-\uDFFF]|\uD86D[\uDC00-\uDF34\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1D]|\uD87E[\uDC00-\uDE1D]]+)/gi,"<a class='AutoLink' href='/SearchIllustByTagV.jsp?KWD=$2'>#$2</a>");
		srcText = srcText.replace(/((http|https):\/\/[\w\.\-\/:;&?,=#!~]+)/gi,"<a class='AutoLink' href='$1' target='_blank'>$1</a>");
		//this.innerHTML = srcText.replace(/[#＃]+[A-Za-z0-9-_ぁ-ヶ亜-黑]+/g, function(hash) {
		this.innerHTML = srcText.replace(/(#|＃)[\w]*[a-zA-Z0-9ぁ-ヾー-龥豈-鶴]+/g, function(hash) {
			var no_mark_hash = hash.replace(/[#＃]/, "");
			return " <a class='AutoLink' href='"+SEARCH_TAG+"?KWD="+encodeURIComponent(no_mark_hash)+"'>#"+no_mark_hash+"</a>";
			});
	});
}

function GotoLogin() {
	location.href = "/LoginFormV.jsp";
}

function DispMsg(strMessage) {
	$("#DispMsg").html(strMessage);
	$("#DispMsg").slideDown(200, function() {
		setTimeout(function() {
			$("#DispMsg").slideUp(200);
		}, 3000);
	});
}

function DispMsgStatic(strMessage) {
	setTimeout(function(){
		$("#DispMsg").html(strMessage);
		$("#DispMsg").show();
	}, 0);
}

function HideMsgStatic() {
	setTimeout(function(){
		$("#DispMsg").hide();
	}, 1000);
}

$(function(){
	jQuery.extend({
		ajaxSingle: (function(options){
			var ajaxSending = false;
			return function(options){
				try{
					if(!ajaxSending){
						ajaxSending = true;
						options.complete = (function(){
							var complete = typeof(options.complete)=="function" ? options.complete : function(a,b){} ;
							return function(a,b){
								ajaxSending = false;
							};
						})();
						$.ajax(options);
					} else {
						;
					}
				}catch(e){
					ajaxSending = false;
				}
			};
		})()
	});

	$(window).on('scroll', function() {
		if ($(this).scrollTop() >= 75) {
			$('.MainMenu').addClass('Fixed');
		} else {
			$('.MainMenu').removeClass('Fixed');
		}
	});
});

function CreateIllustThumb(cItem) {
	return CreateIllustThumbBase(cItem, 0);
}

function CreateIllustThumbPc(cItem) {
	return CreateIllustThumbBase(cItem, 1);
}

function CreateIllustThumbBase(cItem, nMode) {
	var ILLUST_VIEW = (nMode==0)?"/IllustViewV.jsp":"/IllustViewPcV.jsp";
	var $objItem = $("<a/>").addClass("IllustThumb").attr("href", ILLUST_VIEW+"?ID="+cItem.user_id+"&TD="+cItem.content_id);
	var $objCategory = $("<span/>").addClass("Category C"+cItem.category_id).html(cItem.category);
	var $objItemImg = $("<img/>").addClass("IllustThumbImg").attr("src", cItem.file_name+"_360.jpg");
	$objItem.append($objCategory);
	$objItem.append($objItemImg);
	return $objItem;
}

function SendEmoji(nContentId, nCategory, nPos , nUserId) {
	$.ajax({
		"type": "post",
		"data": {"IID": nContentId, "CAT": nCategory, "POS": nPos, "UID": nUserId},
		"url": "/f/SendEmojiF.jsp",
		"dataType": "json",
		"success": function(data) {
			if(data.result_num>0) {
				var $objResEmoji = $("<span/>").addClass("ResEmoji").html(data.result);
				$("#ResEmojiAdd_"+nContentId).before($objResEmoji);
			}
		}
	});
	return false;
}

function DeleteContentBase(nUserId, nContentId) {
	$.ajaxSingle({
		"type": "post",
		"data": { "UID":nUserId, "CID":nContentId },
		"url": "/f/DeleteContentF.jsp",
		"dataType": "json",
		"success": function(data) {
			$('#IllustItem_'+nContentId).remove();
		},
		"error": function(req, stat, ex){
			DispMsg('Delete Error');
		}
	});
}

