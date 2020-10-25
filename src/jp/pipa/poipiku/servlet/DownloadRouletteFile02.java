package jp.pipa.poipiku.servlet;

import java.awt.Graphics;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;

import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jp.pipa.poipiku.*;
import jp.pipa.poipiku.util.*;

/**
 * Servlet implementation class DownloadImageFile
 */
@WebServlet(name="DownloadRouletteFile02", urlPatterns={"/DownloadRouletteFile02"})
public class DownloadRouletteFile02 extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String BASE_FILEN_NAME = "/event/20190901/template_odai.png";
	private static final String ROULETTE_BASE[] = {"/event/20190901/r1_odai01/", "/event/20190901/r1_odai02/"};
	private static final int BASE_POINT[][] = {{505, 11}, {757, 11}};
	private static final int BASE_WIDTH = 233;


	public DownloadRouletteFile02() {
		super();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		CheckLogin cCheckLogin = new CheckLogin(request, response);
		CDownloadImageFile cResults = new CDownloadImageFile();
		if(!cResults.getParam(request)) return;
		BufferedImage imgFile = cResults.getResults(cCheckLogin);
		if(imgFile == null) return;

		response.setHeader("Cache-Control", "public");
		response.setContentType("image/png");
		//{
		//response.setContentType("application/octet-stream");
		//response.setHeader("Content-Transfer-Encoding", "binary");
		//}

		//{
		//response.setHeader("Content-Disposition", "attachment;filename=\"template.png\"");
		response.setHeader("Content-Disposition", "inline;filename=\"template.png\"");
		//}
		//response.setStatus(HttpServletResponse.SC_OK);

		try {
			OutputStream outStream = response.getOutputStream();
			ImageIO.write(imgFile, "png", outStream);
			outStream.flush();
			outStream.close();
		} catch (Exception e) {
			;
		}
	}


	class CDownloadImageFile {
		public Integer[] m_nRoullete = new Integer[ROULETTE_BASE.length];
		public boolean getParam(HttpServletRequest request) {
			boolean bRtn = false;
			try {
				request.setCharacterEncoding("UTF-8");
				for(int n=0; n < m_nRoullete.length; n++) {
					m_nRoullete[n] = Util.toInt(request.getParameter(String.format("R%d", n+1)));
					if(m_nRoullete[n] < 1) return false;
				}
				bRtn = true;
			}
			catch(Exception e) {
				;
			}
			return bRtn;
		}

		public BufferedImage getResults(CheckLogin cCheckLogin) {
			BufferedImage imgFile = null;

			try {
				String strBaseFileName = getServletContext().getRealPath(BASE_FILEN_NAME);
				if(strBaseFileName.isEmpty()) return null;
				imgFile = ImageIO.read(new File(strBaseFileName));
				Graphics graphics = imgFile.createGraphics();
				for(int n=0; n < m_nRoullete.length; n++) {
					String strRouletteFileName = getServletContext().getRealPath(ROULETTE_BASE[n] + String.format("%02d.png", m_nRoullete[n]));
					if(strRouletteFileName.isEmpty()) return null;
					BufferedImage imgRouletteFile = ImageIO.read(new File(strRouletteFileName));
					graphics.drawImage(imgRouletteFile.getScaledInstance(BASE_WIDTH, -1, Image.SCALE_AREA_AVERAGING),
							BASE_POINT[n][0],
							BASE_POINT[n][1],
							null);
				}
				graphics.dispose();
			} catch(Exception e) {
				e.printStackTrace();
			} finally {
			}
			return imgFile;
		}
	}
}
