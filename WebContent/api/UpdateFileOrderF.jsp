<%@page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.nio.file.Path"%>
<%@page import="java.nio.file.Paths"%>
<%@page import="java.nio.file.Files"%>
<%@page import="java.io.IOException"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@page import="org.apache.commons.fileupload.disk.*"%>
<%@page import="org.apache.commons.fileupload.servlet.*"%>
<%@page import="org.codehaus.jackson.JsonGenerationException"%>
<%@page import="org.codehaus.jackson.map.JsonMappingException"%>
<%@page import="org.codehaus.jackson.map.ObjectMapper"%>
<%@page import="org.apache.commons.collections4.*"%>
<%@include file="/inner/Common.jsp"%>
<%!class UpdateFileOrderCParam {
	public int m_nUserId = -1;
	public int m_nContentId = 0;
	public int[] m_vNewIdList = null;

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			m_nUserId		= Common.ToInt(request.getParameter("UID"));
			m_nContentId	= Common.ToInt(request.getParameter("IID"));
			String strJson	= Common.TrimAll(request.getParameter("AID"));

			ObjectMapper mapper = new ObjectMapper();
			m_vNewIdList = mapper.readValue(strJson, int[].class);

			Log.d("m_nUserId:" + m_nUserId);
			Log.d("m_nContentId:" + m_nContentId);
			Log.d(strJson);
			nRtn = 0;
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			nRtn = -99;
		}
		return nRtn;
	}
}
public class CEditedContent {
	public int append_id = 0;
	public int file_width = 0;
	public int file_height = 0;
	public long files_size = 0;
	public long file_complex = 0;
	public String name = "";

	public CEditedContent() {}
}

