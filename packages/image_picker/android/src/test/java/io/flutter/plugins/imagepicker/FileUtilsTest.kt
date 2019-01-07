package io.flutter.plugins.imagepicker

import org.junit.Assert.assertNull
import org.junit.Test

class FileUtilsTest {

	@Test
	fun returnNullIfCannotGetCursor() {
		val nullString = FileUtils.getDataColumn(null, null, null,null)
		assertNull(nullString)
	}

}
