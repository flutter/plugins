import 'instance_manager.dart';

class ProcessCameraProvider extends JavaObject {

    ProcessCameraProvider.detached({
        super.binaryMessenger,
        super.instanceManager})
        : _api = ProcessCameraProviderHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();
    
    final ProcessCameraProviderHostApiImpl _api;

    static Future<ProcessCameraProvider> getInstance({
        BinaryMessenger? binaryMessenger,
        InstanceManager? instanceManager}) {
            ProcessCameraProviderFlutterApi.setup(ProcessCameraProviderFlutterApiImpl(binaryMessenger: binaryMessenger, instanceManager: instanceMananger))
        return ProcessCameraProviderHostApiImpl(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
        ).getInstance();
    }
}

class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
  ProcessCameraProvideHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? JavaObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  final BinaryMessenger? binaryMessenger;

  final InstanceManager instanceManager;

  static Future<ProcessCameraProvider> getInstancefromInstances() {
    return instanceManager.getInstance(await getInstance());
  }
}

class ProcessCameraProviderFlutterApiImpl implements ProcessCameraProviderFlutterApi {
  /// Constructs a [ProcessCameraProviderFlutterApiImpl].
  ProcessCameraProviderFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void create(
    int identifier
  ) {
    instanceManager.addHostCreatedInstance(
      ProcessCameraProvider.detached(),
      identifier,
      onCopy: (ProcessCameraProvider original) => ProcessCameraProvider.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
    );
  }
}