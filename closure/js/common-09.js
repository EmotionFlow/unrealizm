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

function CreateIllustItem(cItem, nUserId) {
	return CreateIllustItemBase(cItem, nUserId, 0);
}

function CreateIllustItemPc(cItem, nUserId) {
	return CreateIllustItemBase(cItem, nUserId, 1);
}

function CreateIllustItemBase(cItem, nUserId, nMode) {
	// nMode : 0-app, 1-pc & smart phone
	var ILLUST_LIST = (nMode==0)?"/IllustListV.jsp":"/IllustListPcV.jsp";
	var ILLUST_HEART = (nMode==0)?"/IllustHeartV.jsp":"/IllustHeartPcV.jsp";
	var REPORT_FORM = (nMode==0)?"/ReportFormV.jsp":"/ReportFormPcV.jsp";
	var ILLUST_DETAIL = (nMode==0)?"/IllustDetailV.jsp":"/IllustDetailPcV.jsp";

	var $objItem = $("<div/>").addClass("IllustItem").attr('id', 'IllustItem_'+cItem.content_id);

	var $objItemUser = $("<div/>").addClass("IllustItemUser");
	var $objItemUserThumb = $("<a/>").addClass("IllustItemUserThumb").attr("href", ILLUST_LIST+"?ID="+cItem.user_id);
	var $objItemUserThumbImg = $("<img/>").addClass("IllustItemUserThumbImg").attr("src", cItem.user_file_name+"_120.jpg");
	var $objItemUserName = $("<a/>").addClass("IllustItemUserName").attr("href", ILLUST_LIST+"?ID="+cItem.user_id).html(cItem.nickname);
	$objItemUserThumb.append($objItemUserThumbImg);
	$objItemUser.append($objItemUserThumb);
	$objItemUser.append($objItemUserName);

	var $objItemCommand = $("<div/>").addClass("IllustItemCommand");
	var $objCategory = $("<span/>").addClass("Category C"+cItem.category_id).html(cItem.category);
	$objItemCommand.append($objCategory);
	var $objItemCommandSub = $("<div/>").addClass("IllustItemCommandSub");
	var url="https://twitter.com/share?url=" + encodeURIComponent("https://poipiku.com/"+cItem.user_id+"/"+cItem.content_id+".html");
	var $objItemCommandSocial = $("<a/>").addClass("IllustItemCommandTweet fab fa-twitter-square").attr("href", url);
	var $objItemCommandDelete = $("<a/>").addClass("IllustItemCommandDelete far fa-trash-alt").attr("data-id", cItem.content_id).attr("href", "javascript:void(0)").click(function(){
		DeleteContent($(this).data("id"));
	});
	var $IllustItemCommandInfo = $("<a/>").addClass("IllustItemCommandInfo fas fa-info-circle").attr("href", REPORT_FORM+"?TD="+cItem.content_id);
	$objItemCommandSub.append($objItemCommandSocial);
	if(cItem.user_id==nUserId) {
		$objItemCommandSub.append($objItemCommandDelete);
	} else {
		$objItemCommandSub.append($IllustItemCommandInfo);
	}
	$objItemCommand.append($objItemCommandSub);

	var $objIllustItemDesc = $("<div/>").addClass("IllustItemDesc").html(cItem.description).autoLink();

	var $objItemThumb = $("<a/>").addClass("IllustItemThumb").attr("href", ILLUST_DETAIL+"?TD="+cItem.content_id);
	if(nMode==1) {
		$objItemThumb.attr("target", "_blank");
	}
	var $objItemThumbImg = $("<img/>").addClass("IllustItemThumbImg").attr("src", cItem.file_name+"_640.jpg");
	$objItemThumb.append($objItemThumbImg);

	$objItem.append($objItemUser);
	$objItem.append($objItemCommand);
	$objItem.append($objIllustItemDesc);
	$objItem.append($objItemThumb);

	return $objItem;
}

function SendComment(nContentId, strDescription, nUserId) {
	if(strDescription.length <= 0) return;
	$.ajax({
		"type": "post",
		"data": {"IID": nContentId, "DES": strDescription, "UID": nUserId},
		"url": "/f/SendCommentF.jsp",
		"success": function(data) {
			var $objResEmoji = $("<span/>").addClass("ResEmoji").html(strDescription);
			$("#ResEmojiAdd_"+nContentId).before($objResEmoji);
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

