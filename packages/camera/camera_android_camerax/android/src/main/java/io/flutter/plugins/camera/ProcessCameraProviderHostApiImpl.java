public class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
    private final BinaryMessenger binaryMessenger;
    private final InstanceManager instanceManager;

    public ProcessCameraProviderHostApiImpl(BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
        this.binaryMessenger = binaryMessenger;
        this.instanceManager = instanceManager;
      }

    @override
    void getInstance(Result<Long> result) {
        ListenableFuture<ProcessCameraProvider> cameraProviderFuture =
            ProcessCameraProvider.getInstance(this);

        cameraProviderFuture.addListener(() -> {
        try {
            // Camera provider is now guaranteed to be available
            ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
            if (!instanceManager.containsInstance(cameraProvider)) {
                final ProcessCameraProviderFlutterApiImpl flutterApi =
                    ProcessCameraProviderFlutterApiImpl(binaryMessenger, instanceManager);
                flutterApi.create(cameraProvider, result -> {});
            }
        } catch (Exception e) {
            result.error(e);
        }
    });

}