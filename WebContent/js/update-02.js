function UpdateFileOrder(b,d,c){var a=[];$.each($(".qq-upload-list-selector.qq-upload-list").sortable("toArray"),function(c,b){a.push(parseInt(b))});$.ajax({type:"post",data:{UID:b,IID:d,AID:JSON.stringify(a)},url:"/f/UpdateFileOrderF.jsp",dataType:"json",success:function(a){console.log("UploadFileOrderF:"+a.result);c&&0<c.length&&(completeMsg(),setTimeout(function(){location.href=c},1E3))},error:function(a){console.log(a)}})}
function UpdatePasteOrderAjax(b,d,c){return $.ajax({type:"post",data:{UID:b,IID:d,AID:JSON.stringify(c)},url:"/f/UpdateFileOrderF.jsp",dataType:"json"})}
function initUpdateFile(b,d){updateTweetButton();multiFileUploader=new qq.FineUploader({session:{endpoint:"/f/GetIllustFileListF.jsp?TD="+d+"&ID="+b,refreshOnRequest:!0},element:document.getElementById("file-drop-area"),autoUpload:!1,button:document.getElementById("TimeLineAddImage"),maxConnections:1,validation:{allowedExtensions:["jpeg","jpg","gif","png"],itemLimit:200,sizeLimit:2E7,stopOnFirstInvalidFile:!1},retry:{enableAuto:!1},callbacks:{onUpload:function(c,a){this.newfile_num&&0<this.newfile_num&&
(this.setEndpoint("/f/UpdateFileAppendF.jsp",c),this.setParams({UID:this.user_id,IID:this.content_id},c))},onComplete:function(c,a,b,d){append_id=b.append_id;$(".qq-file-id-"+c).attr("id",append_id)},onAllComplete:function(c,a){console.log("onAllComplete",c,a,this.tweet);this.newfile_num&&0<this.newfile_num?(1==this.tweet?Tweet(this.user_id,this.content_id,this.tweet_image,this.delete_tweet):(completeMsg(),setTimeout(function(){location.href="/MyIllustListV.jsp"},1E3)),UpdateFileOrder(this.user_id,
this.content_id,"/MyIllustListV.jsp")):($("li.qq-upload-success").removeClass("qq-upload-success"),$("button.qq-upload-cancel").removeClass("qq-hide"))},onValidate:function(c){var a=this.getSubmittedSize(),b=this.getSubmittedNum();this.showTotalSize(a,b);a+=c.size;if(a>this.total_size)return!1;this.showTotalSize(a,b+1)},onStatusChange:function(c,a,b){this.newfile_num&&0<this.newfile_num&&this.showTotalSize(this.getSubmittedSize(),this.getSubmittedNum())}}});multiFileUploader.getSubmittedNum=function(){return this.getUploads({status:qq.status.SUBMITTED}).length};
multiFileUploader.getSubmittedSize=function(){var c=this.getUploads({status:qq.status.SUBMITTED}),a=0;$.each(c,function(){a+=this.size});return a};multiFileUploader.showTotalSize=function(c,a){var b="(jpeg|png|gif, 200files, total 50MByte)";0<c&&(b="("+a+"/200,  "+Math.ceil((multiFileUploader.total_size-c)/1024)+" KByte)",$("#TimeLineAddImage").removeClass("Light"),completeAddFile());$("#TotalSize").html(b)};multiFileUploader.sessionRequestComplete=function(b,a,d,h){alert(a)};multiFileUploader.total_size=
52428800}function Tweet(b,d,c,a){$.ajax({type:"post",data:{UID:b,IID:d,IMG:c,DELTW:a},url:"/f/UploadFileTweetF.jsp",dataType:"json",success:function(a){console.log("UploadFileTweetF");completeMsg();setTimeout(function(){location.href="/MyIllustListV.jsp"},1E3)}})}
function UpdateFile(b,d){if(multiFileUploader&&!(0>=$(".qq-upload-list-selector.qq-upload-list").children("li").length)){var c=$("#EditCategory").val(),a=$.trim($("#EditDescription").val());a=a.substr(0,200);var g=$.trim($("#EditTagList").val());g=g.substr(0,100);var h=$("#ContentOpenId").val(),e=$("#EditPublish").val(),q=$("#EditPassword").val(),p=$("#OptionRecent").prop("checked")?1:0,r=$("#OptionTweet").prop("checked")?1:0,t=$("#OptionImage").prop("checked")?1:0,k=$("#OptionDeleteTweet").prop("checked")?
1:0,u=null,l=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),f=null,m=null;10==e&&(u=$("#EditTwitterList").val());if(1==l&&(f=getPublishDateTime($("#EditTimeLimitedStart").val()),m=getPublishDateTime($("#EditTimeLimitedEnd").val()),strPublishStartPresent=$("#EditTimeLimitedStartPresent").val(),strPublishEndPresent=$("#EditTimeLimitedEndPresent").val(),!checkPublishDatetime(f,m,!0,strPublishStartPresent,strPublishEndPresent)))return;setTweetSetting($("#OptionTweet").prop("checked"));setTweetImageSetting($("#OptionImage").prop("checked"));
setLastCategorySetting(c);99==e&&(r=0);var n=r;1==l&&(n=2!=h&&comparePublishDate(strPublishStartPresent,f)&&comparePublishDate(strPublishEndPresent,m)?1:0);startMsg();$.ajaxSingle({type:"post",data:{IID:d,UID:b,CAT:c,DES:a,TAG:g,PID:e,PPW:q,PLD:u,LTP:l,REC:p,PST:f,PED:m,TWT:getTweetSetting(),TWI:getTweetImageSetting(),DELTW:k,ED:0},url:"/f/UpdateFileRefTwitterF.jsp",dataType:"json",success:function(a){console.log("UpdateFileRefTwitterF:"+a.content_id);a&&0<a.content_id?0<multiFileUploader.getSubmittedNum()?
(multiFileUploader.user_id=b,multiFileUploader.content_id=d,multiFileUploader.tweet=n,multiFileUploader.tweet_image=t,multiFileUploader.delete_tweet=k,multiFileUploader.newfile_num=multiFileUploader.getSubmittedNum(),multiFileUploader.uploadStoredFiles()):1==n?(UpdateFileOrder(b,d,null),Tweet(b,d,t,k)):UpdateFileOrder(b,d,"/MyIllustListV.jsp"):errorMsg(a.result)}})}}
function initUpdatePaste(b,d){updateTweetButton();var c=getLastCategorySetting();$("#EditCategory option").each(function(){$(this).val()==c&&$("#EditCategory").val(c)});g_strPasteMsg=$("#TimeLineAddImage").html();$("#TimeLineAddImage").pastableContenteditable();$("#TimeLineAddImage").on("pasteImage",function(a,b){10>$(".InputFile").length&&(a=createPasteElm(b.dataURL),$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()}).on("pasteImageError",function(a,b){b.url&&
alert("error data : "+b.url)}).on("pasteText",function(a,b){$("#TimeLineAddImage").html(g_strPasteMsg)});$.ajax({type:"post",data:{ID:b,TD:d},url:"/f/GetIllustFileListF.jsp",dataType:"json",success:function(a){$.each(a,function(a,b){10>$(".InputFile").length&&(a=createPasteListItem(b.thumbnailUrl,b.append_id),$("#PasteZone").append(a),$("#TimeLineAddImage").html(g_strPasteMsg));updatePasteNum()})}})}
function UpdatePasteAppendFAjax(b,d,c){b.parent().addClass("Done");b=b.attr("src").replace("data:image/png;base64,","");return 0>=b.length?null:$.ajax({type:"post",data:{UID:d,IID:c,DATA:b},url:"/f/UpdatePasteAppendF.jsp",dataType:"json",async:!1})}function UpdateFileRefTwitterFAjax(b,d,c,a,g,h,e,q,p,r,t,k,u,l,f){return $.ajax({type:"post",data:{UID:b,IID:d,CAT:c,DES:a,TAG:g,PID:h,PPW:e,PLD:q,LTP:r,REC:p,PST:t,PED:k,TWT:u,TWI:l,DELTW:f,ED:1},url:"/f/UpdateFileRefTwitterF.jsp",dataType:"json"})}
function UploadFileTweetFAjax(b,d,c,a){return $.ajax({type:"post",data:{UID:b,IID:d,IMG:c,DELTW:a},url:"/f/UploadFileTweetF.jsp",dataType:"json"})}
function createUpdatePaste(){var b=!1;return function(d,c){if(!b){b=!0;var a=0;$(".imgView").each(function(){0<$.trim($(this).attr("src")).length&&a++});console.log(a);if(!(0>=a)){var g=$("#EditCategory").val(),h=$.trim($("#EditDescription").val());h=h.substr(0,200);var e=$.trim($("#EditTagList").val());e=e.substr(0,100);var q=$("#ContentOpenId").val(),p=$("#EditPublish").val(),r=$("#EditPassword").val(),t=$("#OptionRecent").prop("checked")?1:0,k=$("#OptionTweet").prop("checked")?1:0,u=$("#OptionImage").prop("checked")?
1:0,l=$("#OptionDeleteTweet").prop("checked")?1:0,f=null,m=getLimitedTimeFlg("EditPublish","OptionLimitedTimePublish"),n=null,v=null;10==p&&(f=$("#EditTwitterList").val());if(1==m&&(n=getPublishDateTime($("#EditTimeLimitedStart").val()),v=getPublishDateTime($("#EditTimeLimitedEnd").val()),strPublishStartPresent=$("#EditTimeLimitedStartPresent").val(),strPublishEndPresent=$("#EditTimeLimitedEndPresent").val(),!checkPublishDatetime(n,v,!0,strPublishStartPresent,strPublishEndPresent)))return;setTweetSetting($("#OptionTweet").prop("checked"));
setTweetImageSetting($("#OptionImage").prop("checked"));setLastCategorySetting(g);99==p&&(k=0);var w=k;1==m&&(w=2==q||null!=strPublishStartPresent&&null!=strPublishEndPresent?2!=q&&comparePublishDate(strPublishStartPresent,n)&&comparePublishDate(strPublishEndPresent,v)?1:0:0);startMsg();var x=[],y=null;UpdateFileRefTwitterFAjax(d,c,g,h,e,p,r,f,t,m,n,v,getTweetSetting(),getTweetImageSetting(),l).done(function(a){var b=null;$(".imgView").each(function(){b=UpdatePasteAppendFAjax($(this),d,a.content_id);
null!=b&&x.push(b)});y=1==w?UploadFileTweetFAjax(d,a.content_id,u,l):function(){var a=$.Deferred();a.resolve();return a.promise()};$.when.apply($,x).then(function(){var b=[];$.each($("#PasteZone").sortable("toArray"),function(a,c){b.push(parseInt(c))});for(var c=0;c<arguments.length;c++){var e=1==b.length?arguments[0].append_id:arguments[c][0].append_id;0<=e&&(b[c]=e);if(1==b.length)break}return UpdatePasteOrderAjax(d,a.content_id,b)},function(a){errorMsg(-10)}).then(y,function(a){errorMsg(-11)}).then(function(){completeMsg();
setTimeout(function(){location.href="/MyIllustListV.jsp"},1E3)},function(a){errorMsg(-12)})});return!1}}}}var UpdatePaste=createUpdatePaste();
