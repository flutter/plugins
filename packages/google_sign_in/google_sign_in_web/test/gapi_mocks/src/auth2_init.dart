// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of gapi_mocks;

// JS mock of a gapi.auth2, with a successfully identified user
String auth2InitSuccess(GoogleSignInUserData userData) => testIife('''
${gapi()}

var mockUser = ${googleUser(userData)};

function GapiAuth2() {}
GapiAuth2.prototype.init = function (initOptions) {
  return {
    then: (onSuccess, onError) => {
      window.setTimeout(() => {
        onSuccess(window.gapi.auth2);
      }, 30);
    },
    currentUser: {
      listen: (cb) => {
        window.setTimeout(() => {
          cb(mockUser);
        }, 30);
      }
    }
  }
};

GapiAuth2.prototype.getAuthInstance = function () {
  return {
    signIn: () => {
      return new Promise((resolve, reject) => {
        window.setTimeout(() => {
          resolve(mockUser);
        }, 30);
      });
    },
    currentUser: {
      get: () => mockUser,
    },
  }
};

window.gapi.auth2 = new GapiAuth2();
''');
