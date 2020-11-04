$(function(){jQuery.extend({ajaxSingle:function(b){var a=!1;return function(c){try{a||(a=!0,c.complete=function(){return function(d,e){a=!1}}(),$.ajax(c))}catch(d){a=!1}}}()})});var vg=null;function setCookie(b,a,c){c=b+"="+encodeURIComponent(a)+"; ";document.cookie=c+"path=/; expires=Tue, 31-Dec-2030 23:59:59; "}function setCookieOneTime(b,a,c){c=b+"="+encodeURIComponent(a)+"; ";document.cookie=c+"path=/; "}
function setCookieWeek(b,a,c){dateExp=new Date;dateExp.setTime(dateExp.getTime()+6048E5);c=b+"="+encodeURIComponent(a)+"; ";c=c+"path=/; expires="+dateExp.toGMTString();document.cookie=c}function getCookie(b){var a=b+"=";b=document.cookie;var c=b.indexOf(a);if(0>c)return null;a=c+a.length;c=b.indexOf(";",a);-1==c&&(c=b.length);return decodeURIComponent(b.substring(a,c))}
function deleteCookie(b,a){dTime=new Date;dTime.setTime(0);a=b+"="+encodeURIComponent("0")+"; ";a=a+"path=/; expires="+(dTime.toGMTString()+"; ");document.cookie=a}function ChLang(b){0<b.length?setCookie("LANG",b):deleteCookie("LANG");$.ajaxSingle({type:"post",data:{LD:"ja"==b?1:0},url:"/f/UpdateLanguageF.jsp",success:function(a){location.reload(!0)}})}function setLocalStrage(b,a){a={val:a};a=JSON.stringify(a);localStorage.setItem(b,a)}
function getLocalStrage(b){b=localStorage.getItem(b);return b?(b=JSON.parse(b))?b.val:null:null}function SearchIllustByKeyword(){var b=$("#HeaderSearchBox").val();location.href="/SearchIllustByKeywordPcV.jsp?KWD="+encodeURIComponent(b)}function SearchTagByKeyword(){var b=$("#HeaderSearchBox").val();location.href="/SearchTagByKeywordPcV.jsp?KWD="+encodeURIComponent(b)}
function SearchUserByKeyword(){var b=$("#HeaderSearchBox").val();location.href="/SearchUserByKeywordPcV.jsp?KWD="+encodeURIComponent(b)}var sendObjectMessage=function(b){var a=document.createElement("iframe");a.setAttribute("src","myurlscheme://"+b);document.documentElement.appendChild(a);a.parentNode.removeChild(a)};
$.fn.autoLink=function(b){var a=0==b?"/SearchIllustByTagV.jsp":"/SearchIllustByTagPcV.jsp";return this.each(function(){var c=this.innerHTML;c=c.replace(/((http|https):\/\/[\w\.\-\/:;&?,=#!~]+)/gi,"<a class='AutoLink' href='$1' target='_blank'>$1</a>");this.innerHTML=c.replace(/(#|\uff03)[\w]*[a-zA-Z0-9\u3041-\u30fe\u30fc-\u9fa5\u8c48-\u9db4]+/g,function(d){d=d.replace(/[#\uff03]/,"");return" <a class='AutoLink' href='"+a+"?KWD="+encodeURIComponent(d)+"'>#"+d+"</a>"})})};
function GotoLogin(){location.href="/LoginFormV.jsp"}function DispMsg(b){0>=$("#DispMsg").length&&$("body").append($("<div/>").attr("id","DispMsg"));$("#DispMsg").html(b);$("#DispMsg").slideDown(200,function(){setTimeout(function(){$("#DispMsg").slideUp(200)},3E3)})}function DispMsgStatic(b){setTimeout(function(){$("#DispMsg").html(b);$("#DispMsg").show()},0)}function HideMsgStatic(){setTimeout(function(){$("#DispMsg").hide()},1E3)}
function DeleteContentInteractive(b,a,c,d,e,g,f,h,k){Swal.fire({title:"",text:d,type:"question",showCancelButton:!0,confirmButtonText:e,cancelButtonText:g}).then(function(l){l.value&&(c?Swal.fire({title:"",text:f,type:"question",showCancelButton:!0,confirmButtonText:h,cancelButtonText:k}).then(function(m){m.value?DeleteContentBase(b,a,!0):DeleteContentBase(b,a,!1)}):DeleteContentBase(b,a,!1))})}
function DeleteContentBase(b,a,c){$.ajaxSingle({type:"post",data:{UID:b,CID:a,DELTW:c?1:0},url:"/f/DeleteContentF.jsp",dataType:"json",success:function(d){$("#IllustItem_"+a).slideUp(300,function(){$("#IllustItem_"+a).remove();vg&&vg.vgrefresh()})},error:function(d,e,g){DispMsg("Delete Error")}})}
function switchEmojiKeyboard(b,a,c){var d=$(b).parent().parent().children(".ResEmojiBtnList");d.hide();var e=d.eq(c);e.loading||(e.loading=!0,d=$("<div/>").addClass("Waiting"),e.empty(),e.append(d),$.ajax({type:"post",data:{IID:a,CAT:c},url:"/f/GetEmojiListF.jsp",dataType:"html",success:function(g){e.html(g);e.loading=!1;vg&&vg.vgrefresh()},error:function(g,f,h){$(".Waiting").remove();DispMsg("emoji loading Error");e.loading=!1}}));e.show();$(b).parent().children(".ResBtnSetItem").removeClass("Selected");
$(b).addClass("Selected")}function EditDesc(b){$("#IllustItemDesc_"+b).hide();$("#IllustItemTag_"+b).hide();$("#IllustItemDescEdit_"+b).show();$("#IllustItemCategory_"+b).hide();$("#IllustItemCategoryEdit_"+b).show()}
function UpdateDesc(b,a,c){var d=$("#EditCategory_"+a).val(),e=$.trim($("#IllustItemDescEdit_"+a+" .IllustItemDescEditTxt").val());e=e.substr(0,200);var g=$.trim($("#IllustItemDescEdit_"+a+" .IllustItemTagEditTxt").val());g=g.substr(0,100);$.ajaxSingle({type:"post",data:{UID:b,IID:a,CAT:d,DES:e,TAG:g,MOD:c},url:"/f/UpdateDescF.jsp",dataType:"json",success:function(f){$("#IllustItemDesc_"+a).html(f.html);$("#IllustItemDescEdit_"+a+" .IllustItemDescEditTxt").val(f.text);$("#IllustItemTag_"+a).html(f.htmlTag);
$("#IllustItemDescEdit_"+a+" .IllustItemTagEditTxt").val(f.textTag);$("#IllustItemDesc_"+a).show();$("#IllustItemTag_"+a).show();$("#IllustItemDescEdit_"+a).hide();$("#IllustItemCategory_"+a+" .Category").removeClass().addClass("Category C"+d).text(f.category_name);f=$("#IllustItemCategory_"+a+" .Category").attr("href");f=f.replace(/CD=\d+/i,"CD="+d);$("#IllustItemCategory_"+a+" .Category").attr("href",f);$("#IllustItemCategory_"+a).show();$("#IllustItemCategoryEdit_"+a).hide()},error:function(f,
h,k){DispMsg("Connection error")}})}function UpdateFollowTag(b,a,c){$.ajaxSingle({type:"post",data:{UID:b,TXT:a,TYP:c},url:"/f/UpdateFollowTagF.jsp",dataType:"json",success:function(d){0>d.result?DispMsg(d.message):1==d.result?$(".TitleCmdFollow").addClass("Selected"):0==d.result?$(".TitleCmdFollow").removeClass("Selected"):DispMsg("You need to login")},error:function(d,e,g){DispMsg("Connection error")}})}
function UpdateBookmark(b,a){$.ajaxSingle({type:"post",data:{UID:b,IID:a},url:"/f/UpdateBookmarkF.jsp",dataType:"json",success:function(c){1==c.result?$("#IllustItemBookmarkBtn_"+a).addClass("Selected"):0==c.result?$("#IllustItemBookmarkBtn_"+a).removeClass("Selected"):DispMsg("You need to login")},error:function(c,d,e){DispMsg("Connection error")}})}function fixedEncodeURIComponent(b){return encodeURIComponent(b).replace(/[!'()*]/g,function(a){return"%"+a.charCodeAt(0).toString(16)})}
function moveTagSearch(b,a){location.href=b+fixedEncodeURIComponent(a)}function updateCategoryMenuPos(b){if($("#CategoryMenu").length&&$("#CategoryMenu .CategoryBtn.Selected").length){var a=$("#CategoryMenu").outerWidth(),c=$("#CategoryMenu").scrollLeft(),d=$("#CategoryMenu .CategoryBtn.Selected").outerWidth();a=$("#CategoryMenu .CategoryBtn.Selected").position().left+c+(d-a)/2;$("#CategoryMenu").animate({scrollLeft:a},b)}}
function ShowAllReaction(b,a){$.ajax({type:"post",data:{IID:b},url:"/f/ShowAllReactionF.jsp",dataType:"json",success:function(c){console.log(c);0<c.result_num?($(a).hide(),$("#IllustItemResList_"+b+" .ResEmoji").remove(),$("#ResEmojiAdd_"+b).before(c.html),vg&&vg.vgrefresh()):$(a).html(c.html)}});return!1}
function generateShowAppendFile(){var b={};return function(a,c,d,e){console.log(a,c,d);console.log("twitter friendships: "+b);var g=$("#IllustItem_"+c+' input[name="PAS"]').val(),f=b[a];f||(f=-1);$.ajax({type:"post",data:{UID:a,IID:c,PAS:g,MD:d,TWF:f},url:"/f/ShowAppendFileF.jsp",dataType:"json",success:function(h){0<h.result_num?($("#IllustItem_"+c+" .IllustItemThubExpand").html(h.html),$(e).parent().hide(),$("#IllustItem_"+c).removeClass("R15 R18 R18G Password Login Follower TFollower TFollow TEach TList"),
$("#IllustItem_"+c+" .IllustItemThubExpand").slideDown(300,function(){vg&&vg.vgrefresh()}),$("#IllustItemText_"+c).css("max-height","none")):DispMsg(h.html);0<=h.tw_friendship&&(b[a]=h.tw_friendship)},error:function(h){console.log(h)}})}}var ShowAppendFile=generateShowAppendFile();
function TweetMyBox(b,a,c,d){b='<h2 class="TweetMyBoxTitle" style="padding: 10px 0 0 0;">'+c.TweetTitle+'</h2><h3 class="TweetMyBoxSubTitle">'+c.TweetStep1+'</h3><div class="TweetMyBoxInfo"><a class="BtnBase Selected TweetMyBoxBtn" href="'+a+'" target="_blank"><i class="fab fa-twitter"></i> '+c.TweetTweet+'</a><i class="fa fa-info-circle"></i> '+c.TweetInfo1+'</div><h3 class="TweetMyBoxSubTitle">'+c.TweetStep2+'</h3><div class="TweetMyBoxInfoStep2">'+c.TweetInfo2+'</div><div class="TweetMyBoxPinLink"><a href="/how_to/TwPinPcV.jsp" target="_blank">'+
c.TweetHowToPin+'</a></div><hr class="TweetMyBoxHr"/><h2 class="TweetMyBoxTitle">'+c.ShareURLTitle+'</h2><div><input id="MyBoxUrlTxt" type="text" readonly value="'+b+'"><a id="CopyMyBoxUrlBtn" class="BtnBase Selected" href="javascript:void(0);">'+c.ShareURLCopy+'</a></div><h2 class="TweetMyBoxTitle">'+c.ShareQRTitle+'</h2><div class="MyBoxQRCode"><div class="QRCode"><span id="QRCodeImg"></span>';d||(b+='<span class="DownloadMyBoxQR"><a id="DownloadMyBoxQRBtn" class="BtnBase Selected" href="javascript:void(0);">'+
c.ShareQRDownload+"</a></span>");Swal.fire({html:b+"</div></div>",showCloseButton:!0,showCancelButton:!1,showConfirmButton:!1,onOpen:function(){$("#QRCodeImg").qrcode({width:64,height:64,text:$("#MyBoxUrlTxt").val()});$("#CopyMyBoxUrlBtn").click(function(){$("#MyBoxUrlTxt").select();document.execCommand("Copy");alert(c.ShareURLCopied)});$("#DownloadMyBoxQRBtn").click(function(){var e=$("#QRCodeImg canvas")[0],g=document.createElement("a");g.href=e.toDataURL("image/png");g.download="poipiku_qrcode.png";
g.click()})}})};
