package com.example.wrapper_example.example_library;

public class MyClass {
  public final String primitiveField;

  public final MyOtherClass classField;

  public MyClass(String primitiveField, MyOtherClass classField) {
    this.primitiveField = primitiveField;
    this.classField = classField;
  }

  public static void myStaticMethod() {

  }

  public void myMethod(int primitiveParam, MyOtherClass classParam) {

  }

  // visible for overriding
  public void myCallbackMethod() {

  }
}
