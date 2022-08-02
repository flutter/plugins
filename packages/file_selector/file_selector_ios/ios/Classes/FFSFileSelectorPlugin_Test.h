#import "FFSFileSelectorPlugin.h"

#import "messages.g.h"

// This header is available in the Test module. Import via "@import file_selector_ios.Test;".
@interface FFSFileSelectorPlugin() <FFSFileSelectorApi, UIDocumentPickerDelegate>

/**
 * The completion block of a FFSFileSelectorApi request.
 * It is saved and invoked later in a UIDocumentPickerDelegate method.
 */
@property(nonatomic) void (^_Nullable pendingCompletion)
    (NSArray<NSString *> *_Nullable, FlutterError *_Nullable);
/**
 * Overrides the view controller used for presenting the document picker.
 */
@property(nonatomic) UIViewController * _Nullable presentingViewControllerOverride;

/**
 * Overrides the UIDocumentPickerViewController used for file picking.
 */
@property(nonatomic) UIDocumentPickerViewController *_Nullable documentPickerViewControllerOverride;

@end
