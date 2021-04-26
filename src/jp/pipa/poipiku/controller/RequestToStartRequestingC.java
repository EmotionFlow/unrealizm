package jp.pipa.poipiku.controller;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.cache.CacheUsers0000;
import jp.pipa.poipiku.util.DatabaseUtil;
import jp.pipa.poipiku.util.Log;
import jp.pipa.poipiku.util.Util;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public final class RequestToStartRequestingC extends Controller{
	public enum ResultDetail implements CodeEnum<RequestToStartRequestingC.ResultDetail> {
		Undef(0),
		Done(1),
		AlreadyRequested(2),
		Error(-1);

		@Override
		public int getCode() {
			return code;
		}

		private final int code;
		private ResultDetail(int code) {
			this.code = code;
		}
	}

	public ResultDetail resultDetail = ResultDetail.Undef;
	public int clientUserId = -1;
	public int creatorUserId = -1;

    public RequestToStartRequestingC(){}

	public void getParam(HttpServletRequest request) {
		try {
			request.setCharacterEncoding("UTF-8");
			clientUserId = Util.toInt(request.getParameter("CLIENT"));
			creatorUserId = Util.toInt(request.getParameter("CREATOR"));
		} catch(Exception ignored) { }
	}

    public boolean getResults(CheckLogin checkLogin) {
    	boolean result = false;
    	resultDetail = ResultDetail.Error;
    	if (!checkLogin.m_bLogin) return false;
    	if (checkLogin.m_nUserId != clientUserId) return false;

	    CacheUsers0000 cacheUsers = CacheUsers0000.getInstance();
	    CacheUsers0000.User u = cacheUsers.getUser(creatorUserId);
	    if (u == null) {
		    // 存在しないクリエイターあての場合、正常処理したようにしておく。
		    resultDetail = ResultDetail.Done;
		    result = true;
	    } else {
		    RequestToStartRequesting req = new RequestToStartRequesting(clientUserId, creatorUserId);
		    if (req.isExists()) {
			    resultDetail = ResultDetail.AlreadyRequested;
			    result = true;
		    } else {
			    if (req.insert()) {
				    resultDetail = ResultDetail.Done;
				    Request poipikuRequest = new Request();
				    poipikuRequest.creatorUserId = creatorUserId;
				    int total_count = req.countByCreator();
				    if (total_count >= 1 && total_count <= 10) {
					    RequestNotifier.notifyRequestToStartRequesting(poipikuRequest.creatorUserId, total_count, false);
				    } else if (total_count % 10 == 0) {
					    RequestNotifier.notifyRequestToStartRequesting(poipikuRequest.creatorUserId, total_count, true);
				    }
				    result = true;
			    } else {
				    resultDetail = ResultDetail.Error;
			    }
		    }
	    }
		return result;
	}
}
