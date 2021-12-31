# Dart Hybrid Logical Clock (HLC)

This is a Dart port of the hybrid logical clock implementation described by Jared Forsyth in [this article](https://jaredforsyth.com/posts/hybrid-logical-clocks/).

HLCs are a useful primitive for [CRDT](https://crdt.tech/) implementations.

Generated documentation can be found [here](https://dart-hlc.misha.jp/).

## Install

[![Pub Version](https://img.shields.io/pub/v/hlc?color=green)](https://pub.dev/packages/hlc)

In `pubspec.yaml`:

```yaml
dependencies:
  hlc: ^1.0.0
```

## Usage

Import the library:

```dart
import 'package:hlc/hlc.dart';
```

Initialize a local HLC with the current wall clock:

```dart
var hlc = HLC.now();
```

Perform a local action that requires advancing the local HLC:

```dart
hlc = hlc.increment();
```

Receive a remote HLC, applying it to the local one:

```dart
final remoteHlc = HLC.now(); // From somewhere in the network.
hlc = hlc.receive(remoteHlc);
```

Serialize/deserialize an HLC while maintaining its topological ordering:

```dart
final serialized = hlc.pack();
final deserialized = HLC.unpack(serialized);
```
