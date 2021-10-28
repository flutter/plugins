package io.flutter.plugins.webviewflutter;

/**
 * Represents a resource, or a holder of resources, which may be released once they are no longer
 * needed.
 */
interface Releasable {
  void release();
}
