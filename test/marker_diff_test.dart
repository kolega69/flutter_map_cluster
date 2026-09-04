import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cluster/src/marker_diff.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  Marker marker(Key? key) =>
      Marker(key: key, point: const LatLng(0, 0), child: const SizedBox());

  group('markersChanged', () {
    test('false when lengths and keys match, in order', () {
      final a = [marker(const ValueKey('a')), marker(const ValueKey('b'))];
      final b = [marker(const ValueKey('a')), marker(const ValueKey('b'))];
      expect(markersChanged(a, b), isFalse);
    });

    test('true when lengths differ', () {
      final a = [marker(const ValueKey('a'))];
      final b = [marker(const ValueKey('a')), marker(const ValueKey('b'))];
      expect(markersChanged(a, b), isTrue);
    });

    test('true when a key differs', () {
      final a = [marker(const ValueKey('a'))];
      final b = [marker(const ValueKey('a2'))];
      expect(markersChanged(a, b), isTrue);
    });

    test('true when either side is missing a key', () {
      final a = [marker(const ValueKey('a'))];
      final b = [marker(null)];
      expect(markersChanged(a, b), isTrue);
    });

    test('true when matching keys appear in a different order', () {
      final a = [marker(const ValueKey('a')), marker(const ValueKey('b'))];
      final b = [marker(const ValueKey('b')), marker(const ValueKey('a'))];
      expect(markersChanged(a, b), isTrue);
    });
  });
}
