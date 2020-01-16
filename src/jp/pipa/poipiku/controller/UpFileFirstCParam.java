package jp.pipa.poipiku.controller;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;

import java.nio.file.Files;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;

import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.commons.lang3.RandomStringUtils;

import jp.pipa.poipiku.Common;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

public class UpFileFirstCParam {
    protected ServletContext m_cServletContext = null;

	public int m_nUserId = -1;
	public int m_nContentId = 0;
    FileItem item_file = null;

    UpFileFirstCParam(ServletContext context){
		m_cServletContext = context;
	}

	public int GetParam(HttpServletRequest request) {
		int nRtn = -1;
		try {
			String strRelativePath = Common.GetUploadPath();
			String strRealPath = m_cServletContext.getRealPath(strRelativePath);
			DiskFileItemFactory factory = new DiskFileItemFactory();
			factory.setSizeThreshold(40*1024*1024);	// 送信サイズの最大を変えた時は tomcatのmaxPostSizeとnginxのclient_max_body_size、client_body_buffer_sizeも変更すること
			factory.setRepository(new File(strRealPath));
			ServletFileUpload upload = new ServletFileUpload(factory);
			upload.setSizeMax(40*1024*1024);
			upload.setHeaderEncoding("UTF-8");

			List items = upload.parseRequest(request);
			Iterator iter = items.iterator();
			while (iter.hasNext()) {
				FileItem item = (FileItem) iter.next();
				if (item.isFormField()) {
					String strName = item.getFieldName();
					if(strName.equals("UID")) {
						m_nUserId = Common.ToInt(item.getString());
					} else if(strName.equals("IID")) {
						m_nContentId = Common.ToInt(item.getString());
					}
					item.delete();
				} else {
					item_file = item;
					nRtn = 0;
				}
			}
		} catch(FileUploadException e) {
			nRtn = ErrorOccured(e, -2);
		} catch(Exception e) {
			nRtn = ErrorOccured(e, -99);
		}
		return nRtn;
	}

    protected int ErrorOccured(Exception e, int errCode) {
        e.printStackTrace();
        m_nUserId = -1;
        return -99;
    }

};
