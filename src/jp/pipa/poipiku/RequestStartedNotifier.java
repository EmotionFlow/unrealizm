package jp.pipa.poipiku;

import jp.pipa.poipiku.util.Log;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;

import java.util.List;

public final class RequestStartedNotifier extends Notifier{
	public RequestStartedNotifier(){
		CATEGORY = "request";
		NOTIFICATION_INFO_TYPE = Common.NOTIFICATION_TYPE_REQUEST_STARTED;
	}

	// リクエストを開始したことを周囲にお知らせする
	// followeeListが多いと2万近くなるので、非同期処理前提。
	public boolean notifyRequestStarted(int creatorUserId){
		boolean result = false;
		try {
			RequestCreator creator = new RequestCreator(creatorUserId);
			if (creator.notified == RequestCreator.NOTIFIED_STARTED) {
				Log.d(String.format("%d: フォロワーに通知済み", creatorUserId));
				return false;
			}

			User fromUser = new User(creatorUserId);

			VelocityContext context = new VelocityContext();
			context.put("creator_nickname", fromUser.nickname);

			Template template = getTitleTemplate("to_followee", "ja");
			String msg = merge(template, context);

			// クリエイターをフォローしている人一覧
			List<Integer> followeeList = FollowUser.selectFollowToMeList(fromUser.id);
			for (int userId : followeeList) {
				User toUser = new User(userId);
				notifyByWeb(toUser, creatorUserId, -1, Common.CONTENT_TYPE_TEXT, msg, InsertMode.TryInsert);
			}
			result = true;

			creator.updateNotifiedStarted();
		} catch (Exception e) {
			e.printStackTrace();
			Log.d("notifyRequestEnabled failed.");
		}
		return result;
	}
}
