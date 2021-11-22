<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script type="text/javascript">
	function DispNeedLoginMsg() {
		DispMsg("<%=_TEX.T("Common.NeedLogin")%>");
	}
	function DispUnknownErrorMsg() {
		DispMsg("<%=_TEX.T("Common.Error.ERR_UNKNOWN")%>");
	}
	$(function(){initDetailOverlay();});
</script>

<div id="DetailOverlay">
	<div class="DetailOverlayHeader"><div id="DetailOverlayClose" class="DetailOverlayClose"><i class="fas fa-times"></i></div></div>
	<div id="DetailOverlayInner"></div>
</div>
