package jp.pipa.poipiku.util;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.color.ColorSpace;
import java.awt.geom.AffineTransform;
import java.awt.image.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

import javax.imageio.*;
import javax.imageio.metadata.*;
import javax.imageio.stream.FileImageOutputStream;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.ImageOutputStream;

import org.w3c.dom.*;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Metadata;
import com.drew.metadata.MetadataException;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.jpeg.JpegDirectory;

public class ImageUtil {
	public static void createThumbIllust(String strSrcFileName, boolean bLoop) throws IOException {
		deleteFilesClean(strSrcFileName);

		BufferedImage cImage = ImageUtil.read(strSrcFileName);
		int nWidth = cImage.getWidth();
		int nHeight = cImage.getHeight();

		if(nWidth<=800) {
			Path pathSrc = Paths.get(strSrcFileName);
			Path pathDst = Paths.get(strSrcFileName+"_640.jpg");
			Files.copy(pathSrc, pathDst);
		} else {
			ImageUtil.createThumb(strSrcFileName, strSrcFileName+"_640.jpg", 800, 0, bLoop);
		}
		double lfZoom = Math.max(240.0/nWidth, 240.0/nHeight);
		if(lfZoom>=1.0) {
			Path pathSrc = Paths.get(strSrcFileName);
			Path pathDst = Paths.get(strSrcFileName+"_360.jpg");
			Files.copy(pathSrc, pathDst);
		} else {
			//ImageUtil.createThumbNormalize(strSrcFileName, strSrcFileName+"_360.jpg", 360, bLoop);
			int nCalWidth = (int)(nWidth * lfZoom);
			ImageUtil.createThumb(strSrcFileName, strSrcFileName+"_360.jpg", nCalWidth, 0, bLoop);
		}
	}
	public static void createThumbIllust(String strSrcFileName) throws IOException {
		createThumbIllust(strSrcFileName, true);
	}
	public static void createThumbProfile(String strSrcFileName) throws IOException {
		deleteFilesClean(strSrcFileName);
		ImageUtil.createThumbNormalize(strSrcFileName, strSrcFileName+"_120.jpg",  120, true);
	}


	public static boolean createThumbNormalize(String strSrcFileName, String strDstFileName, int newWidth, boolean bLoop) throws IOException {
		boolean bRtn = false;
		String ext = getExt(strSrcFileName);
		switch (ext) {
		case "gif":
			createThumbGifNormalize(strSrcFileName, strDstFileName, newWidth, bLoop);
			break;
		case "jpeg":
			createThumbJpgNormalize(strSrcFileName, strDstFileName, newWidth);
			break;
		case "png":
		default:
			createThumbPngNormalize(strSrcFileName, strDstFileName, newWidth);
			break;
		}
		bRtn = true;
		return bRtn;
	}

	public static void createThumbJpgNormalize(String strSrcFileName, String strDstFileName, int newWidth) throws IOException {
		BufferedImage image = resizeImageNormalize(ImageUtil.read(strSrcFileName), newWidth);
		long lnJpegSize = saveJpeg(image, strDstFileName);
		long lnPngSize = savePng(image, strDstFileName);
		//Log.d(String.format("createThumbJpgNormalize:jpq=%d, png=%d", lnJpegSize, lnPngSize));
		if(lnJpegSize < lnPngSize*.7) {
			saveJpeg(image, strDstFileName);
		}
	}

	public static void createThumbPngNormalize(String strSrcFileName, String strDstFileName, int newWidth) throws IOException {
		BufferedImage image = resizeImageNormalize(ImageUtil.readPng(strSrcFileName), newWidth);
		long lnJpegSize = saveJpeg(image, strDstFileName);
		long lnPngSize = savePng(image, strDstFileName);
		//Log.d(String.format("createThumbPngNormalize:jpq=%d, png=%d", lnJpegSize, lnPngSize));
		if(lnJpegSize < lnPngSize*.7) {
			saveJpeg(image, strDstFileName);
		}

	}

	public static void createThumbGifNormalize(String strSrcFileName, String strDstFileName, int newWidth, boolean bLoop) throws IOException {
		ImageFrame[] frames = readGif(strSrcFileName);
		for (int i = 0; i < frames.length; i++) {
			// code to resize the image
			BufferedImage image = resizeImageNormalize(frames[i].getImage(), newWidth);
			frames[i].setImage(image);
		}

		ImageOutputStream output = new FileImageOutputStream(new File(strDstFileName));
		GifSequenceWriter writer = new GifSequenceWriter(output, frames[0].getImage().getType(), frames[0].getDelay(), bLoop);
		writer.writeToSequence(frames[0].getImage());
		for (int i = 1; i < frames.length; i++) {
			BufferedImage nextImage = frames[i].getImage();
			writer.writeToSequence(nextImage, frames[i].getDelay());
		}
		writer.close();
		output.close();
	}

