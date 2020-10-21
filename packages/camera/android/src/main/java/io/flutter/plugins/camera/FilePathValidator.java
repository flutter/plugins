package io.flutter.plugins.camera;

import java.io.File;

class FilePathValidator {
    static class FileFactory {
        File makeFile(String filePath) {
            return new File(filePath);
        }
    }

    private String errorMessage;
    private final String filePath;
    private final FileFactory fileFactory;
    private boolean isValid;

    public FilePathValidator(String filePath) {
        this(filePath, new FileFactory());
    }

    FilePathValidator(
            String filePath,
            FilePathValidator.FileFactory factory) {
        this.filePath = filePath;
        this.fileFactory = factory;
    }

    public void validate() {
        File file = fileFactory.makeFile(this.filePath);
        if (file.exists()) {
            this.errorMessage = file.isDirectory()
                    ? "File at path '" + filePath + "' is a directory. This path should be a destination file path."
                    : "File at path '" + filePath + "' already exists. Cannot overwrite.";
            this.isValid = false;
            return;
        }
        this.isValid = true;
    }

    public boolean isValid() {
        return this.isValid;
    }

    public String getErrorMessage() {
        return this.errorMessage;
    }
}