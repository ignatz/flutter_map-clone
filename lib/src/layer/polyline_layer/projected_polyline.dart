part of 'polyline_layer.dart';

@immutable
class _ProjectedPolyline<R extends Object> {
  final Polyline<R> polyline;
  final List<DoublePoint> points;

  const _ProjectedPolyline._({
    required this.polyline,
    required this.points,
  });

  _ProjectedPolyline.fromPolyline(Projection projection, Polyline<R> polyline)
      : this._(
          polyline: polyline,
          points: List<DoublePoint>.generate(
            polyline.points.length,
            (j) {
              final (x, y) = projection.projectXY(polyline.points[j]);
              return DoublePoint(x, y);
            },
            growable: false,
          ),
        );
}
