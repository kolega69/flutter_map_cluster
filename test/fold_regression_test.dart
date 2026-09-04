import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cluster/flutter_map_cluster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const pointA = LatLng(50.45, 30.52);
  const pointB = LatLng(50.4501, 30.5201);

  Marker marker(String id, LatLng point, {Key? key, bool selected = false}) {
    return Marker(
      key: key,
      point: point,
      width: 24,
      height: 24,
      child: ColoredBox(
        key: Key(id),
        color: selected ? Colors.orange : Colors.red,
      ),
    );
  }

  Widget harness(List<Marker> markers) {
    return MaterialApp(
      home: Scaffold(
        body: FlutterMap(
          options: const MapOptions(initialCenter: pointA, initialZoom: 13),
          children: [
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                zoomToBoundsOnClick: false,
                spiderfyCluster: true,
                markers: markers,
                builder: (context, clusteredMarkers) => ColoredBox(
                  key: const Key('cluster-badge'),
                  color: Colors.blue,
                  child: Center(child: Text('${clusteredMarkers.length}')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets(
    'unkeyed markers: rebuilding between two cluster taps still folds cleanly',
    (tester) async {
      await tester.pumpWidget(
        harness([marker('marker-0', pointA), marker('marker-1', pointB)]),
      );
      await tester.pumpAndSettle();

      // Open.
      await tester.tap(find.byKey(const Key('cluster-badge')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('marker-0')), findsOneWidget);
      expect(find.byKey(const Key('marker-1')), findsOneWidget);

      // Simulate an app rebuild: a brand-new, unkeyed markers list with
      // equivalent content forces the cluster tree to be discarded and
      // rebuilt from scratch.
      await tester.pumpWidget(
        harness([marker('marker-0', pointA), marker('marker-1', pointB)]),
      );
      await tester.pumpAndSettle();

      // Close.
      await tester.tap(find.byKey(const Key('cluster-badge')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('marker-0')), findsNothing);
      expect(find.byKey(const Key('marker-1')), findsNothing);
    },
  );

  testWidgets(
    'keyed markers with a selection change: rebuilding between two cluster '
    'taps still folds cleanly',
    (tester) async {
      await tester.pumpWidget(
        harness([
          marker('marker-0', pointA, key: const ValueKey('key-0-false')),
          marker('marker-1', pointB, key: const ValueKey('key-1-false')),
        ]),
      );
      await tester.pumpAndSettle();

      // Open.
      await tester.tap(find.byKey(const Key('cluster-badge')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('marker-0')), findsOneWidget);
      expect(find.byKey(const Key('marker-1')), findsOneWidget);

      // Rebuild with marker-0 now "selected" — its key legitimately changes,
      // so the tree is still rebuilt, but through a realistic, keyed path
      // rather than an always-different list.
      await tester.pumpWidget(
        harness([
          marker(
            'marker-0',
            pointA,
            key: const ValueKey('key-0-true'),
            selected: true,
          ),
          marker('marker-1', pointB, key: const ValueKey('key-1-false')),
        ]),
      );
      await tester.pumpAndSettle();

      // Close.
      await tester.tap(find.byKey(const Key('cluster-badge')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('marker-0')), findsNothing);
      expect(find.byKey(const Key('marker-1')), findsNothing);
    },
  );
}
