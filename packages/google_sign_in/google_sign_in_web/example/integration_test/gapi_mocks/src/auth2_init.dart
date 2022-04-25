// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of gapi_mocks;

// JS mock of a gapi.auth2, with a successfully identified user
String auth2InitSuccess(GoogleSignInUserData userData) => testIife('''
${gapi()}

var mockUser = ${googleUser(userData)};

function GapiAuth2() {}
GapiAuth2.prototype.init = function (initOptions) {
  /*Leak the initOptions so we can look at them later.*/
  window['gapi2.init.parameters'] = initOptions;
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

String auth2InitError() => testIife('''
${gapi()}

function GapiAuth2() {}
GapiAuth2.prototype.init = function (initOptions) {
  return {
    then: (onSuccess, onError) => {
      window.setTimeout(() => {
        onError({
          error: 'idpiframe_initialization_failed',
          details: 'This error was raised from a test.',
        });
      }, 30);
    }
  }
};

window.gapi.auth2 = new GapiAuth2();
''');

String auth2SignInError([String error = 'popup_closed_by_user']) => testIife('''
${gapi()}

var mockUser = null;

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
          reject({
            error: '$error'
          });
        }, 30);
      });
    },
  }
};

window.gapi.auth2 = new GapiAuth2();
''');
