var $jscomp=$jscomp||{};$jscomp.scope={};$jscomp.findInternal=function(a,c,b){a instanceof String&&(a=String(a));for(var e=a.length,d=0;d<e;d++){var m=a[d];if(c.call(b,m,d,a))return{i:d,v:m}}return{i:-1,v:void 0}};$jscomp.ASSUME_ES5=!1;$jscomp.ASSUME_NO_NATIVE_MAP=!1;$jscomp.ASSUME_NO_NATIVE_SET=!1;$jscomp.SIMPLE_FROUND_POLYFILL=!1;
$jscomp.defineProperty=$jscomp.ASSUME_ES5||"function"==typeof Object.defineProperties?Object.defineProperty:function(a,c,b){a!=Array.prototype&&a!=Object.prototype&&(a[c]=b.value)};$jscomp.getGlobal=function(a){return"undefined"!=typeof window&&window===a?a:"undefined"!=typeof global&&null!=global?global:a};$jscomp.global=$jscomp.getGlobal(this);
$jscomp.polyfill=function(a,c,b,e){if(c){b=$jscomp.global;a=a.split(".");for(e=0;e<a.length-1;e++){var d=a[e];d in b||(b[d]={});b=b[d]}a=a[a.length-1];e=b[a];c=c(e);c!=e&&null!=c&&$jscomp.defineProperty(b,a,{configurable:!0,writable:!0,value:c})}};$jscomp.polyfill("Array.prototype.find",function(a){return a?a:function(a,b){return $jscomp.findInternal(this,a,b).v}},"es6","es3");var multiFileUploader=null;$.ajaxSetup({cache:!1});
(function(){var a=window.jQuery;a.paste=function(a){"undefined"!==typeof console&&null!==console&&console.log("DEPRECATED: This method is deprecated. Please use $.fn.pastableNonInputable() instead.");return d.mountNonInputable(a)._container};a.fn.pastableNonInputable=function(){var c;var f=0;for(c=this.length;f<c;f++){var b=this[f];b._pastable||a(b).is("textarea, input:text, [contenteditable]")||(d.mountNonInputable(b),b._pastable=!0)}return this};a.fn.pastableTextarea=function(){var c;var b=0;for(c=
this.length;b<c;b++){var h=this[b];h._pastable||a(h).is(":not(textarea, input:text)")||(d.mountTextarea(h),h._pastable=!0)}return this};a.fn.pastableContenteditable=function(){var c;var b=0;for(c=this.length;b<c;b++){var h=this[b];h._pastable||a(h).is(":not([contenteditable])")||(d.mountContenteditable(h),h._pastable=!0)}return this};var c=function(a,c){var b,f,g;null==c&&(c=512);if(!(b=a.match(/^data:([^;]+);base64,(.+)$/)))return null;a=b[1];var l=atob(b[2]);b=[];for(g=0;g<l.length;){var k=l.slice(g,
g+c);var e=Array(k.length);for(f=0;f<k.length;)e[f]=k.charCodeAt(f),f++;e=new Uint8Array(e);b.push(e);g+=c}return new Blob(b,{type:a})};var b=function(){return a(document.createElement("div")).attr("contenteditable",!0).attr("aria-hidden",!0).attr("tabindex",-1).css({width:1,height:1,position:"fixed",left:-100,overflow:"hidden",opacity:1E-17})};var e=function(c,b){var f=c.nodeName.toLowerCase();if("area"===f){b=c.parentNode;f=b.name;if(!c.href||!f||"map"!==b.nodeName.toLowerCase())return!1;c=a("img[usemap='#"+
f+"']");return 0<c.length&&c.is(":visible")}/^(input|select|textarea|button|object)$/.test(f)?(f=!c.disabled)&&(b=a(c).closest("fieldset")[0])&&(f=!b.disabled):f="a"===f?c.href||b:b;return(f=f||a(c).is("[contenteditable]"))&&a(c).is(":visible")};var d=function(){function d(c,b){this._container=c;this._target=b;this._container=a(this._container);this._target=a(this._target).addClass("pastable");this._container.on("paste",function(a){return function(c){var b,f,d;a.originalEvent=null!==c.originalEvent?
c.originalEvent:null;a._paste_event_fired=!0;if(null!=(null!=(b=c.originalEvent)?b.clipboardData:void 0)){var e=c.originalEvent.clipboardData;if(e.items){var g=null;a.originalEvent.pastedTypes=[];var h=e.items;var n=0;for(f=h.length;n<f;n++)b=h[n],b.type.match(/^text\/(plain|rtf|html)/)&&a.originalEvent.pastedTypes.push(b.type);var m=e.items;n=f=0;for(h=m.length;f<h;n=++f){b=m[n];if(b.type.match(/^image\//)){e=new FileReader;e.onload=function(b){return a._handleImage(b.target.result,a.originalEvent,
g)};try{e.readAsDataURL(b.getAsFile())}catch(v){}c.preventDefault();break}if("text/plain"===b.type){if(0===n&&1<e.items.length&&e.items[1].type.match(/^image\//)){var r=!0;var t=e.items[1].type}b.getAsString(function(b){return r?(g=b,a._target.trigger("pasteText",{text:b,isFilename:!0,fileType:t,originalEvent:a.originalEvent})):a._target.trigger("pasteText",{text:b,originalEvent:a.originalEvent})})}"text/rtf"===b.type&&b.getAsString(function(b){return a._target.trigger("pasteTextRich",{text:b,originalEvent:a.originalEvent})});
"text/html"===b.type&&b.getAsString(function(b){return a._target.trigger("pasteTextHtml",{text:b,originalEvent:a.originalEvent})})}}else{if(-1!==Array.prototype.indexOf.call(e.types,"text/plain")){var q=e.getData("Text");setTimeout(function(){return a._target.trigger("pasteText",{text:q,originalEvent:a.originalEvent})},1)}a._checkImagesInContainer(function(b){return a._handleImage(b,a.originalEvent)})}}if(e=window.clipboardData)if(null!=(d=q=e.getData("Text"))&&d.length)setTimeout(function(){a._target.trigger("pasteText",
{text:q,originalEvent:a.originalEvent});return a._target.trigger("_pasteCheckContainerDone")},1);else{e=e.files;d=0;for(b=e.length;d<b;d++)c=e[d],a._handleImage(URL.createObjectURL(c),a.originalEvent);a._checkImagesInContainer(function(a){})}return null}}(this))}d.prototype._target=null;d.prototype._container=null;d.mountNonInputable=function(c){var f=new d(b().appendTo(c),c);a(c).on("click",function(a){return function(a){if(!e(a.target,!1)&&!window.getSelection().toString())return f._container.focus()}}(this));
f._container.on("focus",function(b){return function(){return a(c).addClass("pastable-focus")}}(this));return f._container.on("blur",function(b){return function(){return a(c).removeClass("pastable-focus")}}(this))};d.mountTextarea=function(c){var e,f;if("undefined"!==typeof DataTransfer&&null!==DataTransfer&&DataTransfer.prototype&&null!=(e=Object.getOwnPropertyDescriptor)&&null!=(f=e.call(Object,DataTransfer.prototype,"items"))&&f.get)return this.mountContenteditable(c);var g=new d(b().insertBefore(c),
c);var l=!1;a(c).on("keyup",function(a){var c;if(17===(c=a.keyCode)||224===c)l=!1;return null});a(c).on("keydown",function(b){var e;if(17===(e=b.keyCode)||224===e)l=!0;null!=b.ctrlKey&&null!=b.metaKey&&(l=b.ctrlKey||b.metaKey);l&&86===b.keyCode&&(g._textarea_focus_stolen=!0,g._container.focus(),g._paste_event_fired=!1,setTimeout(function(b){return function(){if(!g._paste_event_fired)return a(c).focus(),g._textarea_focus_stolen=!1}}(this),1));return null});a(c).on("paste",function(a){return function(){}}(this));
a(c).on("focus",function(b){return function(){if(!g._textarea_focus_stolen)return a(c).addClass("pastable-focus")}}(this));a(c).on("blur",function(b){return function(){if(!g._textarea_focus_stolen)return a(c).removeClass("pastable-focus")}}(this));a(g._target).on("_pasteCheckContainerDone",function(b){return function(){a(c).focus();return g._textarea_focus_stolen=!1}}(this));return a(g._target).on("pasteText",function(b){return function(b,e){var d=a(c).prop("selectionStart");var f=a(c).prop("selectionEnd");
b=a(c).val();a(c).val(""+b.slice(0,d)+e.text+b.slice(f));a(c)[0].setSelectionRange(d+e.text.length,d+e.text.length);return a(c).trigger("change")}}(this))};d.mountContenteditable=function(b){new d(b,b);a(b).on("focus",function(c){return function(){return a(b).addClass("pastable-focus")}}(this));return a(b).on("blur",function(c){return function(){return a(b).removeClass("pastable-focus")}}(this))};d.prototype._handleImage=function(a,b,e){if(a.match(/^webkit\-fake\-url:\/\//))return this._target.trigger("pasteImageError",
{message:"You are trying to paste an image in Safari, however we are unable to retieve its data."});this._target.trigger("pasteImageStart");var d=new Image;d.crossOrigin="anonymous";d.onload=function(a){return function(){var f=document.createElement("canvas");f.width=d.width;f.height=d.height;f.getContext("2d").drawImage(d,0,0,f.width,f.height);var g=null;try{g=f.toDataURL("image/png");var h=c(g)}catch(u){}g&&a._target.trigger("pasteImage",{blob:h,dataURL:g,width:d.width,height:d.height,originalEvent:b,
name:e});return a._target.trigger("pasteImageEnd")}}(this);d.onerror=function(b){return function(){b._target.trigger("pasteImageError",{message:"Failed to get image from: "+a,url:a});return b._target.trigger("pasteImageEnd")}}(this);return d.src=a};d.prototype._checkImagesInContainer=function(b){var c;var e=Math.floor(1E3*Math.random());var d=this._container.find("img");var f=0;for(c=d.length;f<c;f++){var k=d[f];k["_paste_marked_"+e]=!0}return setTimeout(function(c){return function(){var d;var f=
c._container.find("img");var g=0;for(d=f.length;g<d;g++)k=f[g],k["_paste_marked_"+e]||(b(k.src),a(k).remove());return c._target.trigger("_pasteCheckContainerDone")}}(this),1)};return d}()}).call(this);function DispDescCharNum(){var a=200-$("#EditDescription").val().length;$("#DescriptionCharNum").html(a)}function DispTagListCharNum(){var a=100-$("#EditTagList").val().length;$("#EditTagListCharNum").html(a)}
function OnChangeTab(a){setCookie("MOD",a);window.location.href=0==a?"/UploadFilePcV.jsp":"/UploadPastePcV.jsp"}function setTweetSetting(a){setLocalStrage("upload_tweet",a)}function getTweetSetting(){return getLocalStrage("upload_tweet")?!0:!1}function setTweetImageSetting(a){setLocalStrage("upload_tweet_image",a)}function getTweetImageSetting(){return getLocalStrage("upload_tweet_image")?!0:!1}function setLastCategorySetting(a){setLocalStrage("last_category",a)}
function getLastCategorySetting(){return getLocalStrage("last_category")}function checkPublishDatetime(a,c,b,e,d){e=void 0===e?null:e;d=void 0===d?null:d;if(b&&e===a&&d===c)return!0;if(""==a||""==c)return dateTimeEmptyMsg(),!1;if(!b||b&&(e!==a||d!==c))if(Date.parse(a)<Date.now()||Date.parse(c)<Date.now())return dateTimePastMsg(),!1;return Date.parse(a)>Date.parse(c)?(dateTimeReverseMsg(),!1):!0}
function updateTweetButton(){$("#OptionTweet").prop("checked")?($("#ImageSwitch .OptionLabel").removeClass("disabled"),$("#ImageSwitch .onoffswitch").removeClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!1)):($("#ImageSwitch .OptionLabel").addClass("disabled"),$("#ImageSwitch .onoffswitch").addClass("disabled"),$("#OptionImage:checkbox").prop("disabled",!0))}
function initStartDatetime(a){$("#EditTimeLimitedStart").flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,defaultDate:a})}function initEndDatetime(a){$("#EditTimeLimitedEnd").flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,defaultDate:a})}
function updateOptionLimitedTimePublish(){var a=$("#ItemTimeLimitedVal");$("#OptionLimitedTimePublish").prop("checked")?a.slideDown(300,function(){$.each(["#EditTimeLimitedStart","#EditTimeLimitedEnd"],function(a,b){0>$(b)[0].classList.value.indexOf("flatpickr-input")&&(a=new Date,a.setMinutes(30*Math.floor((a.getMinutes()+45)/30)),$(b).flatpickr({enableTime:!0,dateFormat:"Z",altInput:!0,altFormat:"Y/m/d H:i",time_24hr:!0,minuteIncrement:30,minDate:a}))})}):a.slideUp(300)}
function updateAreaLimitedTimePublish(a){var c=$("#ItemTimeLimitedFlg"),b=$("#ItemTimeLimitedVal");99!=a?c.slideDown(300,function(){updateOptionLimitedTimePublish()}):$("#OptionLimitedTimePublish").prop("checked")?b.slideUp(300,function(){c.slideUp(300)}):c.slideUp(300)}
function updatePublish(){var a=parseInt($("#EditPublish").val(),10);updateAreaLimitedTimePublish(a);var c=[$("#ItemTwitterList"),$("#ItemPassword")];if(4==a||10==a||11==a){var b=null,e=null;switch(a){case 4:e=$("#ItemPassword");break;case 10:e=$("#ItemTwitterList")}for(a=0;a<c.length;a++){var d=c[a];if(d.is(":visible")){b=d;break}}null==b?e.slideDown(300):b.slideUp(300,function(){e.delay(150).slideDown(300)})}else for(a=0;a<c.length;a++)d=c[a],d.is(":visible")&&d.slideUp(300)}
function initUploadFile(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==a&&$("#EditCategory").val(a)});updateTweetButton();multiFileUploader=new qq.FineUploader({element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg",
"jpg","gif","png"],itemLimit:200,sizeLimit:2E7,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(a,b){this.first_file?(this.first_file=!1,this.setEndpoint("/f/UploadFileFirstF.jsp",a),console.log("UploadFileFirstF")):(this.setEndpoint("/f/UploadFileAppendF.jsp",a),console.log("UploadFileAppendF"));this.setParams({UID:this.user_id,IID:this.illust_id,PID:this.publish_id,REC:this.recent},a)},onAllComplete:function(a,b){console.log("onAllComplete",a,b,this.tweet);1==this.tweet?
$.ajax({type:"post",data:{UID:this.user_id,IID:this.illust_id,IMG:this.tweet_image},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):(completeMsg(),setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3))},onValidate:function(a){var b=this.getSubmittedSize(),c=this.getSubmittedNum();this.showTotalSize(b,c);b+=a.size;if(b>this.total_size)return!1;this.showTotalSize(b,c+1)},
onStatusChange:function(a,b,e){this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};multiFileUploader.getSubmittedSize=function(){var a=this.getUploads({status:qq.status.SUBMITTED}),b=0;$.each(a,function(){b+=this.size});return b};multiFileUploader.showTotalSize=function(a,b){var c="(jpeg|png|gif, 200files, total 50MByte)";0<a&&(c="("+b+"/200,  "+Math.ceil((multiFileUploader.total_size-
a)/1024)+" KByte)",$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(c)};multiFileUploader.total_size=52428800}function getPublishDateTime(a){return""==a?"":(new Date(a)).toISOString()}
function UploadFile(a){if(multiFileUploader&&!(0>=multiFileUploader.getSubmittedNum())){var c=$("#EditCategory").val(),b=$.trim($("#EditDescription").val());b=b.substr(0,200);var e=$.trim($("#EditTagList").val());e=e.substr(0,100);var d=$("#EditPublish").val(),m=$("#EditPassword").val(),f=$("#OptionRecent").prop("checked")?1:0,h=$("#OptionTweet").prop("checked")?1:0,n=$("#OptionImage").prop("checked")?1:0,g=null,l=$("#OptionLimitedTimePublish").prop("checked")?1:0,k=null,p=null;10==d&&(g=$("#EditTwitterList").val());
if(1==l&&(k=getPublishDateTime($("#EditTimeLimitedStart").val()),p=getPublishDateTime($("#EditTimeLimitedEnd").val()),!checkPublishDatetime(k,p,!1)))return;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(c);99==d&&(f=2,h=0);startMsg();console.log("start upload");$.ajaxSingle({type:"post",data:{UID:a,CAT:c,DES:b,TAG:e,PID:d,PPW:m,PLD:g,LTP:l,PST:k,PED:p,TWT:getTweetSetting(),TWI:getTweetImageSetting()},url:"/f/UploadFileRefTwitterF.jsp",
dataType:"json",success:function(b){console.log("UploadFileReferenceF");b&&b.content_id&&(0<b.content_id?(multiFileUploader.first_file=!0,multiFileUploader.user_id=a,multiFileUploader.illust_id=b.content_id,multiFileUploader.recent=f,multiFileUploader.tweet=h,multiFileUploader.tweet_image=n,multiFileUploader.publish_id=d,multiFileUploader.uploadStoredFiles()):errorMsg())}})}}var g_strPasteMsg="";
function initUploadPaste(){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var a=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==a&&$("#EditCategory").val(a)});updateTweetButton();g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(a,b){10>$(".InputFile").length&&(a=createPasteElm(b.dataURL),
$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){$("#TimeLineAddImage").html(g_strPasteMsg)})}
function createPasteElm(a){var c=$("<div />").addClass("InputFile"),b=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);c.append(b).append(a);return c}
function createPasteListItem(a,c){c=$("<li />").addClass("InputFile").attr("id",c);var b=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);c.append(b).append(a);return c}
function createPasteListItem(a,c){c=$("<li />").addClass("InputFile").attr("id",c);var b=$("<div />").addClass("DeletePaste").html('<i class="fas fa-times"></i>').on("click",function(){$(this).parent().remove();updatePasteNum()});a=$("<img />").addClass("imgView").attr("src",a);c.append(b).append(a);return c}
function initPasteElm(a){a.on("pasteImage",function(a,b){$(".OrgMessage",this).hide();$(".imgView",this).attr("src",b.dataURL).show()}).on("pasteImageError",function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){})}function updatePasteNum(){strTotal="("+$(".InputFile").length+"/10)";$("#TotalSize").html(strTotal)}
function UploadPaste(a){var c=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&c++});console.log(c);if(!(0>=c)){var b=$("#EditCategory").val(),e=$.trim($("#EditDescription").val());e=e.substr(0,200);var d=$.trim($("#EditTagList").val());d=d.substr(0,100);var m=$("#EditPublish").val(),f=$("#EditPassword").val(),h=$("#OptionRecent").prop("checked")?1:0,n=$("#OptionTweet").prop("checked")?1:0,g=$("#OptionImage").prop("checked")?1:0,l=null,k=$("#EditTimeLimitedStart").val(),p=$("#EditTimeLimitedEnd").val();
10==m&&(l=$("#EditTwitterList").val());if(11!=m||checkPublishDatetime(k,p,!1))return setTweetSetting($("#OptionTweet").prop("checked")),setTweetImageSetting($("#OptionImage").prop("checked")),setLastCategorySetting(b),99==m&&(h=2,n=0),startMsg(),$.ajaxSingle({type:"post",data:{UID:a,CAT:b,DES:e,TAG:d,PID:m,PPW:f,PLD:l,PST:k,PED:p,TWT:getTweetSetting(),TWI:getTweetImageSetting(),ED:1},url:"/f/UploadFileRefTwitterF.jsp",dataType:"json",success:function(b){console.log("UploadFileReferenceF",b.content_id);
var c=!0;$(".imgView").each(function(){$(this).parent().addClass("Done");var d=$(this).attr("src").replace("data:image/png;base64,","");if(0>=d.length)return!0;c?(c=!1,$.ajax({type:"post",data:{UID:a,IID:b.content_id,REC:h,DATA:d},url:"/f/UploadPasteFirstF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteFirstF")}})):$.ajax({type:"post",data:{UID:a,IID:b.content_id,DATA:d},url:"/f/UploadPasteAppendF.jsp",dataType:"json",async:!1,success:function(a){console.log("UploadPasteAppendF")}})});
1==n?$.ajax({type:"post",data:{UID:a,IID:b.content_id,IMG:g},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}),!1}};
