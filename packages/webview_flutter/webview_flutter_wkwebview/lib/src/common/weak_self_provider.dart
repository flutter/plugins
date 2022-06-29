///
mixin WeakSelfProvider<T extends Object> {
  ///
  S withWeakSelf<S>(S Function(WeakReference<T> weakSelf) onCreateWeakSelf) {
    return onCreateWeakSelf(WeakReference<T>(this as T));
  }
}
