typedef WeakReferenceCallback<T> = T Function(WeakReference<Object>? weakRef);

T? passWeakReferenceToCallback<T, S extends Function?>(
  S callback,
  Object? callbackReference,
) {
  if (callback == null) {
    return null;
  }
  final WeakReference<Object>? weakReference = callbackReference == null
      ? null
      : WeakReference<Object>(callbackReference);
  return callback(weakReference) as T;
}
