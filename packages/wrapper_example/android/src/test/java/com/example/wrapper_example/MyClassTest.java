package com.example.wrapper_example;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;

import com.example.wrapper_example.example_library.MyClass;
import com.example.wrapper_example.example_library.MyOtherClass;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class MyClassTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public MyClass mockMyClass;

  @Mock public BinaryMessenger mockBinaryMessenger;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  public void hostApiCreate() {
    final MyOtherClass myOtherClass = new MyOtherClass();
    instanceManager.addDartCreatedInstance(myOtherClass, 0);

    final MyClassHostApiImpl myClassHostApi =
        new MyClassHostApiImpl(mockBinaryMessenger, instanceManager);

    myClassHostApi.create(1L, "myString", 0L);

    final MyClass createdMyClass = instanceManager.getInstance(1L);
    assertNotNull(createdMyClass);
  }

  @Test
  public void myStaticMethod() {
    final boolean[] myStaticMethodCalled = {false};
    final MyClassHostApiImpl myClassHostApi =
        new MyClassHostApiImpl(
            mockBinaryMessenger,
            instanceManager,
            new MyClassHostApiImpl.MyClassProxy() {
              @Override
              public void myStaticMethod() {
                myStaticMethodCalled[0] = true;
              }
            });

    myClassHostApi.myStaticMethod();
    assertTrue(myStaticMethodCalled[0]);
  }

  @Test
  public void myMethod() {
    final MyOtherClass myOtherClass = new MyOtherClass();
    instanceManager.addDartCreatedInstance(myOtherClass, 0);

    final MyClassHostApiImpl myClassHostApi =
        new MyClassHostApiImpl(mockBinaryMessenger, instanceManager);

    instanceManager.addDartCreatedInstance(mockMyClass, 1);

    myClassHostApi.myMethod(1L, "myString", 0L);
    verify(mockMyClass).myMethod("myString", myOtherClass);
  }

  @Test
  public void flutterApiCreate() {
    final MyClassFlutterApiImpl spyFlutterApi =
        spy(new MyClassFlutterApiImpl(mockBinaryMessenger, instanceManager));

    final MyClass myClass = new MyClass("myString", new MyOtherClass());
    spyFlutterApi.create(myClass, "myString", reply -> {});

    final long identifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(myClass));
    verify(spyFlutterApi).create(eq(identifier), eq("myString"), any());
  }

  @Test
  public void myCallbackMethod() {
    final MyClassFlutterApiImpl spyFlutterApi =
        spy(new MyClassFlutterApiImpl(mockBinaryMessenger, instanceManager));

    final MyClassHostApiImpl.MyClassImpl myClass =
        new MyClassHostApiImpl.MyClassImpl(
            "myString", new MyOtherClass(), mockBinaryMessenger, instanceManager) {
          @Override
          public MyClassFlutterApiImpl getApi() {
            return spyFlutterApi;
          }
        };
    instanceManager.addDartCreatedInstance(myClass, 0);

    myClass.myCallbackMethod();
    verify(spyFlutterApi).myCallbackMethod(eq(0L), any());
  }
}
