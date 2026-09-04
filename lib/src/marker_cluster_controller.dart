import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Lets app code programmatically collapse whichever cluster is currently
/// spiderfied on a [MarkerClusterLayerWidget] — for example when a
/// different, non-clustered marker is tapped, or when the map background is
/// tapped — and query whether a given point belongs to the currently-open
/// spiderfy, so app code can tell "tapped one of the fanned-out siblings"
/// (leave it open) apart from "tapped something else" (fold it).
class MarkerClusterController {
  VoidCallback? _fold;
  bool Function(LatLng)? _isSpiderfied;

  /// Collapses whichever cluster is currently spiderfied. No-op if no
  /// cluster is open, or if this controller isn't attached to a
  /// [MarkerClusterLayerWidget] yet.
  void foldClusters() => _fold?.call();

  /// Whether [point] is one of the markers currently fanned out by an open
  /// spiderfy. False when nothing is open, or this controller isn't
  /// attached to a [MarkerClusterLayerWidget] yet.
  bool isSpiderfied(LatLng point) => _isSpiderfied?.call(point) ?? false;

  /// Called by [MarkerClusterLayerWidget]'s State; not meant to be called
  /// directly by app code. Public (rather than library-private) only
  /// because this class and the layer's State live in separate files —
  /// Dart's underscore privacy is per-file.
  void attach(VoidCallback fold, bool Function(LatLng point) isSpiderfied) {
    _fold = fold;
    _isSpiderfied = isSpiderfied;
  }

  void detach() {
    _fold = null;
    _isSpiderfied = null;
  }
}
