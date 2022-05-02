
NSKeyValueObservingOptions FWFNSKeyValueObservingOptionsFromEnumData(FWFNSKeyValueObservingOptionsEnumData *data) {
  switch(data.value) {
    
    case FWFNSKeyValueObservingOptionsEnumNewValue:
      return NSKeyValueObservingOptionsNewValue;
    
    case FWFNSKeyValueObservingOptionsEnumOldValue:
      return NSKeyValueObservingOptionsOldValue;
    
    case FWFNSKeyValueObservingOptionsEnumInitialValue:
      return NSKeyValueObservingOptionsInitialValue;
    
    case FWFNSKeyValueObservingOptionsEnumPriorNotification:
      return NSKeyValueObservingOptionsPriorNotification;
    
  }
  
  return -1;
}

NSKeyValueChange FWFNSKeyValueChangeFromEnumData(FWFNSKeyValueChangeEnumData *data) {
  switch(data.value) {
    
    case FWFNSKeyValueChangeEnumSetting:
      return NSKeyValueChangeSetting;
    
    case FWFNSKeyValueChangeEnumInsertion:
      return NSKeyValueChangeInsertion;
    
    case FWFNSKeyValueChangeEnumRemoval:
      return NSKeyValueChangeRemoval;
    
    case FWFNSKeyValueChangeEnumReplacement:
      return NSKeyValueChangeReplacement;
    
  }
  
  return -1;
}

NSKeyValueChangeKey FWFNSKeyValueChangeKeyFromEnumData(FWFNSKeyValueChangeKeyEnumData *data) {
  switch(data.value) {
    
    case FWFNSKeyValueChangeKeyEnumIndexes:
      return NSKeyValueChangeKeyIndexes;
    
    case FWFNSKeyValueChangeKeyEnumKind:
      return NSKeyValueChangeKeyKind;
    
    case FWFNSKeyValueChangeKeyEnumNewValue:
      return NSKeyValueChangeKeyNewValue;
    
    case FWFNSKeyValueChangeKeyEnumNotificationIsPrior:
      return NSKeyValueChangeKeyNotificationIsPrior;
    
    case FWFNSKeyValueChangeKeyEnumOldValue:
      return NSKeyValueChangeKeyOldValue;
    
  }
  
  return -1;
}

NSHttpCookiePropertyKey FWFNSHttpCookiePropertyKeyFromEnumData(FWFNSHttpCookiePropertyKeyEnumData *data) {
  switch(data.value) {
    
    case FWFNSHttpCookiePropertyKeyEnumComment:
      return NSHttpCookiePropertyKeyComment;
    
    case FWFNSHttpCookiePropertyKeyEnumCommentUrl:
      return NSHttpCookiePropertyKeyCommentUrl;
    
    case FWFNSHttpCookiePropertyKeyEnumDiscard:
      return NSHttpCookiePropertyKeyDiscard;
    
    case FWFNSHttpCookiePropertyKeyEnumDomain:
      return NSHttpCookiePropertyKeyDomain;
    
    case FWFNSHttpCookiePropertyKeyEnumExpires:
      return NSHttpCookiePropertyKeyExpires;
    
    case FWFNSHttpCookiePropertyKeyEnumMaximumAge:
      return NSHttpCookiePropertyKeyMaximumAge;
    
    case FWFNSHttpCookiePropertyKeyEnumName:
      return NSHttpCookiePropertyKeyName;
    
    case FWFNSHttpCookiePropertyKeyEnumOriginUrl:
      return NSHttpCookiePropertyKeyOriginUrl;
    
    case FWFNSHttpCookiePropertyKeyEnumPath:
      return NSHttpCookiePropertyKeyPath;
    
    case FWFNSHttpCookiePropertyKeyEnumPort:
      return NSHttpCookiePropertyKeyPort;
    
    case FWFNSHttpCookiePropertyKeyEnumSameSitePolicy:
      return NSHttpCookiePropertyKeySameSitePolicy;
    
    case FWFNSHttpCookiePropertyKeyEnumSecure:
      return NSHttpCookiePropertyKeySecure;
    
    case FWFNSHttpCookiePropertyKeyEnumValue:
      return NSHttpCookiePropertyKeyValue;
    
    case FWFNSHttpCookiePropertyKeyEnumVersion:
      return NSHttpCookiePropertyKeyVersion;
    
  }
  
  return -1;
}
