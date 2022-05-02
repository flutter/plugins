flutter pub run code_template_processor --template-file lib/src/web_kit/template.h --data-file lib/src/web_kit/web_kit.simple_ast.json --token-opener /*- lib/src/web_kit/output.h
flutter pub run code_template_processor --template-file lib/src/web_kit/template.m --data-file lib/src/web_kit/web_kit.simple_ast.json lib/src/web_kit/output.m
flutter pub run code_template_processor --template-file lib/src/web_kit/template_test.m --data-file lib/src/web_kit/web_kit.simple_ast.json lib/src/web_kit/output_test.m
flutter pub run code_template_processor --template-file lib/src/web_kit/data_template.h --data-file lib/src/foundation/foundation.simple_ast.json --token-opener /*- lib/src/web_kit/data_output.h
flutter pub run code_template_processor --template-file lib/src/web_kit/data_template.m --data-file lib/src/foundation/foundation.simple_ast.json lib/src/web_kit/data_output.m
