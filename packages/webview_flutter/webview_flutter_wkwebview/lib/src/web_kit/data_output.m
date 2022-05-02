
NSKeyValueObservingOptions FWFNSKeyValueObservingOptionsFromEnumData(FWFNSKeyValueObservingOptionsEnumData *data) {
  switch (data.value) {
    
    case FWFNSKeyValueObservingOptionsEnum NewValue:
      return NSKeyValueObservingOptions NewValue;
      
    case FWFNSKeyValueObservingOptionsEnum OldValue:
      return NSKeyValueObservingOptions OldValue;
      
    case FWFNSKeyValueObservingOptionsEnum InitialValue:
      return NSKeyValueObservingOptions InitialValue;
      
    case FWFNSKeyValueObservingOptionsEnum PriorNotification:
      return NSKeyValueObservingOptions PriorNotification;
      
  }

  return -1;
}

NSKeyValueChange FWFNSKeyValueChangeFromEnumData(FWFNSKeyValueChangeEnumData *data) {
  switch (data.value) {
    
    case FWFNSKeyValueChangeEnum Setting:
      return NSKeyValueChange Setting;
      
    case FWFNSKeyValueChangeEnum Insertion:
      return NSKeyValueChange Insertion;
      
    case FWFNSKeyValueChangeEnum Removal:
      return NSKeyValueChange Removal;
      
    case FWFNSKeyValueChangeEnum Replacement:
      return NSKeyValueChange Replacement;
      
  }

  return -1;
}

NSKeyValueChangeKey FWFNSKeyValueChangeKeyFromEnumData(FWFNSKeyValueChangeKeyEnumData *data) {
  switch (data.value) {
    
    case FWFNSKeyValueChangeKeyEnum Indexes:
      return NSKeyValueChangeKey Indexes;
      
    case FWFNSKeyValueChangeKeyEnum Kind:
      return NSKeyValueChangeKey Kind;
      
    case FWFNSKeyValueChangeKeyEnum NewValue:
      return NSKeyValueChangeKey NewValue;
      
    case FWFNSKeyValueChangeKeyEnum NotificationIsPrior:
      return NSKeyValueChangeKey NotificationIsPrior;
      
    case FWFNSKeyValueChangeKeyEnum OldValue:
      return NSKeyValueChangeKey OldValue;
      
  }

  return -1;
}

NSHttpCookiePropertyKey FWFNSHttpCookiePropertyKeyFromEnumData(FWFNSHttpCookiePropertyKeyEnumData *data) {
  switch (data.value) {
    
    case FWFNSHttpCookiePropertyKeyEnum Comment:
      return NSHttpCookiePropertyKey Comment;
      
    case FWFNSHttpCookiePropertyKeyEnum CommentUrl:
      return NSHttpCookiePropertyKey CommentUrl;
      
    case FWFNSHttpCookiePropertyKeyEnum Discard:
      return NSHttpCookiePropertyKey Discard;
      
    case FWFNSHttpCookiePropertyKeyEnum Domain:
      return NSHttpCookiePropertyKey Domain;
      
    case FWFNSHttpCookiePropertyKeyEnum Expires:
      return NSHttpCookiePropertyKey Expires;
      
    case FWFNSHttpCookiePropertyKeyEnum MaximumAge:
      return NSHttpCookiePropertyKey MaximumAge;
      
    case FWFNSHttpCookiePropertyKeyEnum Name:
      return NSHttpCookiePropertyKey Name;
      
    case FWFNSHttpCookiePropertyKeyEnum OriginUrl:
      return NSHttpCookiePropertyKey OriginUrl;
      
    case FWFNSHttpCookiePropertyKeyEnum Path:
      return NSHttpCookiePropertyKey Path;
      
    case FWFNSHttpCookiePropertyKeyEnum Port:
      return NSHttpCookiePropertyKey Port;
      
    case FWFNSHttpCookiePropertyKeyEnum SameSitePolicy:
      return NSHttpCookiePropertyKey SameSitePolicy;
      
    case FWFNSHttpCookiePropertyKeyEnum Secure:
      return NSHttpCookiePropertyKey Secure;
      
    case FWFNSHttpCookiePropertyKeyEnum Value:
      return NSHttpCookiePropertyKey Value;
      
    case FWFNSHttpCookiePropertyKeyEnum Version:
      return NSHttpCookiePropertyKey Version;
      
  }

  return -1;
}
