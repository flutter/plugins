## 0.0.1

* The Cloud Functions for Firebase client SDKs let you call functions
  directly from a Firebase app. This plugin exposes this ability to
  Flutter apps.

  [Callable functions](https://firebase.google.com/docs/functions/callable)
  are similar to other HTTP functions, with these additional features:

    - With callables, Firebase Authentication and FCM tokens are
      automatically included in requests.
    - The functions.https.onCall trigger automatically deserializes
      the request body and validates auth tokens.