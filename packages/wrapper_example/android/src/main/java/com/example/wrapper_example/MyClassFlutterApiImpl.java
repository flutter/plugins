package com.example.wrapper_example;

import com.example.wrapper_example.example_library.MyClass;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;

public class MyClassFlutterApiImpl extends GeneratedExampleLibraryApis.MyClassFlutterApi {
  private final InstanceManager instanceManager;

  public MyClassFlutterApiImpl(BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  public void myCallbackMethod(MyClass instance, Reply<Void> callback) {
    myCallbackMethod(
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(instance)),
        callback);
  }
}