	public static BufferedImage resizeImageNormalize(BufferedImage image, int width) {
		Image imgSmall = null;
		if (image.getWidth() < image.getHeight()) {
			imgSmall = image.getScaledInstance(width, -1, java.awt.Image.SCALE_SMOOTH);
		} else {
			imgSmall = image.getScaledInstance(-1, width, java.awt.Image.SCALE_SMOOTH);
		}
		if (imgSmall == null)
			return null;
		BufferedImage thumb = new BufferedImage(width, width, image.getType());
		thumb.getGraphics().drawImage(imgSmall, (width - imgSmall.getWidth(null)) / 2,
				(width - imgSmall.getHeight(null)) / 2, imgSmall.getWidth(null), imgSmall.getHeight(null), Color.white,
				null);
		return thumb;
	}

	public static boolean createThumb(String strSrcFileName, String strDstFileName, int newWidth, int newHeight, boolean bLoop) throws IOException {
		if(newWidth<=0 && newHeight<=0) return false;

		boolean bRtn = false;

		if(newWidth<=0) {
			BufferedImage cImage = ImageUtil.read(strSrcFileName);
			newWidth = cImage.getWidth()*newHeight/cImage.getHeight();
		} else if(newHeight<=0) {
			BufferedImage cImage = ImageUtil.read(strSrcFileName);
			newHeight = cImage.getHeight()*newWidth/cImage.getWidth();
		}

		String ext = getExt(strSrcFileName);

		switch (ext) {
		case "gif":
			createThumbGif(strSrcFileName, strDstFileName, newWidth, newHeight, bLoop);
			break;
		case "jpeg":
			createThumbJpg(strSrcFileName, strDstFileName, newWidth, newHeight);
			break;
		case "png":
		default:
			createThumbPng(strSrcFileName, strDstFileName, newWidth, newHeight);
			break;
		}

		bRtn = true;

		return bRtn;
	}

	public static void createThumbJpg(String strSrcFileName, String strDstFileName, int newWidth, int newHeight) {
		ImageMagickUtil.createThumbnail(strSrcFileName, strDstFileName, newWidth, newHeight);
	}

	public static void createThumbPng(String strSrcFileName, String strDstFileName, int newWidth, int newHeight)
			throws IOException {
		BufferedImage image = resizeImage(ImageUtil.readPng(strSrcFileName), newWidth, newHeight);
		long lnJpegSize = saveJpeg(image, strDstFileName);
		long lnPngSize = savePng(image, strDstFileName);
		//Log.d(String.format("createThumbPng:jpq=%d, png=%d", lnJpegSize, lnPngSize));
		if(lnJpegSize < lnPngSize*.7) {
			saveJpeg(image, strDstFileName);
		}
	}

	private static long saveJpeg(BufferedImage image, String strDstFileName) throws FileNotFoundException, IOException {
		deleteFile(strDstFileName);
		File file = new File(strDstFileName);
		FileImageOutputStream output = new FileImageOutputStream(file);
		ImageWriter writeImage = ImageIO.getImageWritersByFormatName("jpeg").next();
		ImageWriteParam writeParam = writeImage.getDefaultWriteParam();
		writeParam.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
		writeParam.setCompressionQuality(0.9f);
		writeImage.setOutput(output);
		writeImage.write(null, new IIOImage(image, null, null), writeParam);
		writeImage.dispose();
		return file.length();
	}

	private static long savePng(BufferedImage image, String strDstFileName) throws IOException {
		deleteFile(strDstFileName);
		File file = new File(strDstFileName);
		ImageIO.write(image, "png", file);
		return file.length();
	}

