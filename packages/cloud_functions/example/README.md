# cloud_functions_example

Demonstrates how to use the cloud_functions plugin.

## Function

This example assumes the existence of the following function:

```
import * as functions from 'firebase-functions';

export const repeat = functions.https.onCall((data, context) => {
  return {
      repeat_message: data.message,
      repeat_count: data.count + 1,
  }
});
```

This function accepts a message and count from the client and responds with
the same message and an incremented count.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).
