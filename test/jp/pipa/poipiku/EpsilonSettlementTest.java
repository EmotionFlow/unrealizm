package jp.pipa.poipiku;

import org.junit.jupiter.api.BeforeEach;

// Epsilon CGIへの接続が必要なテスト。必要な時のみ、コメントインして実行する。
public class EpsilonSettlementTest {
	@BeforeEach
	void setUp() {
		DBConnection.setUp();
	}
//	@Test
//	public void testChangeCreditCardInfo() {
//		CardSettlementEpsilon settlementEpsilon = new CardSettlementEpsilon(21808);
//		String rediectUrl = settlementEpsilon.changeCreditCardInfo();
//		Log.d(rediectUrl);
//		assertTrue(rediectUrl!=null &&  !rediectUrl.isEmpty());
//	}

//	@Test
//	public void testCancelSubscription() {
//		CardSettlementEpsilon settlementEpsilon = new CardSettlementEpsilon(431846);
//		assertTrue(settlementEpsilon.cancelSubscription(664));
//	}
}
