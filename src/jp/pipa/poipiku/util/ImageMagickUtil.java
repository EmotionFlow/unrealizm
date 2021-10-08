package jp.pipa.poipiku.util;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class ImageMagickUtil {
    private static final Path CONVERT_CMD_PATH = Paths.get("/usr/local/bin/convert");
    private static final Path MONTAGE_CMD_PATH = Paths.get("/usr/local/bin/montage");
    private static final Path AUTO_TWEET_HEADER = Paths.get("/var/www/html/poipiku/img/AutoTweetHeader.png");
    private static final Path DEV_NULL = Paths.get("/dev/null");

    public static int createThumbnail(String srcPath, String dstPath, String format, Integer width, Integer height) {
        int exitCode = -1;
        List<String> cmd = new ArrayList<>();

        // メモリ制限などのオプションは、policy.xml参照のこと。
        // ファイルの場所は、$ convert -list configure | grep etc で確認できる。
        cmd.add(CONVERT_CMD_PATH.toString());
        cmd.add(srcPath);
        cmd.add("-auto-orient");
        cmd.add("-thumbnail");
        cmd.add(String.format(
                "%sx%s",
                width!=null && width>0 ? width.toString() : "",
                height!=null && height>0 ? height.toString() : "")
        );
        cmd.add("-flatten");
        cmd.add(format + ":" + dstPath);
        exitCode = runExternalCommand(cmd, null);

        return exitCode;
    }

    public static int createMontage(List<String> srcPathList, String dstPath) {
        if (srcPathList.isEmpty()|| dstPath == null || dstPath.isEmpty()){
            return -1;
        }

        int exitCode = -1;
        List<String> montageCmd = new ArrayList<>();
        montageCmd.add(MONTAGE_CMD_PATH.toString());
        montageCmd.addAll(srcPathList);
//        montageCmd.add("-crop");montageCmd.add("240x240");
//        montageCmd.add("-gravity");montageCmd.add("center");
        montageCmd.add("-tile");montageCmd.add("3x3");
        montageCmd.add("-resize");montageCmd.add("100x100");
        montageCmd.add("-extent");montageCmd.add("100x100");
        montageCmd.add("-background");montageCmd.add("#f6f6f6");
        montageCmd.add("-geometry");montageCmd.add("100x100+5+5");
        montageCmd.add("-border");montageCmd.add("5");
        montageCmd.add("-bordercolor");montageCmd.add("#ffffff");
        montageCmd.add(dstPath);
        System.out.println(String.join(" ", montageCmd));
        exitCode = runExternalCommand(montageCmd, null);
        if (exitCode < 0) return exitCode;

        List<String> convertCmd = new ArrayList<>();
        convertCmd.add(CONVERT_CMD_PATH.toString());
        convertCmd.add("-background");convertCmd.add("#f1f9fc");
        convertCmd.add("-border");convertCmd.add("5");
        convertCmd.add("-bordercolor");convertCmd.add("#f1f9fc");
        convertCmd.add(dstPath);
        convertCmd.add(dstPath);
        System.out.println(String.join(" ", convertCmd));
        exitCode = runExternalCommand(convertCmd, null);
        if (exitCode < 0) return exitCode;

        convertCmd.clear();
        convertCmd.add(CONVERT_CMD_PATH.toString());
        convertCmd.add("-append");convertCmd.add(AUTO_TWEET_HEADER.toString());
        convertCmd.add(dstPath);
        convertCmd.add(dstPath);
        System.out.println(String.join(" ", convertCmd));
        exitCode = runExternalCommand(convertCmd, null);
        if (exitCode < 0) return exitCode;

        convertCmd.clear();
        convertCmd.add(CONVERT_CMD_PATH.toString());
        convertCmd.add("-background");convertCmd.add("#cccccc");
        convertCmd.add("-border");convertCmd.add("1");
        convertCmd.add("-bordercolor");convertCmd.add("#cccccc");
        convertCmd.add(dstPath);
        convertCmd.add(dstPath);
        System.out.println(String.join(" ", convertCmd));
        exitCode = runExternalCommand(convertCmd, null);

        return exitCode;
    }


    private static int runExternalCommand(List<String> command, Path log) {
        ProcessBuilder pb = new ProcessBuilder(command);
        pb.redirectErrorStream(true);
        if(log==null) {
            pb.redirectOutput(DEV_NULL.toFile());
        } else {
            pb.redirectOutput(log.toFile());
        }

        int exitCode = -1;
        try {
            Process proc = pb.start();
            exitCode = proc.waitFor();
        } catch(IOException | InterruptedException e) {
            e.printStackTrace();
        }
        return exitCode;
    }
}
