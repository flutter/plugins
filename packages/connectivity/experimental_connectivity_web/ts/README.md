# JS Facade generator

This npm script takes the `network-information-types` npm package, and runs it through Dart's `dart_js_facade_gen` to auto-generate (most) of the JS facades used by this plugin.

The process is not completely automated yet, but it should be pretty close.

To generate the facades, and after [installing `npm`](https://www.npmjs.com/get-npm), do:

```
npm install
npm run build
```

The above will fetch the required dependencies, and generate a `dist/network_information_types.dart` file that you can use with the plugin.

```
cp dist/*.dart ../lib/src/generated
```

This script should come handy once the Network Information Web API changes, or becomes stable, so the JS-interop part of this plugin can be regenerated more easily.

Read more:

* [Dart JS Interop](https://dart.dev/web/js-interop)
* [dart_js_facade_gen](https://www.npmjs.com/package/dart_js_facade_gen)