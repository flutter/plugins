package com.example.wrapper_example;

import androidx.annotation.NonNull;

public class BaseObjectHostApiImpl implements GeneratedExampleLibraryApis.BaseObjectHostApi {
  private final InstanceManager instanceManager;

  public BaseObjectHostApiImpl(InstanceManager instanceManager) {
    this.instanceManager = instanceManager;
  }

  @Override
  public void dispose(@NonNull Long identifier) {
    instanceManager.remove(identifier);
  }
}
