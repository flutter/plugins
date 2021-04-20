package io.flutter.plugins.webviewflutter.adblock;


import android.net.Uri;
import android.util.Log;

import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import androidx.arch.core.util.Function;
import io.flutter.plugins.webviewflutter.content_type.ContentType;

import static io.flutter.plugins.webviewflutter.adblock.ContentBlockingRuleTypes.*;

enum ContentBlockerOperationResult {
    SUCCESS,
    ERROR_CAN_NOT_READ_FILE,
    ERROR_CAN_NOT_COMPILE_RULE,
}

enum ContentBlockingKeys {
    TYPE("type"),
    FILE_PATH("file_path"),
    HOSTS("hosts");

    final String rawName;

    ContentBlockingKeys(String rawName) {
        this.rawName = rawName;
    }
}

enum ContentBlockingRuleTypes {
    JSON("json"),
    DAT("dat"),
    HOSTS("hosts");

    final String rawName;

    ContentBlockingRuleTypes(String rawName) {
        this.rawName = rawName;
    }

    static ContentBlockingRuleTypes forRawName(String rawName) {
        for (ContentBlockingRuleTypes value : values()) {
            if (value.rawName.equals(rawName)) return value;
        }
        throw new UnsupportedOperationException("The rawName " + rawName + " is not part of the ContentBlockingRuleTypes enum");
    }
}

public enum ContentBlocker implements ContentBlockEngine {
    INSTANCE;

    private final Map<String, ContentBlockEngine> engines = Collections.synchronizedMap(new LinkedHashMap<String, ContentBlockEngine>());
    private final AtomicBoolean isReady = new AtomicBoolean(false);
    private static final String TAG = "ContentBlocker";

    public boolean isReady() {
        return isReady.get();
    }

    public void setupContentBlocking(Map<String, Map<String, Object>> rules) {
        for (final Map.Entry<String, Map<String, Object>> rule : rules.entrySet()) {
            ContentBlockingRuleTypes type = forRawName((String) rule.getValue().get(ContentBlockingKeys.TYPE.rawName));
            switch (type) {
                case HOSTS:
                    @SuppressWarnings("unchecked")
                    Collection<String> hosts = (Collection<String>) rule.getValue().get(ContentBlockingKeys.HOSTS.rawName);
                    engines.put(rule.getKey(), new HashBlockEngine(hosts));
                    break;
                case DAT:
                    final String pathToDatFile = (String) rule.getValue().get(ContentBlockingKeys.FILE_PATH.rawName);
                    new RustAdblockeEngine(pathToDatFile, rule.getKey(), new Function<RustAdblockeEngine, Void>() {
                        // Careful: apply is called on a Worker Thread
                        @Override
                        public Void apply(RustAdblockeEngine engine) {
                            if (engine != null) {
                                engines.put(rule.getKey(), engine);
                            } else {
                                // TODO Throw error so that Flutter understands that this resource is not valid
                                Log.d(TAG, "Could not init rust adblock engine:  " + pathToDatFile);
                            }
                            return null;
                        }
                    });

                    break;
                case JSON:
                default:
                    throw new UnsupportedOperationException("Rules type " + type);
            }
        }

        isReady.set(true);
    }

    @Override
    public BlockResult shouldBlock(Uri hostedUrl, Uri requestedUrl, ContentType type) {
        for (ContentBlockEngine engine : engines.values()) {
            BlockResult blockResult = engine.shouldBlock(hostedUrl, requestedUrl, type);
            switch (blockResult) {
                case BLOCK:
                    return blockResult;
                case OK:
                default:
                    break;
            }
        }
        return BlockResult.OK;
    }
}


interface ContentBlockEngine {
    /**
     * The engine decides if the [requestedUrl] will be blocked. It might be useful to provide
     * the host url for white-listing purposes.
     *
     * @param hostedUrl    (i.e. https://heise.de)
     * @param requestedUrl (i.e. https://heise.de/ads/script)
     * @param type (The types of content that is requested)
     * @return The decision if the requestedUrl should be blocked.
     */
    BlockResult shouldBlock(Uri hostedUrl, Uri requestedUrl, ContentType type);
}

