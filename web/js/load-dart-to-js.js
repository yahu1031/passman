var serviceWorkerVersion = null;
var scriptLoaded = false;
document.onkeydown = function (e) {
  if (event.keyCode == 123) {
    return false;
  }
  if (e.ctrlKey && e.shiftKey && e.keyCode == 'I'.charCodeAt(0)) {
    console.log('%c Inspection was blocked. Please don\'t use it unless you are developer!!', 'font-family: \'Lexend Deca\';font-weight: bold; font-size: 20px;color: red;');
    console.log('%c Trying to help us out? Then check out here https://github.com/yahu1031/passman', 'font-family: \'Lexend Deca\';font-weight: 400; font-size: 14px;color: black;');
    return false;
  }
  if (e.ctrlKey && e.shiftKey && e.keyCode == 'C'.charCodeAt(0)) {
    console.log('%c Element section was blocked. Please don\'t use it unless you are developer!!', 'font-family: \'Lexend Deca\';font-weight: bold; font-size: 20px;color: red;');
    console.log('%c Trying to help us out? Then check out here https://github.com/yahu1031/passman', 'font-family: \'Lexend Deca\';font-weight: 400; font-size: 14px;color: black;');
    return false;
  }
  if (e.ctrlKey && e.shiftKey && e.keyCode == 'J'.charCodeAt(0)) {
    console.log('%c Developer console was blocked. Please don\'t use it unless you are developer!!', 'font-family: \'Lexend Deca\';font-weight: bold; font-size: 20px;color: red;');
    console.log('%c Trying to help us out? Then check out here https://github.com/yahu1031/passman', 'font-family: \'Lexend Deca\';font-weight: 400; font-size: 14px;color: black;');
    return false;
  }
  if (e.ctrlKey && e.keyCode == 'U'.charCodeAt(0)) {
    console.log('%c Looking at source code was blocked. Please don\'t use it unless you are developer!!', 'font-family: \'Lexend Deca\';font-weight: bold; font-size: 20px;color: red;');
    console.log('%c Trying to help us out? Then check out here https://github.com/yahu1031/passman', 'font-family: \'Lexend Deca\';font-weight: 400; font-size: 14px;color: black;');
    return false;
  }
}
function loadMainDartJs() {
  if (scriptLoaded) {
    return;
  }
  scriptLoaded = true;
  var scriptTag = document.createElement('script');
  scriptTag.src = 'main.dart.js';
  scriptTag.type = 'application/javascript';
  document.body.append(scriptTag);
}

if ('serviceWorker' in navigator) {
  // Service workers are supported. Use them.
  window.addEventListener('load', function () {
    // Wait for registration to finish before dropping the <script> tag.
    // Otherwise, the browser will load the script multiple times,
    // potentially different versions.
    var serviceWorkerUrl = 'flutter_service_worker.js?v=' + serviceWorkerVersion;
    navigator.serviceWorker.register(serviceWorkerUrl)
      .then((reg) => {
        function waitForActivation(serviceWorker) {
          serviceWorker.addEventListener('statechange', () => {
            if (serviceWorker.state == 'activated') {
          console.log('%c version 2.4.0-alpha.', 'font-family: \'Lexend Deca\';font-weight: 300; font-size: 10px;color: green;');
              console.log('%c Installed new service worker.', 'font-family: \'Lexend Deca\';font-weight: 500; font-size: 14px;color: green;');
              loadMainDartJs();
            }
          });
        }
        if (!reg.active && (reg.installing || reg.waiting)) {
          // No active web worker and we have installed or are installing
          // one for the first time. Simply wait for it to activate.
          waitForActivation(reg.installing ?? reg.waiting);
        } else if (!reg.active.scriptURL.endsWith(serviceWorkerVersion)) {
          // When the app updates the serviceWorkerVersion changes, so we
          // need to ask the service worker to update.
          console.log('%c version 2.4.0-alpha.', 'font-family: \'Lexend Deca\';font-weight: 300; font-size: 10px;color: green;');
          console.log('%c New service worker available.', 'font-family: \'Lexend Deca\';font-weight: 500; font-size: 14px;color: green;');
          reg.update();
          waitForActivation(reg.installing);
        } else {
          // Existing service worker is still good.
          console.log('%c version 2.4.0-alpha.', 'font-family: \'Lexend Deca\';font-weight: 300; font-size: 10px;color: green;');
          console.log('%c Loading app from service worker.', 'font-family: \'Lexend Deca\';font-weight: 500; font-size: 14px;color: green;');
          loadMainDartJs();
        }
      });
    // If service worker doesn't succeed in a reasonable amount of time,
    // fallback to plaint <script> tag.
    setTimeout(() => {
      if (!scriptLoaded) {
        console.warn(
          '%c Failed to load app from service worker. Falling back to plain <script> tag.',
          'font-family: \'Lexend Deca\';font-weight: 500; font-size: 20px;color: orange;'
        );
        loadMainDartJs();
      }
    }, 4000);
  });
} else {
  // Service workers not supported. Just drop the <script> tag.
  loadMainDartJs();
}