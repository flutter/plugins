part of firebase_dynamic_links;

class FirebaseDynamicLinks {
  FirebaseDynamicLinks._();

  @visibleForTesting
  static const MethodChannel channel =
      const MethodChannel('plugins.flutter.io/firebase_dynamic_links');

  static final FirebaseDynamicLinks instance = new FirebaseDynamicLinks._();
}
