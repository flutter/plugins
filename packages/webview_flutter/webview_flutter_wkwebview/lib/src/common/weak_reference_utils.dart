/// Helper method for creating callbacks methods with a weak reference.
S withWeakRefenceTo<T extends Object, S extends Object>(
  T reference,
  S Function(WeakReference<T> weakReference) onCreate,
) {
  final WeakReference<T> weakReference = WeakReference<T>(reference);
  return onCreate(weakReference);
}
