import '../models/document.dart';
import 'constants.dart';

class FileUtils{

  static String loadIcon(String mimeType){
    String key = "";
    if(mimeType.contains("text")) key = "text";
    else if(mimeType.contains("image")) key = "image";
    else if(mimeType.contains("video")) key = "video";
    else if(mimeType.contains("audio")) key = "audio";
    else key = mimeType;
    if(FILE_TYPE_ICONS_MAP.containsKey(key))
      return FILE_TYPE_ICONS_MAP[key]!;
    else
      return "unknown.png";
  }

  static String getFileSize(double byte){
    double kbyte = byte/1024;
    if(kbyte.toStringAsFixed(FILE_SIZE_FRACTION_DIGITS).length < 4+FILE_SIZE_FRACTION_DIGITS){
      return kbyte.toStringAsFixed(FILE_SIZE_FRACTION_DIGITS)+" KB";
    }
    double mbyte = kbyte/1024;
    if(mbyte.toStringAsFixed(FILE_SIZE_FRACTION_DIGITS).length < 4+FILE_SIZE_FRACTION_DIGITS){
      return mbyte.toStringAsFixed(FILE_SIZE_FRACTION_DIGITS)+" MB";
    }
    return (mbyte/1024).toStringAsFixed(FILE_SIZE_FRACTION_DIGITS)+" GB";
  }
}