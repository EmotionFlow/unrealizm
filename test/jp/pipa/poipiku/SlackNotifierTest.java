package jp.pipa.poipiku;

import jp.pipa.poipiku.util.SlackNotifier;
import org.junit.jupiter.api.Test;

public class SlackNotifierTest {
	private static String WEBHOOK_URL = "https://hooks.slack.com/services/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";
	@Test
	public void testNotify() {
		SlackNotifier slackNotifier = new SlackNotifier(WEBHOOK_URL);
		slackNotifier.notify("hogehoge");
		slackNotifier.notify("12345\n67890");
		slackNotifier.notify("あいうえお");
		slackNotifier.notify("あいう\nえお");
	}
}