	public static void createThumbGif(String strSrcFileName, String strDstFileName, int newWidth, int newHeight, boolean bLoop) throws IOException {
		ImageFrame[] frames = readGif(strSrcFileName);
		for (int i = 0; i < frames.length; i++) {
			// code to resize the image
			BufferedImage image = resizeImage(frames[i].getImage(), newWidth, newHeight);
			frames[i].setImage(image);
		}

		ImageOutputStream output = new FileImageOutputStream(new File(strDstFileName));
		GifSequenceWriter writer = new GifSequenceWriter(output, frames[0].getImage().getType(), frames[0].getDelay(), bLoop);
		writer.writeToSequence(frames[0].getImage());
		for (int i = 1; i < frames.length; i++) {
			BufferedImage nextImage = frames[i].getImage();
			writer.writeToSequence(nextImage, frames[i].getDelay());
		}
		writer.close();
		output.close();
	}

	public static BufferedImage resizeImage(BufferedImage image, int width, int height) {
		BufferedImage thumb = new BufferedImage(width, height, image.getType());
		thumb.getGraphics().drawImage(image.getScaledInstance(width, height, Image.SCALE_AREA_AVERAGING), 0, 0, width,
				height, null);
		return thumb;
	}

	private static ImageFrame[] readGif(String strSrcFileName) throws IOException {
		ArrayList<ImageFrame> frames = new ArrayList<ImageFrame>(2);
		ImageReader reader = (ImageReader) ImageIO.getImageReadersByFormatName("gif").next();
		reader.setInput(ImageIO.createImageInputStream(new File(strSrcFileName)));
		int lastx = 0;
		int lasty = 0;
		int width = -1;
		int height = -1;
		IIOMetadata metadata = reader.getStreamMetadata();
		Color backgroundColor = null;

		if (metadata != null) {
			IIOMetadataNode globalRoot = (IIOMetadataNode) metadata.getAsTree(metadata.getNativeMetadataFormatName());
			NodeList globalColorTable = globalRoot.getElementsByTagName("GlobalColorTable");
			NodeList globalScreeDescriptor = globalRoot.getElementsByTagName("LogicalScreenDescriptor");
			if (globalScreeDescriptor != null && globalScreeDescriptor.getLength() > 0) {
				IIOMetadataNode screenDescriptor = (IIOMetadataNode) globalScreeDescriptor.item(0);
				if (screenDescriptor != null) {
					width = Integer.parseInt(screenDescriptor.getAttribute("logicalScreenWidth"));
					height = Integer.parseInt(screenDescriptor.getAttribute("logicalScreenHeight"));
				}
			}
			if (globalColorTable != null && globalColorTable.getLength() > 0) {
				IIOMetadataNode colorTable = (IIOMetadataNode) globalColorTable.item(0);
				if (colorTable != null) {
					String bgIndex = colorTable.getAttribute("backgroundColorIndex");
					IIOMetadataNode colorEntry = (IIOMetadataNode) colorTable.getFirstChild();
					while (colorEntry != null) {
						if (colorEntry.getAttribute("index").equals(bgIndex)) {
							int red = Integer.parseInt(colorEntry.getAttribute("red"));
							int green = Integer.parseInt(colorEntry.getAttribute("green"));
							int blue = Integer.parseInt(colorEntry.getAttribute("blue"));
							backgroundColor = new Color(red, green, blue);
							break;
						}
						colorEntry = (IIOMetadataNode) colorEntry.getNextSibling();
					}
				}
			}
		}

		BufferedImage master = null;
		boolean hasBackround = false;
		for (int frameIndex = 0;; frameIndex++) {
			BufferedImage image;
			try {
				image = reader.read(frameIndex);
			} catch (Exception e) {
				break;
			}
			if (width == -1 || height == -1) {
				width = image.getWidth();
				height = image.getHeight();
			}
			IIOMetadataNode root = (IIOMetadataNode) reader.getImageMetadata(frameIndex).getAsTree("javax_imageio_gif_image_1.0");
			IIOMetadataNode gce = (IIOMetadataNode) root.getElementsByTagName("GraphicControlExtension").item(0);
			NodeList children = root.getChildNodes();
			int delay = Integer.valueOf(gce.getAttribute("delayTime"))*10; // gifのdelayは1/100なのでmsに変換
			String disposal = gce.getAttribute("disposalMethod");
			if (master == null) {
				master = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
				master.createGraphics().setColor(backgroundColor);
				master.createGraphics().fillRect(0, 0, master.getWidth(), master.getHeight());
				hasBackround = image.getWidth() == width && image.getHeight() == height;
				master.createGraphics().drawImage(image, 0, 0, null);
			} else {
				int x = 0;
				int y = 0;
				for (int nodeIndex = 0; nodeIndex < children.getLength(); nodeIndex++) {
					Node nodeItem = children.item(nodeIndex);
					if (nodeItem.getNodeName().equals("ImageDescriptor")) {
						NamedNodeMap map = nodeItem.getAttributes();
						x = Integer.valueOf(map.getNamedItem("imageLeftPosition").getNodeValue());
						y = Integer.valueOf(map.getNamedItem("imageTopPosition").getNodeValue());
					}
				}
				if (disposal.equals("restoreToPrevious")) {
					BufferedImage from = frames.get(0).getImage();	// エラー対策として先頭フレームを入れておく
					for (int i = frameIndex - 1; i >= 0; i--) {
						if (!frames.get(i).getDisposal().equals("restoreToPrevious") || frameIndex == 0) {
							from = frames.get(i).getImage();
							break;
						}
					}
					{
						ColorModel model = from.getColorModel();
						boolean alpha = from.isAlphaPremultiplied();
						WritableRaster raster = from.copyData(null);
						master = new BufferedImage(model, raster, alpha, null);
					}
				} else if (disposal.equals("restoreToBackgroundColor") && backgroundColor != null) {
					if (!hasBackround || frameIndex > 1) {
						master.createGraphics().fillRect(lastx, lasty, frames.get(frameIndex - 1).getWidth(),
								frames.get(frameIndex - 1).getHeight());
					}
				}
				master.createGraphics().drawImage(image, x, y, null);
				lastx = x;
				lasty = y;
			}
			{
				BufferedImage copy;
				{
					ColorModel model = master.getColorModel();
					boolean alpha = master.isAlphaPremultiplied();
					WritableRaster raster = master.copyData(null);
					copy = new BufferedImage(model, raster, alpha, null);
				}
				frames.add(new ImageFrame(copy, delay, disposal, image.getWidth(), image.getHeight()));
			}
			master.flush();
		}
		reader.dispose();

		return frames.toArray(new ImageFrame[frames.size()]);
	}

