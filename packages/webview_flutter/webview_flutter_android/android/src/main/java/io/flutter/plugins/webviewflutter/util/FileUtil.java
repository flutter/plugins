package util;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.text.TextUtils;
import android.widget.Toast;

import androidx.core.content.ContextCompat;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import io.flutter.Log;

/**
 * 文件工具类
 */
public class FileUtil {
    private static final String JPEG_FILE_PREFIX = "IMG_";
    private static final String JPEG_FILE_SUFFIX = ".jpg";

    private static final String VIDEO_FILE_PREFIX = "VID_";
    private static final String VIDEO_FILE_SUFFIX = ".mp4";
    /**
     * 读取文件为byte[]
     *
     * @param filePath
     * @return
     */
    public static byte[] readFile(String filePath) {
        final File file = new File(filePath);
        if (!file.exists()) {
            return null;
        }
        try {
            InputStream stream = new FileInputStream(file);
            byte[] buffer = new byte[(int) file.length()];
            stream.read(buffer);
            stream.close();
            return buffer;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 保存文件
     *
     * @param filePath
     * @param data
     */
    public static void saveFile(String filePath, byte[] data) {
        File targetFile = new File(filePath);
        FileOutputStream osw;
        try {
            if (!targetFile.exists()) {
                targetFile.createNewFile();
                osw = new FileOutputStream(targetFile);
                osw.write(data);
                osw.close();
            } else {
                osw = new FileOutputStream(targetFile, true);
                osw.write(data);
                osw.flush();
                osw.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 文件拷贝
     *
     * @param prefile
     * @param newfile
     */
    public static int copyFile(String prefile, String newfile) {
        try {
            InputStream fosfrom = new FileInputStream(prefile);
            OutputStream fosto = new FileOutputStream(newfile);
            byte bt[] = new byte[1024];
            int c;
            while ((c = fosfrom.read(bt)) > 0) {
                fosto.write(bt, 0, c);
            }
            fosfrom.close();
            fosto.close();
            return 0;

        } catch (Exception ex) {
            return -1;
        }
    }

//	/**
//	 * asset文件夹读取文件
//	 *
//	 * @param context
//	 * @param path
//	 * @return
//	 */
//	public static String readTxtFromAsset(Context context, String path) {
//		Resources resource = context.getResources();
//		AssetManager am = resource.getAssets();
//		InputStream is = null;
//		String content = "";
//		try {
//			is = am.open(path);
//			int length = is.available();
//			byte[] buffer = new byte[length];
//			is.read(buffer);
//			content = EncodingUtils.getString(buffer, "UTF-8");
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//		if (is != null) {
//			try {
//				is.close();
//			} catch (IOException e) {
//				e.printStackTrace();
//			}
//		}
//		return content;
//	}

//	/**
//	 * 从sd卡读文件
//	 *
//	 * @param path
//	 * @return
//	 */
//	public static String readTxtFromSd(String path) {
//		String content = "";
//		InputStream stream = null;
//		final File file = new File(path);
//		if (!file.exists()) {
//			return null;
//		}
//		try {
//			stream = new FileInputStream(file);
//			byte[] buffer = new byte[(int) file.length()];
//			stream.read(buffer);
//			content = EncodingUtils.getString(buffer, "UTF-8");
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//		if (stream != null) {
//			try {
//				stream.close();
//			} catch (IOException e) {
//				e.printStackTrace();
//			}
//		}
//		return content;
//	}

    /**
     * 删除单个文件
     *
     * @param sPath 被删除文件的文件
     * @return 单个文件删除成功返回true，否则返回false
     */
    public static boolean deleteFile(String sPath) {
        boolean flag = false;
        File file = new File(sPath);
        // 路径为文件且不为空则进行删除
        if (file.isFile() && file.exists()) {
            file.delete();
            flag = true;
        }
        return flag;
    }

    /**
     * 删除目录（文件夹）以及目录下的文
     *
     * @param sPath 被删除目录的文件路径
     * @return 目录删除成功返回true，否则返回false
     */
    public static boolean deleteDirectory(String sPath) {
        //如果sPath不以文件分隔符结尾，自动添加文件分隔�?
        if (!sPath.endsWith(File.separator)) {
            sPath = sPath + File.separator;
        }
        File dirFile = new File(sPath);
        //如果dir对应的文件不存在，或者不是一个目录，则
        if (!dirFile.exists() || !dirFile.isDirectory()) {
            return false;
        }
        boolean flag = true;
        //删除文件夹下的所有文件包括子目录
        File[] files = dirFile.listFiles();
        for (int i = 0; i < files.length; i++) {
            //删除子文件
            if (files[i].isFile()) {
                flag = deleteFile(files[i].getAbsolutePath());
                if (!flag) break;
            } //删除子目件
            else {
                flag = deleteDirectory(files[i].getAbsolutePath());
                if (!flag) break;
            }
        }
        if (!flag) return false;
        //删除当前目录
        if (dirFile.delete()) {
            return true;
        } else {
            return false;
        }
    }

    public static void mediaScan(Context context, String file) {
        Intent scanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(new
                File(file)));
        context.sendBroadcast(scanIntent);
    }


    //创建一个文件存放拍照的图片
    //放在应用关联缓存目录下，不需要申请运行时权限
    public static File createImageFile(Context ctx) throws IOException {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String imageFileName = JPEG_FILE_PREFIX + timeStamp + "_";
        return File.createTempFile(imageFileName, JPEG_FILE_SUFFIX, ctx.getExternalCacheDir());
    }


    /**
     * 获取文件长度
     * @param filePath
     */
    public static long getFileSize(String filePath) {
        if(TextUtils.isEmpty(filePath))return 0;
        File file = new File(filePath);
        if (file.exists() && file.isFile()) {
            return file.length();
        }
        return 0;
    }


    /**
     * 检查SD卡是否挂载
     *
     * @return
     */
    public static boolean checkSDcard(Context context){
        boolean flag = Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
        if (!flag) {
            Toast.makeText(context,"请插入手机存储卡再使用本功能", Toast.LENGTH_SHORT).show();
        }
        return flag;
    }
}
