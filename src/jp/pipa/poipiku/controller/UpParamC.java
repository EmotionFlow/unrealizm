package jp.pipa.poipiku.controller;

import java.io.UnsupportedEncodingException;

import javax.servlet.http.HttpServletRequest;

public class UpParamC {
    protected void GetParams(HttpServletRequest request) throws Exception{
        request.setCharacterEncoding("UTF-8");
    };
};
