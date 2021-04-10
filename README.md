<h1 align="center">Password Manager</h1>

<p>
  <img alt="Version" src="https://img.shields.io/badge/version-2.5.0--alpha-orange.svg?cacheSeconds=2592000" />
  <a href="https://github.com/yahu1031/passman#readme" target="_blank">
    <img alt="Documentation" src="https://img.shields.io/badge/documentation-no-brightgreen.svg" />
  </a>
  <a href="https://github.com/yahu1031/passman/graphs/commit-activity" target="_blank">
    <img alt="Maintenance" src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" />
  </a>
  <a href="https://github.com/yahu1031/passman/blob/main/LICENSE" target="_blank">
    <img alt="License: MIT" src="https://img.shields.io/github/license/yahu1031/passman" />
  </a>
</p>

A new Flutter project for storing passwords safely. [Password Manager](https://password-magnager.web.app), Stores your all passwords. No one knows your passwords 😎. Hide from everyone, sometimes from us and you.

---

<h2 align="center" style="font-size: 40px">Still in development 🏗️</h2>

---

## 💻 Development ##

To develop or contribute this application, follow the instructions.

### _Adding secret data_ ###

- Create a `.dart` file in the lib folder.

- In that, you need to declare some constant values as follows,

    <span style="color:orange"><b>Warning:</b></span> This is very sensitive data. Never add this to your git repository.

```dart
const String secretPassKey = 'YOUR 32 CHARACTER LENGTH STRING';
const String imgSecretPassKey = 'YOUR 32 CHARACTER LENGTH STRING';
const String geoEncodingAPI = 'API KEY FOR locationiq.com';
```

> NOTE: Make sure your ***`secretPassKey`*** and ***`imgSecretPassKey`*** better not to be same.

### _Getting LocationIQ API Key_ ###

- Get an API key from [LocationIQ](https://my.locationiq.com/dashboard#accesstoken). This helps you in geocoding.

### _Firebase Setup_ ###

- Create a Google Firebase project.

- Enable Google Signin.

- Get Fingerprint SHA-1 and SHA-256 key and set up your project and download the `google-services.json` file.

- Add Web project and copy the Firebase SDK snippet and create a new file `firebase-config.js` in `web/js/` and paste the code. The code must look like this

    ```js
    var firebaseConfig = {
        apiKey: "***********************",
        authDomain: "***********************",
        databaseURL: "***********************",
        projectId: "***********************",
        storageBucket: "***********************",
        messagingSenderId: "***********************",
        appId: "***********************",
        measurementId: "***********************"
    };
    // Initialize Firebase
    firebase.initializeApp(firebaseConfig);
    firebase.analytics();
    ```

    <span style="color:orange"><b>Warning:</b></span> `google-services.json` is very sensitive data. Never add this to your git repository.

- Head over to cloud console and Search for **OAuth 2.0 Client IDs** in Credentials section.

- Click on the web client and add your URIs -

    ```txt
    http://localhost
    http://localhost:1031
    https://localhost
    https://localhost:1031
    ```

    and save them

> Note: Please use `--web-port 1031` as additional arguments in `flutter run` command. I have already add that in launch.json in VS Code. Users using Android studios must make a note of it.

## ➕ Contribution ##

Contributions, Issues, and feature requests are welcome!
Feel free to check [issues page](https://github.com/passman/issues/). Please don't forget to check [Code of Conduct](https://github.com/yahu1031).

## 👨🏻‍💻 Author ##

**Minnu**

- Github: [@yahu1031](https://github.com/yahu1031)

- Twitter: [@minnu1031](https://twitter.com/minnu1031)

- Instagram: [@\_son_of_raghava.rao\_](https://instagram.com/_son_of_raghava.rao_/)

## 💪 Show your support ##

Give one ⭐️ if this project helped you!

## 📝 License ##

Copyright © 2020 [minnu](https://github.com/yahu1031).<br />
This project is [MIT](https://github.com/yahu1031/passman/blob/main/LICENSE) licensed.

---

<h2 align="center">Made with 💚</h2>
