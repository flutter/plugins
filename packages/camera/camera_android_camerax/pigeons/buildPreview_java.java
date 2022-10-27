public class buildPreview_java {
    void buildPreview() {
        ProcessCameraProvider processCameraProvider = processCameraProvider.getInstance();
        Preview preview = new Preview.build();
        CameraSelector.Builder cameraSelectorBuilder = new CameraSelector.Builder();
        CameraSelector cameraSelector = cameraSelectorBuilder.requireLensFacing(CameraSelector.LENS_FACING_FRONT).build();

        // [B] //
        Preview.SurfaceProvider surfaceProvider =
            new Preview.SurfaceProvider() {
                @Override
                void onSurface(SurfaceRequest request) {
                    // Will provide Surface to preview that is derived from
                    // Flutter's TextureRegistry.
                }
        };

        preview.setSurfaceProvider(surfaceProvider);
        Camera camera =
            processCameraProvider.bindToLifecycle(
                (LifecycleOwner) this, cameraSelector, preview);
    }
}
