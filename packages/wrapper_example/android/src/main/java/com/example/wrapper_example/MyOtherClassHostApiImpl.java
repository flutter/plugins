package com.example.wrapper_example;

import androidx.annotation.NonNull;

import com.example.wrapper_example.example_library.MyOtherClass;

public class MyOtherClassHostApiImpl implements GeneratedExampleLibraryApis.MyOtherClassHostApi {
  private final InstanceManager instanceManager;

  public MyOtherClassHostApiImpl(InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  @Override
  public void create(@NonNull Long identifier) {
    instanceManager.addDartCreatedInstance(new MyOtherClass(), identifier);
  }
}
