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

			//並び換え、削除後のappend_idリスト
			ObjectMapper mapper = new ObjectMapper();
			m_vNewIdList = mapper.readValue(strJson, int[].class);
			Log.d("m_nUserId:" + m_nUserId);
			Log.d("m_nContentId:" + m_nContentId);
			Log.d(strJson);

			if(m_vNewIdList.length > 0) {
				nRtn = 0;
			} else {
				Log.d("New filelist is empty.");
				nRtn = -3;
			}
		} catch(Exception e) {
			e.printStackTrace();
			m_nUserId = -1;
			nRtn = -99;
		}
		return nRtn;
	}
}

//再編集画像クラス
public class CEditedContent {
	public int append_id = 0;
	public int file_width = 0;
	public int file_height = 0;
	public long files_size = 0;
	public long file_complex = 0;
	public String name = "";
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

			//元の画像情報をファイルリストにセット
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
				Log.d("Old (" + cOld.append_id + "):" + cOld.name);
			}
			cResSet.close();cResSet=null;
			cState.close();cState=null;

			//画像情報を新ファイルリストにコピー
			boolean bExists = false;
			List<CEditedContent> vNewFileList = new ArrayList<CEditedContent>(cParam.m_vNewIdList.length);
			for (int append_id: cParam.m_vNewIdList) {
				for (CEditedContent cOld: vOldFileList) {
					if (append_id == cOld.append_id) {
						bExists = true;
						CEditedContent cNew = new CEditedContent();
						cNew.append_id = cOld.append_id;
						cNew.name = cOld.name;
						cNew.file_width = cOld.file_width;
						cNew.file_height = cOld.file_height;
						cNew.files_size = cOld.files_size;
						cNew.file_complex = cOld.file_complex;
						vNewFileList.add(cNew);
						Log.d("New (" + cNew.append_id + "):" + cNew.name);
						break;
					}
				}
			}

			//新リストのappend_idが元リストと1つもマッチしなかったら不正データなので終了
			if (!bExists) {
				Log.d("Unknown append_id.");
				return -3;
			}

			//元リストにあって新リストにないファイルを抽出（削除候補）
			List<CEditedContent> cDiff = new ArrayList<CEditedContent>();
			for (CEditedContent cOld: vOldFileList) {
				boolean bExist = false;
				for (int append_id: cParam.m_vNewIdList) {
					if (cOld.append_id==append_id) {
						bExist = true;
						break;
					}
				}
				if(!bExist) {
					cDiff.add(cOld);
				}
			}

			//不要ファイルの削除
			boolean bHead = false;
			if (cDiff.size() > 0) {
				String[] strDelList = new String[cDiff.size()];
				for (int i=0; i<cDiff.size(); i++) {
					int append_id = cDiff.get(i).append_id;
					strDelList[i] = Integer.toString(append_id);
					String strPath = getServletContext().getRealPath(cDiff.get(i).name);
					Log.d("Delete file:" + strPath);

					ImageUtil.deleteFile(strPath);
					ImageUtil.deleteFile(strPath + "_360.jpg");
					ImageUtil.deleteFile(strPath + "_640.jpg");

					//元リストからも削除
					Iterator<CEditedContent> it = vOldFileList.iterator();
					while (it.hasNext()) {
						if (it.next().append_id == append_id && append_id != -1) {
							it.remove();
						}
					}

					//先頭画像の削除有無
					if (append_id == -1) bHead = true;
				}
				Log.d("Delete appendId:" + String.join(",", strDelList));

				//不要レコード削除
				if (strDelList.length > 0) {
					strSql = "DELETE FROM contents_appends_0000 WHERE content_id=? AND append_id IN (" + String.join(",", strDelList) + ");";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cParam.m_nContentId);
					cState.executeUpdate();
					cState.close();cState=null;
				}

				//先頭が削除されて1個ずつズレるケース
				if (bHead) {
					//余る要素の削除
					strSql = "DELETE FROM contents_appends_0000 WHERE content_id=? AND append_id=?;";
					cState = cConn.prepareStatement(strSql);
					cState.setInt(1, cParam.m_nContentId);
					cState.setInt(2, vOldFileList.get(vOldFileList.size() - 1).append_id);
					cState.executeUpdate();
					cState.close();cState=null;
					Log.d("先頭が削除されたので末尾1個削除(" + vOldFileList.get(vOldFileList.size() - 1).append_id + "):" + vOldFileList.get(vOldFileList.size() - 1).name);
					//vOldFileList.remove(vOldFileList.size() - 1);
				}
			}

			//append_idの振り直し
			int p = 0;
			for (int i=0; i<vNewFileList.size(); i++) {
				CEditedContent cTmp = vNewFileList.get(i);
				if (i==0 && vOldFileList.get(i).append_id != -1) {
					p = 1;	//
					Log.d("こないはず");
				}
				if((i+p) < vOldFileList.size()) {
					cTmp.append_id = vOldFileList.get(i+p).append_id;
					Log.d("New appendId:"+cTmp.append_id);
					vNewFileList.set(i, cTmp);
				}
			}

			//並び替え
			for (int i=0; i<vNewFileList.size(); i++) {
				//先頭画像はcontents_0000にセット
				if (i == 0) {
					strSql = "UPDATE contents_0000 SET file_name=?,file_width=?,file_height=?,file_size=?,file_complex=? WHERE content_id=?;";
					cState = cConn.prepareStatement(strSql);
					cState.setString(1, vNewFileList.get(i).name);
					cState.setInt(2, vNewFileList.get(i).file_width);
					cState.setInt(3, vNewFileList.get(i).file_height);
					cState.setLong(4, vNewFileList.get(i).files_size);
					cState.setLong(5, vNewFileList.get(i).file_complex);
					cState.setInt(6, cParam.m_nContentId);
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
					cState.setInt(7, vNewFileList.get(i).append_id);
					cState.executeUpdate();
				}
				cState.close();cState=null;
			}

			//画像枚数の更新
			strSql = "UPDATE contents_0000 SET file_num=? WHERE content_id=?;";
			cState = cConn.prepareStatement(strSql);
			cState.setLong(1, vNewFileList.size());
			cState.setInt(2, cParam.m_nContentId);
			cState.executeUpdate();

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