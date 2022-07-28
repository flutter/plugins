public class ProcessCameraProviderFlutterApiImpl extends ProcessCameraProviderFlutterApi {
    public ProcessCameraProviderFlutterApiImpl(BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
        super(binaryMessenger);
        this.instanceManager = instanceManager;
      }

    private final InstanceManager instanceManager;

    void create(ProcessCameraProvider processCameraProvider, Reply<Void> reply) {
        create(instanceManager.getIdentifierForStrongReference(processCameraProvider), reply);
    }
}