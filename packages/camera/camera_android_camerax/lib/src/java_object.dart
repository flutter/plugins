@immutable
class JavaObject {
    JavaObject.detached({
        BinaryMessenger? binaryMessenger,
        InstanceManager? instanceManager});

    /// Global instance of [InstanceManager].
    static final InstanceManager globalInstanceManager =
        InstanceManager(onWeakReferenceRemoved: (int identifier) {
        BaseObjectHostApiImpl().dispose(identifier);
    });
}