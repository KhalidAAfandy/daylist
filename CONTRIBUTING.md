# Contributing to Daylist

Bug reports, accessibility improvements, documentation and focused pull requests
are welcome. For larger changes, open an issue to discuss the scope first.

## Local setup

Install Flutter 3.44.0 (Dart 3.12), clone the repository, then run:

```sh
flutter pub get
flutter run -d chrome
```

Before submitting a pull request:

```sh
dart format lib test
dart analyze --fatal-infos lib test
flutter test
flutter build web
```

Add behavioral tests for changed task or persistence behavior. Explain the problem,
include screenshots for interface changes and list the checks you ran. Keep generated
build output, local paths, credentials and signing keys out of commits.

Please be respectful, constructive and considerate in discussions and reviews.
