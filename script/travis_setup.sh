#!/bin/bash
set -ev
git clone https://github.com/flutter/flutter.git --depth 1
./flutter/bin/flutter doctor
export PATH=`pwd`/flutter/bin:`pwd`/flutter/bin/cache/dart-sdk/bin:$PATH
./flutter/bin/cache/dart-sdk/bin/pub global activate flutter_plugin_tools
