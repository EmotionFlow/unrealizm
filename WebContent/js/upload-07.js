var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.findInternal=function(a,f,d){a instanceof String&&(a=String(a));for(var h=a.length,g=0;g<h;g++){var e=a[g];if(f.call(d,e,g,a))return{i:g,v:e}}return{i:-1,v:void 0}};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,f,d){a!=Array.prototype&&a!=Object.prototype&&(a[f]=d.value)};
$jscomp.getGlobal=function(a){return"undefined"!=typeof window&&window===a?a:"undefined"!=typeof global&&null!=global?global:a};$jscomp.global=$jscomp.getGlobal(this);$jscomp.polyfill=function(a,f,d,h){if(f){d=$jscomp.global;a=a.split(".");for(h=0;h<a.length-1;h++){var g=a[h];g in d||(d[g]={});d=d[g]}a=a[a.length-1];h=d[a];f=f(h);f!=h&&null!=f&&$jscomp.defineProperty(d,a,{configurable:!0,writable:!0,value:f})}};
$jscomp.polyfill("Array.prototype.find",function(a){return a?a:function(a,d){return $jscomp.findInternal(this,a,d).v}},"es6","es3");var multiFileUploader=null;$.ajaxSetup({cache:!1});
(function(){var a=window.jQuery;a.paste=function(a){"undefined"!==typeof console&&null!==console&&console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");return g.mountNonInputable(a)._container};a.fn.pastableNonInputable=function(){var e;var b=0;for(e=this.length;b<e;b++){var c=this[b];c._pastable||a(c).is("textarea, input:text, [contenteditable]")||(g.mountNonInputable(c),c._pastable=!0)}return this};a.fn.pastableTextarea=function(){var e;var b=0;for(e=
this.length;b<e;b++){var c=this[b];c._pastable||a(c).is(":not(textarea, input:text)")||(g.mountTextarea(c),c._pastable=!0)}return this};a.fn.pastableContenteditable=function(){var e;var b=0;for(e=this.length;b<e;b++){var c=this[b];c._pastable||a(c).is(":not([contenteditable])")||(g.mountContenteditable(c),c._pastable=!0)}return this};var f=function(a,b){var c,e,k;null==b&&(b=512);if(!(c=a.match(/^data:([^;]+);base64,(.+)$/)))return null;a=c[1];var d=atob(c[2]);c=[];for(k=0;k<d.length;){var f=d.slice(k,
k+b);var l=Array(f.length);for(e=0;e<f.length;)l[e]=f.charCodeAt(e),e++;l=new Uint8Array(l);c.push(l);k+=b}return new Blob(c,{type:a})};var d=function(){return a(document.createElement("div")).attr("contenteditable",!0).attr("aria-hidden",!0).attr("tabindex",-1).css({width:1,height:1,position:"fixed",left:-100,overflow:"hidden",opacity:1E-17})};var h=function(e,b){var c=e.nodeName.toLowerCase();if("area"===c){b=e.parentNode;c=b.name;if(!e.href||!c||"map"!==b.nodeName.toLowerCase())return!1;e=a("img[usemap='#"+
c+"']");return 0<e.length&&e.is(":visible")}/^(input|select|textarea|button|object)$/.test(c)?(c=!e.disabled)&&(b=a(e).closest("fieldset")[0])&&(c=!b.disabled):c="a"===c?e.href||b:b;return(c=c||a(e).is("[contenteditable]"))&&a(e).is(":visible")};var g=function(){function e(b,c){this._container=b;this._target=c;this._container=a(this._container);this._target=a(this._target).addClass("pastable");this._container.on("paste",function(a){return function(b){var c,e,f;a.originalEvent=null!==b.originalEvent?
b.originalEvent:null;a._paste_event_fired=!0;if(null!=(null!=(c=b.originalEvent)?c.clipboardData:void 0)){var d=b.originalEvent.clipboardData;if(d.items){var k=null;a.originalEvent.pastedTypes=[];var g=d.items;var h=0;for(e=g.length;h<e;h++)c=g[h],c.type.match(/^text\/(plain|rtf|html)/)&&a.originalEvent.pastedTypes.push(c.type);var n=d.items;h=e=0;for(g=n.length;e<g;h=++e){c=n[h];if(c.type.match(/^image\//)){d=new FileReader;d.onload=function(b){return a._handleImage(b.target.result,a.originalEvent,
k)};try{d.readAsDataURL(c.getAsFile())}catch(t){}b.preventDefault();break}if("text/plain"===c.type){if(0===h&&1<d.items.length&&d.items[1].type.match(/^image\//)){var p=!0;var q=d.items[1].type}c.getAsString(function(b){return p?(k=b,a._target.trigger("pasteText",{text:b,isFilename:!0,fileType:q,originalEvent:a.originalEvent})):a._target.trigger("pasteText",{text:b,originalEvent:a.originalEvent})})}"text/rtf"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextRich",{text:b,originalEvent:a.originalEvent})});
"text/html"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextHtml",{text:b,originalEvent:a.originalEvent})})}}else{if(-1!==Array.prototype.indexOf.call(d.types,"text/plain")){var m=d.getData("Text");setTimeout(function(){return a._target.trigger("pasteText",{text:m,originalEvent:a.originalEvent})},1)}a._checkImagesInContainer(function(b){return a._handleImage(b,a.originalEvent)})}}if(d=window.clipboardData)if(null!=(f=m=d.getData("Text"))&&f.length)setTimeout(function(){a._target.trigger("pasteText",
{text:m,originalEvent:a.originalEvent});return a._target.trigger("_pasteCheckContainerDone")},1);else{d=d.files;f=0;for(c=d.length;f<c;f++)b=d[f],a._handleImage(URL.createObjectURL(b),a.originalEvent);a._checkImagesInContainer(function(a){})}return null}}(this))}e.prototype._target=null;e.prototype._container=null;e.mountNonInputable=function(b){var c=new e(d().appendTo(b),b);a(b).on("click",function(a){return function(a){if(!h(a.target,!1)&&!window.getSelection().toString())return c._container.focus()}}(this));
c._container.on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return c._container.on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};e.mountTextarea=function(b){var c,f;if("undefined"!==typeof DataTransfer&&null!==DataTransfer&&DataTransfer.prototype&&null!=(c=Object.getOwnPropertyDescriptor)&&null!=(f=c.call(Object,DataTransfer.prototype,"items"))&&f.get)return this.mountContenteditable(b);var k=new e(d().insertBefore(b),
b);var g=!1;a(b).on("keyup",function(a){var b;if(17===(b=a.keyCode)||224===b)g=!1;return null});a(b).on("keydown",function(c){var d;if(17===(d=c.keyCode)||224===d)g=!0;null!=c.ctrlKey&&null!=c.metaKey&&(g=c.ctrlKey||c.metaKey);g&&86===c.keyCode&&(k._textarea_focus_stolen=!0,k._container.focus(),k._paste_event_fired=!1,setTimeout(function(c){return function(){if(!k._paste_event_fired)return a(b).focus(),k._textarea_focus_stolen=!1}}(this),1));return null});a(b).on("paste",function(a){return function(){}}(this));
a(b).on("focus",function(c){return function(){if(!k._textarea_focus_stolen)return a(b).addClass("pastable-focus")}}(this));a(b).on("blur",function(c){return function(){if(!k._textarea_focus_stolen)return a(b).removeClass("pastable-focus")}}(this));a(k._target).on("_pasteCheckContainerDone",function(c){return function(){a(b).focus();return k._textarea_focus_stolen=!1}}(this));return a(k._target).on("pasteText",function(c){return function(c,d){var e=a(b).prop("selectionStart");var f=a(b).prop("selectionEnd");
c=a(b).val();a(b).val(""+c.slice(0,e)+d.text+c.slice(f));a(b)[0].setSelectionRange(e+d.text.length,e+d.text.length);return a(b).trigger("change")}}(this))};e.mountContenteditable=function(b){new e(b,b);a(b).on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return a(b).on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};e.prototype._handleImage=function(a,c,d){if(a.match(/^webkit\-fake\-url:\/\//))return this._target.trigger("pasteImageError",
{message:"You are trying to paste an image in Safari, however we are unable to retieve its data."});this._target.trigger("pasteImageStart");var b=new Image;b.crossOrigin="anonymous";b.onload=function(a){return function(){var e=document.createElement("canvas");e.width=b.width;e.height=b.height;e.getContext("2d").drawImage(b,0,0,e.width,e.height);var g=null;try{g=e.toDataURL("image/png");var h=f(g)}catch(r){}g&&a._target.trigger("pasteImage",{blob:h,dataURL:g,width:b.width,height:b.height,originalEvent:c,
name:d});return a._target.trigger("pasteImageEnd")}}(this);b.onerror=function(b){return function(){b._target.trigger("pasteImageError",{message:"Failed to get image from: "+a,url:a});return b._target.trigger("pasteImageEnd")}}(this);return b.src=a};e.prototype._checkImagesInContainer=function(b){var c;var e=Math.floor(1E3*Math.random());var d=this._container.find("img");var f=0;for(c=d.length;f<c;f++){var g=d[f];g["_paste_marked_"+e]=!0}return setTimeout(function(c){return function(){var d;var f=
c._container.find("img");var h=0;for(d=f.length;h<d;h++)g=f[h],g["_paste_marked_"+e]||(b(g.src),a(g).remove());return c._target.trigger("_pasteCheckContainerDone")}}(this),1)};return e}()}).call(this);function DispDescCharNum(){var a=200-$("#EditDescription").val().length;$("#DescriptionCharNum").html(a)}function OnChangeTab(a){setCookie("MOD",a);window.location.href=0==a?"/UploadFilePcV.jsp":"/UploadPastePcV.jsp"}function setTweetSetting(a){setLocalStrage("upload_tweet",a)}
function getTweetSetting(){return getLocalStrage("upload_tweet")?!0:!1}function setTweetImageSetting(a){setLocalStrage("upload_tweet_image",a)}function getTweetImageSetting(){return getLocalStrage("upload_tweet_image")?!0:!1}
function updateTweetButton(){$("#OptionTweet").prop("checked")?($("#ImageSwitch .OptionLabel").removeClass("disabled"),$("#ImageSwitch .onoffswitch").removeClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!1)):($("#ImageSwitch .OptionLabel").addClass("disabled"),$("#ImageSwitch .onoffswitch").addClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!0))}
function updateOneCushionButton(){$("#OptionOneCushion").prop("checked")?($("#R18Switch .OptionLabel").removeClass("disabled"),$("#R18Switch .onoffswitch").removeClass("disabled"),$("#OptionR18:checkbox").prop("disabled",!1)):($("#R18Switch .OptionLabel").addClass("disabled"),$("#R18Switch .onoffswitch").addClass("disabled"),$("#OptionR18:checkbox").prop("disabled",!0))}
function initUploadFile(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());updateOneCushionButton();updateTweetButton();multiFileUploader=new qq.FineUploader({element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg","jpg","gif","png"],itemLimit:200,sizeLimit:2E7,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(a,
f){this.first_file?(this.first_file=!1,this.setEndpoint("/f/UploadFileFirstF.jsp",a),console.log("UploadFileFirstF")):(this.setEndpoint("/f/UploadFileAppendF.jsp",a),console.log("UploadFileAppendF"));this.setParams({UID:this.user_id,IID:this.illust_id,REC:this.recent},a)},onAllComplete:function(a,f){console.log("onAllComplete",a,f,this.tweet);1==this.tweet?$.ajax({type:"post",data:{UID:this.user_id,IID:this.illust_id,IMG:this.tweet_image},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");
completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):(completeMsg(),setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3))},onValidate:function(a){var f=this.getSubmittedSize(),d=this.getSubmittedNum();this.showTotalSize(f,d);f+=a.size;if(f>this.total_size)return!1;this.showTotalSize(f,d+1)},onStatusChange:function(a,f,d){this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};
multiFileUploader.getSubmittedSize=function(){var a=this.getUploads({status:qq.status.SUBMITTED}),f=0;$.each(a,function(){f+=this.size});return f};multiFileUploader.showTotalSize=function(a,f){var d="(jpeg / png / gif, 200files, total 50MByte)";0<a&&(d="("+f+" / 200,  "+Math.ceil((multiFileUploader.total_size-a)/1024)+" KByte)",$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(d)};multiFileUploader.total_size=52428800}
function UploadFile(a){if(multiFileUploader&&!(0>=multiFileUploader.getSubmittedNum())){var f=$("#EditCategory").val(),d=$.trim($("#EditDescription").val());d=d.substr(0,200);var h=$("#OptionRecent").prop("checked")?1:0,g=$("#OptionOneCushion").prop("checked")?2:0;0<g&&(g=$("#OptionR18").prop("checked")?4:2);var e=$("#OptionTweet").prop("checked")?1:0,b=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));
startMsg();console.log("start upload");$.ajaxSingle({type:"post",data:{UID:a,CAT:f,SAF:g,DES:d},url:"/f/UploadFileReferenceF.jsp",dataType:"json",success:function(c){console.log("UploadFileReferenceF");c&&c.content_id&&(0<c.content_id?(multiFileUploader.first_file=!0,multiFileUploader.user_id=a,multiFileUploader.illust_id=c.content_id,multiFileUploader.recent=h,multiFileUploader.tweet=e,multiFileUploader.tweet_image=b,multiFileUploader.uploadStoredFiles()):errorMsg())}})}}var g_strPasteMsg="";
function initUploadPaste(a){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());updateOneCushionButton();updateTweetButton();g_strPasteMsg=a;a=createPasteElm();$("#PasteZone").append(a)}
function createPasteElm(){var a=$("<div />").addClass("InputFile"),f=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){if(10<=$(".InputFile.Removable").length){var a=createPasteElm();$("#PasteZone").append(a)}$(this).parent().remove();updatePasteNum()}),d=$("<div />").addClass("OrgMessage").text(g_strPasteMsg),h=$("<img />").addClass("imgView").attr("src","");a.append(f).append(d).append(h);a.pastableNonInputable();a.on("pasteImage",function(a,d){$(this).addClass("Removable");
$(".OrgMessage",this).hide();$(".imgView",this).attr("src",d.dataURL).show();updatePasteNum();10>$(".InputFile.Removable").length&&(a=createPasteElm(),$("#PasteZone").append(a))}).on("pasteImageError",function(a,d){d.url&&alert("error data : "+d.url)}).on("pasteText",function(a,d){});return a}function updatePasteNum(){strTotal="("+$(".InputFile.Removable").length+" / 10)";$("#TotalSize").html(strTotal)}
function initPasteElm(a){a.on("pasteImage",function(a,d){$(".OrgMessage",this).hide();$(".imgView",this).attr("src",d.dataURL).show()}).on("pasteImageError",function(a,d){d.url&&alert("error data : "+d.url)}).on("pasteText",function(a,d){})}
function UploadPaste(a){var f=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&f++});console.log(f);if(!(0>=f)){startMsg();var d=$("#EditCategory").val(),h=$.trim($("#EditDescription").val());h=h.substr(0,200);var g=$("#OptionRecent").prop("checked")?1:0,e=$("#OptionOneCushion").prop("checked")?2:0;0<e&&(e=$("#OptionR18").prop("checked")?4:2);$("#OptionTweet").prop("checked");var b=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));
$.ajaxSingle({type:"post",data:{UID:a,CAT:d,SAF:e,DES:h},url:"/f/UploadFileReferenceF.jsp",dataType:"json",success:function(c){console.log("UploadFileReferenceF",c.content_id);var d=!0;$(".imgView").each(function(){var b=$(this).attr("src").replace("data:image/png;base64,","");if(0>=b.length)return!0;d?(d=!1,$.ajax({type:"post",data:{UID:a,IID:c.content_id,REC:g,DATA:b},url:"/f/UploadPasteFirstF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteFirstF")}})):$.ajax({type:"post",
data:{UID:a,IID:c.content_id,DATA:b},url:"/f/UploadPasteAppendF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteAppendF")}})});$.ajax({type:"post",data:{UID:a,IID:c.content_id,IMG:b},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}})}});return!1}};
