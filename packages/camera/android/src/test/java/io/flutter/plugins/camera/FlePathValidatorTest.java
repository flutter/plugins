package io.flutter.plugins.camera;
import io.flutter.plugin.common.MethodChannel;
import org.junit.Test;
import java.io.File;
import static junit.framework.TestCase.assertEquals;
import static org.mockito.Mockito.*;
public class FlePathValidatorTest {

    @Test
    public void onMethodCall_startVideoRecordingReturnsIsDirectory()  {
        FilePathValidator.FileFactory mockFactory = mock(FilePathValidator.FileFactory.class);
        MethodChannel.Result result = mock(MethodChannel.Result.class);
        File mockFile = mock(File.class);
        String filePath = "foo";
        when(mockFile.exists()).thenReturn(true);
        when(mockFile.isDirectory()).thenReturn(true);
        when(mockFactory.makeFile(filePath)).thenReturn(mockFile);
        FilePathValidator validator = new FilePathValidator(filePath,mockFactory);
        validator.validate();
        assertEquals("filePathInvalid", "File at path '"+ filePath + "' is a directory. This path should be a destination file path.", validator.getErrorMessage());
    }

    @Test
    public void onMethodCall_startVideoRecordingReturnsFileAlreadyExists()  {
        FilePathValidator.FileFactory mockFactory = mock(FilePathValidator.FileFactory.class);
        MethodChannel.Result result = mock(MethodChannel.Result.class);
        File mockFile = mock(File.class);
        String filePath = "foo";
        when(mockFile.exists()).thenReturn(true);
        when(mockFactory.makeFile(filePath)).thenReturn(mockFile);
        FilePathValidator validator = new FilePathValidator(filePath,mockFactory);
        validator.validate();
        assertEquals("File at path '" + filePath + "' already exists. Cannot overwrite.", validator.getErrorMessage());
    }

    @Test
    public void onMethodCall_startVideoRecordingReturnsIsValid()  {
        FilePathValidator.FileFactory mockFactory = mock(FilePathValidator.FileFactory.class);
        MethodChannel.Result result = mock(MethodChannel.Result.class);
        File mockFile = mock(File.class);
        String filePath = "foo";
        when(mockFile.exists()).thenReturn(true);
        when(mockFactory.makeFile(filePath)).thenReturn(mockFile);
        FilePathValidator validator = new FilePathValidator(filePath,mockFactory);
        validator.validate();
        assertEquals(true, validator.isValid());
    }
}