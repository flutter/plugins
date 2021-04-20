package io.flutter.plugins.webviewflutter.content_type;

import android.os.Build;
import android.webkit.WebResourceRequest;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

public enum ContentType {
    DOCUMENT("main_frame"),
    FONT("font"),
    IMAGE("image"),
    MEDIA("media"),
    OBJECT("object"),
    OBJECT_SUBREQUEST("object_subrequest"),
    OTHER("other"),
    PING("ping"),
    SCRIPT("script"),
    STYLESHEET("stylesheet"),
    SUBDOCUMENT("subdocument"),
    XMLHTTPREQUEST("xml_dtd");

    public final String rawName;

    static ContentTypeDetector contentTypeDetector;

    ContentType(String rawName) {
        this.rawName = rawName;
    }


    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @NonNull
    public static ContentType guessContentType(WebResourceRequest request) {
        ContentType detect = getContentTypeDetectorLazy().detect(request);
        return detect != null ? detect : OTHER;
    }

    public static Set<ContentType> maskOf(final ContentType... contentTypes) {
        final Set<ContentType> set = new HashSet<>(contentTypes.length);
        set.addAll(Arrays.asList(contentTypes));
        return set;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private static ContentTypeDetector getContentTypeDetectorLazy() {
        if (contentTypeDetector == null) {
            final HeadersContentTypeDetector headersContentTypeDetector =
                    new HeadersContentTypeDetector();
            final UrlFileExtensionTypeDetector urlFileExtensionTypeDetector =
                    new UrlFileExtensionTypeDetector();
            contentTypeDetector = new OrderedContentTypeDetector(headersContentTypeDetector,
                    urlFileExtensionTypeDetector);
        }
        return contentTypeDetector;
    }


}
