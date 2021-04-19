/*
 * This file is part of Adblock Plus <https://adblockplus.org/>,
 * Copyright (C) 2006-present eyeo GmbH
 *
 * Adblock Plus is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Adblock Plus is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Adblock Plus.  If not, see <http://www.gnu.org/licenses/>.
 */

package io.flutter.plugins.webviewflutter.content_type;

import android.webkit.WebResourceRequest;


/**
 * Detects content type based on {@link HeadersContentTypeDetector}
 * and {@link UrlFileExtensionTypeDetector}
 * <p>
 * Can accept a list of content type detectors
 * <p>
 * {@link ContentType#XMLHTTPREQUEST} is detected separately
 * just by checking header `HEADER_REQUESTED_WITH_XMLHTTPREQUEST`
 */
public class OrderedContentTypeDetector implements ContentTypeDetector {
    private final ContentTypeDetector[] detectors;

    /**
     * Creates an instance of a `MultipleContentTypeDetector`
     * with provided detectors
     * <p>
     * At the moment only {@link HeadersContentTypeDetector}
     * and {@link UrlFileExtensionTypeDetector} exists
     *
     * @param detectors an array of instances of {@link ContentTypeDetector}
     */
    public OrderedContentTypeDetector(final ContentTypeDetector... detectors) {
        this.detectors = detectors;
    }

    @Override
    public ContentType detect(final WebResourceRequest request) {
        ContentType contentType;

        for (final ContentTypeDetector detector : detectors) {
            contentType = detector.detect(request);

            // if contentType == null, that means
            // that the detector was unavailable to detect content type
            if (contentType != null) {
                return contentType;
            }
        }

        // returning result
        // if nothing found, its safe to return null
        return null;
    }
}
