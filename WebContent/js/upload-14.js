var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.findInternal=function(a,d,b){a instanceof String&&(a=String(a));for(var h=a.length,k=0;k<h;k++){var f=a[k];if(d.call(b,f,k,a))return{i:k,v:f}}return{i:-1,v:void 0}};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,d,b){a!=Array.prototype&&a!=Object.prototype&&(a[d]=b.value)};
$jscomp.getGlobal=function(a){return"undefined"!=typeof window&&window===a?a:"undefined"!=typeof global&&null!=global?global:a};$jscomp.global=$jscomp.getGlobal(this);$jscomp.polyfill=function(a,d,b,h){if(d){b=$jscomp.global;a=a.split(".");for(h=0;h<a.length-1;h++){var k=a[h];k in b||(b[k]={});b=b[k]}a=a[a.length-1];h=b[a];d=d(h);d!=h&&null!=d&&$jscomp.defineProperty(b,a,{configurable:!0,writable:!0,value:d})}};
$jscomp.polyfill("Array.prototype.find",function(a){return a?a:function(a,b){return $jscomp.findInternal(this,a,b).v}},"es6","es3");var multiFileUploader=null;$.ajaxSetup({cache:!1});
(function(){var a=window.jQuery;a.paste=function(a){"undefined"!==typeof console&&null!==console&&console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");return k.mountNonInputable(a)._container};a.fn.pastableNonInputable=function(){var b;var c=0;for(b=this.length;c<b;c++){var g=this[c];g._pastable||a(g).is("textarea, input:text, [contenteditable]")||(k.mountNonInputable(g),g._pastable=!0)}return this};a.fn.pastableTextarea=function(){var b;var c=0;for(b=
this.length;c<b;c++){var g=this[c];g._pastable||a(g).is(":not(textarea, input:text)")||(k.mountTextarea(g),g._pastable=!0)}return this};a.fn.pastableContenteditable=function(){var b;var c=0;for(b=this.length;c<b;c++){var g=this[c];g._pastable||a(g).is(":not([contenteditable])")||(k.mountContenteditable(g),g._pastable=!0)}return this};var d=function(a,c){var b,l,d;null==c&&(c=512);if(!(b=a.match(/^data:([^;]+);base64,(.+)$/)))return null;a=b[1];var p=atob(b[2]);b=[];for(d=0;d<p.length;){var m=p.slice(d,
d+c);var f=Array(m.length);for(l=0;l<m.length;)f[l]=m.charCodeAt(l),l++;f=new Uint8Array(f);b.push(f);d+=c}return new Blob(b,{type:a})};var b=function(){return a(document.createElement("div")).attr("contenteditable",!0).attr("aria-hidden",!0).attr("tabindex",-1).css({width:1,height:1,position:"fixed",left:-100,overflow:"hidden",opacity:1E-17})};var h=function(b,c){var d=b.nodeName.toLowerCase();if("area"===d){c=b.parentNode;d=c.name;if(!b.href||!d||"map"!==c.nodeName.toLowerCase())return!1;b=a("img[usemap='#"+
d+"']");return 0<b.length&&b.is(":visible")}/^(input|select|textarea|button|object)$/.test(d)?(d=!b.disabled)&&(c=a(b).closest("fieldset")[0])&&(d=!c.disabled):d="a"===d?b.href||c:c;return(d=d||a(b).is("[contenteditable]"))&&a(b).is(":visible")};var k=function(){function f(b,d){this._container=b;this._target=d;this._container=a(this._container);this._target=a(this._target).addClass("pastable");this._container.on("paste",function(a){return function(b){var c,d,g;a.originalEvent=null!==b.originalEvent?
b.originalEvent:null;a._paste_event_fired=!0;if(null!=(null!=(c=b.originalEvent)?c.clipboardData:void 0)){var e=b.originalEvent.clipboardData;if(e.items){var h=null;a.originalEvent.pastedTypes=[];var f=e.items;var l=0;for(d=f.length;l<d;l++)c=f[l],c.type.match(/^text\/(plain|rtf|html)/)&&a.originalEvent.pastedTypes.push(c.type);var k=e.items;l=d=0;for(f=k.length;d<f;l=++d){c=k[l];if(c.type.match(/^image\//)){e=new FileReader;e.onload=function(b){return a._handleImage(b.target.result,a.originalEvent,
h)};try{e.readAsDataURL(c.getAsFile())}catch(u){}b.preventDefault();break}if("text/plain"===c.type){if(0===l&&1<e.items.length&&e.items[1].type.match(/^image\//)){var q=!0;var r=e.items[1].type}c.getAsString(function(b){return q?(h=b,a._target.trigger("pasteText",{text:b,isFilename:!0,fileType:r,originalEvent:a.originalEvent})):a._target.trigger("pasteText",{text:b,originalEvent:a.originalEvent})})}"text/rtf"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextRich",{text:b,originalEvent:a.originalEvent})});
"text/html"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextHtml",{text:b,originalEvent:a.originalEvent})})}}else{if(-1!==Array.prototype.indexOf.call(e.types,"text/plain")){var n=e.getData("Text");setTimeout(function(){return a._target.trigger("pasteText",{text:n,originalEvent:a.originalEvent})},1)}a._checkImagesInContainer(function(b){return a._handleImage(b,a.originalEvent)})}}if(e=window.clipboardData)if(null!=(g=n=e.getData("Text"))&&g.length)setTimeout(function(){a._target.trigger("pasteText",
{text:n,originalEvent:a.originalEvent});return a._target.trigger("_pasteCheckContainerDone")},1);else{e=e.files;g=0;for(c=e.length;g<c;g++)b=e[g],a._handleImage(URL.createObjectURL(b),a.originalEvent);a._checkImagesInContainer(function(a){})}return null}}(this))}f.prototype._target=null;f.prototype._container=null;f.mountNonInputable=function(c){var d=new f(b().appendTo(c),c);a(c).on("click",function(a){return function(a){if(!h(a.target,!1)&&!window.getSelection().toString())return d._container.focus()}}(this));
d._container.on("focus",function(b){return function(){return a(c).addClass("pastable-focus")}}(this));return d._container.on("blur",function(b){return function(){return a(c).removeClass("pastable-focus")}}(this))};f.mountTextarea=function(c){var d,h;if("undefined"!==typeof DataTransfer&&null!==DataTransfer&&DataTransfer.prototype&&null!=(d=Object.getOwnPropertyDescriptor)&&null!=(h=d.call(Object,DataTransfer.prototype,"items"))&&h.get)return this.mountContenteditable(c);var e=new f(b().insertBefore(c),
c);var k=!1;a(c).on("keyup",function(a){var b;if(17===(b=a.keyCode)||224===b)k=!1;return null});a(c).on("keydown",function(b){var d;if(17===(d=b.keyCode)||224===d)k=!0;null!=b.ctrlKey&&null!=b.metaKey&&(k=b.ctrlKey||b.metaKey);k&&86===b.keyCode&&(e._textarea_focus_stolen=!0,e._container.focus(),e._paste_event_fired=!1,setTimeout(function(b){return function(){if(!e._paste_event_fired)return a(c).focus(),e._textarea_focus_stolen=!1}}(this),1));return null});a(c).on("paste",function(a){return function(){}}(this));
a(c).on("focus",function(b){return function(){if(!e._textarea_focus_stolen)return a(c).addClass("pastable-focus")}}(this));a(c).on("blur",function(b){return function(){if(!e._textarea_focus_stolen)return a(c).removeClass("pastable-focus")}}(this));a(e._target).on("_pasteCheckContainerDone",function(b){return function(){a(c).focus();return e._textarea_focus_stolen=!1}}(this));return a(e._target).on("pasteText",function(b){return function(b,d){var e=a(c).prop("selectionStart");var g=a(c).prop("selectionEnd");
b=a(c).val();a(c).val(""+b.slice(0,e)+d.text+b.slice(g));a(c)[0].setSelectionRange(e+d.text.length,e+d.text.length);return a(c).trigger("change")}}(this))};f.mountContenteditable=function(b){new f(b,b);a(b).on("focus",function(d){return function(){return a(b).addClass("pastable-focus")}}(this));return a(b).on("blur",function(d){return function(){return a(b).removeClass("pastable-focus")}}(this))};f.prototype._handleImage=function(a,b,h){if(a.match(/^webkit\-fake\-url:\/\//))return this._target.trigger("pasteImageError",
{message:"You are trying to paste an image in Safari, however we are unable to retieve its data."});this._target.trigger("pasteImageStart");var c=new Image;c.crossOrigin="anonymous";c.onload=function(a){return function(){var e=document.createElement("canvas");e.width=c.width;e.height=c.height;e.getContext("2d").drawImage(c,0,0,e.width,e.height);var g=null;try{g=e.toDataURL("image/png");var f=d(g)}catch(t){}g&&a._target.trigger("pasteImage",{blob:f,dataURL:g,width:c.width,height:c.height,originalEvent:b,
name:h});return a._target.trigger("pasteImageEnd")}}(this);c.onerror=function(b){return function(){b._target.trigger("pasteImageError",{message:"Failed to get image from: "+a,url:a});return b._target.trigger("pasteImageEnd")}}(this);return c.src=a};f.prototype._checkImagesInContainer=function(b){var d;var c=Math.floor(1E3*Math.random());var e=this._container.find("img");var h=0;for(d=e.length;h<d;h++){var f=e[h];f["_paste_marked_"+c]=!0}return setTimeout(function(d){return function(){var e;var h=
d._container.find("img");var g=0;for(e=h.length;g<e;g++)f=h[g],f["_paste_marked_"+c]||(b(f.src),a(f).remove());return d._target.trigger("_pasteCheckContainerDone")}}(this),1)};return f}()}).call(this);function DispDescCharNum(){var a=200-$("#EditDescription").val().length;$("#DescriptionCharNum").html(a)}function OnChangeTab(a){setCookie("MOD",a);window.location.href=0==a?"/UploadFilePcV.jsp":"/UploadPastePcV.jsp"}function setTweetSetting(a){setLocalStrage("upload_tweet",a)}
function getTweetSetting(){return getLocalStrage("upload_tweet")?!0:!1}function setTweetImageSetting(a){setLocalStrage("upload_tweet_image",a)}function getTweetImageSetting(){return getLocalStrage("upload_tweet_image")?!0:!1}function setLastCategorySetting(a){setLocalStrage("last_category",a)}function getLastCategorySetting(){return getLocalStrage("last_category")}
function updateTweetButton(){$("#OptionTweet").prop("checked")?($("#ImageSwitch .OptionLabel").removeClass("disabled"),$("#ImageSwitch .onoffswitch").removeClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!1)):($("#ImageSwitch .OptionLabel").addClass("disabled"),$("#ImageSwitch .onoffswitch").addClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!0))}
function updateOneCushionButton(){$("#OptionOneCushion").prop("checked")?($("#R18Switch .OptionLabel").removeClass("disabled"),$("#R18Switch .onoffswitch").removeClass("disabled"),$("#OptionR18:checkbox").prop("disabled",!1)):($("#R18Switch .OptionLabel").addClass("disabled"),$("#R18Switch .onoffswitch").addClass("disabled"),$("#OptionR18:checkbox").prop("disabled",!0))}
function initUploadFile(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==a&&$("#EditCategory").val(a)});updateOneCushionButton();updateTweetButton();multiFileUploader=new qq.FineUploader({element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg",
"jpg","gif","png"],itemLimit:200,sizeLimit:2E7,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(a,b){this.first_file?(this.first_file=!1,this.setEndpoint("/f/UploadFileFirstF.jsp",a),console.log("UploadFileFirstF")):(this.setEndpoint("/f/UploadFileAppendF.jsp",a),console.log("UploadFileAppendF"));this.setParams({UID:this.user_id,IID:this.illust_id,REC:this.recent},a)},onAllComplete:function(a,b){console.log("onAllComplete",a,b,this.tweet);1==this.tweet?$.ajax({type:"post",
data:{UID:this.user_id,IID:this.illust_id,IMG:this.tweet_image},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):(completeMsg(),setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3))},onValidate:function(a){var b=this.getSubmittedSize(),d=this.getSubmittedNum();this.showTotalSize(b,d);b+=a.size;if(b>this.total_size)return!1;this.showTotalSize(b,d+1)},onStatusChange:function(a,
b,h){this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};multiFileUploader.getSubmittedSize=function(){var a=this.getUploads({status:qq.status.SUBMITTED}),b=0;$.each(a,function(){b+=this.size});return b};multiFileUploader.showTotalSize=function(a,b){var d="(jpeg|png|gif, 200files, total 50MByte)";0<a&&(d="("+b+"/200,  "+Math.ceil((multiFileUploader.total_size-a)/1024)+" KByte)",
$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(d)};multiFileUploader.total_size=52428800}
function UploadFile(a){if(multiFileUploader&&!(0>=multiFileUploader.getSubmittedNum())){var d=$("#EditCategory").val(),b=$.trim($("#EditDescription").val());b=b.substr(0,200);var h=$("#OptionRecent").prop("checked")?1:0,k=$("#OptionOneCushion").prop("checked")?2:0;0<k&&(k=$("#OptionR18").prop("checked")?4:2);var f=$("#OptionTweet").prop("checked")?1:0,c=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));
setLastCategorySetting(d);startMsg();console.log("start upload");$.ajaxSingle({type:"post",data:{UID:a,CAT:d,SAF:k,DES:b},url:"/f/UploadFileReferenceF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF");b&&b.content_id&&(0<b.content_id?(multiFileUploader.first_file=!0,multiFileUploader.user_id=a,multiFileUploader.illust_id=b.content_id,multiFileUploader.recent=h,multiFileUploader.tweet=f,multiFileUploader.tweet_image=c,multiFileUploader.uploadStoredFiles()):errorMsg())}})}}
var g_strPasteMsg="";
function initUploadPaste(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==a&&$("#EditCategory").val(a)});updateOneCushionButton();updateTweetButton();g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(a,b){10>$(".InputFile").length&&(a=
createPasteElm(b.dataURL),$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){$("#TimeLineAddImage").html(g_strPasteMsg)})}
function createPasteElm(a){var d=$("<div />").addClass("InputFile"),b=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);d.append(b).append(a);return d}
function initPasteElm(a){a.on("pasteImage",function(a,b){$(".OrgMessage",this).hide();$(".imgView",this).attr("src",b.dataURL).show()}).on("pasteImageError",function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){})}function updatePasteNum(){strTotal="("+$(".InputFile").length+"/10)";$("#TotalSize").html(strTotal)}
function UploadPaste(a){var d=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&d++});console.log(d);if(!(0>=d)){startMsg();var b=$("#EditCategory").val(),h=$.trim($("#EditDescription").val());h=h.substr(0,200);var k=$("#OptionRecent").prop("checked")?1:0,f=$("#OptionOneCushion").prop("checked")?2:0;0<f&&(f=$("#OptionR18").prop("checked")?4:2);var c=$("#OptionTweet").prop("checked")?1:0,g=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));
setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(b);$.ajaxSingle({type:"post",data:{UID:a,CAT:b,SAF:f,DES:h},url:"/f/UploadFileReferenceF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF",b.content_id);var d=!0;$(".imgView").each(function(){$(this).parent().addClass("Done");var c=$(this).attr("src").replace("data:image/png;base64,","");if(0>=c.length)return!0;d?(d=!1,$.ajax({type:"post",data:{UID:a,IID:b.content_id,REC:k,DATA:c},url:"/f/UploadPasteFirstF.jsp",
dataType:"json",async:!1,success:function(a){console.log("UploadPasteFirstF")}})):$.ajax({type:"post",data:{UID:a,IID:b.content_id,DATA:c},url:"/f/UploadPasteAppendF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteAppendF")}})});1==c?$.ajax({type:"post",data:{UID:a,IID:b.content_id,IMG:g},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):setTimeout(function(){location.href=
"/MyHomePcV.jsp"},1E3)}});return!1}};
