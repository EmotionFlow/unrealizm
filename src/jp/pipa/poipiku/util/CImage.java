package jp.pipa.poipiku.util;

import java.awt.*;
import java.awt.color.*;
import java.awt.geom.*;
import java.awt.image.*;
import java.io.*;
import java.nio.file.*;
import java.util.*;

import javax.imageio.*;
import javax.imageio.stream.*;

import com.drew.imaging.*;
import com.drew.metadata.*;
import com.drew.metadata.exif.*;
import com.drew.metadata.jpeg.*;

public class CImage {
	public static boolean checkImage(String strSrcFileName) {
		String ext = "";
		try {
			File fileSrc = new File(strSrcFileName);
			ImageInputStream iis = ImageIO.createImageInputStream(fileSrc);
			Iterator<ImageReader> readers = ImageIO.getImageReaders(iis);
			if(readers.hasNext()) {
				ImageReader reader = (ImageReader)readers.next();
				ext = reader.getFormatName().toLowerCase();
			}
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		}

		if(!ext.equals("jpeg") && !ext.equals("jpg") && !ext.equals("gif") && !ext.equals("png")) {
			return false;
		}
		return true;
	}

	public static BufferedImage getOrientatedImage(String strSrcFileName) {
		BufferedImage imgOrg = null;

		try {
			File fileSrc = new File(strSrcFileName);
			imgOrg = ImageIO.read(fileSrc);
			Metadata metadata = ImageMetadataReader.readMetadata(fileSrc);
			Directory directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
			JpegDirectory jpegDirectory = (JpegDirectory) metadata.getFirstDirectoryOfType(JpegDirectory.class);
			int nOrientation = directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
			int width = jpegDirectory.getImageWidth();
			int height = jpegDirectory.getImageHeight();

			int nDistWidth = imgOrg.getWidth();
			int nDistHeight = imgOrg.getHeight();
			AffineTransform affineTransform = new AffineTransform();
			switch (nOrientation) {
			case 2: // Flip X
				affineTransform.scale(-1.0, 1.0);
				affineTransform.translate(-width, 0);
				break;
			case 3: // PI rotation
				affineTransform.translate(width, height);
				affineTransform.rotate(Math.PI);
				break;
			case 4: // Flip Y
				affineTransform.scale(1.0, -1.0);
				affineTransform.translate(0, -height);
				break;
			case 5: // - PI/2 and Flip X
				affineTransform.rotate(-Math.PI / 2);
				affineTransform.scale(-1.0, 1.0);
				nDistWidth = imgOrg.getHeight();
				nDistHeight = imgOrg.getWidth();
				break;
			case 6: // -PI/2 and -width
				affineTransform.translate(height, 0);
				affineTransform.rotate(Math.PI / 2);
				nDistWidth = imgOrg.getHeight();
				nDistHeight = imgOrg.getWidth();
				break;
			case 7: // PI/2 and Flip
				affineTransform.scale(-1.0, 1.0);
				affineTransform.translate(-height, 0);
				affineTransform.translate(0, width);
				affineTransform.rotate(3 * Math.PI / 2);
				nDistWidth = imgOrg.getHeight();
				nDistHeight = imgOrg.getWidth();
				break;
			case 8: // PI / 2
				affineTransform.translate(0, width);
				affineTransform.rotate(3 * Math.PI / 2);
				nDistWidth = imgOrg.getHeight();
				nDistHeight = imgOrg.getWidth();
				break;
			case 1:
			default:
				break;
			}

			AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
			BufferedImage imgDest = new BufferedImage(nDistWidth, nDistHeight, imgOrg.getType());
			return affineTransformOp.filter(imgOrg, imgDest);
		} catch(Exception e) {
			e.printStackTrace();
			return imgOrg;
		}
	}

