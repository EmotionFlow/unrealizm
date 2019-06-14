<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="jp.pipa.poipiku.*"%>
<%@page import="jp.pipa.poipiku.util.*"%>
<script>
function getScriptOutput(src, callback) {
		var $ifr = $("<iframe hidden\/>");
		$ifr.appendTo("body");
		$ifr[0].contentWindow.setOutput = function(output) {
				$ifr.remove();
				callback(output.replace(/<script[^>]+?\/>|<script(.|\s)*?\/script>/gi, ""));
		};
		var doc = $ifr[0].contentWindow.document;
		doc.open();
		doc.write(
				"<div id=\"output\"><script src=\"" + src + "\"><\/script><\/div><script>setOutput(document.querySelector(\"#output\").innerHTML);<\/script>"
		);
		doc.close();
}
</script>
<%{%>
<%int nRand = (int)(Math.random()*10000);%>
<div id="<%=nRand%>"></div>
<script>
getScriptOutput("//ad.adpon.jp/fr.js?fid=d097c4bd-72cd-4687-9449-44e7702d7885", function(html) {
		$("#<%=nRand%>").append(html);
		//document.write(adsCode2);
		//$("h2").eq(2).before(adsCode2);
});
</script>
<%}%>