var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.findInternal=function(a,d,b){a instanceof String&&(a=String(a));for(var h=a.length,g=0;g<h;g++){var l=a[g];if(d.call(b,l,g,a))return{i:g,v:l}}return{i:-1,v:void 0}};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.SIMPLE_FROUND_POLYFILL=!1;
$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,d,b){a!=Array.prototype&&a!=Object.prototype&&(a[d]=b.value)};$jscomp.getGlobal=function(a){return"undefined"!=typeof window&&window===a?a:"undefined"!=typeof global&&null!=global?global:a};$jscomp.global=$jscomp.getGlobal(this);
$jscomp.polyfill=function(a,d,b,h){if(d){b=$jscomp.global;a=a.split(".");for(h=0;h<a.length-1;h++){var g=a[h];g in b||(b[g]={});b=b[g]}a=a[a.length-1];h=b[a];d=d(h);d!=h&&null!=d&&$jscomp.defineProperty(b,a,{configurable:!0,writable:!0,value:d})}};$jscomp.polyfill("Array.prototype.find",function(a){return a?a:function(a,b){return $jscomp.findInternal(this,a,b).v}},"es6","es3");var multiFileUploader=null;$.ajaxSetup({cache:!1});
(function(){var a=window.jQuery;a.paste=function(a){"undefined"!==typeof console&&null!==console&&console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");return g.mountNonInputable(a)._container};a.fn.pastableNonInputable=function(){var b;var c=0;for(b=this.length;c<b;c++){var f=this[c];f._pastable||a(f).is("textarea, input:text, [contenteditable]")||(g.mountNonInputable(f),f._pastable=!0)}return this};a.fn.pastableTextarea=function(){var b;var c=0;for(b=
this.length;c<b;c++){var f=this[c];f._pastable||a(f).is(":not(textarea, input:text)")||(g.mountTextarea(f),f._pastable=!0)}return this};a.fn.pastableContenteditable=function(){var b;var c=0;for(b=this.length;c<b;c++){var f=this[c];f._pastable||a(f).is(":not([contenteditable])")||(g.mountContenteditable(f),f._pastable=!0)}return this};var d=function(a,c){var b,k,e;null==c&&(c=512);if(!(b=a.match(/^data:([^;]+);base64,(.+)$/)))return null;a=b[1];var d=atob(b[2]);b=[];for(e=0;e<d.length;){var p=d.slice(e,
e+c);var n=Array(p.length);for(k=0;k<p.length;)n[k]=p.charCodeAt(k),k++;n=new Uint8Array(n);b.push(n);e+=c}return new Blob(b,{type:a})};var b=function(){return a(document.createElement("div")).attr("contenteditable",!0).attr("aria-hidden",!0).attr("tabindex",-1).css({width:1,height:1,position:"fixed",left:-100,overflow:"hidden",opacity:1E-17})};var h=function(b,c){var f=b.nodeName.toLowerCase();if("area"===f){c=b.parentNode;f=c.name;if(!b.href||!f||"map"!==c.nodeName.toLowerCase())return!1;b=a("img[usemap='#"+
f+"']");return 0<b.length&&b.is(":visible")}/^(input|select|textarea|button|object)$/.test(f)?(f=!b.disabled)&&(c=a(b).closest("fieldset")[0])&&(f=!c.disabled):f="a"===f?b.href||c:c;return(f=f||a(b).is("[contenteditable]"))&&a(b).is(":visible")};var g=function(){function g(b,f){this._container=b;this._target=f;this._container=a(this._container);this._target=a(this._target).addClass("pastable");this._container.on("paste",function(a){return function(b){var c,f,d;a.originalEvent=null!==b.originalEvent?
b.originalEvent:null;a._paste_event_fired=!0;if(null!=(null!=(c=b.originalEvent)?c.clipboardData:void 0)){var e=b.originalEvent.clipboardData;if(e.items){var g=null;a.originalEvent.pastedTypes=[];var h=e.items;var k=0;for(f=h.length;k<f;k++)c=h[k],c.type.match(/^text\/(plain|rtf|html)/)&&a.originalEvent.pastedTypes.push(c.type);var l=e.items;k=f=0;for(h=l.length;f<h;k=++f){c=l[k];if(c.type.match(/^image\//)){e=new FileReader;e.onload=function(b){return a._handleImage(b.target.result,a.originalEvent,
g)};try{e.readAsDataURL(c.getAsFile())}catch(v){}b.preventDefault();break}if("text/plain"===c.type){if(0===k&&1<e.items.length&&e.items[1].type.match(/^image\//)){var r=!0;var t=e.items[1].type}c.getAsString(function(b){return r?(g=b,a._target.trigger("pasteText",{text:b,isFilename:!0,fileType:t,originalEvent:a.originalEvent})):a._target.trigger("pasteText",{text:b,originalEvent:a.originalEvent})})}"text/rtf"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextRich",{text:b,originalEvent:a.originalEvent})});
"text/html"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextHtml",{text:b,originalEvent:a.originalEvent})})}}else{if(-1!==Array.prototype.indexOf.call(e.types,"text/plain")){var q=e.getData("Text");setTimeout(function(){return a._target.trigger("pasteText",{text:q,originalEvent:a.originalEvent})},1)}a._checkImagesInContainer(function(b){return a._handleImage(b,a.originalEvent)})}}if(e=window.clipboardData)if(null!=(d=q=e.getData("Text"))&&d.length)setTimeout(function(){a._target.trigger("pasteText",
{text:q,originalEvent:a.originalEvent});return a._target.trigger("_pasteCheckContainerDone")},1);else{e=e.files;d=0;for(c=e.length;d<c;d++)b=e[d],a._handleImage(URL.createObjectURL(b),a.originalEvent);a._checkImagesInContainer(function(a){})}return null}}(this))}g.prototype._target=null;g.prototype._container=null;g.mountNonInputable=function(c){var d=new g(b().appendTo(c),c);a(c).on("click",function(a){return function(a){if(!h(a.target,!1)&&!window.getSelection().toString())return d._container.focus()}}(this));
d._container.on("focus",function(b){return function(){return a(c).addClass("pastable-focus")}}(this));return d._container.on("blur",function(b){return function(){return a(c).removeClass("pastable-focus")}}(this))};g.mountTextarea=function(c){var d,h;if("undefined"!==typeof DataTransfer&&null!==DataTransfer&&DataTransfer.prototype&&null!=(d=Object.getOwnPropertyDescriptor)&&null!=(h=d.call(Object,DataTransfer.prototype,"items"))&&h.get)return this.mountContenteditable(c);var e=new g(b().insertBefore(c),
c);var m=!1;a(c).on("keyup",function(a){var b;if(17===(b=a.keyCode)||224===b)m=!1;return null});a(c).on("keydown",function(b){var d;if(17===(d=b.keyCode)||224===d)m=!0;null!=b.ctrlKey&&null!=b.metaKey&&(m=b.ctrlKey||b.metaKey);m&&86===b.keyCode&&(e._textarea_focus_stolen=!0,e._container.focus(),e._paste_event_fired=!1,setTimeout(function(b){return function(){if(!e._paste_event_fired)return a(c).focus(),e._textarea_focus_stolen=!1}}(this),1));return null});a(c).on("paste",function(a){return function(){}}(this));
a(c).on("focus",function(b){return function(){if(!e._textarea_focus_stolen)return a(c).addClass("pastable-focus")}}(this));a(c).on("blur",function(b){return function(){if(!e._textarea_focus_stolen)return a(c).removeClass("pastable-focus")}}(this));a(e._target).on("_pasteCheckContainerDone",function(b){return function(){a(c).focus();return e._textarea_focus_stolen=!1}}(this));return a(e._target).on("pasteText",function(b){return function(b,d){var e=a(c).prop("selectionStart");var f=a(c).prop("selectionEnd");
b=a(c).val();a(c).val(""+b.slice(0,e)+d.text+b.slice(f));a(c)[0].setSelectionRange(e+d.text.length,e+d.text.length);return a(c).trigger("change")}}(this))};g.mountContenteditable=function(b){new g(b,b);a(b).on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return a(b).on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};g.prototype._handleImage=function(a,b,g){if(a.match(/^webkit\-fake\-url:\/\//))return this._target.trigger("pasteImageError",
{message:"You are trying to paste an image in Safari, however we are unable to retieve its data."});this._target.trigger("pasteImageStart");var c=new Image;c.crossOrigin="anonymous";c.onload=function(a){return function(){var e=document.createElement("canvas");e.width=c.width;e.height=c.height;e.getContext("2d").drawImage(c,0,0,e.width,e.height);var f=null;try{f=e.toDataURL("image/png");var h=d(f)}catch(u){}f&&a._target.trigger("pasteImage",{blob:h,dataURL:f,width:c.width,height:c.height,originalEvent:b,
name:g});return a._target.trigger("pasteImageEnd")}}(this);c.onerror=function(b){return function(){b._target.trigger("pasteImageError",{message:"Failed to get image from: "+a,url:a});return b._target.trigger("pasteImageEnd")}}(this);return c.src=a};g.prototype._checkImagesInContainer=function(b){var c;var d=Math.floor(1E3*Math.random());var e=this._container.find("img");var g=0;for(c=e.length;g<c;g++){var h=e[g];h["_paste_marked_"+d]=!0}return setTimeout(function(c){return function(){var e;var f=
c._container.find("img");var g=0;for(e=f.length;g<e;g++)h=f[g],h["_paste_marked_"+d]||(b(h.src),a(h).remove());return c._target.trigger("_pasteCheckContainerDone")}}(this),1)};return g}()}).call(this);function DispDescCharNum(){var a=200-$("#EditDescription").val().length;$("#DescriptionCharNum").html(a)}function DispTagListCharNum(){var a=100-$("#EditTagList").val().length;$("#EditTagListCharNum").html(a)}
function OnChangeTab(a){setCookie("MOD",a);window.location.href=0==a?"/UploadFilePcV.jsp":"/UploadPastePcV.jsp"}function setTweetSetting(a){setLocalStrage("upload_tweet",a)}function getTweetSetting(){return getLocalStrage("upload_tweet")?!0:!1}function setTweetImageSetting(a){setLocalStrage("upload_tweet_image",a)}function getTweetImageSetting(){return getLocalStrage("upload_tweet_image")?!0:!1}function setLastCategorySetting(a){setLocalStrage("last_category",a)}
function getLastCategorySetting(){return getLocalStrage("last_category")}function updateTweetButton(){$("#OptionTweet").prop("checked")?($("#ImageSwitch .OptionLabel").removeClass("disabled"),$("#ImageSwitch .onoffswitch").removeClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!1)):($("#ImageSwitch .OptionLabel").addClass("disabled"),$("#ImageSwitch .onoffswitch").addClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!0))}
function updatePublish(){4==$("#EditPublish").val()?$("#ItemPassword").slideDown(300):$("#ItemPassword").slideUp(300)}
function initUploadFile(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==a&&$("#EditCategory").val(a)});updateTweetButton();multiFileUploader=new qq.FineUploader({element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg",
"jpg","gif","png"],itemLimit:200,sizeLimit:2E7,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(a,b){this.first_file?(this.first_file=!1,this.setEndpoint("/f/UploadFileFirstF.jsp",a),console.log("UploadFileFirstF")):(this.setEndpoint("/f/UploadFileAppendF.jsp",a),console.log("UploadFileAppendF"));this.setParams({UID:this.user_id,IID:this.illust_id,REC:this.recent},a)},onAllComplete:function(a,b){console.log("onAllComplete",a,b,this.tweet);1==this.tweet?$.ajax({type:"post",
data:{UID:this.user_id,IID:this.illust_id,IMG:this.tweet_image},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):(completeMsg(),setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3))},onValidate:function(a){var b=this.getSubmittedSize(),d=this.getSubmittedNum();this.showTotalSize(b,d);b+=a.size;if(b>this.total_size)return!1;this.showTotalSize(b,d+1)},onStatusChange:function(a,
b,h){this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};multiFileUploader.getSubmittedSize=function(){var a=this.getUploads({status:qq.status.SUBMITTED}),b=0;$.each(a,function(){b+=this.size});return b};multiFileUploader.showTotalSize=function(a,b){var d="(jpeg|png|gif, 200files, total 50MByte)";0<a&&(d="("+b+"/200,  "+Math.ceil((multiFileUploader.total_size-a)/1024)+" KByte)",
$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(d)};multiFileUploader.total_size=52428800}
function UploadFile(a){if(multiFileUploader&&!(0>=multiFileUploader.getSubmittedNum())){var d=$("#EditCategory").val(),b=$.trim($("#EditDescription").val());b=b.substr(0,200);var h=$.trim($("#EditTagList").val());h=h.substr(0,100);var g=$("#EditPublish").val(),l=$("#EditPassword").val(),c=$("#OptionRecent").prop("checked")?1:0,f=$("#OptionTweet").prop("checked")?1:0,k=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));
setLastCategorySetting(d);99==g&&(c=2,f=0);startMsg();console.log("start upload");$.ajaxSingle({type:"post",data:{UID:a,CAT:d,DES:b,TAG:h,PID:g,PPW:l,PLD:""},url:"/f/UploadFileRefTwitterF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF");b&&b.content_id&&(0<b.content_id?(multiFileUploader.first_file=!0,multiFileUploader.user_id=a,multiFileUploader.illust_id=b.content_id,multiFileUploader.recent=c,multiFileUploader.tweet=f,multiFileUploader.tweet_image=k,multiFileUploader.uploadStoredFiles()):
errorMsg())}})}}var g_strPasteMsg="";
function initUploadPaste(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==a&&$("#EditCategory").val(a)});updateTweetButton();g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(a,b){10>$(".InputFile").length&&(a=createPasteElm(b.dataURL),
$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){$("#TimeLineAddImage").html(g_strPasteMsg)})}
function createPasteElm(a){var d=$("<div />").addClass("InputFile"),b=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);d.append(b).append(a);return d}
function initPasteElm(a){a.on("pasteImage",function(a,b){$(".OrgMessage",this).hide();$(".imgView",this).attr("src",b.dataURL).show()}).on("pasteImageError",function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){})}function updatePasteNum(){strTotal="("+$(".InputFile").length+"/10)";$("#TotalSize").html(strTotal)}
function UploadPaste(a){var d=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&d++});console.log(d);if(!(0>=d)){var b=$("#EditCategory").val(),h=$.trim($("#EditDescription").val());h=h.substr(0,200);var g=$.trim($("#EditTagList").val());g=g.substr(0,100);var l=$("#EditPublish").val(),c=$("#EditPassword").val(),f=$("#OptionRecent").prop("checked")?1:0,k=$("#OptionTweet").prop("checked")?1:0,e=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));
setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(b);99==l&&(f=2,k=0);startMsg();$.ajaxSingle({type:"post",data:{UID:a,CAT:b,DES:h,TAG:g,PID:l,PPW:c,PLD:""},url:"/f/UploadFileRefTwitterF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF",b.content_id);var c=!0;$(".imgView").each(function(){$(this).parent().addClass("Done");var d=$(this).attr("src").replace("data:image/png;base64,","");if(0>=d.length)return!0;c?(c=!1,$.ajax({type:"post",data:{UID:a,
IID:b.content_id,REC:f,DATA:d},url:"/f/UploadPasteFirstF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteFirstF")}})):$.ajax({type:"post",data:{UID:a,IID:b.content_id,DATA:d},url:"/f/UploadPasteAppendF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteAppendF")}})});1==k?$.ajax({type:"post",data:{UID:a,IID:b.content_id,IMG:e},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href=
"/MyHomePcV.jsp"},1E3)}}):setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}});return!1}};
