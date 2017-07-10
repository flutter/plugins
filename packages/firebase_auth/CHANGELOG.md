## 0.1.1

* Updated to Firebase SDK to always use latest patch version for 11.0.x builds

## 0.1.0

* Updated to Firebase SDK Version 11.0.1
* **Breaking Change**: You need to add a maven section with the "https://maven.google.com" endpoint to the repository section of your `android/build.gradle`. For example:
```gradle
allprojects {
    repositories {
        jcenter()
        maven {                              // NEW
            url "https://maven.google.com"   // NEW
        }                                    // NEW
    }
}
```

## 0.0.4

* Add method getToken() to FirebaseUser

## 0.0.3+1

* Updated README.md

## 0.0.3

* Added support for createUserWithEmailAndPassword, signInWithEmailAndPassword, and signOut Firebase methods

## 0.0.2+1

* Updated README.md

## 0.0.2

* Bump buildToolsVersion to 25.0.3

## 0.0.1

* Initial Release
