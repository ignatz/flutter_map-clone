import 'dart:math';

class TileCoordinates {
  int x;
  int y;
  int z;

  TileCoordinates(this.x, this.y, this.z);

  @override
  String toString() => 'TileCoordinate($x, $y, $z)';

  // Overridden because Point's distanceTo does not allow comparing with a point
  // of a different type.
  double distanceTo(Point<num> other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TileCoordinates &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }

  @override
  int get hashCode {
    // NOTE: the odd numbers are due to JavaScript's integer precision of 53 bits.
    return x ^ y << 24 ^ z << 48;
  }
}