	public static boolean saveIllustImages(String strSrcFileName, String strDstFileName) {
		try {
			File fileOutput = new File(strDstFileName);
			String strDirName = fileOutput.getParent();
			File cDir = new File(strDirName);
			if(!cDir.exists()) {
				cDir.mkdirs();
			}

			//BufferedImage cImage = getOrientatedImage(strSrcFileName);
			BufferedImage cImage = ImageIO.read(new File(strSrcFileName));
			Files.copy(Paths.get(strSrcFileName), Paths.get(strDstFileName));
			if(cImage.getWidth()<=640) {
				Files.copy(Paths.get(strSrcFileName), Paths.get(strDstFileName+"_640.jpg"));
			} else {
				saveImageJpg(cImage, strDstFileName+"_640.jpg", 640);
			}
			if(cImage.getWidth()<=360) {
				Files.copy(Paths.get(strSrcFileName), Paths.get(strDstFileName+"_360.jpg"));
			} else {
				saveImageN(cImage, strDstFileName+"_360.jpg", 360);
			}

			//for(int nCnt=0; nCnt<10; nCnt++) {
			//	Thread.sleep(100);
			//	File fileOut = new File(strDstFileName);
			//	if(fileOut.exists()) {
			//		Log.d(nCnt + " - created : "+strDstFileName);
			//		break;
			//	}
			//}
		} catch(Exception e){
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public static boolean saveProfileImages(String strSrcFileName, String strFileName) {
		try {
			File fileOutput = new File(strFileName);
			String strDirName = fileOutput.getParent();
			File cDir = new File(strDirName);
			if(!cDir.exists()) {
				cDir.mkdirs();
			}

			//BufferedImage cImage = getOrientatedImage(strSrcFileName);
			BufferedImage cImage = ImageIO.read(new File(strSrcFileName));
			saveImageJpg(cImage, strFileName, 1080);
			saveImageW(cImage, strFileName+"_120.jpg", 120, 120);
		} catch(Exception e){
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public static boolean saveProfileHeaderImages(String strSrcFileName, String strFileName) {
		try {
			File fileOutput = new File(strFileName);
			String strDirName = fileOutput.getParent();
			File cDir = new File(strDirName);
			if(!cDir.exists()) {
				cDir.mkdirs();
			}

			//BufferedImage cImage = getOrientatedImage(strSrcFileName);
			BufferedImage cImage = ImageIO.read(new File(strSrcFileName));
			saveImageJpg(cImage, strFileName, 1280);
		} catch(Exception e){
			e.printStackTrace();
			return false;
		}
		return true;
	}

	private static boolean saveImageJpg(BufferedImage cImage, String strFileName, int nWidth) {
		try{
			Graphics2D g = null;
			int nImgWidth = cImage.getWidth();
			int nImgHeight = cImage.getHeight();

			if(nImgWidth<nWidth) {
				nWidth = nImgWidth;
				//ImageIO.write(cImage, "jpeg", new File(strFileName));
				//return true;
			}

			// Conver ARGB to RGB
			BufferedImage cImageRGB = new BufferedImage(nImgWidth, nImgHeight, BufferedImage.TYPE_INT_RGB);
			g = cImageRGB.createGraphics();
			g.setColor(Color.white);
			g.fillRect(0, 0, nImgWidth, nImgHeight);
			ColorSpace rgbCS = cImageRGB.getColorModel().getColorSpace();
			ColorConvertOp colorConvert = new ColorConvertOp(rgbCS, null);
			colorConvert.filter(cImage, cImageRGB);
			g.dispose();

			// 縮小画像作成
			Image imgScaled = cImageRGB.getScaledInstance(nWidth, -1, java.awt.Image.SCALE_SMOOTH);
			int nScaledHeight = imgScaled.getHeight(null);
			BufferedImage cImageDst = new BufferedImage(nWidth, nScaledHeight, BufferedImage.TYPE_INT_RGB);
			g = cImageDst.createGraphics();
			g.drawImage(imgScaled, 0, 0, nWidth, nScaledHeight, Color.white, null);
			g.dispose();
			ImageIO.write(cImageDst, "jpeg", new File(strFileName));
		} catch(Exception e){
			e.printStackTrace();
			return false;
		}
		return true;
	}

	private static boolean saveImageN(BufferedImage cImage, String strFileName, int nSize) {
		try{
			Graphics2D g;
			int nImgWidth = cImage.getWidth();
			int nImgHeight = cImage.getHeight();

			// Conver ARGB to RGB
			BufferedImage cImageRGB = new BufferedImage(nImgWidth, nImgHeight, BufferedImage.TYPE_INT_RGB);
			g = cImageRGB.createGraphics();
			g.setColor(Color.white);
			g.fillRect(0, 0, nImgWidth, nImgHeight);
			ColorSpace rgbCS = cImageRGB.getColorModel().getColorSpace();
			ColorConvertOp colorConvert = new ColorConvertOp(rgbCS, null);
			colorConvert.filter(cImage, cImageRGB);
			g.dispose();

			// 縮小画像作成
			if(nImgWidth>nImgHeight) {
				int nMinSize = Math.min(nImgHeight, nSize);
				Image imgScaled = cImageRGB.getScaledInstance(-1, nMinSize, java.awt.Image.SCALE_SMOOTH);
				int nScaledWidth = imgScaled.getWidth(null);
				BufferedImage cImageDst = new BufferedImage(nSize, nSize, BufferedImage.TYPE_INT_RGB);
				g = cImageDst.createGraphics();
				g.setColor(Color.white);
				g.fillRect(0, 0, nSize, nSize);
				g.drawImage(imgScaled, (nSize-nScaledWidth)/2, (nSize-nMinSize)/2, nScaledWidth, nMinSize, Color.white, null);
				g.dispose();
				ImageIO.write(cImageDst, "jpeg", new File(strFileName));
			} else {
				int nMinSize = Math.min(nImgWidth, nSize);
				Image imgScaled = cImageRGB.getScaledInstance(nMinSize, -1, java.awt.Image.SCALE_SMOOTH);
				int nScaledHight = imgScaled.getHeight(null);
				BufferedImage cImageDst = new BufferedImage(nSize, nSize, BufferedImage.TYPE_INT_RGB);
				g = cImageDst.createGraphics();
				g.setColor(Color.white);
				g.fillRect(0, 0, nSize, nSize);
				g.drawImage(imgScaled, (nSize-nMinSize)/2, (nSize-nScaledHight)/2, nMinSize, nScaledHight, Color.white, null);
				g.dispose();
				ImageIO.write(cImageDst, "jpeg", new File(strFileName));
			}
		} catch(Exception e){
			e.printStackTrace();
			return false;
		}
		return true;
	}

	private static boolean saveImageW(BufferedImage cImage, String strFileName, int nWidth, int nMinHeight) {
		try{
			Graphics2D g;
			int nImgWidth = cImage.getWidth();
			int nImgHeight = cImage.getHeight();

			// Conver ARGB to RGB
			BufferedImage cImageRGB = new BufferedImage(nImgWidth, nImgHeight, BufferedImage.TYPE_INT_RGB);
			g = cImageRGB.createGraphics();
			g.setColor(Color.white);
			g.fillRect(0, 0, nImgWidth, nImgHeight);
			ColorSpace rgbCS = cImageRGB.getColorModel().getColorSpace();
			ColorConvertOp colorConvert = new ColorConvertOp(rgbCS, null);
			colorConvert.filter(cImage, cImageRGB);
			g.dispose();

			// 縮小画像作成
			if(nImgWidth>nWidth) {
				Image imgScaled = cImageRGB.getScaledInstance(nWidth, -1, java.awt.Image.SCALE_SMOOTH);
				int nScaledHeight = imgScaled.getHeight(null);
				int nMaxHeight = Math.max(nScaledHeight, nMinHeight);
				BufferedImage cImageDst = new BufferedImage(nWidth, nMaxHeight, BufferedImage.TYPE_INT_RGB);
				g = cImageDst.createGraphics();
				g.setColor(Color.white);
				g.fillRect(0, 0, nWidth, nMaxHeight);
				g.drawImage(imgScaled, 0, (nMaxHeight-nScaledHeight)/2, nWidth, nScaledHeight, Color.white, null);
				g.dispose();
				ImageIO.write(cImageDst, "jpeg", new File(strFileName));
			} else {
				//cImageRGB
				int nMaxHeight = Math.max(nImgHeight, nMinHeight);
				BufferedImage cImageDst = new BufferedImage(nWidth, nMaxHeight, BufferedImage.TYPE_INT_RGB);
				g = cImageDst.createGraphics();
				g.setColor(Color.white);
				g.fillRect(0, 0, nWidth, nMaxHeight);
				g.drawImage(cImageRGB, (nWidth-nImgWidth)/2, (nMaxHeight-nImgHeight)/2, nImgWidth, nImgHeight, Color.white, null);
				g.dispose();
				ImageIO.write(cImageDst, "jpeg", new File(strFileName));
			}
		} catch(Exception e){
			e.printStackTrace();
			return false;
		}
		return true;
	}

	public static void DeleteFiles(String strFileName) {
		DeleteFile(strFileName);
		DeleteFile(strFileName+"_640.jpg");
		DeleteFile(strFileName+"_360.jpg");
		DeleteFile(strFileName+"_120.jpg");
	}

	public static void DeleteFile(String strFileName) {
		File oDelFile = new File(strFileName);
		if (oDelFile.exists())
			oDelFile.delete();
	}
}
