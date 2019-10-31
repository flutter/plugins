part of gapi_mocks;

const String gapiInitSuccess = '''
(function() {
    function Gapi() {};
    Gapi.prototype.load = function (script, callback) {
        window.setTimeout(() => {
          callback();
        }, 30);
    };

    // Initialize the gapi.auth mock.
    // function GapiAuth2() {}
    // GapiAuth2.prototype.init = function (initOptions) {
    //   // Returns the promise of a future GoogleAuth object
    //   return new Promise((resolve, reject) => {
    //     window.setTimeout(() => {
    //       resolve();
    //     }, 30);
    //   });
    // };
    window.gapi = new Gapi();
    // window.gapi.auth2 = new GapiAuth2();
  
    window['$kGapiOnloadCallbackFunctionName']();
  })();
''';
