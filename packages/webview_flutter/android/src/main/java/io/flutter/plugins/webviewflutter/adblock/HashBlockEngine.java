package io.flutter.plugins.webviewflutter.adblock;

import android.net.Uri;

import java.util.Collection;
import java.util.HashSet;

import io.flutter.plugins.webviewflutter.adblock.BlockResult;
import io.flutter.plugins.webviewflutter.adblock.ContentBlockEngine;
import io.flutter.plugins.webviewflutter.content_type.ContentType;

class HashBlockEngine implements ContentBlockEngine {

    final HashSet<String> hosts;

    HashBlockEngine(Collection<String> hosts) {
        this.hosts = new HashSet<>(hosts);
    }


    @Override
    public BlockResult shouldBlock(Uri hostedUrl, Uri requestedUrl, ContentType type) {
        String host = requestedUrl.getHost();
        return hosts.contains(host) ? BlockResult.BLOCK : BlockResult.OK;
    }
}