	public static void createGallery(ArrayList<String> vSrcFileName, String strDstFileName, int newWidth) throws IOException {
		int CANVAS_WIDTH = newWidth;
		int CANVAS_HEIGHT = 0;

		ArrayList<BufferedImage> vBufferedImage = new ArrayList<BufferedImage>();
		for(String strSrcFileName : vSrcFileName) {
			if(!(new File(strSrcFileName)).isFile()) continue;
			BufferedImage cImage = null;
			switch (getExt(strSrcFileName)) {
			case "gif": {
					ImageFrame[] frames = readGif(strSrcFileName);
					if(frames.length<=0) break;
					cImage = frames[0].getImage();
				}
				break;
			case "jpeg": {
					cImage = ImageUtil.read(strSrcFileName);
				}
				break;
			case "png":
			default: {
					cImage = ImageUtil.readPng(strSrcFileName);
				}
				break;
			}
			if(cImage==null) continue;
			int newHeight = cImage.getHeight()*newWidth/cImage.getWidth();
			CANVAS_HEIGHT += newHeight;
			vBufferedImage.add(resizeImage(cImage, newWidth, newHeight));
			//if(CANVAS_HEIGHT>2048*8) break;
		}

		BufferedImage cImageRGB = new BufferedImage(CANVAS_WIDTH, CANVAS_HEIGHT, BufferedImage.TYPE_INT_RGB);
		Graphics2D g = cImageRGB.createGraphics();
		g.setColor(Color.white);
		g.fillRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
		int y = 0;
		for(BufferedImage cImage : vBufferedImage) {
			int width = cImage.getWidth();
			int height = cImage.getHeight();
			g.drawImage(cImage, (newWidth-width)/2, y, width, height, Color.white, null);
			y += height;
		}
		g.dispose();

		ImageIO.write(cImageRGB, "jpg", new File(strDstFileName));
	}


