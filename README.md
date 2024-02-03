# comind

This is the primary frontend for {comind}, a platform for thinking stuff together.

The app is written in [Flutter](https://flutter.dev/), a cross-platform
framework for building mobile apps.

The front end is basically in a super-pre-alpha state. It is not ready for
production use. It is not ready for testing. It is not ready for anything
except for me to play around with. Please don't use it.

## Disclaimer

The app is 

- Currently dogshit and I am working on it. Please don't judge me. 
- Riddled security errors. Please don't hack me.
- Not finished. Please don't ask me when it will be finished.
- Not a good example of how to write flutter apps. Please don't use it as a reference.
- Not a good example of how to write dart code. Please don't use it as a reference.
- Not a good example of how to write code. Please don't use it as a reference.
- Not a good example of how to write. Please don't use it as a reference.
- Probably going to break constantly. Please don't be surprised.
- Probably going to be slow. Please don't be surprised.
- Probably going to be buggy. Please don't be surprised.

## Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)

## Getting Started

You should be able to run the app on your local machine by running the
following command:

For web: 

```bash
flutter run -d chrome
```

For linux:

```bash
flutter run -d linux
```

For other stuff: 

```bash
I don't know google it
```

## Making fonts work

The icons use [Font Awesome](https://fontawesome.com/). Unfortunately these are not included in the repository for 
licensing reasons. Please see
[this issue](https://github.com/fluttercommunity/font_awesome_flutter/issues/257) for
more information.

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/docs/development/ui/assets-and-images#resolution-aware).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter
apps](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
