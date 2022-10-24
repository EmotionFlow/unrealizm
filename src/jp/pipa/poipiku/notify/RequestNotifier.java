package jp.pipa.poipiku.notify;
import java.io.StringWriter;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.Log;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;

public final class RequestNotifier extends Notifier {
	private static final String REQUEST_BOARD_URL = "https://unrealizm.com/MyRequestListPcV.jsp";

	public RequestNotifier(){
		vmTemplateCategory = "request";
		infoType = Common.NOTIFICATION_TYPE_REQUEST;
	}

	private boolean notifyByWeb(User to, Request request, String description){
		return super.notifyByWeb(to, request.id, -1, request.requestCategory, description, "", InsertMode.Upsert);
	}

	private void notifyByEmail(User toUser, String menuId, Request.Status requestStatus, int requestId, String statusName) {
		final String toUrl = String.format(
				"%s?MENUID=%s&ST=%d&RID=%d",
				REQUEST_BOARD_URL, menuId, requestStatus.getCode(), requestId);
		try {
			VelocityContext context = new VelocityContext();
			context.put("request_board_url", toUrl);
			context.put("to_name", toUser.nickname);

			Template template = getBodyTemplate(statusName, toUser.langLabel);

			super.notifyByEmail(toUser, getSubject(statusName, toUser.langLabel), merge(template, context));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void notifyRequestEnabled(final CheckLogin checkLogin, final ResourceBundleControl _TEX){
		try {
			User creator = new User(checkLogin.m_nUserId);

			VelocityContext context = new VelocityContext();
			context.put("to_name", checkLogin.m_strNickName);
			context.put("user_id", checkLogin.m_nUserId);

			Template template = getBodyTemplate("enabled", _TEX.T("Lang"));

			final String mailBody = merge(template, context);
			final String mailSubject = getSubject("enabled", _TEX.T("Lang"));

			super.notifyByEmail(creator, mailSubject, mailBody);
		} catch (Exception e) {
			e.printStackTrace();
			Log.d("notifyRequestEnabled failed.");
		}
	}

	public void notifyRequestReceived(final Request request){
		final User client = new User(request.clientUserId);
		final User creator = new User(request.creatorUserId);
		final String statusName = "received";
		if (client.id > 0 && creator.id > 0) {
			notifyByEmail(creator, "RECEIVED", Request.Status.WaitingApproval, request.id, statusName);
			final String title = getTitle(statusName, creator.langLabel);
			notifyByWeb(creator, request, title);
			notifyByApp(creator, title, false);
		}
	}

	public void notifyRequestCanceled(final CheckLogin checkLogin, Request request){
		/** スケブに倣ってキャンセル通知はしないでおく。
		final User client = new User(request.clientUserId);
		final User creator = new User(request.creatorUserId);
		final User notifyTo = checkLogin.m_nUserId==request.clientUserId ? creator : client;
		final String statusName = "canceled";

		if (client.id > 0 && creator.id > 0) {
			notifyByEmail(notifyTo, notifyTo.equals(client) ? "SENT" : "RECEIVED",
					Request.Status.Canceled, request.id, statusName);
			final String title = getTitle(statusName, notifyTo.langLabel);
			notifyByWeb(notifyTo, request, title);
			notifyByApp(notifyTo, title);
		}
		/**/
	}

	public void notifyRequestAccepted(Request request) {
		final User client = new User(request.clientUserId);
		final User creator = new User(request.creatorUserId);
		final String statusName = "accepted";
		if (client.id > 0 && creator.id > 0) {
			notifyByEmail(client, "SENT",
					Request.Status.InProgress, request.id, statusName + "_client");
			notifyByEmail(creator, "RECEIVED",
					Request.Status.InProgress, request.id, statusName + "_creator");

			final String title = getTitle(statusName + "_client", client.langLabel);
			notifyByWeb(client, request, title);
			notifyByApp(client, title, false);
		}
	}

	public void notifyRequestDelivered(Request request) {
		final User client = new User(request.clientUserId);
		final User creator = new User(request.creatorUserId);
		final String statusName = "delivered";
		if (client.id > 0 && creator.id > 0) {
			notifyByEmail(client, "SENT",
					Request.Status.Done, request.id, statusName);

			final String title = getTitle(statusName, client.langLabel);
			notifyByWeb(client, request, title);
			notifyByApp(client, title, false);
		}
	}

	public void notifyRequestToStartRequesting(int creatorUserId, int total_count, boolean isTotalMsg) {
		if (total_count < 0) return;
		final User creator = new User(creatorUserId);
		final String statusName = "to_start_requesting";
		if (creator.id < 0) return;
		StringWriter sw = new StringWriter();
		if (!isTotalMsg) {
			Template template = Velocity.getTemplate(getVmPath(statusName + "/title-single.vm", creator.langLabel), "UTF-8");
			template.merge(null, sw);
		} else {
			VelocityContext context = new VelocityContext();
			context.put("total_count", total_count);
			Template template = Velocity.getTemplate(getVmPath(statusName + "/title-total.vm", creator.langLabel), "UTF-8");
			template.merge(context, sw);
		}
		final String title = sw.toString();
		Request r = new Request();
		r.id = total_count * -1;
		notifyByWeb(creator, r, title);
		notifyByApp(creator, title, false);
	}
}