	public static void createAnimatedGif(String strOrgFileName, String strSrcFileName, String strDstFileName, int nDelay, boolean bLoop) throws IOException {
		Log.d("createAnimatedGif start");
		ArrayList<BufferedImage> imgTarg = new ArrayList<BufferedImage>();
		if(strOrgFileName!=null && !strOrgFileName.isEmpty()) {
			// 追記元ファイルの読み込み
			File oTargFile = new File(strOrgFileName);
			if(oTargFile.isFile() && oTargFile.exists()) {
				String ext = getExt(strOrgFileName);
				switch (ext) {
				case "gif":
					ImageFrame[] frames = readGif(strOrgFileName);
					for (int i = 0; i < frames.length; i++) {
						BufferedImage imgFrame = frames[i].getImage();
						if(imgFrame.getType()!=BufferedImage.TYPE_INT_RGB) {
							// Convert to RGB
							BufferedImage cImageRGB = new BufferedImage(imgFrame.getWidth(), imgFrame.getHeight(), BufferedImage.TYPE_INT_RGB);
							Graphics2D g = cImageRGB.createGraphics();
							g.setColor(Color.white);
							g.fillRect(0, 0, imgFrame.getWidth(), imgFrame.getHeight());
							ColorSpace rgbCS = cImageRGB.getColorModel().getColorSpace();
							ColorConvertOp colorConvert = new ColorConvertOp(rgbCS, null);
							colorConvert.filter(imgFrame, cImageRGB);
							g.dispose();
							imgFrame = cImageRGB;
						}
						imgTarg.add(imgFrame);
					}
					break;
				case "jpeg":
					imgTarg.add(ImageUtil.read(strOrgFileName));
					break;
				case "png":
				default:
					imgTarg.add(ImageUtil.readPng(strOrgFileName));
					break;
				}
			}
		}

		// 追加ファイルの読み込み
		String ext = getExt(strSrcFileName);
		switch (ext) {
		case "gif":
			ImageFrame[] frames = readGif(strSrcFileName);
			for (int i = 0; i < frames.length; i++) {
				BufferedImage imgFrame = frames[i].getImage();
				if(imgFrame.getType()!=BufferedImage.TYPE_INT_RGB) {
					// Convert to RGB
					BufferedImage cImageRGB = new BufferedImage(imgFrame.getWidth(), imgFrame.getHeight(), BufferedImage.TYPE_INT_RGB);
					Graphics2D g = cImageRGB.createGraphics();
					g.setColor(Color.white);
					g.fillRect(0, 0, imgFrame.getWidth(), imgFrame.getHeight());
					ColorSpace rgbCS = cImageRGB.getColorModel().getColorSpace();
					ColorConvertOp colorConvert = new ColorConvertOp(rgbCS, null);
					colorConvert.filter(imgFrame, cImageRGB);
					g.dispose();
					imgFrame = cImageRGB;
				}
				imgTarg.add(imgFrame);
			}
			break;
		case "jpeg":
			imgTarg.add(ImageUtil.read(strSrcFileName));
			break;
		case "png":
		default:
			imgTarg.add(ImageUtil.readPng(strSrcFileName));
			break;
		}

		// ファイルの書き込み
		ImageOutputStream output = new FileImageOutputStream(new File(strDstFileName));
		GifSequenceWriter writer = new GifSequenceWriter(output, BufferedImage.TYPE_INT_RGB, nDelay, bLoop);
		writer.writeToSequence(imgTarg.get(0));
		for (int i = 1; i < imgTarg.size(); i++) {
			writer.writeToSequence(imgTarg.get(i), nDelay);
		}
		writer.close();
		output.close();
	}


	public static String getExt(String strSrcFileName) throws IOException {
		return getExt(ImageIO.createImageInputStream(new File(strSrcFileName)));
	}

	public static String getExt(ImageInputStream stream) throws IOException {
		String ext = "";
		Iterator<ImageReader> readers = ImageIO.getImageReaders(stream);
		if (readers.hasNext()) {
			ImageReader reader = readers.next();
			ext = reader.getFormatName().toLowerCase();
		}
		return ext;
	}

	public static int[] getImageSize(String strSrcFileName) throws IOException {
		BufferedImage cImage = ImageUtil.read(strSrcFileName);
		return new int[] { cImage.getWidth(), cImage.getHeight() };
	}

