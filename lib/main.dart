import 'package:filehive/screens/home_screen.dart';
import 'package:filehive/screens/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:filehive/utilities/color_scheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeMode themeMode(){
      final theme = ref.watch(themeProvider);
      switch (theme) {

        case 'light':
          return ThemeMode.light;

        case 'dark':
          return ThemeMode.dark;

        default:
          return ThemeMode.system;
      }
    }
    return MaterialApp(
      title: 'FileHive - search and organize files',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.asapTextTheme(),
        // scaffoldBackgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.asapTextTheme(),
        // scaffoldBackgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      home: const FileHive(),
      themeMode: themeMode(),
    );
  }
}
