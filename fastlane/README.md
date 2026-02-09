fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### screenshots_all

```sh
[bundle exec] fastlane screenshots_all
```



### screenshots_flutter_all

```sh
[bundle exec] fastlane screenshots_flutter_all
```



----


## iOS

### ios screenshots_ios

```sh
[bundle exec] fastlane ios screenshots_ios
```

Capture iOS App Store screenshots via snapshot (requires UI tests)

### ios screenshots_flutter_ios

```sh
[bundle exec] fastlane ios screenshots_flutter_ios
```

Capture iOS screenshots via Flutter integration test flow (all locales)

----


## Android

### android screenshots_android

```sh
[bundle exec] fastlane android screenshots_android
```

Capture Android Play Store screenshots via screengrab (requires instrumentation screenshot tests)

### android screenshots_flutter_android

```sh
[bundle exec] fastlane android screenshots_flutter_android
```

Capture Android screenshots via Flutter integration test flow (all locales)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
