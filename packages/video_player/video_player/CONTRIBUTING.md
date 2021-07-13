## Updating pigeon-generated files

If you update files in the pigeons/ directory, run the following
command in this directory (ignore the errors you get about
dependencies in the examples directory):

```bash
flutter pub upgrade
flutter pub run pigeon --dart_null_safety --input pigeons/messages.dart
# git commit your changes so that your working environment is clean
(cd ../../../; ./script/tool_runner.sh format --clang-format=clang-format-7)
```

If you update pigeon itself and want to test the changes here,
temporarily update the pubspec.yaml by adding the following to the
`dependency_overrides` section, assuming you have checked out the
`flutter/packages` repo in a sibling directory to the `plugins` repo:

```yaml
  pigeon:
    path:
      ../../../../packages/packages/pigeon/
```

Then, run the commands above. When you run `pub get` it should warn
you that you're using an override. If you do this, you will need to
publish pigeon before you can land the updates to this package, since
the CI tests run the analysis using latest published version of
pigeon, not your version or the version on master.

In either case, the configuration will be obtained automatically from
the `pigeons/messages.dart` file (see `configurePigeon` at the bottom
of that file).

While contributing, you may also want to set the following dependency
overrides:

```yaml
dependency_overrides:
  video_player_platform_interface:
    path:
      ../video_player_platform_interface
  video_player_web:
    path:
      ../video_player_web
```

## Publishing plugin updates that span multiple plugin packages

If your change affects both the interface package and the
implementation packages, then you will need to publish a version of
the plugin in between landing the interface changes and the
implementation changes, since the implementations depend on the
interface via pub.

To do this, follow these steps:

1. Create a PR that has all the changes, and update the
`pubspec.yaml`s to have path-based dependency overrides as described
in the "Updating pigeon-generated files" section above.

2. Upload that PR and get it reviewed and into a state where the only
test failure is the one complaining that you can't publish a package
that has dependency overrides.

3. Create a PR that's a subset of the one in the previous step that
only includes the interface changes, with no dependency overrides, and
submit that.

4. Once you have had that reviewed and landed, publish the interface
parts of the plugin to pub.

5. Now, update the original full PR to not use dependency overrides
but to instead refer to the new version of the plugin, and sync it to
master (so that the interface changes are gone from the PR). Submit
that PR.

6. Once you have had _that_ PR reviewed and landed, publish the
implementation parts of the plugin to pub.

You may need to publish each implementation package independently of
the main package also, depending on exactly what your change entails.
