import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cluster/flutter_map_cluster.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const pointA = LatLng(50.45, 30.52);
  const pointB = LatLng(50.4501, 30.5201);

  Marker marker(String id, LatLng point) => Marker(
        point: point,
        width: 24,
        height: 24,
        child: ColoredBox(key: Key(id), color: Colors.red),
      );

  Widget harness(
    MarkerClusterController controller, {
    void Function()? onClusterTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: FlutterMap(
          options: const MapOptions(initialCenter: pointA, initialZoom: 13),
          children: [
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                zoomToBoundsOnClick: false,
                spiderfyCluster: true,
                controller: controller,
                markers: [
                  marker('marker-0', pointA),
                  marker('marker-1', pointB),
                ],
                builder: (context, markers) => ColoredBox(
                  key: const Key('cluster-badge'),
                  color: Colors.blue,
                  child: Center(child: Text('${markers.length}')),
                ),
                onClusterTap:
                    onClusterTap == null ? null : (_) => onClusterTap(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('foldClusters collapses an open spiderfy', (tester) async {
    final controller = MarkerClusterController();
    await tester.pumpWidget(harness(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cluster-badge')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('marker-0')), findsOneWidget);
    expect(find.byKey(const Key('marker-1')), findsOneWidget);

    controller.foldClusters();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('marker-0')), findsNothing);
    expect(find.byKey(const Key('marker-1')), findsNothing);
  });

  testWidgets('foldClusters is a no-op when nothing is open', (tester) async {
    final controller = MarkerClusterController();
    await tester.pumpWidget(harness(controller));
    await tester.pumpAndSettle();

    expect(() => controller.foldClusters(), returnsNormally);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('marker-0')), findsNothing);
    expect(find.byKey(const Key('marker-1')), findsNothing);
  });

  testWidgets('foldClusters before the widget has built does not throw', (
    tester,
  ) async {
    final controller = MarkerClusterController();
    expect(() => controller.foldClusters(), returnsNormally);
  });

  testWidgets(
    'a fold request racing the very tap that opens a cluster does not '
    'immediately close it',
    (tester) async {
      final controller = MarkerClusterController();
      // Mirrors a real app's wiring: onClusterTap has its own side effect
      // whose listener reacts on a later microtask, calling foldClusters()
      // — landing while _spiderfy's forward animation, started
      // synchronously by the same tap, is still in flight.
      await tester.pumpWidget(
        harness(
          controller,
          onClusterTap: () => scheduleMicrotask(controller.foldClusters),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cluster-badge')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('marker-0')), findsOneWidget);
      expect(find.byKey(const Key('marker-1')), findsOneWidget);
    },
  );

  testWidgets('isSpiderfied before the widget has built returns false', (
    tester,
  ) async {
    final controller = MarkerClusterController();
    expect(controller.isSpiderfied(pointA), isFalse);
  });

  testWidgets("isSpiderfied reports membership of the open cluster's points", (
    tester,
  ) async {
    final controller = MarkerClusterController();
    await tester.pumpWidget(harness(controller));
    await tester.pumpAndSettle();

    expect(controller.isSpiderfied(pointA), isFalse);
    expect(controller.isSpiderfied(pointB), isFalse);

    await tester.tap(find.byKey(const Key('cluster-badge')));
    await tester.pumpAndSettle();

    expect(controller.isSpiderfied(pointA), isTrue);
    expect(controller.isSpiderfied(pointB), isTrue);
    // An unrelated point, not part of this cluster.
    expect(controller.isSpiderfied(const LatLng(10, 10)), isFalse);

    controller.foldClusters();
    await tester.pumpAndSettle();

    expect(controller.isSpiderfied(pointA), isFalse);
    expect(controller.isSpiderfied(pointB), isFalse);
  });
}
