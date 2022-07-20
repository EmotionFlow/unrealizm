package jp.pipa.poipiku.controller.upcontents.v2;

import jp.pipa.poipiku.Common;
import jp.pipa.poipiku.util.Util;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.util.Iterator;
import java.util.List;

public class UpFileAppendCParam {
	protected ServletContext m_cServletContext = null;

	public int userId = -1;
	public int contentId = 0;
	public boolean isPasteUpload = false;
	String encodedImage = "";
	FileItem fileItem = null;
	String userAgent = null;

	UpFileAppendCParam(ServletContext context){
		m_cServletContext = context;
	}

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			if(request.getContentType().contains("multipart")){
				isPasteUpload = false;
				String strRelativePath = Common.GetUploadTemporaryPath();
				String strRealPath = m_cServletContext.getRealPath(strRelativePath);
				// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること
				DiskFileItemFactory factory = new DiskFileItemFactory(200*1024*1024, new File(strRealPath));
				ServletFileUpload upload = new ServletFileUpload(factory);
				upload.setSizeMax(200*1024*1024);
				upload.setHeaderEncoding("UTF-8");

				List items = upload.parseRequest(request);
				Iterator iter = items.iterator();
				while (iter.hasNext()) {
					FileItem item = (FileItem) iter.next();
					if (item.isFormField()) {
						String strName = item.getFieldName();
						if(strName.equals("UID")) {
							userId = Util.toInt(item.getString());
						} else if(strName.equals("IID")) {
							contentId = Util.toInt(item.getString());
						}
						item.delete();
					} else {
						fileItem = item;
						nRtn = 0;
					}
				}
			} else {
				isPasteUpload = true;
				userId = Util.toInt(request.getParameter("UID"));
				contentId = Util.toInt(request.getParameter("IID"));
				encodedImage = Util.toString(request.getParameter("DATA"));	// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること

				nRtn = 0;
			}
			userAgent =request.getHeader("user-agent");
		} catch(FileUploadException e) {
			e.printStackTrace();
			nRtn = -1;
		} catch(Exception e) {
			e.printStackTrace();
			userId = -1;
			nRtn = -99;
		}
		return nRtn;
	}

	protected int ErrorOccured(Exception e, int errCode) {
		e.printStackTrace();
		userId = -1;
		return -99;
	}

};
