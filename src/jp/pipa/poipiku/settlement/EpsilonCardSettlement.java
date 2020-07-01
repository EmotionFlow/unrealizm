package jp.pipa.poipiku.settlement;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Log;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class EpsilonCardSettlement extends CardSettlement {

    protected String createOrderId(int userId, int contentId){
        return String.format("poipiku-%d-%d-%d", userId, contentId, System.currentTimeMillis());
    }

    private String createAgentUserId(int userId){
        return String.format("poipiku_com_%d", userId);
    }

    public EpsilonCardSettlement(int _userId, int _contentId, int _amount,
                                 String _agentToken, String _cardExpire, String _cardSecurityCode){
        super(_userId, _contentId, _amount, _agentToken, _cardExpire, _cardSecurityCode);
        agent_id = Agent.EPSILON;
    }

    public boolean authorize(){
        if(!authorizeCheckBase()){
            return false;
        }

        SettlementSendInfo ssi = new SettlementSendInfo();
        ssi.setUserId(userId);
        ssi.setUserName(userName);
        ssi.setUserNameKana(userNameKana);
        ssi.setUserMailAdd(userMailAdd);
        ssi.setItemCode(config.getItem_code());
        // 商品の指定がある場合のみ入れておく
        if( !item.isEmpty() ){
            ssi.setItemName((String)resource.getGoods().get(item).get("name"));
            ssi.setItemPrice((Integer)resource.getGoods().get(item).get("price"));
        }
        ssi.setStCode((String)resource.getSelect_st_code().get(st));
        ssi.setMissionCode(Integer.parseInt(missionCode));
        ssi.setProcessCode(Integer.parseInt(processCode));
        ssi.setUserTel(userTel);
        ssi.setConveniCode(Integer.parseInt(conveniCode));
        // オーダーNoを設定→ここでは「年月日時分秒ミリ」
        ssi.setOrderNumber( new SimpleDateFormat("yyyyMMddHHmmssSSS").format(Calendar.getInstance().getTime())	);
        ssi.setMemo1(config.getMemo1());
        ssi.setMemo2(config.getMemo2());
        if ( consigneePostal != null && !consigneePostal.isEmpty()){
            ssi.setConsigneePostal(consigneePostal);
            ssi.setConsigneeName(consigneeName);
            ssi.setConsigneeAddress(String.format("%s%s", resource.getPref_list().get(consigneePref),
                    consigneeAddress ) );
            ssi.setConsigneeTel(consigneeTel);
            ssi.setOrdererPostal(ordererPostal);
            ssi.setOrdererName(ordererName);
            ssi.setOrdererAddress(String.format("%s%s", resource.getPref_list().get(ordererPref),
                    ordererAddress ) );
            ssi.setOrdererTel(ordererTel);
        }
        EpsilonSettlement epsilonSettlement = new EpsilonSettlement(ssi,config);
        SettlementResultInfo settlementResultInfo = epsilonSettlement.execSettlement();
        if( settlementResultInfo != null ){
            if( "0".equals(settlementResultInfo.getResult())){
                request.setAttribute("err_msg",settlementResultInfo.getErrCode()+" "+ settlementResultInfo.getErrDetail());
            }else if( settlementResultInfo.getRedirect() != null){
                // EPSILONにリダイレクト
                response.sendRedirect(settlementResultInfo.getRedirect());
                return;
            }else if( settlementResultInfo.getTransCode() != null ){
                String redirect = String.format("/sample_java/settlement_comp?trans_code=%s",settlementResultInfo.getTransCode());
                response.sendRedirect(redirect);
                return;
            }else{
                ServletContext context = this.getServletContext();
                request.setAttribute("result", settlementResultInfo.getResult());
                RequestDispatcher dispatcher
                        = context.getRequestDispatcher("/jsp/userResult.jsp");
                dispatcher.forward(request, response);
                return;
            }
        }else{
            request.setAttribute("err_msg", "データの送信に失敗しました");
        }



        return false;

    }

}