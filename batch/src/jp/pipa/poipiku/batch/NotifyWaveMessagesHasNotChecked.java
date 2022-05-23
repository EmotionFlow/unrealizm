package jp.pipa.poipiku.batch;

import jp.pipa.poipiku.notify.WaveMessagesHasNotCheckedNotifier;
import jp.pipa.poipiku.util.Log;

import java.time.LocalDateTime;

public class NotifyWaveMessagesHasNotChecked extends Batch {
	// 配信時間帯
	private static final int[] DELIVERY_TIME = {7, 23};

	public static void main(String[] args) {
		// 配信時間帯外だったら何もしない
		LocalDateTime now = LocalDateTime.now();
		if (!(DELIVERY_TIME[0] < now.getHour() && now.getHour() < DELIVERY_TIME[1])) {
			Log.d("配信時間外");
			return;
		}

		WaveMessagesHasNotCheckedNotifier notifier = new WaveMessagesHasNotCheckedNotifier();
		notifier.notifyWave(dataSource);
	}
}