	public static BufferedImage read(String strSrcFileName) throws IOException {
		File fileSrc = new File(strSrcFileName);
		BufferedImage bufferedImageSrc = null;
		try {
			bufferedImageSrc = ImageIO.read(fileSrc);
		} catch(Exception e) {
			bufferedImageSrc = ImageUtil.readImageCMYK(fileSrc);
		}

		String ext = getExt(strSrcFileName);
		if(!ext.equals("jpeg")) return bufferedImageSrc;

		try {
			// Exif処理
			Metadata metadata = ImageMetadataReader.readMetadata(fileSrc);
			if(metadata==null) return bufferedImageSrc;
			ExifIFD0Directory exifIFD0Directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
			if(exifIFD0Directory==null) return bufferedImageSrc;
			int orientation = exifIFD0Directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
			JpegDirectory jpegDirectory = (JpegDirectory) metadata.getFirstDirectoryOfType(JpegDirectory.class);
			if(jpegDirectory==null) return bufferedImageSrc;
			int width = jpegDirectory.getImageWidth();
			int height = jpegDirectory.getImageHeight();
			//Log.d(String.format("read jpeg : orientation=%d, width=%d, height=%d", orientation, width, height));
			//int width = bufferedImageSrc.getWidth();
			//int height = bufferedImageSrc.getHeight();
			AffineTransform affineTransform = new AffineTransform();
			switch (orientation) {
			case 2: { // Flip X
				affineTransform.scale(-1.0, 1.0);
				affineTransform.translate(-width, 0);
				AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
				BufferedImage destinationImage = new BufferedImage(bufferedImageSrc.getWidth(), bufferedImageSrc.getHeight(), bufferedImageSrc.getType());
				destinationImage = affineTransformOp.filter(bufferedImageSrc, destinationImage);
				if(destinationImage!=null) bufferedImageSrc = destinationImage;
				break;
			}
			case 3: { // PI rotation
				affineTransform.translate(width, height);
				affineTransform.rotate(Math.PI);
				AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
				BufferedImage destinationImage = new BufferedImage(bufferedImageSrc.getWidth(), bufferedImageSrc.getHeight(), bufferedImageSrc.getType());
				destinationImage = affineTransformOp.filter(bufferedImageSrc, destinationImage);
				if(destinationImage!=null) bufferedImageSrc = destinationImage;
				break;
			}
			case 4: { // Flip Y
				affineTransform.scale(1.0, -1.0);
				affineTransform.translate(0, -height);
				AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
				BufferedImage destinationImage = new BufferedImage(bufferedImageSrc.getWidth(), bufferedImageSrc.getHeight(), bufferedImageSrc.getType());
				destinationImage = affineTransformOp.filter(bufferedImageSrc, destinationImage);
				if(destinationImage!=null) bufferedImageSrc = destinationImage;
				break;
			}
			case 5: { // - PI/2 and Flip X
				affineTransform.rotate(-Math.PI/2);
				affineTransform.scale(-1.0, 1.0);
				AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
				BufferedImage destinationImage = new BufferedImage(bufferedImageSrc.getHeight(), bufferedImageSrc.getWidth(), bufferedImageSrc.getType());
				destinationImage = affineTransformOp.filter(bufferedImageSrc, destinationImage);
				if(destinationImage!=null) bufferedImageSrc = destinationImage;
				break;
			}
			case 6: { // -PI/2 and -width
				affineTransform.translate(height, 0);
				affineTransform.rotate(Math.PI/2);
				AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
				BufferedImage destinationImage = new BufferedImage(bufferedImageSrc.getHeight(), bufferedImageSrc.getWidth(), bufferedImageSrc.getType());
				destinationImage = affineTransformOp.filter(bufferedImageSrc, destinationImage);
				if(destinationImage!=null) bufferedImageSrc = destinationImage;
				break;
			}
			case 7: { // PI/2 and Flip
				affineTransform.scale(-1.0, 1.0);
				affineTransform.translate(-height, 0);
				affineTransform.translate(0, width);
				affineTransform.rotate(3 * Math.PI/2);
				AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
				BufferedImage destinationImage = new BufferedImage(bufferedImageSrc.getHeight(), bufferedImageSrc.getWidth(), bufferedImageSrc.getType());
				destinationImage = affineTransformOp.filter(bufferedImageSrc, destinationImage);
				if(destinationImage!=null) bufferedImageSrc = destinationImage;
				break;
			}
			case 8: { // PI/2
				affineTransform.translate(0, width);
				affineTransform.rotate(3 * Math.PI/2);
				AffineTransformOp affineTransformOp = new AffineTransformOp(affineTransform, AffineTransformOp.TYPE_BILINEAR);
				BufferedImage destinationImage = new BufferedImage(bufferedImageSrc.getHeight(), bufferedImageSrc.getWidth(), bufferedImageSrc.getType());
				destinationImage = affineTransformOp.filter(bufferedImageSrc, destinationImage);
				if(destinationImage!=null) bufferedImageSrc = destinationImage;
				break;
			}
			case 1:
			default:
				break;
			}
		} catch (MetadataException e) {
			//Log.d(e.getMessage());
			//e.printStackTrace();
		} catch (ImageProcessingException e) {
			//Log.d(e.getMessage());
			//e.printStackTrace();
		} catch (IOException e) {
			//Log.d(e.getMessage());
			//e.printStackTrace();
		}
		return bufferedImageSrc;
	}

