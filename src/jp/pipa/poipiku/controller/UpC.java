package jp.pipa.poipiku.controller;
import jp.pipa.poipiku.*;

public class UpC {
    protected static int GetSafeFilterDB(int publishId){
        int safe_filter = Common.SAFE_FILTER_ALL;
        switch(publishId) {
            case Common.PUBLISH_ID_R15:
                safe_filter = Common.SAFE_FILTER_R15;
                break;
            case Common.PUBLISH_ID_R18:
                safe_filter = Common.SAFE_FILTER_R18;
                break;
            case Common.PUBLISH_ID_R18G:
                safe_filter = Common.SAFE_FILTER_R18G;
                break;
        }
        return safe_filter;
    }
    protected static int GetTweetParamDB(boolean isTweetTxt, boolean isTweetImg){
        int ret = 0;
        if(isTweetTxt) ret += 1;
        if(isTweetImg) ret += 2;
        return ret;
    }
}
