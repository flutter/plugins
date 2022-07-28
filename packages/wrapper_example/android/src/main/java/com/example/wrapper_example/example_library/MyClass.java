package com.example.wrapper_example.example_library;

import android.util.Log;

public class MyClass {
  private static final String TAG = "MyClass";

  public final String primitiveField;
  public final MyOtherClass classField;

  public MyClass(String primitiveField, MyOtherClass classField) {
    this.primitiveField = primitiveField;
    this.classField = classField;
    Log.d(TAG, String.format("Called constructor with `%s` and `%s`", primitiveField, classField.toString()));
  }

  public static void myStaticMethod() {
    Log.d(TAG, "Called myStaticMethod.");
  }

  public void myMethod(String primitiveParam, MyOtherClass classParam) {
    Log.d(TAG, String.format("Called `myMethod` with `%s` and `%s`", primitiveParam, classParam.toString()));
    myCallbackMethod();
  }

  // visible for overriding
  public void myCallbackMethod() {

  }
}
