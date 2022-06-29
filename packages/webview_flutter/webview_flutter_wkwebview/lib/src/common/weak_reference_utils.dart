/// Helper method to create a callback with a [WeakReference].
S withWeakRef<T extends Object, S extends Object>(
  T reference,
  S Function(WeakReference<T> weakRef) onCreateCallback,
) {
  return onCreateCallback(WeakReference<T>(reference));
}
