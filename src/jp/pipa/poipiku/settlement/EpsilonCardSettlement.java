package jp.pipa.poipiku.settlement;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.settlement.epsilon.*;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class EpsilonCardSettlement extends CardSettlement {

    protected String createOrderId(int userId, int contentId){
        return String.format("poipiku-%d-%d-%d", userId, contentId, System.currentTimeMillis());
    }

    private String getAgentUserId(int userId){
        return String.format("poipiku-com-%d", userId);
    }

    public EpsilonCardSettlement(int _userId, int _contentId, int _poipikuOrderId, int _amount,
                                 String _agentToken, String _cardExpire, String _cardSecurityCode){
        super(_userId, _contentId, _poipikuOrderId, _amount, _agentToken, _cardExpire, _cardSecurityCode);
        agent_id = Agent.EPSILON;
    }

    public boolean authorize(){
        if(!authorizeCheckBase()){
            return false;
        }

        //TODO 初回か登録済かを判定
        boolean isFirst = true;

        SettlementSendInfo ssi = new SettlementSendInfo();
        ssi.setUserId(getAgentUserId(userId));
        ssi.setUserName("DUMMY");
        ssi.setUserNameKana("DUMMY");
        ssi.setUserMailAdd("dummy@example.com");
        ssi.setItemCode(Integer.toString(poipikuOrderId));

        ssi.setStCode("11000-0000-00000");
        ssi.setMissionCode(1);               // 課金区分（一回課金固定）
        ssi.setProcessCode(isFirst ? 1 : 2); // 初回/登録済み課金
        ssi.setUserTel("00000000000");
        ssi.setConveniCode(0);              // コンビニ指定なし

        ssi.setOrderNumber(createOrderId(userId, contentId));
        ssi.setMemo1("");
        ssi.setMemo2("");

        EpsilonSettlement epsilonSettlement = new EpsilonSettlement(ssi);
        SettlementResultInfo settlementResultInfo = epsilonSettlement.execSettlement();
        if( settlementResultInfo != null ){
            /* settlementResultInfo.getResult()
            0：決済NG
            1：決済OK
            5：3DS処理　（カード会社に接続必要）
            9：システムエラー（パラメータ不足、不正等）
             */
            if( "1".equals(settlementResultInfo.getResult())){
                // TODO TABLE creditcard_tokensにレコードがなかったら追加、あるなら更新。
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
}