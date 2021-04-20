package io.flutter.plugins.webviewflutter.adblock.content_type;

public class HttpConstants {
    public static final String HEADER_REFERRER = "Referer";
    public static final String HEADER_REQUESTED_WITH = "X-Requested-With";
    public static final String HEADER_REQUESTED_WITH_XMLHTTPREQUEST = "XMLHttpRequest";
    public static final String HEADER_REQUESTED_RANGE = "Range";
    public static final String HEADER_LOCATION = "Location";
    public static final String HEADER_COOKIE = "Cookie";
    public static final String HEADER_USER_AGENT = "User-Agent";
    public static final String HEADER_ACCEPT = "Accept";
    public static final String HEADER_REFRESH = "Refresh";
    // use low-case strings as in WebResponse all header keys are lowered-case
    public static final String HEADER_SET_COOKIE = "set-cookie";
    public static final String HEADER_WWW_AUTHENTICATE = "www-authenticate";
    public static final String HEADER_PROXY_AUTHENTICATE = "proxy-authenticate";
    public static final String HEADER_EXPIRES = "expires";
    public static final String HEADER_DATE = "date";
    public static final String HEADER_RETRY_AFTER = "retry-after";
    public static final String HEADER_LAST_MODIFIED = "last-modified";
    public static final String HEADER_CONTENT_LENGTH = "content-length";

    /**
     * Possible values for request method argument (see `request(..)` method)
     */
    public static final String REQUEST_METHOD_GET = "GET";
    public static final String REQUEST_METHOD_POST = "POST";
    public static final String REQUEST_METHOD_HEAD = "HEAD";
    public static final String REQUEST_METHOD_OPTIONS = "OPTIONS";
    public static final String REQUEST_METHOD_PUT = "PUT";
    public static final String REQUEST_METHOD_DELETE = "DELETE";
    public static final String REQUEST_METHOD_TRACE = "TRACE";

    public static final String MIME_TYPE_TEXT_HTML = "text/html";
}