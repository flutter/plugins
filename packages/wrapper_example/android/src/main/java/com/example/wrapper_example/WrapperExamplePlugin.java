package com.example.wrapper_example;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import com.example.wrapper_example.GeneratedExampleLibraryApis.BaseObjectHostApi;
import com.example.wrapper_example.GeneratedExampleLibraryApis.MyOtherClassHostApi;
import com.example.wrapper_example.GeneratedExampleLibraryApis.MyClassHostApi;

/** WrapperExamplePlugin */
public class WrapperExamplePlugin implements FlutterPlugin {
  private InstanceManager instanceManager;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    final BinaryMessenger binaryMessenger = flutterPluginBinding.getBinaryMessenger();

    instanceManager = InstanceManager.open(identifier -> {
      new GeneratedExampleLibraryApis.BaseObjectFlutterApi(binaryMessenger).dispose(identifier, reply -> {});
    });

    BaseObjectHostApi.setup(binaryMessenger, new BaseObjectHostApiImpl(instanceManager));
    MyOtherClassHostApi.setup(binaryMessenger, new MyOtherClassHostApiImpl(instanceManager));
    MyClassHostApi.setup(binaryMessenger, new MyClassHostApiImpl(binaryMessenger, instanceManager));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    instanceManager.close();
  }
}
