package io.flutter.plugins.camera;

import static junit.framework.TestCase.assertEquals;
import static junit.framework.TestCase.assertFalse;
import static junit.framework.TestCase.assertTrue;
import static org.mockito.Mockito.*;

import java.io.File;
import org.junit.Test;

public class FilePathValidatorTest {

  @Test
  public void validate_ReturnsIsDirectory() {
    FilePathValidator.FileFactory mockFactory = mock(FilePathValidator.FileFactory.class);
    File mockFile = mock(File.class);
    String filePath = "foo";

    when(mockFile.exists()).thenReturn(true);
    when(mockFile.isDirectory()).thenReturn(true);
    when(mockFactory.makeFile(filePath)).thenReturn(mockFile);

    FilePathValidator validator = new FilePathValidator(filePath, mockFactory);
    validator.validate();

    assertEquals(
        "filePathInvalid",
        "File at path '"
            + filePath
            + "' is a directory. This path should be a destination file path.",
        validator.getErrorMessage());
  }

  @Test
  public void validate_ReturnsFileAlreadyExists() {
    FilePathValidator.FileFactory mockFactory = mock(FilePathValidator.FileFactory.class);
    File mockFile = mock(File.class);
    String filePath = "foo";

    when(mockFile.exists()).thenReturn(true);
    when(mockFactory.makeFile(filePath)).thenReturn(mockFile);

    FilePathValidator validator = new FilePathValidator(filePath, mockFactory);
    validator.validate();

    assertEquals(
        "File at path '" + filePath + "' already exists. Cannot overwrite.",
        validator.getErrorMessage());
  }

  @Test
  public void validate_ReturnsIsNotValid_WhenFileExist() {
    FilePathValidator.FileFactory mockFactory = mock(FilePathValidator.FileFactory.class);
    File mockFile = mock(File.class);
    String filePath = "foo";

    when(mockFile.exists()).thenReturn(true);
    when(mockFile.isDirectory()).thenReturn(false);
    when(mockFactory.makeFile(filePath)).thenReturn(mockFile);

    FilePathValidator validator = new FilePathValidator(filePath, mockFactory);
    validator.validate();

    assertFalse(validator.isValid());
  }

  @Test
  public void validate_ReturnsIsNotValid_WhenFilePathIsDirectory() {
    FilePathValidator.FileFactory mockFactory = mock(FilePathValidator.FileFactory.class);
    File mockFile = mock(File.class);
    String filePath = "foo";

    when(mockFile.exists()).thenReturn(true);
    when(mockFile.isDirectory()).thenReturn(true);
    when(mockFactory.makeFile(filePath)).thenReturn(mockFile);

    FilePathValidator validator = new FilePathValidator(filePath, mockFactory);
    validator.validate();

    assertFalse(validator.isValid());
  }

  @Test
  public void validate_ReturnsIsValid_WhenFileDoesNotExist() {
    FilePathValidator.FileFactory mockFactory = mock(FilePathValidator.FileFactory.class);
    File mockFile = mock(File.class);
    String filePath = "foo";

    when(mockFile.exists()).thenReturn(false);
    when(mockFactory.makeFile(filePath)).thenReturn(mockFile);

    FilePathValidator validator = new FilePathValidator(filePath, mockFactory);
    validator.validate();

    assertTrue(validator.isValid());
  }
}
