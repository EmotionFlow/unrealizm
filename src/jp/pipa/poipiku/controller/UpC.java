package jp.pipa.poipiku.controller;

public class UpC {
    protected static int TweetParamToDB(boolean isTweetTxt, boolean isTweetImg){
        int ret = 0;
        if(isTweetTxt) ret += 1;
        if(isTweetImg) ret += 2;
        return ret;
    };
};
