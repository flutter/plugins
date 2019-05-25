part of firebase_ml_vision;

/// Used to manage available models
///
///
/// A model manager is created via
/// `modelManager()` in [FirebaseVision]:
///
/// ```dart
///
/// final ModelManager modelManager =
///     FirebaseLanguage.instance.modelManager();
///
/// final List<String> = await modelManager.downloadModel('modelname');
/// ```
///

class ModelManager {
  ModelManager._();

  /// Sets up model
  Future<String> setupModel(String modelName, String modelLocation) async {
    if (modelLocation == ModelLocation.Local) {
      final String status = await FirebaseVision.channel.invokeMethod(
          'ModelManager#setupLocalModel',
          <String, dynamic>{'model': modelName});
      return status;
    } else {
      final String status = await FirebaseVision.channel.invokeMethod(
          'ModelManager#setupRemoteModel',
          <String, dynamic>{'model': modelName});
      return status;
    }
  }
}
