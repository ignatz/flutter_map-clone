import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'test_utils/mocks.dart';
import 'test_utils/test_app.dart';

void main() {
  setupMocks();

  testWidgets('flutter_map', (tester) async {
    final markers = <Marker>[
      Marker(
        width: 80,
        height: 80,
        point: LatLng(45.5231, -122.6765),
        builder: (_) => const FlutterLogo(),
      ),
      Marker(
        width: 80,
        height: 80,
        point: LatLng(40, -120), // not visible
        builder: (_) => const FlutterLogo(),
      ),
    ];

    await tester.pumpWidget(TestApp(markers: markers));
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(TileLayer), findsOneWidget);
    expect(find.byType(RawImage), findsWidgets);
    expect(find.byType(MarkerLayer), findsWidgets);
    expect(find.byType(FlutterLogo), findsOneWidget);
  });

  testWidgets('flutter_map keyboard', (tester) async {
    final mapKey = UniqueKey();
    int builds = 0;

    final map = FlutterMap(
      key: mapKey,
      options: MapOptions(
        center: LatLng(45.5231, -122.6765),
        zoom: 13,
      ),
      children: [
        Builder(
          builder: (BuildContext context) {
            final _ = FlutterMapState.of(context);
            builds++;
            return Container();
          },
        ),
      ],
    );

    Widget wrapMapInApp({required double bottomInset}) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: bottomInset),
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: map,
          ),
        ),
      );
    }

    await tester.pumpWidget(wrapMapInApp(bottomInset: 0));
    expect(find.byType(FlutterMap), findsOneWidget);

    // Emulate a keyboard popping up by putting a non-zero bottom ViewInset.
    await tester.pumpWidget(wrapMapInApp(bottomInset: 100));

    // The map should not have rebuild after the first build.
    expect(builds, equals(1));
  });
}