class UpdateFileOrderC {
	public int GetResults(UpdateFileOrderCParam cParam, ResourceBundleControl _TEX) {
		int nRtn = -1;
		DataSource dsPostgres = null;
		Connection cConn = null;
		PreparedStatement cState = null;
		ResultSet cResSet = null;
		String strSql = "";

		try {
			// regist to DB
			dsPostgres = (DataSource)new InitialContext().lookup(Common.DB_POSTGRESQL);
			cConn = dsPostgres.getConnection();

			//元のファイルリストを取得
			strSql = "(SELECT -1 as append_id,file_name,file_width,file_height,file_size,file_complex FROM contents_0000 WHERE user_id=? AND content_id=?) UNION (SELECT append_id,file_name,file_width,file_height,file_size,file_complex FROM contents_appends_0000 WHERE content_id=?) ORDER BY append_id";
			cState = cConn.prepareStatement(strSql);
			cState.setInt(1, cParam.m_nUserId);
			cState.setInt(2, cParam.m_nContentId);
			cState.setInt(3, cParam.m_nContentId);
			cResSet = cState.executeQuery();

			//画像情報をファイルリストにセット
			List<CEditedContent> vNewFileList = new ArrayList<CEditedContent>(cParam.m_vNewIdList.length);
			List<CEditedContent> vOldFileList = new ArrayList<CEditedContent>(cParam.m_vNewIdList.length);
			while (cResSet.next()) {
				CEditedContent cOld = new CEditedContent();
				cOld.append_id = cResSet.getInt("append_id");
				cOld.name = cResSet.getString("file_name");
				cOld.file_width = cResSet.getInt("file_width");
				cOld.file_height = cResSet.getInt("file_height");
				cOld.files_size = cResSet.getLong("file_size");
				cOld.file_complex = cResSet.getLong("file_complex");
				vOldFileList.add(cOld);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			for (int append_id: cParam.m_vNewIdList) {
				for (CEditedContent cOld: vOldFileList) {
					if (append_id == cOld.append_id) {
						CEditedContent cNew = new CEditedContent();
						cNew.append_id = cOld.append_id;
						cNew.name = cOld.name;
						cNew.file_width = cOld.file_width;
						cNew.file_height = cOld.file_height;
						cNew.files_size = cOld.files_size;
						cNew.file_complex = cOld.file_complex;
						vNewFileList.add(cNew);
						break;
					}
				}
			}

			//旧リストにあって新リストにないファイルを抽出（削除候補）
			List<CEditedContent> cDiff = new ArrayList<CEditedContent>();
			for (CEditedContent cOld: vOldFileList) {
				boolean bExist = false;
				for (int append_id: cParam.m_vNewIdList) {
					if (cOld.append_id==append_id) {
						bExist = true;
						break;
					}
				}
				if(!bExist) cDiff.add(cOld);
			}

			//不要ファイルの削除
			if (cDiff.size() > 0) {
				String[] strDelList = new String[cDiff.size()];
				for (int i=0; i<cDiff.size(); i++) {
					strDelList[i] = Integer.toString(cDiff.get(i).append_id);
					String strPath = getServletContext().getRealPath(cDiff.get(i).name);
					Log.d(strPath);
					ImageUtil.deleteFile(strPath);
					ImageUtil.deleteFile(strPath + "_360.jpg");
					ImageUtil.deleteFile(strPath + "_640.jpg");
				}
				Log.d("File to delete:" + String.join(",", strDelList));

				//不要レコード削除
				if (strDelList.length > 0) {
					strSql = "DELETE FROM contents_appends_0000 WHERE content_id=? AND append_id IN (" + String.join(",", strDelList) + ");";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cParam.m_nContentId);
					cState.executeUpdate();
					cState.close();cState=null;
				}
			}

			//並び替え
			for (int i=0; i<vNewFileList.size(); i++) {
				Log.d("Old:" + vOldFileList.get(i).append_id + " New:" + vNewFileList.get(i).append_id);
				if (vNewFileList.get(i).append_id != vOldFileList.get(i).append_id) {
					//先頭画像はcontents_0000にセット
					if (i == 0) {
						strSql = "UPDATE contents_0000 SET file_name=?,file_width=?,file_height=?,file_size=?,file_complex=?,file_num=? WHERE content_id=?;";
						cState = cConn.prepareStatement(strSql);
						cState.setString(1, vNewFileList.get(i).name);
						cState.setInt(2, vNewFileList.get(i).file_width);
						cState.setInt(3, vNewFileList.get(i).file_height);
						cState.setLong(4, vNewFileList.get(i).files_size);
						cState.setLong(5, vNewFileList.get(i).file_complex);
						cState.setLong(6, vNewFileList.size());
						cState.setInt(7, cParam.m_nContentId);
						cState.executeUpdate();
					//2枚目以降はcontents_appends_0000にセット
					} else {
						strSql = "UPDATE contents_appends_0000 SET file_name=?,file_width=?,file_height=?,file_size=?,file_complex=? WHERE content_id=? AND append_id=?";
						cState = cConn.prepareStatement(strSql);
						cState.setString(1, vNewFileList.get(i).name);
						cState.setInt(2, vNewFileList.get(i).file_width);
						cState.setInt(3, vNewFileList.get(i).file_height);
						cState.setLong(4, vNewFileList.get(i).files_size);
						cState.setLong(5, vNewFileList.get(i).file_complex);
						cState.setInt(6, cParam.m_nContentId);
						cState.setInt(7, vOldFileList.get(i).append_id);
						cState.executeUpdate();
					}
				}
			}

			//先頭が削除されて1個ずつズレるケース
			int pos = 0;
			if (vNewFileList.size() < vOldFileList.size()) {
				String[] strDelList = new String[vOldFileList.size() - vNewFileList.size()];
				for (int d = vNewFileList.size(); d < vOldFileList.size(); d++) {
					strDelList[pos++] = Integer.toString(vOldFileList.get(d).append_id);
				}
				strSql = "DELETE FROM contents_appends_0000 WHERE content_id=? AND append_id IN (" + String.join(",", strDelList) + ");";
				cState = cConn.prepareStatement(strSql);
				cState.setInt(1, cParam.m_nContentId);
				cState.executeUpdate();
				cState.close();cState=null;
			}

			nRtn = 0;
		} catch(Exception e) {
			Log.d(strSql);
			e.printStackTrace();
		} finally {
			try{if(cResSet!=null){cResSet.close();cResSet=null;}}catch(Exception e){;}
			try{if(cState!=null){cState.close();cState=null;}}catch(Exception e){;}
			try{if(cConn!=null){cConn.close();cConn=null;}}catch(Exception e){;}
		}
		return nRtn;
	}
}%><%
Log.d("UpdateFileOrderC");
CheckLogin cCheckLogin = new CheckLogin(request, response);

int nRtn = 0;
UpdateFileOrderCParam cParam = new UpdateFileOrderCParam();
cParam.m_nUserId = cCheckLogin.m_nUserId;
nRtn = cParam.GetParam(request);

if (cCheckLogin.m_bLogin && cParam.m_nUserId==cCheckLogin.m_nUserId && nRtn==0) {
	UpdateFileOrderC cResults = new UpdateFileOrderC();
	nRtn = cResults.GetResults(cParam, _TEX);
}
%>
{"result": <%=nRtn%>}