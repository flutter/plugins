#import "FFSFileSelectorPlugin.h"

#import "messages.g.h"

// This header is available in the Test module. Import via "@import file_selector_ios.Test;".
@interface FFSFileSelectorPlugin () <FFSFileSelectorApi, UIDocumentPickerDelegate>

/**
 * Overrides the view controller used for presenting the document picker.
 */
@property(nonatomic) UIViewController *_Nullable presentingViewControllerOverride;

/**
 * Overrides the UIDocumentPickerViewController used for file picking.
 */
@property(nonatomic) UIDocumentPickerViewController *_Nullable documentPickerViewControllerOverride;

@end
