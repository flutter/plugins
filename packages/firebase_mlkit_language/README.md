# ML Kit Natural Language Plugin

![Pub](https://img.shields.io/pub/v/firebase_mlkit_language.svg?color=orange)

A Flutter plugin to use the [ML Kit Natural Language for Firebase API](https://firebase.google.com/docs/ml-kit/).

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/rishab2113/firebase_mlkit_language/issues) and [Pull Requests](https://github.com/rishab2113/firebase_mlkit_language/pulls) are most welcome!

Note: iOS Only

## Usage

To use this plugin, add `firebase_mlkit_language` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). You must also configure Firebase for each platform project: Android and iOS (see the example folder or https://codelabs.developers.google.com/codelabs/flutter-firebase/#4 for step by step details).

### iOS
Versions `1.0.0+` use the latest ML Kit for Firebase version which requires a minimum deployment
target of 9.0. You can add the line `platform :ios, '9.0'` in your iOS project `Podfile`.

## Supported Languages
All the supported languages can be found [here](https://firebase.google.com/docs/ml-kit/translation-language-support).

Furthermore, they can be found within the `SupportedLanguages` class.

## Using the ML Kit Language Identifier

### 1. Create an instance of a language identifier

Initialize a `LanguageIdentifier`.

```dart
final LanguageIdentifier languageIdentifier = FirebaseLanguage.instance.languageIdentifier()
```

### 2. Call `processText(String)` with `languageIdentifier`

`processText(String)` returns `List<LanguageLabel>` in decreasing order of probability of detected language.

```dart
final List<LanguageLabel> labels = await languageIdentifier.processText('Sample Text');
```

### 3. Extract data

`<LanguageLabel>` contains the language names and confidence of the prediction, accessible via `.text` and `.confidence`.

```dart
for (LanguageLabel label in labels) {
  final String text = label.text;
  final double confidence = label.confidence;
}
```

## Using the ML Kit Language Translator

### Note

Get an instance of `ModelManager`, and download the needed translation models(optional, results in faster first-use).

```dart
FirebaseLanguage.instance.modelManager().downloadModel(SupportedLanguages.lang);
```

### 1. Create an instance of a language translator

Initialize a `LanguageTranslator`.

```dart
final FirebaseLanguage.instance.languageTranslator(SupportedLanguages.lang, SupportedLanguages.lang);
```

### 2. Call `processText(String) with languageTranslator`

`processText(String)` returns a string containing the text translated to the target language.

```dart
final String translatedString = await languageTranslator.processText('Sample Text');
```

## Using the ML Kit Model Manager

### 1. Create an instance of a model manager

Initialize a `ModelManager`

```dart
final ModelManager modelManager = FirebaseLanguage.instance.modelManager()
```

### 2. Download Model using the model manager

`downloadModel()` downloads the specified model to the device's local storage. It is recommended to download all the models needed to be used before translating to ensure a fast first-use. On a successful download, the string "Downloaded" will be returned.

```dart
modelManager.downloadModel(SupportedLanguages.lang)
```

### 3. Delete Model using the model manager

`deleteModel()` deletes the specified model from the device's local storage. On a successful delete, the string "Deleted" will be returned. If the model specified is not present on the device, the string "Model not downloaded" will be returned.

```dart
modelManager.deleteModel(SupportedLanguages.lang)
```

### 4. View Models

`viewModels()` returns a list of the BCP-47 language codes of all the languages downloaded onto the local storage of the device.

```dart
modelManager.viewModels()
```
