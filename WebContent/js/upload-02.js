var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.findInternal=function(a,f,e){a instanceof String&&(a=String(a));for(var h=a.length,g=0;g<h;g++){var d=a[g];if(f.call(e,d,g,a))return{i:g,v:d}}return{i:-1,v:void 0}};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,f,e){a!=Array.prototype&&a!=Object.prototype&&(a[f]=e.value)};
$jscomp.getGlobal=function(a){return"undefined"!=typeof window&&window===a?a:"undefined"!=typeof global&&null!=global?global:a};$jscomp.global=$jscomp.getGlobal(this);$jscomp.polyfill=function(a,f,e,h){if(f){e=$jscomp.global;a=a.split(".");for(h=0;h<a.length-1;h++){var g=a[h];g in e||(e[g]={});e=e[g]}a=a[a.length-1];h=e[a];f=f(h);f!=h&&null!=f&&$jscomp.defineProperty(e,a,{configurable:!0,writable:!0,value:f})}};
$jscomp.polyfill("Array.prototype.find",function(a){return a?a:function(a,e){return $jscomp.findInternal(this,a,e).v}},"es6","es3");var multiFileUploader=null;$.ajaxSetup({cache:!1});
(function(){var a=window.jQuery;a.paste=function(a){"undefined"!==typeof console&&null!==console&&console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");return g.mountNonInputable(a)._container};a.fn.pastableNonInputable=function(){var d;var b=0;for(d=this.length;b<d;b++){var c=this[b];c._pastable||a(c).is("textarea, input:text, [contenteditable]")||(g.mountNonInputable(c),c._pastable=!0)}return this};a.fn.pastableTextarea=function(){var d;var b=0;for(d=
this.length;b<d;b++){var c=this[b];c._pastable||a(c).is(":not(textarea, input:text)")||(g.mountTextarea(c),c._pastable=!0)}return this};a.fn.pastableContenteditable=function(){var d;var b=0;for(d=this.length;b<d;b++){var c=this[b];c._pastable||a(c).is(":not([contenteditable])")||(g.mountContenteditable(c),c._pastable=!0)}return this};var f=function(a,b){var c,k,d;null==b&&(b=512);if(!(c=a.match(/^data:([^;]+);base64,(.+)$/)))return null;a=c[1];var f=atob(c[2]);c=[];for(d=0;d<f.length;){var m=f.slice(d,
d+b);var e=Array(m.length);for(k=0;k<m.length;)e[k]=m.charCodeAt(k),k++;e=new Uint8Array(e);c.push(e);d+=b}return new Blob(c,{type:a})};var e=function(){return a(document.createElement("div")).attr("contenteditable",!0).attr("aria-hidden",!0).attr("tabindex",-1).css({width:1,height:1,position:"fixed",left:-100,overflow:"hidden",opacity:1E-17})};var h=function(d,b){var c=d.nodeName.toLowerCase();if("area"===c){b=d.parentNode;c=b.name;if(!d.href||!c||"map"!==b.nodeName.toLowerCase())return!1;d=a("img[usemap='#"+
c+"']");return 0<d.length&&d.is(":visible")}/^(input|select|textarea|button|object)$/.test(c)?(c=!d.disabled)&&(b=a(d).closest("fieldset")[0])&&(c=!b.disabled):c="a"===c?d.href||b:b;return(c=c||a(d).is("[contenteditable]"))&&a(d).is(":visible")};var g=function(){function d(b,c){this._container=b;this._target=c;this._container=a(this._container);this._target=a(this._target).addClass("pastable");this._container.on("paste",function(a){return function(b){var c,d,f;a.originalEvent=null!==b.originalEvent?
b.originalEvent:null;a._paste_event_fired=!0;if(null!=(null!=(c=b.originalEvent)?c.clipboardData:void 0)){var e=b.originalEvent.clipboardData;if(e.items){var l=null;a.originalEvent.pastedTypes=[];var g=e.items;var k=0;for(d=g.length;k<d;k++)c=g[k],c.type.match(/^text\/(plain|rtf|html)/)&&a.originalEvent.pastedTypes.push(c.type);var h=e.items;k=d=0;for(g=h.length;d<g;k=++d){c=h[k];if(c.type.match(/^image\//)){e=new FileReader;e.onload=function(b){return a._handleImage(b.target.result,a.originalEvent,
l)};try{e.readAsDataURL(c.getAsFile())}catch(t){}b.preventDefault();break}if("text/plain"===c.type){if(0===k&&1<e.items.length&&e.items[1].type.match(/^image\//)){var p=!0;var q=e.items[1].type}c.getAsString(function(b){return p?(l=b,a._target.trigger("pasteText",{text:b,isFilename:!0,fileType:q,originalEvent:a.originalEvent})):a._target.trigger("pasteText",{text:b,originalEvent:a.originalEvent})})}"text/rtf"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextRich",{text:b,originalEvent:a.originalEvent})});
"text/html"===c.type&&c.getAsString(function(b){return a._target.trigger("pasteTextHtml",{text:b,originalEvent:a.originalEvent})})}}else{if(-1!==Array.prototype.indexOf.call(e.types,"text/plain")){var n=e.getData("Text");setTimeout(function(){return a._target.trigger("pasteText",{text:n,originalEvent:a.originalEvent})},1)}a._checkImagesInContainer(function(b){return a._handleImage(b,a.originalEvent)})}}if(e=window.clipboardData)if(null!=(f=n=e.getData("Text"))&&f.length)setTimeout(function(){a._target.trigger("pasteText",
{text:n,originalEvent:a.originalEvent});return a._target.trigger("_pasteCheckContainerDone")},1);else{e=e.files;f=0;for(c=e.length;f<c;f++)b=e[f],a._handleImage(URL.createObjectURL(b),a.originalEvent);a._checkImagesInContainer(function(a){})}return null}}(this))}d.prototype._target=null;d.prototype._container=null;d.mountNonInputable=function(b){var c=new d(e().appendTo(b),b);a(b).on("click",function(a){return function(a){if(!h(a.target,!1)&&!window.getSelection().toString())return c._container.focus()}}(this));
c._container.on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return c._container.on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};d.mountTextarea=function(b){var c,f;if("undefined"!==typeof DataTransfer&&null!==DataTransfer&&DataTransfer.prototype&&null!=(c=Object.getOwnPropertyDescriptor)&&null!=(f=c.call(Object,DataTransfer.prototype,"items"))&&f.get)return this.mountContenteditable(b);var l=new d(e().insertBefore(b),
b);var g=!1;a(b).on("keyup",function(a){var b;if(17===(b=a.keyCode)||224===b)g=!1;return null});a(b).on("keydown",function(c){var e;if(17===(e=c.keyCode)||224===e)g=!0;null!=c.ctrlKey&&null!=c.metaKey&&(g=c.ctrlKey||c.metaKey);g&&86===c.keyCode&&(l._textarea_focus_stolen=!0,l._container.focus(),l._paste_event_fired=!1,setTimeout(function(c){return function(){if(!l._paste_event_fired)return a(b).focus(),l._textarea_focus_stolen=!1}}(this),1));return null});a(b).on("paste",function(a){return function(){}}(this));
a(b).on("focus",function(c){return function(){if(!l._textarea_focus_stolen)return a(b).addClass("pastable-focus")}}(this));a(b).on("blur",function(c){return function(){if(!l._textarea_focus_stolen)return a(b).removeClass("pastable-focus")}}(this));a(l._target).on("_pasteCheckContainerDone",function(c){return function(){a(b).focus();return l._textarea_focus_stolen=!1}}(this));return a(l._target).on("pasteText",function(c){return function(c,e){var d=a(b).prop("selectionStart");var f=a(b).prop("selectionEnd");
c=a(b).val();a(b).val(""+c.slice(0,d)+e.text+c.slice(f));a(b)[0].setSelectionRange(d+e.text.length,d+e.text.length);return a(b).trigger("change")}}(this))};d.mountContenteditable=function(b){new d(b,b);a(b).on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return a(b).on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};d.prototype._handleImage=function(a,c,e){if(a.match(/^webkit\-fake\-url:\/\//))return this._target.trigger("pasteImageError",
{message:"You are trying to paste an image in Safari, however we are unable to retieve its data."});this._target.trigger("pasteImageStart");var b=new Image;b.crossOrigin="anonymous";b.onload=function(a){return function(){var d=document.createElement("canvas");d.width=b.width;d.height=b.height;d.getContext("2d").drawImage(b,0,0,d.width,d.height);var g=null;try{g=d.toDataURL("image/png");var h=f(g)}catch(r){}g&&a._target.trigger("pasteImage",{blob:h,dataURL:g,width:b.width,height:b.height,originalEvent:c,
name:e});return a._target.trigger("pasteImageEnd")}}(this);b.onerror=function(b){return function(){b._target.trigger("pasteImageError",{message:"Failed to get image from: "+a,url:a});return b._target.trigger("pasteImageEnd")}}(this);return b.src=a};d.prototype._checkImagesInContainer=function(b){var c;var e=Math.floor(1E3*Math.random());var d=this._container.find("img");var f=0;for(c=d.length;f<c;f++){var g=d[f];g["_paste_marked_"+e]=!0}return setTimeout(function(c){return function(){var d;var f=
c._container.find("img");var h=0;for(d=f.length;h<d;h++)g=f[h],g["_paste_marked_"+e]||(b(g.src),a(g).remove());return c._target.trigger("_pasteCheckContainerDone")}}(this),1)};return d}()}).call(this);function DispDescCharNum(){var a=200-$("#EditDescription").val().length;$("#DescriptionCharNum").html(a)}function OnChangeTab(a){setCookie("MOD",a);window.location.href=0==a?"/UploadFilePcV.jsp":"/UploadPastePcV.jsp"}function setTweetSetting(a){setLocalStrage("upload_tweet",a)}
function getTweetSetting(){return getLocalStrage("upload_tweet")?!0:!1}function setTweetImageSetting(a){setLocalStrage("upload_tweet_image",a)}function getTweetImageSetting(){return getLocalStrage("upload_tweet_image")?!0:!1}function updateTweetButton(){$("#OptionTweet").prop("checked")?($("#ImageSwitch").removeClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!1)):($("#ImageSwitch").addClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!0))}
function initUploadFile(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());updateTweetButton();multiFileUploader=new qq.FineUploader({element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg","jpg","gif","png"],itemLimit:100,sizeLimit:1E7,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(a,f){this.first_file?
(this.first_file=!1,this.setEndpoint("/f/UploadFileFirstF.jsp",a),console.log("UploadFileFirstF")):(this.setEndpoint("/f/UploadFileAppendF.jsp",a),console.log("UploadFileAppendF"));this.setParams({UID:this.user_id,IID:this.illust_id,REC:this.recent},a)},onAllComplete:function(a,f){console.log("onAllComplete",a,f,this.tweet);1==this.tweet?$.ajax({type:"post",data:{UID:this.user_id,IID:this.illust_id,IMG:this.tweet_image},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");
completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):(completeMsg(),setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3))},onValidate:function(a){var f=this.getSubmittedSize(),e=this.getSubmittedNum();this.showTotalSize(f,e);f+=a.size;if(f>this.total_size)return!1;this.showTotalSize(f,e+1)},onStatusChange:function(a,f,e){this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};
multiFileUploader.getSubmittedSize=function(){var a=this.getUploads({status:qq.status.SUBMITTED}),f=0;$.each(a,function(){f+=this.size});return f};multiFileUploader.showTotalSize=function(a,f){var e="";0<a&&(e=" (Remaning: "+(200-f)+" files. "+Math.ceil((multiFileUploader.total_size-a)/1024)+" KByte)",$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(e)};multiFileUploader.total_size=31457280}
function UploadFile(a){if(multiFileUploader&&!(0>=multiFileUploader.getSubmittedNum())){var f=$("#EditCategory").val(),e=$.trim($("#EditDescription").val()),h=$("#OptionRecent").prop("checked")?1:0,g=$("#OptionTweet").prop("checked")?1:0,d=$("#OptionImage").prop("checked")?1:0;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));e=e.substr(0,200);startMsg();console.log("start upload");$.ajaxSingle({type:"post",data:{UID:a,CAT:f,DES:e},url:"/f/UploadFileReferenceF.jsp",
dataType:"json",success:function(b){console.log("UploadFileReferenceF");b&&b.content_id&&(0<b.content_id?(multiFileUploader.first_file=!0,multiFileUploader.user_id=a,multiFileUploader.illust_id=b.content_id,multiFileUploader.recent=h,multiFileUploader.tweet=g,multiFileUploader.tweet_image=d,multiFileUploader.uploadStoredFiles()):errorMsg())}})}}
function initUploadPaste(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());updateTweetButton();$("#InputFile").pastableNonInputable();$("#InputFile").on("pasteImage",function(a,f){$(".OrgMessage").hide();$("#imgView").attr("src",f.dataURL).show()}).on("pasteImageError",function(a,f){f.url&&alert("error data : "+f.url)}).on("pasteText",function(a,f){})}
function UploadPaste(a){startMsg();var f=$("#EditCategory").val(),e=$.trim($("#EditDescription").val()),h=$("#OptionRecent").prop("checked")?1:0,g=$("#OptionTweet").prop("checked")?1:0,d=$("#OptionImage").prop("checked")?1:0,b=$("#imgView").attr("src").replace("data:image/png;base64,","");setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));$.ajaxSingle({type:"post",data:{UID:a,DES:e,REC:h,TWI:g,IMG:d,CAT:f,DATA:b},url:"/f/UploadPasteF.jsp",dataType:"json",
success:function(a){0<a.result?(completeMsg(),setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)):errorMsg(a.result)}})};