	public static long getConplex(String strSrcFileName) throws IOException {
		String strDstFileName = strSrcFileName + "_complex.jpg";
		ImageIO.write(resizeImageNormalize(ImageUtil.read(strSrcFileName), 1000), "jpg", new File(strDstFileName));
		long nFileSize = (new File(strDstFileName)).length();
		deleteFile(strDstFileName);
		return nFileSize;
	}

	public static BufferedImage readPng(String strSrcFileName) throws IOException {
		BufferedImage cImage = ImageUtil.read(strSrcFileName);
		// Convert ARGB to RGB
		BufferedImage cImageRGB = new BufferedImage(cImage.getWidth(), cImage.getHeight(), BufferedImage.TYPE_INT_RGB);
		Graphics2D g = cImageRGB.createGraphics();
		g.setColor(Color.white);
		g.fillRect(0, 0, cImage.getWidth(), cImage.getHeight());
		ColorSpace rgbCS = cImageRGB.getColorModel().getColorSpace();
		ColorConvertOp colorConvert = new ColorConvertOp(rgbCS, null);
		colorConvert.filter(cImage, cImageRGB);
		g.dispose();
		return cImageRGB;
	}

	public static BufferedImage readImageCMYK(File file) throws IOException {
		InputStream stream = new FileInputStream(file);
		Iterator<ImageReader> imageReaders = ImageIO.getImageReadersBySuffix("jpg");
		ImageReader imageReader = imageReaders.next();
		ImageInputStream iis = ImageIO.createImageInputStream(stream);
		imageReader.setInput(iis, true, true);
		Raster raster = imageReader.readRaster(0, null);
		int w = raster.getWidth();
		int h = raster.getHeight();
		BufferedImage result = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
		int rgb[] = new int[3];
		int pixel[] = new int[Math.max(3, raster.getNumDataElements())];
		for (int x = 0; x < w; x++) {
			for (int y = 0; y < h; y++) {
				raster.getPixel(x, y, pixel);
				int Y = pixel[0];
				int CR = pixel[1];
				int CB = pixel[2];
				toRGB(Y, CB, CR, rgb);
				int r = rgb[0];
				int g = rgb[1];
				int b = rgb[2];
				int bgr = ((b & 0xFF) << 16) | ((g & 0xFF) << 8) | (r & 0xFF);
				result.setRGB(x, y, bgr);
			}
		}
		iis.close();iis=null;
		stream.close();stream=null;
		return result;
	}

	private static void toRGB(int y, int cb, int cr, int rgb[]) {
		float Y = y / 255.0f;
		float Cb = (cb - 128) / 255.0f;
		float Cr = (cr - 128) / 255.0f;
		float R = Y + 1.4f * Cr;
		float G = Y - 0.343f * Cb - 0.711f * Cr;
		float B = Y + 1.765f * Cb;
		R = Math.min(1.0f, Math.max(0.0f, R));
		G = Math.min(1.0f, Math.max(0.0f, G));
		B = Math.min(1.0f, Math.max(0.0f, B));
		int r = (int) (R * 255);
		int g = (int) (G * 255);
		int b = (int) (B * 255);
		rgb[0] = r;
		rgb[1] = g;
		rgb[2] = b;
	}

	public static void deleteFile(String strFileName) {
		if(strFileName==null || strFileName.isEmpty()) return;
		File oDelFile = new File(strFileName);
		if(!oDelFile.isFile()) return;
		if(oDelFile.exists()) oDelFile.delete();
	}

	public static void deleteFiles(String strFileName) {
		if(strFileName==null || strFileName.isEmpty()) return;
		deleteFile(strFileName);
		deleteFilesClean(strFileName);
	}

	static void deleteFilesClean(String strFileName) {
		if(strFileName==null || strFileName.isEmpty()) return;
		deleteFile(strFileName+"_640.jpg");
		deleteFile(strFileName+"_360.jpg");
		deleteFile(strFileName+"_120.jpg");
	}
}

class ImageFrame {
	private final int delay;
	private BufferedImage image;
	private final String disposal;
	private int width, height;

	public ImageFrame (BufferedImage image, int delay, String disposal, int width, int height){
		this.image = image;
		this.delay = delay;
		this.disposal = disposal;
		this.width = width;
		this.height = height;
	}

