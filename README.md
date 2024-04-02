# mirage
Desktop application connecting SNGGLE with PC

## Installation
Use git clone to download [mirage](https://github.com/snggle/mirage) project.
```bash
git clone git@github.com:snggle/mirage.git
```

## Usage
The project runs on flutter version **3.13.9**. You can use [fvm](https://fvm.app/documentation/getting-started/installation)
for easy switching between versions
```bash
# Install and use required flutter version
fvm install 3.13.9
fvm use 3.13.9

# Install required packages in pubspec.yaml
fvm flutter pub get

# Run project
fvm flutter run lib/main.dart
```

To generate config files use
```bash
fvm flutter pub run build_runner
```
```bash
# Built-in Commands 
# - build: Runs a single build and exits.
# - watch: Runs a persistent build server that watches the files system for edits and does rebuilds as necessary
# - serve: Same as watch, but runs a development server as well

# Command Line Options
# --delete-conflicting-outputs: Assume conflicting outputs in the users package are from previous builds, and skip the user prompt that would usually be provided.
# 
# Command example:

fvm flutter pub run build_runner watch --delete-conflicting-outputs
```

## Tests
To run tests
```bash
# Run package unit tests
fvm flutter test test/unit --null-assertions

# Run the unit tests from the package example
fvm flutter test example/test/unit --null-assertions

# Run specific test
fvm flutter test path/to/test.dart --null-assertions
```

## Contributing
Pull requests are welcomed. For major changes, please open an issue first, to enable a discussion on what you would like to improve. Please make sure to provide and update tests as well.

## [Licence](./LICENSE.md)