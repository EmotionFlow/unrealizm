function UpdateFileOrder(c,e){var b=[];$.each($(".qq-upload-list-selector.qq-upload-list").sortable("toArray"),function(a,d){b.push(parseInt(d))});$.ajax({type:"post",data:{UID:c,IID:e,AID:JSON.stringify(b)},url:"/f/UpdateFileOrderF.jsp",dataType:"json",success:function(a){console.log("UploadFileOrderF:"+a.result)}})}
function UpdatePasteOrder(c,e){var b=[];$.each($("#PasteZone").sortable("toArray"),function(a,d){b.push(parseInt(d))});$.ajax({type:"post",data:{UID:c,IID:e,AID:JSON.stringify(b)},url:"/f/UpdateFileOrderF.jsp",dataType:"json",success:function(a){console.log("UploadFileOrderF:"+a.result)},error:function(a){console.log(a)}})}function UpdatePasteOrderAjax(c,e,b){return $.ajax({type:"post",data:{UID:c,IID:e,AID:JSON.stringify(b)},url:"/f/UpdateFileOrderF.jsp",dataType:"json"})}
function initUpdateFile(c,e){$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());updateTweetButton();multiFileUploader=new qq.FineUploader({session:{endpoint:"/f/GetIllustFileListF.jsp?TD="+e+"&ID="+c,refreshOnRequest:!0},element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg","jpg","gif","png"],itemLimit:200,sizeLimit:2E7,stopOnFirstInvalidFile:!1},
retry:{enableAuto:!1},callbacks:{onUpload:function(b,a){this.newfile_num&&0<this.newfile_num&&(this.setEndpoint("/f/UpdateFileAppendF.jsp",b),this.setParams({UID:this.user_id,IID:this.illust_id},b))},onComplete:function(b,a,d,c){append_id=d.append_id;$(".qq-file-id-"+b).attr("id",append_id)},onAllComplete:function(b,a){console.log("onAllComplete",b,a,this.tweet);this.newfile_num&&0<this.newfile_num?(1==this.tweet?$.ajax({type:"post",data:{UID:this.user_id,IID:this.illust_id,IMG:this.tweet_image},
url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)}}):(completeMsg(),setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)),UpdateFileOrder(this.user_id,this.illust_id)):($("li.qq-upload-success").removeClass("qq-upload-success"),$("button.qq-upload-cancel").removeClass("qq-hide"))},onValidate:function(b){var a=this.getSubmittedSize(),d=this.getSubmittedNum();this.showTotalSize(a,
d);a+=b.size;if(a>this.total_size)return!1;this.showTotalSize(a,d+1)},onStatusChange:function(b,a,d){this.newfile_num&&0<this.newfile_num&&this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};multiFileUploader.getSubmittedSize=function(){var b=this.getUploads({status:qq.status.SUBMITTED}),a=0;$.each(b,function(){a+=this.size});return a};multiFileUploader.showTotalSize=function(b,
a){var d="(jpeg|png|gif, 200files, total 50MByte)";0<b&&(d="("+a+"/200,  "+Math.ceil((multiFileUploader.total_size-b)/1024)+" KByte)",$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(d)};multiFileUploader.sessionRequestComplete=function(b,a,d,c){alert(a)};multiFileUploader.total_size=52428800}
function UpdateFile(c,e){if(multiFileUploader&&!(0>=$(".qq-upload-list-selector.qq-upload-list").children("li").length)){var b=$("#EditCategory").val(),a=$.trim($("#EditDescription").val());a=a.substr(0,200);var d=$.trim($("#EditTagList").val());d=d.substr(0,100);var f=$("#EditPublish").val(),h=$("#EditPassword").val(),g=$("#OptionRecent").prop("checked")?1:0,l=$("#OptionTweet").prop("checked")?1:0,m=$("#OptionImage").prop("checked")?1:0,k=null,p=$("#EditTimeLimitedStart").val(),n=$("#EditTimeLimitedEnd").val();
10==f&&(k=$("#EditTwitterList").val());if(11!=f||checkPublishDatetime(p,n,!0,$("#EditTimeLimitedStartPresent").val(),$("#EditTimeLimitedEndPresent").val()))setTweetSetting($("#OptionTweet").prop("checked")),setTweetImageSetting($("#OptionImage").prop("checked")),setLastCategorySetting(b),99==f&&(g=2,l=0),startMsg(),$.ajaxSingle({type:"post",data:{UID:c,IID:e,CAT:b,DES:a,TAG:d,PID:f,PPW:h,PLD:k,REC:g,PST:p,PED:n,ED:0},url:"/f/UpdateFileRefTwitterF.jsp",dataType:"json",success:function(a){console.log("UpdateFileRefTwitterF:"+
a.content_id);a&&0<a.content_id?0<multiFileUploader.getSubmittedNum()?(multiFileUploader.user_id=c,multiFileUploader.illust_id=e,multiFileUploader.recent=g,multiFileUploader.first_file=!0,multiFileUploader.tweet=l,multiFileUploader.tweet_image=m,multiFileUploader.newfile_num=multiFileUploader.getSubmittedNum(),multiFileUploader.uploadStoredFiles()):(UpdateFileOrder(c,e),location.href="/MyHomePcV.jsp"):errorMsg(a.result)}})}}
function initUpdatePaste(c,e){console.log("initUpdatePaste");$("#OptionTweet").prop("checked",getTweetSetting());$("#OptionImage").prop("checked",getTweetImageSetting());var b=getLastCategorySetting();$("#EditCategory option").each(function(){console.log($(this).val());$(this).val()==b&&$("#EditCategory").val(b)});updateTweetButton();g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(a,b){10>$(".InputFile").length&&
(a=createPasteElm(b.dataURL),$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",function(a,b){b.url&&alert("error data : "+b.url)}).on("pasteText",function(a,b){$("#TimeLineAddImage").html(g_strPasteMsg)});$.ajax({type:"post",data:{ID:c,TD:e},url:"/f/GetIllustFileListF.jsp",dataType:"json",success:function(a){$.each(a,function(a,b){10>$(".InputFile").length&&(a=createPasteListItem(b.thumbnailUrl,b.append_id),$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));
updatePasteNum()})}})}function UpdatePasteAppendFAjax(c,e,b){c.parent().addClass("Done");c=c.attr("src").replace("data:image/png;base64,","");return 0>=c.length?null:$.ajax({type:"post",data:{UID:e,IID:b,DATA:c},url:"/f/UpdatePasteAppendF.jsp",dataType:"json",async:!1})}function UpdateFileRefTwitterFAjax(c,e,b,a,d,f,h,g,l,m,k){return $.ajax({type:"post",data:{UID:c,IID:e,CAT:b,DES:a,TAG:d,PID:f,PPW:h,PLD:g,REC:l,PST:m,PED:k,ED:1},url:"/f/UpdateFileRefTwitterF.jsp",dataType:"json"})}
function UploadFileTweetFAjax(c,e,b){return $.ajax({type:"post",data:{UID:c,IID:e,IMG:b},url:"/f/UploadFileTweetF.jsp",dataType:"json"})}
function createUpdatePaste(){var c=!1;return function(e,b){if(!c){c=!0;var a=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&a++});console.log(a);if(!(0>=a)){var d=$("#EditCategory").val(),f=$.trim($("#EditDescription").val());f=f.substr(0,200);var h=$.trim($("#EditTagList").val());h=h.substr(0,100);var g=$("#EditPublish").val(),l=$("#EditPassword").val(),m=$("#OptionRecent").prop("checked")?1:0,k=$("#OptionTweet").prop("checked")?1:0,p=$("#OptionImage").prop("checked")?1:0,
n=null,q=$("#EditTimeLimitedStart").val(),r=$("#EditTimeLimitedEnd").val();10==g&&(n=$("#EditTwitterList").val());if(11!=g||checkPublishDatetime(q,r,!0,$("#EditTimeLimitedStartPresent").val(),$("#EditTimeLimitedEndPresent").val())){setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(d);99==g&&(m=2,k=0);startMsg();var t=[],u=null;UpdateFileRefTwitterFAjax(e,b,d,f,h,g,l,n,m,q,r).done(function(a){var b=null;$(".imgView").each(function(){b=
UpdatePasteAppendFAjax($(this),e,a.content_id);null!=b&&t.push(b)});u=1==k?UploadFileTweetFAjax(e,a.content_id,p):function(){var a=$.Deferred();a.resolve();return a.promise()};$.when.apply($,t).then(function(){var b=[];$.each($("#PasteZone").sortable("toArray"),function(a,c){b.push(parseInt(c))});for(var c=0;c<arguments.length;c++){var d=1==b.length?arguments[0].append_id:arguments[c][0].append_id;0<=d&&(b[c]=d);if(1==b.length)break}return UpdatePasteOrderAjax(e,a.content_id,b)},function(a){errorMsg(-10)}).then(u,
function(a){errorMsg(-11)}).then(function(){completeMsg();setTimeout(function(){location.href="/MyHomePcV.jsp"},1E3)},function(a){errorMsg(-12)})});return!1}}}}}var UpdatePaste=createUpdatePaste();
