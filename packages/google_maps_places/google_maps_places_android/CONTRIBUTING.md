## Updating pigeon-generated files

If you update files in the pigeons/ directory, run the following
commands in this directory:

```bash
flutter pub upgrade
flutter pub run pigeon --input pigeons/messages.dart
flutter pub run build_runner build
# git commit your changes so that your working environment is clean
```
