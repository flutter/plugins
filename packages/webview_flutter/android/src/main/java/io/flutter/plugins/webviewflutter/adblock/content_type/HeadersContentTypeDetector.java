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
package io.flutter.plugins.webviewflutter.adblock.content_type;

import android.os.Build;
import android.webkit.WebResourceRequest;

import java.util.Map;

import androidx.annotation.RequiresApi;

import static io.flutter.plugins.webviewflutter.content_type.HttpConstants.HEADER_ACCEPT;
import static io.flutter.plugins.webviewflutter.content_type.HttpConstants.HEADER_REQUESTED_WITH;
import static io.flutter.plugins.webviewflutter.content_type.HttpConstants.HEADER_REQUESTED_WITH_XMLHTTPREQUEST;
import static io.flutter.plugins.webviewflutter.content_type.HttpConstants.MIME_TYPE_TEXT_HTML;

/**
 * Detects content type based on headers
 * <p>
 * It has a limited functionality and can detect only
 * two types of content:
 * - {@link ContentType#XMLHTTPREQUEST} and
 * - {@link ContentType#SUBDOCUMENT}
 * <p>
 * Should be used in {@link OrderedContentTypeDetector}
 */
@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class HeadersContentTypeDetector implements ContentTypeDetector {
    @Override
    public ContentType detect(final WebResourceRequest request) {
        final Map<String, String> headers = request.getRequestHeaders();

        final boolean isXmlHttpRequest =
                headers.containsKey(HEADER_REQUESTED_WITH) &&
                        HEADER_REQUESTED_WITH_XMLHTTPREQUEST.equals(headers.get(HEADER_REQUESTED_WITH));

        if (isXmlHttpRequest) {
            return ContentType.XMLHTTPREQUEST;
        }

        final String acceptType = headers.get(HEADER_ACCEPT);
        if (acceptType != null && acceptType.contains(MIME_TYPE_TEXT_HTML)) {
            return ContentType.SUBDOCUMENT;
        }

        // not detected
        return null;
    }
}
