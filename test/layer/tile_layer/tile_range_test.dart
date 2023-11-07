import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/layer/tile_layer/tile_range.dart';
import 'package:test/test.dart';

void main() {
  group('TileRange', () {
    group('EmptyTileRange', () {
      test('behaves as an empty range', () {
        final tileRange1 = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 1,
          pixelBounds: Bounds(const Point(1, 1), const Point(2, 2)),
        );
        final tileRange2 = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 1,
          pixelBounds: Bounds(const Point(3, 3), const Point(4, 4)),
        );
        final emptyTileRange = tileRange1.intersect(tileRange2);

        expect(
          emptyTileRange,
          isA<EmptyTileRange>()
              .having((e) => e.coordinatesIter, 'coordinates', isEmpty),
        );
      });
    });

    group('DiscreteTileRange', () {
      group('fromPixelBounds', () {
        test('single tile', () {
          final tileRange = DiscreteTileRange.fromPixelBounds(
            zoom: 0,
            tileSize: 10,
            pixelBounds: Bounds(
              const Point(25, 25),
              const Point(25, 25),
            ),
          );

          expect(tileRange.coordinatesIter,
              containsAllInOrder([TileCoordinates(2, 2, 0)]));
        });

        test('lower tile edge', () {
          final tileRange = DiscreteTileRange.fromPixelBounds(
            zoom: 0,
            tileSize: 10,
            pixelBounds: Bounds(
              const Point(0, 0),
              const Point(0.1, 0.1),
            ),
          );

          expect(tileRange.coordinatesIter,
              containsAllInOrder([TileCoordinates(0, 0, 0)]));
        });

        test('upper tile edge', () {
          final tileRange = DiscreteTileRange.fromPixelBounds(
            zoom: 0,
            tileSize: 10,
            pixelBounds: Bounds(
              const Point(0, 0),
              const Point(9.99, 9.99),
            ),
          );

          expect(tileRange.coordinatesIter,
              containsAllInOrder([TileCoordinates(0, 0, 0)]));
        });

        test('both tile edges', () {
          final tileRange = DiscreteTileRange.fromPixelBounds(
            zoom: 0,
            tileSize: 10,
            pixelBounds: Bounds(
              const Point(19.99, 19.99),
              const Point(30.1, 30.1),
            ),
          );

          expect(
              tileRange.coordinatesIter,
              containsAllInOrder([
                TileCoordinates(1, 1, 0),
                TileCoordinates(2, 1, 0),
                TileCoordinates(3, 1, 0),
                TileCoordinates(1, 2, 0),
                TileCoordinates(2, 2, 0),
                TileCoordinates(3, 2, 0),
                TileCoordinates(1, 3, 0),
                TileCoordinates(2, 3, 0),
                TileCoordinates(3, 3, 0),
              ]));
        });
      });

      test('expand', () {
        final tileRange = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(25, 25),
            const Point(25, 25),
          ),
        );

        expect(tileRange.coordinatesIter,
            containsAllInOrder([TileCoordinates(2, 2, 0)]));
        final expandedTileRange = tileRange.expand(1);

        expect(
            expandedTileRange.coordinatesIter,
            containsAllInOrder([
              TileCoordinates(1, 1, 0),
              TileCoordinates(2, 1, 0),
              TileCoordinates(3, 1, 0),
              TileCoordinates(1, 2, 0),
              TileCoordinates(2, 2, 0),
              TileCoordinates(3, 2, 0),
              TileCoordinates(1, 3, 0),
              TileCoordinates(2, 3, 0),
              TileCoordinates(3, 3, 0),
            ]));
      });

      test('no intersection', () {
        final tileRange1 = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(25, 25),
            const Point(25, 25),
          ),
        );

        final tileRange2 = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(35, 35),
            const Point(35, 35),
          ),
        );

        final intersectionA = tileRange1.intersect(tileRange2);
        final intersectionB = tileRange1.intersect(tileRange2);

        expect(intersectionA, isA<EmptyTileRange>());
        expect(intersectionB, isA<EmptyTileRange>());
      });

      test('intersects', () {
        final tileRange1 = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(25, 25),
            const Point(35, 35),
          ),
        );

        final tileRange2 = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(35, 35),
            const Point(45, 45),
          ),
        );

        final intersectionA = tileRange1.intersect(tileRange2).coordinatesIter;
        expect(intersectionA, containsAllInOrder([TileCoordinates(3, 3, 0)]));

        final intersectionB = tileRange1.intersect(tileRange2).coordinatesIter;
        expect(intersectionB, containsAllInOrder([TileCoordinates(3, 3, 0)]));
      });

      test('range within other range', () {
        final tileRange1 = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(25, 25),
            const Point(35, 35),
          ),
        );

        final tileRange2 = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(15, 15),
            const Point(45, 45),
          ),
        );

        final intersectionA =
            tileRange1.intersect(tileRange2).coordinatesIter.toList();
        final intersectionB =
            tileRange1.intersect(tileRange2).coordinatesIter.toList();

        expect(intersectionA, tileRange1.coordinatesIter.toList());
        expect(intersectionB, tileRange1.coordinatesIter.toList());
      });
    });

    test('min/max', () {
      final tileRange = DiscreteTileRange.fromPixelBounds(
        zoom: 0,
        tileSize: 10,
        pixelBounds: Bounds(
          const Point(35, 35),
          const Point(45, 45),
        ),
      );

      expect(tileRange.min, const Point(3, 3));
      expect(tileRange.max, const Point(4, 4));
    });

    group('center', () {
      test('one tile', () {
        final tileRange = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(35, 35),
            const Point(35, 35),
          ),
        );

        expect(tileRange.center, const Point(3, 3));
      });

      test('multiple tiles, even number of tiles', () {
        final tileRange = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(35, 35),
            const Point(45, 45),
          ),
        );

        expect(tileRange.center, const Point(3.5, 3.5));
      });

      test('multiple tiles, odd number of tiles', () {
        final tileRange = DiscreteTileRange.fromPixelBounds(
          zoom: 0,
          tileSize: 10,
          pixelBounds: Bounds(
            const Point(35, 35),
            const Point(55, 55),
          ),
        );

        expect(tileRange.center, const Point(4, 4));
      });
    });

    test('contains', () {
      final tileRange = DiscreteTileRange.fromPixelBounds(
        zoom: 0,
        tileSize: 10,
        pixelBounds: Bounds(
          const Point(35, 35),
          const Point(35, 35),
        ),
      );

      expect(tileRange.contains(TileCoordinates(2, 2, 1)), isFalse);
      expect(tileRange.contains(TileCoordinates(3, 2, 1)), isFalse);
      expect(tileRange.contains(TileCoordinates(4, 2, 1)), isFalse);
      expect(tileRange.contains(TileCoordinates(2, 3, 1)), isFalse);
      expect(tileRange.contains(TileCoordinates(3, 3, 1)), isTrue);
      expect(tileRange.contains(TileCoordinates(4, 3, 1)), isFalse);
      expect(tileRange.contains(TileCoordinates(2, 4, 1)), isFalse);
      expect(tileRange.contains(TileCoordinates(3, 4, 1)), isFalse);
      expect(tileRange.contains(TileCoordinates(4, 4, 1)), isFalse);
    });
  });
}
