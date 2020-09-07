package io.flutter.plugins.share;

import java.util.List;

public class ShareMap {
  List<String> paths;
  List<String> mimeTypes;
  String text;
  String subject;

  public ShareMap() {}

  public List<String> getPaths() {
    return paths;
  }

  public void setPaths(List<String> paths) {
    this.paths = paths;
  }

  public List<String> getMimeTypes() {
    return mimeTypes;
  }

  public void setMimeTypes(List<String> mimeTypes) {
    this.mimeTypes = mimeTypes;
  }

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = text;
  }

  public String getSubject() {
    return subject;
  }

  public void setSubject(String subject) {
    this.subject = subject;
  }
}
