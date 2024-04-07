// import 'package:fluent_ui/fluent_ui.dart' as fui;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
//
// final pathProvider = ChangeNotifierProvider<PathProvider, List<String>>(
//       (ref) => PathProvider(),
// );
//
// class PathProvider extends Notifier<List<String>> {
//   PathProvider() : super(['Root']); // Initial root directory
//
//   void navigateBack() {
//     if (state.length > 1) {
//       state = List.from(state)..removeLast();
//     }
//   }
//
//   void navigateForward(String newPath) {
//     state = List.from(state)..add(newPath);
//   }
// }
