package io.flutter.plugins.imagepicker;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class FileUtilsTest extends FileUtils {

	@Test
	public void returnNullIfCannotGetCursor() {
		String nullString = FileUtils.getDataColumn(null, null, null,null);
		assertEquals(nullString, null);
	}

}
