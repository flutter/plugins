package com.example.wrapper_example;

import androidx.annotation.NonNull;
import com.example.wrapper_example.example_library.MyClassSubclass;
import com.example.wrapper_example.example_library.MyOtherClass;
import io.flutter.plugin.common.BinaryMessenger;

public class MyClassSubclassHostApiImpl
    implements GeneratedExampleLibraryApis.MyClassSubclassHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  public static class MyClassSubclassImpl extends MyClassSubclass {
    private final MyClassFlutterApiImpl myClassApi;

    public MyClassSubclassImpl(
        String primitiveField,
        MyOtherClass classField,
        BinaryMessenger binaryMessenger,
        InstanceManager instanceManager) {
      super(primitiveField, classField);
      myClassApi = new MyClassFlutterApiImpl(binaryMessenger, instanceManager);
    }

    @Override
    public void myCallbackMethod() {
      myClassApi.myCallbackMethod(this, reply -> {});
    }
  }

  public MyClassSubclassHostApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public void create(
      @NonNull Long identifier,
      @NonNull String primitiveField,
      @NonNull Long classFieldIdentifier) {
    instanceManager.addDartCreatedInstance(
        new MyClassHostApiImpl.MyClassImpl(
            primitiveField,
            instanceManager.getInstance(classFieldIdentifier),
            binaryMessenger,
            instanceManager),
        identifier);
  }
}