	public ImageFrame (BufferedImage image){
		this.image = image;
		this.delay = -1;
		this.disposal = null;
		this.width = -1;
		this.height = -1;
	}

	public BufferedImage getImage() {
		return image;
	}

	public void setImage(BufferedImage image) {
		this.image = image;
		this.width = image.getWidth();
		this.height = image.getHeight();
	}

	public int getDelay() {
		return delay;
	}

	public String getDisposal() {
		return disposal;
	}

	public int getWidth() {
		return width;
	}

	public int getHeight() {
		return height;
	}
}
class GifSequenceWriter {
	protected ImageWriter gifWriter;
	protected ImageWriteParam imageWriteParam;
	protected IIOMetadata imageMetaData;

	protected String metaFormatName;
	IIOMetadataNode root;
	protected IIOMetadataNode graphicsControlExtensionNode;

	public GifSequenceWriter(ImageOutputStream outputStream, int imageType, int timeBetweenFramesMS, boolean loopContinuously) throws IIOException, IOException {
		// my method to create a writer
		gifWriter = getWriter();
		imageWriteParam = gifWriter.getDefaultWriteParam();
		ImageTypeSpecifier imageTypeSpecifier = ImageTypeSpecifier.createFromBufferedImageType(imageType);

		imageMetaData = gifWriter.getDefaultImageMetadata(imageTypeSpecifier, imageWriteParam);

		metaFormatName = imageMetaData.getNativeMetadataFormatName();

		root = (IIOMetadataNode) imageMetaData.getAsTree(metaFormatName);

		graphicsControlExtensionNode = getNode(root, "GraphicControlExtension");

		graphicsControlExtensionNode.setAttribute("disposalMethod", "none");
		graphicsControlExtensionNode.setAttribute("userInputFlag", "FALSE");
		graphicsControlExtensionNode.setAttribute("transparentColorFlag", "FALSE");
		graphicsControlExtensionNode.setAttribute("delayTime", Integer.toString(timeBetweenFramesMS / 10));
		graphicsControlExtensionNode.setAttribute("transparentColorIndex", "0");

		IIOMetadataNode commentsNode = getNode(root, "CommentExtensions");
		commentsNode.setAttribute("CommentExtension", "Powerd by PIPA.JP");

		IIOMetadataNode appEntensionsNode = getNode(root, "ApplicationExtensions");

		IIOMetadataNode child = new IIOMetadataNode("ApplicationExtension");

		child.setAttribute("applicationID", "NETSCAPE");
		child.setAttribute("authenticationCode", "2.0");

		int loop = loopContinuously ? 0 : 1;
		Log.d("loopContinuously:"+loopContinuously);

		child.setUserObject(new byte[] { 0x1, (byte) (loop & 0xFF), (byte) ((loop >> 8) & 0xFF) });
		appEntensionsNode.appendChild(child);

		imageMetaData.setFromTree(metaFormatName, root);

		gifWriter.setOutput(outputStream);

		gifWriter.prepareWriteSequence(null);
	}

	public void writeToSequence(RenderedImage img) throws IOException {
		gifWriter.writeToSequence(new IIOImage(img, null, imageMetaData), imageWriteParam);
	}

	public void writeToSequence(RenderedImage img, int timeBetweenFramesMS) throws IOException {
		graphicsControlExtensionNode.setAttribute("delayTime", Integer.toString(timeBetweenFramesMS / 10));
		imageMetaData.setFromTree(metaFormatName, root);

		gifWriter.writeToSequence(new IIOImage(img, null, imageMetaData), imageWriteParam);
	}

	public void close() throws IOException {
		gifWriter.endWriteSequence();
	}

	private static ImageWriter getWriter() throws IIOException {
		Iterator<ImageWriter> iter = ImageIO.getImageWritersBySuffix("gif");
		if (!iter.hasNext()) {
			throw new IIOException("No GIF Image Writers Exist");
		} else {
			return iter.next();
		}
	}

	private static IIOMetadataNode getNode(IIOMetadataNode rootNode, String nodeName) {
		int nNodes = rootNode.getLength();
		for (int i = 0; i < nNodes; i++) {
			if (rootNode.item(i).getNodeName().compareToIgnoreCase(nodeName) == 0) {
				return ((IIOMetadataNode) rootNode.item(i));
			}
		}
		IIOMetadataNode node = new IIOMetadataNode(nodeName);
		rootNode.appendChild(node);
		return (node);
	}
}
