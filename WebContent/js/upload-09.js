var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.findInternal=function(a,b,d){a instanceof String&&(a=String(a));for(var h=a.length,g=0;g<h;g++){var k=a[g];if(b.call(d,k,g,a))return{i:g,v:k}}return{i:-1,v:void 0}};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,b,d){a!=Array.prototype&&a!=Object.prototype&&(a[b]=d.value)};
$jscomp.getGlobal=function(a){return"undefined"!=typeof window&&window===a?a:"undefined"!=typeof global&&null!=global?global:a};$jscomp.global=$jscomp.getGlobal(this);$jscomp.polyfill=function(a,b,d,h){if(b){d=$jscomp.global;a=a.split(".");for(h=0;h<a.length-1;h++){var g=a[h];g in d||(d[g]={});d=d[g]}a=a[a.length-1];h=d[a];b=b(h);b!=h&&null!=b&&$jscomp.defineProperty(d,a,{configurable:!0,writable:!0,value:b})}};
$jscomp.polyfill("Array.prototype.find",function(a){return a?a:function(a,d){return $jscomp.findInternal(this,a,d).v}},"es6","es3");var multiFileUploader=null;$.ajaxSetup({cache:!1});
(function(){var a=window.jQuery;a.paste=function(a){"undefined"!==typeof console&&null!==console&&console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");return g.mountNonInputable(a)._container};a.fn.pastableNonInputable=function(){var b;var c=0;for(b=this.length;c<b;c++){var e=this[c];e._pastable||a(e).is("textarea, input:text, [contenteditable]")||(g.mountNonInputable(e),e._pastable=!0)}return this};a.fn.pastableTextarea=function(){var b;var c=0;for(b=
this.length;c<b;c++){var e=this[c];e._pastable||a(e).is(":not(textarea, input:text)")||(g.mountTextarea(e),e._pastable=!0)}return this};a.fn.pastableContenteditable=function(){var b;var c=0;for(b=this.length;c<b;c++){var e=this[c];e._pastable||a(e).is(":not([contenteditable])")||(g.mountContenteditable(e),e._pastable=!0)}return this};var b=function(a,c){var e,b,f;null==c&&(c=512);if(!(e=a.match(/^data:([^;]+);base64,(.+)$/)))return null;a=e[1];var d=atob(e[2]);e=[];for(f=0;f<d.length;){var l=d.slice(f,
f+c);var k=Array(l.length);for(b=0;b<l.length;)k[b]=l.charCodeAt(b),b++;k=new Uint8Array(k);e.push(k);f+=c}return new Blob(e,{type:a})};var d=function(){return a(document.createElement("div")).attr("contenteditable",!0).attr("aria-hidden",!0).attr("tabindex",-1).css({width:1,height:1,position:"fixed",left:-100,overflow:"hidden",opacity:1E-17})};var h=function(b,c){var e=b.nodeName.toLowerCase();if("area"===e){c=b.parentNode;e=c.name;if(!b.href||!e||"map"!==c.nodeName.toLowerCase())return!1;b=a("img[usemap='#"+
e+"']");return 0<b.length&&b.is(":visible")}/^(input|select|textarea|button|object)$/.test(e)?(e=!b.disabled)&&(c=a(b).closest("fieldset")[0])&&(e=!c.disabled):e="a"===e?b.href||c:c;return(e=e||a(b).is("[contenteditable]"))&&a(b).is(":visible")};var g=function(){function k(b,e){this._container=b;this._target=e;this._container=a(this._container);this._target=a(this._target).addClass("pastable");this._container.on("paste",function(a){return function(b){var c,e,d;a.originalEvent=null!==b.originalEvent?
b.originalEvent:null;a._paste_event_fired=!0;if(null!=(null!=(c=b.originalEvent)?c.clipboardData:void 0)){var f=b.originalEvent.clipboardData;if(f.items){var k=null;a.originalEvent.pastedTypes=[];var g=f.items;var h=0;for(e=g.length;h<e;h++)c=g[h],c.type.match(/^text\/(plain|rtf|html)/)&&a.originalEvent.pastedTypes.push(c.type);var n=f.items;h=e=0;for(g=n.length;e<g;h=++e){c=n[h];if(c.type.match(/^image\//)){f=new FileReader;f.onload=function(c){return a._handleImage(c.target.result,a.originalEvent,
k)};try{f.readAsDataURL(c.getAsFile())}catch(t){}b.preventDefault();break}if("text/plain"===c.type){if(0===h&&1<f.items.length&&f.items[1].type.match(/^image\//)){var p=!0;var q=f.items[1].type}c.getAsString(function(c){return p?(k=c,a._target.trigger("pasteText",{text:c,isFilename:!0,fileType:q,originalEvent:a.originalEvent})):a._target.trigger("pasteText",{text:c,originalEvent:a.originalEvent})})}"text/rtf"===c.type&&c.getAsString(function(c){return a._target.trigger("pasteTextRich",{text:c,originalEvent:a.originalEvent})});
"text/html"===c.type&&c.getAsString(function(c){return a._target.trigger("pasteTextHtml",{text:c,originalEvent:a.originalEvent})})}}else{if(-1!==Array.prototype.indexOf.call(f.types,"text/plain")){var m=f.getData("Text");setTimeout(function(){return a._target.trigger("pasteText",{text:m,originalEvent:a.originalEvent})},1)}a._checkImagesInContainer(function(c){return a._handleImage(c,a.originalEvent)})}}if(f=window.clipboardData)if(null!=(d=m=f.getData("Text"))&&d.length)setTimeout(function(){a._target.trigger("pasteText",
{text:m,originalEvent:a.originalEvent});return a._target.trigger("_pasteCheckContainerDone")},1);else{f=f.files;d=0;for(c=f.length;d<c;d++)b=f[d],a._handleImage(URL.createObjectURL(b),a.originalEvent);a._checkImagesInContainer(function(a){})}return null}}(this))}k.prototype._target=null;k.prototype._container=null;k.mountNonInputable=function(c){var b=new k(d().appendTo(c),c);a(c).on("click",function(a){return function(a){if(!h(a.target,!1)&&!window.getSelection().toString())return b._container.focus()}}(this));
b._container.on("focus",function(b){return function(){return a(c).addClass("pastable-focus")}}(this));return b._container.on("blur",function(b){return function(){return a(c).removeClass("pastable-focus")}}(this))};k.mountTextarea=function(c){var b,h;if("undefined"!==typeof DataTransfer&&null!==DataTransfer&&DataTransfer.prototype&&null!=(b=Object.getOwnPropertyDescriptor)&&null!=(h=b.call(Object,DataTransfer.prototype,"items"))&&h.get)return this.mountContenteditable(c);var f=new k(d().insertBefore(c),
c);var g=!1;a(c).on("keyup",function(a){var c;if(17===(c=a.keyCode)||224===c)g=!1;return null});a(c).on("keydown",function(b){var e;if(17===(e=b.keyCode)||224===e)g=!0;null!=b.ctrlKey&&null!=b.metaKey&&(g=b.ctrlKey||b.metaKey);g&&86===b.keyCode&&(f._textarea_focus_stolen=!0,f._container.focus(),f._paste_event_fired=!1,setTimeout(function(b){return function(){if(!f._paste_event_fired)return a(c).focus(),f._textarea_focus_stolen=!1}}(this),1));return null});a(c).on("paste",function(a){return function(){}}(this));
a(c).on("focus",function(b){return function(){if(!f._textarea_focus_stolen)return a(c).addClass("pastable-focus")}}(this));a(c).on("blur",function(b){return function(){if(!f._textarea_focus_stolen)return a(c).removeClass("pastable-focus")}}(this));a(f._target).on("_pasteCheckContainerDone",function(b){return function(){a(c).focus();return f._textarea_focus_stolen=!1}}(this));return a(f._target).on("pasteText",function(b){return function(b,e){var f=a(c).prop("selectionStart");var d=a(c).prop("selectionEnd");
b=a(c).val();a(c).val(""+b.slice(0,f)+e.text+b.slice(d));a(c)[0].setSelectionRange(f+e.text.length,f+e.text.length);return a(c).trigger("change")}}(this))};k.mountContenteditable=function(b){new k(b,b);a(b).on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return a(b).on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};k.prototype._handleImage=function(a,e,d){if(a.match(/^webkit\-fake\-url:\/\//))return this._target.trigger("pasteImageError",
{message:"You are trying to paste an image in Safari, however we are unable to retieve its data."});this._target.trigger("pasteImageStart");var c=new Image;c.crossOrigin="anonymous";c.onload=function(a){return function(){var f=document.createElement("canvas");f.width=c.width;f.height=c.height;f.getContext("2d").drawImage(c,0,0,f.width,f.height);var g=null;try{g=f.toDataURL("image/png");var h=b(g)}catch(r){}g&&a._target.trigger("pasteImage",{blob:h,dataURL:g,width:c.width,height:c.height,originalEvent:e,
name:d});return a._target.trigger("pasteImageEnd")}}(this);c.onerror=function(b){return function(){b._target.trigger("pasteImageError",{message:"Failed to get image from: "+a,url:a});return b._target.trigger("pasteImageEnd")}}(this);return c.src=a};k.prototype._checkImagesInContainer=function(b){var c;var d=Math.floor(1E3*Math.random());var f=this._container.find("img");var g=0;for(c=f.length;g<c;g++){var h=f[g];h["_paste_marked_"+d]=!0}return setTimeout(function(c){return function(){var e;var f=
c._container.find("img");var g=0;for(e=f.length;g<e;g++)h=f[g],h["_paste_marked_"+d]||(b(h.src),a(h).remove());return c._target.trigger("_pasteCheckContainerDone")}}(this),1)};return k}()}).call(this);function DispDescCharNum(){var a=200-$("#EditDescription").val().length;$("#DescriptionCharNum").html(a)}function OnChangeTab(a){setCookie("MOD",a);window.location.href=0==a?"/UploadFilePcV.jsp":"/UploadPastePcV.jsp"}function setTweetSetting(a){setLocalStrage("upload_tweet",a)}
function getTweetSetting(){return getLocalStrage("upload_tweet")?!0:!1}function setTweetImageSetting(a){setLocalStrage("upload_tweet_image",a)}function getTweetImageSetting(){return getLocalStrage("upload_tweet_image")?!0:!1}function setLastCategorySetting(a){setLocalStrage("last_category",a)}function getLastCategorySetting(){var a=getLocalStrage("last_category");a||(a=0);return a}
function updateTweetButton(){$("#OptionTweet").prop("checked")?($("#ImageSwitch .OptionLabel").removeClass("disabled"),$("#ImageSwitch .onoffswitch").removeClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!1)):($("#ImageSwitch .OptionLabel").addClass("disabled"),$("#ImageSwitch .onoffswitch").addClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!0))}
function updateOneCushionButton(){$("#OptionOneCushion").prop("checked")?($("#R18Switch .OptionLabel").removeClass("disabled"),$("#R18Switch .onoffswitch").removeClass("disabled"),$("#OptionR18:checkbox").prop("disabled",!1)):($("#R18Switch .OptionLabel").addClass("disabled"),$("#R18Switch .onoffswitch").addClass("disabled"),$("#OptionR18:checkbox").prop("disabled",!0))}
function initUploadFile(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());console.log(getLastCategorySetting());$("#EditCategory").val(getLastCategorySetting());updateOneCushionButton();updateTweetButton();multiFileUploader=new qq.FineUploader({element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg","jpg","gif","png"],itemLimit:200,
sizeLimit:2E7,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(a,b){this.first_file?(this.first_file=!1,this.setEndpoint("/f/UploadFileFirstF.jsp",a),console.log("UploadFileFirstF")):(this.setEndpoint("/f/UploadFileAppendF.jsp",a),console.log("UploadFileAppendF"));this.setParams({UID:this.user_id,IID:this.illust_id,REC:this.recent},a)},onAllComplete:function(a,b){console.log("onAllComplete",a,b,this.tweet);1==this.tweet?$.ajax({type:"post",data:{UID:this.user_id,IID:this.illust_id,
IMG:this.tweet_image},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):(completeMsg(),setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3))},onValidate:function(a){var b=this.getSubmittedSize(),d=this.getSubmittedNum();this.showTotalSize(b,d);b+=a.size;if(b>this.total_size)return!1;this.showTotalSize(b,d+1)},onStatusChange:function(a,b,d){this.showTotalSize(this.getSubmittedSize(),
this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};multiFileUploader.getSubmittedSize=function(){var a=this.getUploads({status:qq.status.SUBMITTED}),b=0;$.each(a,function(){b+=this.size});return b};multiFileUploader.showTotalSize=function(a,b){var d="(jpeg|png|gif, 200files, total 50MByte)";0<a&&(d="("+b+"/200,  "+Math.ceil((multiFileUploader.total_size-a)/1024)+" KByte)",$("#TimeLineAddImage").removeClass("Light"),
completeAddFile());$("#TotalSize").html(d)};multiFileUploader.total_size=52428800}
function UploadFile(a){if(multiFileUploader&&!(0>=multiFileUploader.getSubmittedNum())){var b=$("#EditCategory").val(),d=$.trim($("#EditDescription").val());d=d.substr(0,200);var h=$("#OptionRecent").prop("checked")?1:0,g=$("#OptionOneCushion").prop("checked")?2:0;0<g&&(g=$("#OptionR18").prop("checked")?4:2);var k=$("#OptionTweet").prop("checked")?1:0,c=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));
setLastCategorySetting(b);startMsg();console.log("start upload");$.ajaxSingle({type:"post",data:{UID:a,CAT:b,SAF:g,DES:d},url:"/f/UploadFileReferenceF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF");b&&b.content_id&&(0<b.content_id?(multiFileUploader.first_file=!0,multiFileUploader.user_id=a,multiFileUploader.illust_id=b.content_id,multiFileUploader.recent=h,multiFileUploader.tweet=k,multiFileUploader.tweet_image=c,multiFileUploader.uploadStoredFiles()):errorMsg())}})}}
var g_strPasteMsg="";
function initUploadPaste(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());$("#EditCategory").val(getLastCategorySetting());updateOneCushionButton();updateTweetButton();g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(a,b){10>$(".InputFile").length&&(a=createPasteElm(b.dataURL),$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",
function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){$("#TimeLineAddImage").html(g_strPasteMsg)})}function createPasteElm(a){var b=$("<div />").addClass("InputFile"),d=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);b.append(d).append(a);return b}
function initPasteElm(a){a.on("pasteImage",function(a,d){$(".OrgMessage",this).hide();$(".imgView",this).attr("src",d.dataURL).show()}).on("pasteImageError",function(a,d){d.url&&alert("error data : "+d.url)}).on("pasteText",function(a,d){})}function updatePasteNum(){strTotal="("+$(".InputFile").length+"/10)";$("#TotalSize").html(strTotal)}
function UploadPaste(a){var b=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&b++});console.log(b);if(!(0>=b)){startMsg();var d=$("#EditCategory").val(),h=$.trim($("#EditDescription").val());h=h.substr(0,200);var g=$("#OptionRecent").prop("checked")?1:0,k=$("#OptionOneCushion").prop("checked")?2:0;0<k&&(k=$("#OptionR18").prop("checked")?4:2);$("#OptionTweet").prop("checked");var c=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));
setLastCategorySetting(d);$.ajaxSingle({type:"post",data:{UID:a,CAT:d,SAF:k,DES:h},url:"/f/UploadFileReferenceF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF",b.content_id);var d=!0;$(".imgView").each(function(){$(this).parent().addClass("Done");var c=$(this).attr("src").replace("data:image/png;base64,","");if(0>=c.length)return!0;d?(d=!1,$.ajax({type:"post",data:{UID:a,IID:b.content_id,REC:g,DATA:c},url:"/f/UploadPasteFirstF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteFirstF")}})):
$.ajax({type:"post",data:{UID:a,IID:b.content_id,DATA:c},url:"/f/UploadPasteAppendF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteAppendF")}})});$.ajax({type:"post",data:{UID:a,IID:b.content_id,IMG:c},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}})}});return!1}};
