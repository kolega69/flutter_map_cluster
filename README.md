# Flutter Map Cluster

[![pub package](https://img.shields.io/pub/v/flutter_map_cluster.svg)](https://pub.dev/packages/flutter_map_cluster)

A Dart implementation of Leaflet.markercluster for Flutter apps.
This is a plugin for [flutter_map](https://github.com/fleaflet/flutter_map) package.

> **This is a fork** of [`flutter_map_marker_cluster`](https://github.com/lpongetti/flutter_map_marker_cluster)
> by [Lorenzo Pongetti](https://github.com/lpongetti) — nearly all of the clustering, spiderfy and
> animation logic here is his work. This fork fixes a fold/unfold tap bug, avoids unnecessary
> rebuilds, and adds a `MarkerClusterController` for programmatically folding an open cluster. See
> [What's different from upstream](#whats-different-from-upstream) below, and please consider
> [supporting the original author](#supporting-the-original-author).

## Usage

Add flutter_map and flutter_map_cluster to your pubspec:

```yaml
dependencies:
  flutter_map: any
  flutter_map_cluster: any # or the latest version on Pub
```

[flutter_map](https://github.com/fleaflet/flutter_map/releases) package removed old layering system with v3.0.0 use `MarkerClusterLayerWidget` as member of `children` parameter list and configure it using `MarkerClusterLayerOptions`.

```dart
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clustering Many Markers Page')),
      drawer: buildDrawer(context, ClusteringManyMarkersPage.route),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng((maxLatLng.latitude + minLatLng.latitude) / 2,
              (maxLatLng.longitude + minLatLng.longitude) / 2),
          zoom: 6,
          maxZoom: 15,
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 45,
              size: const Size(40, 40),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(50),
              maxZoom: 15,        
              markers: markers,
              builder: (context, markers) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
```

### Run the example

See the `example/` folder for a working example app.

## What's different from upstream

- **Fold/unfold tap bug fixed** — tapping a spiderfied cluster to close it, then tapping it again to
  reopen, no longer occasionally auto-unfolds itself. The cause was `_onClusterTap` comparing the
  tapped `MarkerClusterNode` to the currently-open one by object identity (`==`) instead of using
  the existing `_isSpiderfyCluster` bounds-based check the class already defines elsewhere — a rebuild
  can hand `_onClusterTap` a structurally-equal-but-not-identical node, so the identity check silently
  failed to recognize "this is the cluster that's already open."
- **Avoids unnecessary rebuilds** — `didUpdateWidget` used to rebuild the entire cluster tree whenever
  `oldWidget.options.markers != widget.options.markers`, which is `List<Marker>` reference inequality —
  true on every rebuild that passes a freshly-built marker list, even with identical content. It now
  compares by each marker's `Key` (`markersChanged` in `marker_diff.dart`), so an unrelated parent
  rebuild (e.g. picking a different marker for a popup) doesn't tear down and rebuild every
  cluster/spiderfy in flight.
- **`MarkerClusterController`** — an optional `controller:` on `MarkerClusterLayerOptions` that lets
  app code programmatically fold whichever cluster is currently spiderfied (e.g. when the user taps
  the map background, or a different, non-clustered marker), and query `isSpiderfied(LatLng)` to tell
  "tapped one of the fanned-out siblings" apart from "tapped something else."

## Supporting the Original Author

This fork builds on Lorenzo Pongetti's work. If it's useful to you, please support **him**, the
original author:

A donation through his Ko-Fi page would be infinitly appriciated:
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/lorenzopongetti)

but, if you can't or won't, a star on [his GitHub repo](https://github.com/lpongetti/flutter_map_marker_cluster)
and a like on [his pub.dev package](https://pub.dev/packages/flutter_map_marker_cluster) would also go a long way!
