package io.flutter.plugins.inapppurchase;

import static org.mockito.Mockito.when;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class InAppPurchasePluginTest {
  @Mock Activity activity;
  @Mock Context context;
  @Mock PluginRegistry.Registrar mockRegistrar; // For v1 embedding
  @Mock BinaryMessenger mockMessenger;
  @Mock Application mockApplication;
  @Mock Context mockApplicatonContext;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    when(mockRegistrar.activity()).thenReturn(activity);
    when(mockRegistrar.messenger()).thenReturn(mockMessenger);
    when(mockRegistrar.context()).thenReturn(context);
  }

  @Test
  public void registerWith_doNotCrashWhenApplicationContextIsTypeContext() {
    when(context.getApplicationContext()).thenReturn(mockApplicatonContext);
    InAppPurchasePlugin.registerWith(mockRegistrar);
  }

  @Test
  public void registerWith_doNotCrashWhenApplicationContextIsTypeApplication() {
    when(context.getApplicationContext()).thenReturn(mockApplication);
    InAppPurchasePlugin.registerWith(mockRegistrar);
  }

  @Test
  public void registerWith_doNotCrashWhenApplicationContextIsNull() {
    when(context.getApplicationContext()).thenReturn(null);
    InAppPurchasePlugin.registerWith(mockRegistrar);
  }
}
