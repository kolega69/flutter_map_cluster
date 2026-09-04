import 'package:flutter_map/flutter_map.dart';

/// Whether [a] and [b] represent a genuinely different marker set, compared
/// by [Marker.key] rather than list identity.
///
/// `MarkerClusterLayer.didUpdateWidget` used to rebuild the whole cluster
/// tree whenever `oldWidget.options.markers != widget.options.markers` —
/// true on every rebuild that passes a freshly-built marker list, even one
/// with identical content, since `List<Marker>` has no `==` override. This
/// compares by each marker's key instead, so an unrelated parent rebuild
/// (e.g. picking a different marker for a popup) doesn't tear down and
/// rebuild every cluster/spiderfy in flight. Markers without a key, or a
/// length mismatch, are conservatively treated as changed.
bool markersChanged(List<Marker> a, List<Marker> b) {
  if (a.length != b.length) return true;
  for (var i = 0; i < a.length; i++) {
    if (a[i].key == null || b[i].key == null || a[i].key != b[i].key) {
      return true;
    }
  }
  return false;
}
