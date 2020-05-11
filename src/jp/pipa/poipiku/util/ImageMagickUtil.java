package jp.pipa.poipiku.util;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class ImageMagickUtil {
    private static final Path CONVERT_CMD_PATH = Paths.get("/usr/local/bin/convert");
    private static final Path DEV_NULL = Paths.get("/dev/null");

    public static int createThumbnail(String srcPath, String dstPath, Integer width, Integer height){
        int exitCode = -1;
        List<String> cmd = new ArrayList<>();

        //
        cmd.add(CONVERT_CMD_PATH.toString());
        cmd.add(srcPath);
        cmd.add("-auto-orient");
        cmd.add("-thumbnail");
        cmd.add(String.format(
                "%sx%s",
                width!=null&&width>0?width.toString():"",
                height!=null&height>0?height.toString():"")
        );
        cmd.add(dstPath);

        exitCode = runExternalCommand(cmd, null);

        return exitCode;
    }

    private static int runExternalCommand(List<String> command, Path log)
    {
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
