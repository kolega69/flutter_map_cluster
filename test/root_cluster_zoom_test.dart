import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cluster/flutter_map_cluster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

/// Without `MapOptions.minZoom` the layer falls back to a minimum zoom of 1, so
/// the root of the cluster tree sits at zoom 0 and is the only cluster node
/// with no parent. flutter_map still lets the camera go below zero when
/// `minZoom` is unset, so the layer must treat every zoom below its minimum as
/// the minimum rather than hand the parentless root to the drawing code.
void main() {
  const pointA = LatLng(50.45, 30.52);
  const pointB = LatLng(50.4501, 30.5201);

  Marker marker(String id, LatLng point) {
    return Marker(
      point: point,
      width: 24,
      height: 24,
      child: ColoredBox(key: Key(id), color: Colors.red),
    );
  }

  Widget harness(MapController controller) {
    return MaterialApp(
      home: Scaffold(
        body: FlutterMap(
          mapController: controller,
          options: const MapOptions(initialCenter: pointA, initialZoom: -1.5),
          children: [
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                zoomToBoundsOnClick: false,
                markers: [
                  marker('marker-0', pointA),
                  marker('marker-1', pointB)
                ],
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
    'opening below the minimum zoom draws the lowest cluster level',
    (tester) async {
      await tester.pumpWidget(harness(MapController()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cluster-badge')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.byKey(const Key('marker-0')), findsNothing);
      expect(find.byKey(const Key('marker-1')), findsNothing);
    },
  );

  testWidgets(
    'zooming in from below the minimum zoom keeps the clusters drawn',
    (tester) async {
      final controller = MapController();
      await tester.pumpWidget(harness(controller));
      await tester.pumpAndSettle();

      controller.move(pointA, -0.5);
      await tester.pump();

      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cluster-badge')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    },
  );
}
