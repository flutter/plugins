// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GMSMarker+Userdata.h"

@implementation GMSMarker (Userdata)

- (void)setMarkerId:(NSString *)markerId {
  self.userData = @[ markerId ];
}

- (void)setMarkerID:(NSString *)markerId andClusterManagerId:(NSString *)clusterManagerId {
  self.userData = @[ markerId, clusterManagerId ];
}

- (NSString *)getMarkerId {
  if ([self.userData count] == 0) {
    return nil;
  }
  return self.userData[0];
}

- (NSString *)getClusterManagerId {
  if ([self.userData count] != 2) {
    return nil;
  }

  NSString *clusterManagerId = self.userData[1];
  if (clusterManagerId == (id)[NSNull null]) {
    return nil;
  }
  return clusterManagerId;
}
@end
