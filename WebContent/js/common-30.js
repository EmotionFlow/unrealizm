$(function(){jQuery.extend({ajaxSingle:function(a){var b=!1;return function(a){try{b||(b=!0,a.complete=function(){return function(a,c){b=!1}}(),$.ajax(a))}catch(e){b=!1}}}()})});function setCookie(a,b,c){c=a+"="+encodeURIComponent(b)+"; ";document.cookie=c+"path=/; expires=Tue, 31-Dec-2030 23:59:59; "}function setCookieOneTime(a,b,c){c=a+"="+encodeURIComponent(b)+"; ";document.cookie=c+"path=/; "}
function setCookieWeek(a,b,c){dateExp=new Date;dateExp.setTime(dateExp.getTime()+6048E5);c=a+"="+encodeURIComponent(b)+"; ";c=c+"path=/; "+("expires="+dateExp.toGMTString());document.cookie=c}function getCookie(a){var b=a+"=";a=document.cookie;var c=a.indexOf(b);if(0>c)return null;b=c+b.length;c=a.indexOf(";",b);-1==c&&(c=a.length);return decodeURIComponent(a.substring(b,c))}
function deleteCookie(a,b){dTime=new Date;dTime.setTime(0);b=a+"="+encodeURIComponent("0")+"; ";b=b+"path=/; "+("expires="+dTime.toGMTString()+"; ");document.cookie=b}function ChLang(a){0<a.length?setCookie("LANG",a):deleteCookie("LANG");$.ajaxSingle({type:"post",data:{LD:"ja"==a?1:0},url:"/f/UpdateLanguageF.jsp",success:function(a){location.reload(!0)}})}function setLocalStrage(a,b){b={val:b};b=JSON.stringify(b);localStorage.setItem(a,b)}
function getLocalStrage(a){a=localStorage.getItem(a);return a?(a=JSON.parse(a))?a.val:null:null}function SearchIllustByKeyword(){var a=$("#HeaderSearchBox").val();location.href="/SearchIllustByKeywordPcV.jsp?KWD="+encodeURIComponent(a)}function SearchTagByKeyword(){var a=$("#HeaderSearchBox").val();location.href="/SearchTagByKeywordPcV.jsp?KWD="+encodeURIComponent(a)}
function SearchUserByKeyword(){var a=$("#HeaderSearchBox").val();location.href="/SearchUserByKeywordPcV.jsp?KWD="+encodeURIComponent(a)}var sendObjectMessage=function(a){var b=document.createElement("iframe");b.setAttribute("src","myurlscheme://"+a);document.documentElement.appendChild(b);b.parentNode.removeChild(b)};
$.fn.autoLink=function(a){var b=0==a?"/SearchIllustByTagV.jsp":"/SearchIllustByTagPcV.jsp";return this.each(function(){var a=this.innerHTML;a=a.replace(/((http|https):\/\/[\w\.\-\/:;&?,=#!~]+)/gi,"<a class='AutoLink' href='$1' target='_blank'>$1</a>");this.innerHTML=a.replace(/(#|\uff03)[\w]*[a-zA-Z0-9\u3041-\u30fe\u30fc-\u9fa5\u8c48-\u9db4]+/g,function(a){a=a.replace(/[#\uff03]/,"");return" <a class='AutoLink' href='"+b+"?KWD="+encodeURIComponent(a)+"'>#"+a+"</a>"})})};
function GotoLogin(){location.href="/LoginFormV.jsp"}function DispMsg(a){$("#DispMsg").html(a);$("#DispMsg").slideDown(200,function(){setTimeout(function(){$("#DispMsg").slideUp(200)},3E3)})}function DispMsgStatic(a){setTimeout(function(){$("#DispMsg").html(a);$("#DispMsg").show()},0)}function HideMsgStatic(){setTimeout(function(){$("#DispMsg").hide()},1E3)}
function SendEmoji(a,b,c){$.ajax({type:"post",data:{IID:a,EMJ:b,UID:c},url:"/f/SendEmojiF.jsp",dataType:"json",success:function(b){0<b.result_num&&(b=$("<span/>").addClass("ResEmoji").html(b.result),$("#ResEmojiAdd_"+a).before(b))}});return!1}
function DeleteContentBase(a,b){$.ajaxSingle({type:"post",data:{UID:a,CID:b},url:"/f/DeleteContentF.jsp",dataType:"json",success:function(a){$("#IllustItem_"+b).slideUp(300,function(){$("#IllustItem_"+b).remove();vg&&vg.vgrefresh()})},error:function(a,b,d){DispMsg("Delete Error")}})}
function switchEmojiKeyboard(a,b,c){var e=$(a).parent().parent().children(".ResEmojiBtnList");e.hide();var d=e.eq(c);d.loading||(d.loading=!0,e=$("<div/>").addClass("Waiting"),d.empty(),d.append(e),$.ajax({type:"post",data:{IID:b,CAT:c},url:"/f/GetEmojiListF.jsp",dataType:"html",success:function(a){d.html(a);d.loading=!1;vg&&vg.vgrefresh()},error:function(a,b,c){$(".Waiting").remove();DispMsg("emoji loading Error");d.loading=!1}}));d.show();$(a).parent().children(".ResBtnSetItem").removeClass("Selected");
$(a).addClass("Selected")}function EditDesc(a){$("#IllustItemDesc_"+a).hide();$("#IllustItemTag_"+a).hide();$("#IllustItemDescEdit_"+a).show();$("#IllustItemCategory_"+a).hide();$("#IllustItemCategoryEdit_"+a).show()}
function UpdateDesc(a,b,c){var e=$("#EditCategory_"+b).val(),d=$.trim($("#IllustItemDescEdit_"+b+" .IllustItemDescEditTxt").val());d=d.substr(0,200);var f=$.trim($("#IllustItemDescEdit_"+b+" .IllustItemTagEditTxt").val());f=f.substr(0,100);$.ajaxSingle({type:"post",data:{UID:a,IID:b,CAT:e,DES:d,TAG:f,MOD:c},url:"/f/UpdateDescF.jsp",dataType:"json",success:function(a){$("#IllustItemDesc_"+b).html(a.html);$("#IllustItemDescEdit_"+b+" .IllustItemDescEditTxt").val(a.text);$("#IllustItemTag_"+b).html(a.htmlTag);
$("#IllustItemDescEdit_"+b+" .IllustItemTagEditTxt").val(a.textTag);$("#IllustItemDesc_"+b).show();$("#IllustItemTag_"+b).show();$("#IllustItemDescEdit_"+b).hide();$("#IllustItemCategory_"+b+" .Category").removeClass().addClass("Category C"+e).text(a.category_name);a=$("#IllustItemCategory_"+b+" .Category").attr("href");a=a.replace(/CD=\d+/i,"CD="+e);$("#IllustItemCategory_"+b+" .Category").attr("href",a);$("#IllustItemCategory_"+b).show();$("#IllustItemCategoryEdit_"+b).hide()},error:function(a,
b,c){DispMsg("Connection error")}})}function UpdateFollowTag(a,b,c){$.ajaxSingle({type:"post",data:{UID:a,TXT:b,TYP:c},url:"/f/UpdateFollowTagF.jsp",dataType:"json",success:function(a){1==a.result?$(".TitleCmdFollow").addClass("Selected"):2==a.result?$(".TitleCmdFollow").removeClass("Selected"):DispMsg("You need to login")},error:function(a,b,c){DispMsg("Connection error")}})}
function UpdateBookmark(a,b){$.ajaxSingle({type:"post",data:{UID:a,IID:b},url:"/f/UpdateBookmarkF.jsp",dataType:"json",success:function(a){1==a.result?$("#IllustItemBookmarkBtn_"+b).addClass("Selected"):0==a.result?$("#IllustItemBookmarkBtn_"+b).removeClass("Selected"):DispMsg("You need to login")},error:function(a,b,d){DispMsg("Connection error")}})}function fixedEncodeURIComponent(a){return encodeURIComponent(a).replace(/[!'()*]/g,function(a){return"%"+a.charCodeAt(0).toString(16)})}
function moveTagSearch(a,b){location.href=a+fixedEncodeURIComponent(b)}function updateCategoryMenuPos(a){if($("#CategoryMenu").length){var b=$("#CategoryMenu").outerWidth(),c=$("#CategoryMenu").scrollLeft(),e=$("#CategoryMenu .CategoryBtn.Selected").outerWidth();b=$("#CategoryMenu .CategoryBtn.Selected").position().left+c+(e-b)/2;$("#CategoryMenu").animate({scrollLeft:b},a)}}
function ShowAllReaction(a,b){$.ajax({type:"post",data:{IID:a},url:"/f/ShowAllReactionF.jsp",dataType:"json",success:function(c){console.log(c);0<c.result_num?($(b).hide(),$("#IllustItemResList_"+a+" .ResEmoji").remove(),$("#ResEmojiAdd_"+a).before(c.html)):$(b).html(c.html)}});return!1}function ExpandItem(a,b){$(this).hide();$("#IllustItem_"+a+" .IllustItemThubExpand").slideDown(300,function(){vg&&vg.vgrefresh()})};
