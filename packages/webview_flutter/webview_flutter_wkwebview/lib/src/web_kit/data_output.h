
/**
 * Converts an FWFNSKeyValueObservingOptionsEnumData to an NSKeyValueObservingOptions.
 *
 * @param data The data object containing information to create an NSKeyValueObservingOptions.
 *
 * @return An NSKeyValueObservingOptions or -1 if data could not be converted.
 */
extern NSUInteger FWFNSKeyValueObservingOptionsFromEnumData(FWFNSKeyValueObservingOptionsEnumData *data);

/**
 * Converts an FWFNSKeyValueChangeEnumData to an NSKeyValueChange.
 *
 * @param data The data object containing information to create an NSKeyValueChange.
 *
 * @return An NSKeyValueChange or -1 if data could not be converted.
 */
extern NSUInteger FWFNSKeyValueChangeFromEnumData(FWFNSKeyValueChangeEnumData *data);

/**
 * Converts an FWFNSKeyValueChangeKeyEnumData to an NSKeyValueChangeKey.
 *
 * @param data The data object containing information to create an NSKeyValueChangeKey.
 *
 * @return An NSKeyValueChangeKey or -1 if data could not be converted.
 */
extern NSUInteger FWFNSKeyValueChangeKeyFromEnumData(FWFNSKeyValueChangeKeyEnumData *data);

/**
 * Converts an FWFNSHttpCookiePropertyKeyEnumData to an NSHttpCookiePropertyKey.
 *
 * @param data The data object containing information to create an NSHttpCookiePropertyKey.
 *
 * @return An NSHttpCookiePropertyKey or -1 if data could not be converted.
 */
extern NSUInteger FWFNSHttpCookiePropertyKeyFromEnumData(FWFNSHttpCookiePropertyKeyEnumData *data);
