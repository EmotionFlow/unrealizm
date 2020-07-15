package jp.pipa.poipiku.settlement.epsilon;

import jp.pipa.poipiku.util.Log;

public class User {
    private String m_strUserId;
    public User(String strUserId) {
        m_strUserId = strUserId;
    }

    public boolean deleteUserInfo() {
        SettlementSendInfo ssi = new SettlementSendInfo();
        ssi.userId = m_strUserId;
        ssi.processCode = 9; // 退会
        ssi.memo1 = "DUMMY";
        ssi.memo2 = "DUMMY";
        ssi.xml = 1;

        EpsilonSettlement epsilonSettlement = new EpsilonSettlement(ssi);
        SettlementResultInfo settlementResultInfo = epsilonSettlement.execSettlement();
        if (settlementResultInfo != null) {
            String settlementResultCode = settlementResultInfo.getResult();
            Log.d("settlementResultInfo: " + settlementResultInfo.toString());
            if ("1".equals(settlementResultCode)) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
   }

}
