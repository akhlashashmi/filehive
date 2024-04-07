import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:filehive/screens/preview_screen.dart';
import 'package:filehive/screens/theme_controller.dart';
import 'package:filehive/utilities/open_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../controllers/bookmarks_controller.dart';
import '../controllers/directory_controller.dart';
import '../controllers/files_list_controller.dart';
import '../controllers/pdf_options_controller.dart';
import '../controllers/width_controller.dart';
import '../utilities/file_extension.dart';
import '../widgets/smaller_components.dart';
import '../widgets/text_field.dart';

class FileHive extends ConsumerStatefulWidget {
  const FileHive({super.key});

  @override
  ConsumerState<FileHive> createState() => _FileHiveState();
}

class _FileHiveState extends ConsumerState<FileHive> {
  @override
  void initState() {
    super.initState();
    fetchSelectedDirectory();
  }

  // Replace with your file data
  String? selectedFile;
  int? selectedItemIndex;
  int selectedTabIndex = 0;
  String searchKeyword = '';
  String currentDirectory = '';
  int backPressLeft = 0;
  bool showSnackBar = false;
  bool loading = false;

  List<FileSystemEntity> files = [];
  List<FileSystemEntity> photoFiles = [];
  List<FileSystemEntity> pdfFiles = [];
  List<FileSystemEntity> docFiles = [];
  List<FileSystemEntity> directories = [];
  List<String> bookmarks = [];

  String? selectedDirectory;

  void toggleSnackBar() async {
    setState(() => showSnackBar = true);
    await Future.delayed(const Duration(seconds: 10));
    setState(() => showSnackBar = false);
    snackBarText = '';
  }

  Future<void> printDocument(String filePath) async {
    try {
      // Read the file as bytes
      final File file = File(filePath);
      final Uint8List bytes = await file.readAsBytes();

      // Customize layout settings
      final PdfPageFormat a4Margin2mm = PdfPageFormat.a4.copyWith(
        marginBottom: 2.0 * PdfPageFormat.mm,
        marginTop: 2.0 * PdfPageFormat.mm,
        marginLeft: 2.0 * PdfPageFormat.mm,
        marginRight: 2.0 * PdfPageFormat.mm,
      );

      const PdfPageFormat a5Marigin = PdfPageFormat.legal;

      // Print the document
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        format: a4Margin2mm,
      );
    } catch (e) {
      debugPrint('Error printing document: $e');
      // Handle the error as needed
    }
  }

  Future<void> openFile(String command) async {
    try {
      final file = File(selectedFile!);
      if (await file.exists()) {
        ProcessResult result =
            await Process.run('powershell', ['start "${file.path}"']);
        log(result.stdout);
      } else {
        log('File not found: $selectedFile');
      }
    } catch (e) {
      log('Error opening file: $e');
    }
  }

  void copyToClipboard() {
    try {
      Clipboard.setData(ClipboardData(text: selectedFile!));
      snackBarText = "Path Copied: $selectedFile";
      toggleSnackBar();
    } catch (e) {
      snackBarText = "Couldn't copy the path";
      toggleSnackBar();
    }
  }

  Future<void> categorizeFiles() async {
    switch (selectedTabIndex) {
      case 0:
        break;
      case 1:
        photoFiles = [];
        photoFiles = files
            .where((file) => imageExtensions
                .contains(file.path.split('.').last.toLowerCase()))
            .toList();
        break;
      case 2:
        pdfFiles = [];
        pdfFiles = files
            .where((file) => file.path.split('.').last.toLowerCase() == 'pdf')
            .toList();
        break;
      case 3:
        docFiles = [];
        docFiles = files
            .where((file) =>
                docExtensions.contains(file.path.split('.').last.toLowerCase()))
            .toList();
        break;
      case 4:
        directories = [];
        directories = files.whereType<Directory>().toList();
        break;
      case 5:
        directories = files.whereType<Directory>().toList();
        break;
    }
    // final value = await Isolate.spawn((message) {

    //
    //   return [[...photoFiles],[...pdfFiles],[...docFiles],[...directories]];
    // }, files);
    // final photoFiles = [];
    // final pdfFiles = [];
    // final docFiles = [];
    // final directories = [];
    //
    // for (FileSystemEntity file in files) {
    //   if (file is File) {
    //     final extension = file.path.split('.').last.toLowerCase();
    //     // debugPrint(extension);
    //     if (imageExtensions.contains(extension)) {
    //       photoFiles.add(file);
    //     } else if (docExtensions.contains(extension)) {
    //       docFiles.add(file);
    //     } else if (extension.contains('pdf')) {
    //       pdfFiles.add(file);
    //     }
    //   } else if (file is Directory) {
    //     directories.add(file);
    //   }
    // }
    // setState(() {});
  }

  Future<void> fetchSelectedDirectory() async {
    final directory = ref.read(directoryProvider);
    selectedDirectory = directory;
    log(directory);
    if (directory != '') {
      try {
        files = Directory(directory).listSync(recursive: true);
      } catch (e) {
        log("You don't have the permission to access root directories, Please change your main directory to a child directory.");
        snackBarText =
            "You don't have the permission to access root directories, Please change your main directory to a child directory.";
        toggleSnackBar();
      }
      categorizeFiles();
    }
    setState(() {});
  }

  Future<void> selectDirectory() async {
    final directory = await ref.read(directoryProvider.notifier).set();
    if (directory != null) {
      selectedDirectory = directory;
      try {
        files = Directory(directory).listSync(recursive: true);
      } catch (e) {
        snackBarText =
            "You don't have the permission to access root directories, Please change your main directory to a child directory.";
        toggleSnackBar();
      }
      categorizeFiles();
    }
    setState(() {});
  }

  Future<void> goToParentDirectory() async {
    final directory = ref.read(directoryProvider);
    // if (backPressLeft == 0) {
    //   return;
    // }
    selectedDirectory = directory;
    if (directory != '') {
      try {
        bool results = await ref
            .read(directoryProvider.notifier)
            .setThis(Directory(directory).parent.path);
        if (!results) {
          snackBarText =
              "You don't have the permission to access root directories";
          toggleSnackBar();
        }
        // backPressLeft--;
      } catch (e) {
        snackBarText =
            "You don't have the permission to access root directories, Please change your main directory to a child directory.";
        toggleSnackBar();
      }
      categorizeFiles();
    }
  }

  String buildTitle(int index) {
    switch (index) {
      case 0:
        return 'All files';
      case 1:
        return 'Images';
      case 2:
        return 'PDFs';
      case 3:
        return 'Documents';
      case 4:
        return 'Directories';
      case 5:
        return 'Bookmarks';
      default:
        return 'Settings';
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchSelectedDirectory();
    // Files List Container's Width
    double widthContainer = 0.26;
    if (ref.watch(widthControllerProvider)) {
      widthContainer = 0.4;
    }

    // show or hide side bar / media view
    final showFiles = ref.watch(filesVisibilityProvider);

    log('i got a rebuild');
    bool isFavorite = false;
    final favourites = ref.watch(favoriteFileProvider);
    if (selectedFile != null) {
      if (favourites.contains(selectedFile!)) {
        isFavorite = true;
      }
    }
    final size = MediaQuery.of(context).size;
    switch (selectedTabIndex) {
      case 0:
        files = files
            .where((element) => element.path
                .toLowerCase()
                .contains(searchKeyword.toLowerCase()))
            .toList();
        break;
      case 1:
        photoFiles = photoFiles
            .where((element) => element.path
                .toLowerCase()
                .contains(searchKeyword.toLowerCase()))
            .toList();
        // debugPrint(photoFiles.toString());
        break;
      case 2:
        pdfFiles = pdfFiles
            .where((element) => element.path
                .toLowerCase()
                .contains(searchKeyword.toLowerCase()))
            .toList();
        // debugPrint(pdfFiles.toString());
        break;
      case 3:
        docFiles = docFiles
            .where((element) => element.path
                .toLowerCase()
                .contains(searchKeyword.toLowerCase()))
            .toList();
        // debugPrint(docFiles.toString());
        break;
      case 4:
        directories = directories
            .where((element) => element.path
                .toLowerCase()
                .contains(searchKeyword.toLowerCase()))
            .toList();
        // debugPrint(directories.toString());
        break;
      case 5:
        bookmarks = favourites
            .where((element) =>
                element.toLowerCase().contains(searchKeyword.toLowerCase()))
            .toList();
        // debugPrint(directories.toString());
        break;
      default:
        debugPrint('Index out of range');
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: kToolbarHeight + 3,
            padding: const EdgeInsets.fromLTRB(5, 5, 3, 5),
            child: Center(
              child: AppBar(
                backgroundColor: Theme.of(context).colorScheme.background,
                automaticallyImplyLeading: false,
                title: Text(
                  'FileHive',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.cantarell().fontFamily,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                forceMaterialTransparency: true,
                actions: [
                  // if (directories.isNotEmpty)
                  IconButton(
                    onPressed: goToParentDirectory,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    tooltip: 'Go to directory',
                  ),
                  // const SizedBox(width: 15),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: const Icon(Icons.arrow_forward_ios_rounded),
                  //   tooltip: 'Go back to child',
                  // ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: size.width * 0.25,
                    height: 50,
                    child: CustomTextField(
                      onChanged: (value) {
                        setState(() {
                          setState(() => searchKeyword = value!);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    onPressed: selectDirectory,
                    icon: const Icon(Iconsax.folder_add_outline),
                    tooltip: 'Select Directory',
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    onPressed: fetchSelectedDirectory,
                    icon: const Icon(Iconsax.refresh_outline),
                    tooltip: 'Refresh',
                  ),
                  const SizedBox(width: 15),
                  if (selectedFile != null)
                    IconButton(
                      onPressed: copyToClipboard,
                      icon: const Icon(Iconsax.copy_outline),
                      tooltip: 'Copy path',
                    ),
                  if (selectedFile != null) const SizedBox(width: 15),
                  if (selectedFile != null)
                    IconButton(
                      onPressed: () async {
                        if (favourites.contains(selectedFile!)) {
                          ref
                              .read(favoriteFileProvider.notifier)
                              .removeFavorite(selectedFile!);
                          log('removed form favourites');
                        } else {
                          ref
                              .read(favoriteFileProvider.notifier)
                              .addFavorite(selectedFile!);
                          log('added to favourites');
                        }
                        setState(() {});
                      },
                      icon: isFavorite
                          ? const Icon(EvaIcons.bookmark)
                          : const Icon(EvaIcons.bookmark_outline),
                      tooltip: 'Add bookmark',
                    ),
                  if (selectedFile != null) const SizedBox(width: 15),
                  if (selectedFile != null)
                    IconButton(
                      onPressed: () async {
                        showAdaptiveDialog(
                          context: context,
                          builder: (context) => AlertDialog.adaptive(
                            title: Text(
                              'You are going to perminitly delete this file. Do you confirm this action?',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (selectedFile != null) {
                                    FileSystemEntity file = File(selectedFile!);
                                    file.delete();
                                    if (favourites.contains(selectedFile!)) {
                                      ref
                                          .read(favoriteFileProvider.notifier)
                                          .removeFavorite(selectedFile!);
                                    }
                                    selectedFile = null;
                                    selectedItemIndex == null;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('confirm'),
                              )
                            ],
                          ),
                        );
                      },
                      icon: const Icon(EvaIcons.trash_outline),
                      tooltip: 'Delete selected file',
                    ),
                  if (selectedFile != null) const SizedBox(width: 15),
                  if (selectedFile != null)
                    IconButton(
                      onPressed: () async {
                        if (selectedFile != null) {
                          // await printDocument(selectedFile!);
                        } else {
                          debugPrint('could\'nt print');
                        }
                      },
                      icon: const Icon(Iconsax.printer_outline),
                      tooltip: 'Print',
                    ),
                  if (selectedFile != null) const SizedBox(width: 15),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedTabIndex, // Adjust for selected item
                  onDestinationSelected: (index) {
                    if (index != 7) {
                      selectedItemIndex = null;
                      selectedTabIndex = index;
                      if (!showFiles) {
                        ref.read(filesVisibilityProvider.notifier).toggle();
                      }
                      setState(() {});
                    } else if (index == 7) {
                      ref.read(filesVisibilityProvider.notifier).toggle();
                    }
                  },
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelType: NavigationRailLabelType.selected,
                  // Handle navigation item selection
                  destinations: [
                    customNavigationRailDestination(
                      context: context,
                      icon: Iconsax.document_1_bold,
                      label: 'All Files',
                      isListEmpty: files.isEmpty,
                    ),
                    customNavigationRailDestination(
                      context: context,
                      icon: Iconsax.gallery_bold,
                      label: 'Photos',
                      isListEmpty: photoFiles.isEmpty,
                    ),
                    customNavigationRailDestination(
                      context: context,
                      icon: Bootstrap.file_pdf_fill,
                      label: 'Pdfs',
                      isListEmpty: pdfFiles.isEmpty,
                    ),
                    customNavigationRailDestination(
                      context: context,
                      icon: Iconsax.document_bold,
                      label: 'Other Docs',
                      isListEmpty: docFiles.isEmpty,
                    ),
                    customNavigationRailDestination(
                      context: context,
                      icon: Iconsax.folder_open_bold,
                      label: 'Folders',
                      isListEmpty: directories.isEmpty,
                    ),
                    customNavigationRailDestination(
                      context: context,
                      icon: Iconsax.bookmark_2_bold,
                      label: 'Bookmarked',
                      isListEmpty: favourites.isEmpty,
                    ),
                    customNavigationRailDestination(
                      context: context,
                      icon: Iconsax.setting_bold,
                      label: 'Settings',
                      isListEmpty: false,
                    ),
                    customNavigationRailDestination(
                      context: context,
                      icon: ref.watch(filesVisibilityProvider)
                          ? Iconsax.sidebar_left_bold
                          : Iconsax.sidebar_left_outline,
                      label: 'Sidebar',
                      isListEmpty: false,
                    ),

                    // Add more destinations as needed
                  ],
                ),
                if (showFiles)
                  Container(
                    height: double.infinity,
                    width: size.width * widthContainer,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      color: Theme.of(context)
                          .colorScheme
                          .tertiaryContainer
                          .withOpacity(0.3),
                    ),
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          title: Text(
                            buildTitle(selectedTabIndex),
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                          ),
                          actions: [
                            if (selectedTabIndex == 0)
                              Text(
                                '${files.length}    ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                            if (selectedTabIndex == 1)
                              Text(
                                '${photoFiles.length}    ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                            if (selectedTabIndex == 2)
                              Text(
                                '${pdfFiles.length}    ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                            if (selectedTabIndex == 3)
                              Text(
                                '${docFiles.length}    ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                            if (selectedTabIndex == 4)
                              Text(
                                '${directories.length}    ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                            if (selectedTabIndex == 5)
                              Text(
                                '${favourites.length}    ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                          ],
                          pinned: true,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .tertiaryContainer
                              .withOpacity(0.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          forceMaterialTransparency: false,
                        ),
                        if (selectedTabIndex == 0)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: files.length,
                              (context, index) {
                                final file = files[index].path;
                                return ListTile(
                                  // shape: const RoundedRectangleBorder(
                                  //     // borderRadius: BorderRadius.circular(15),
                                  //     ),
                                  tileColor: selectedItemIndex == index
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                  title: Text(
                                    overflow: TextOverflow.ellipsis,
                                    files[index].path.split('\\').last,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                  subtitle: Text(
                                    overflow: TextOverflow.ellipsis,
                                    files[index].path,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                  leading: buildIcon(files[index]),
                                  onTap: () async {
                                    selectedFile = file;
                                    final fileType =
                                        await FileSystemEntity.type(
                                            selectedFile!);
                                    if (fileType ==
                                        FileSystemEntityType.directory) {
                                      ref
                                          .read(directoryProvider.notifier)
                                          .setThis(files[index].path);
                                    } else {
                                      selectedItemIndex = index;
                                    }
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                        if (selectedTabIndex == 1)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: photoFiles.length,
                              (context, index) {
                                final file = photoFiles[index].path;
                                return ListTile(
                                  tileColor: selectedItemIndex == index
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                  title: Text(
                                    overflow: TextOverflow.ellipsis,
                                    photoFiles[index].path.split('\\').last,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                  subtitle: Text(
                                    overflow: TextOverflow.ellipsis,
                                    photoFiles[index].path,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                  leading: buildIcon(photoFiles[index]),
                                  onTap: () {
                                    setState(() {
                                      selectedFile = file;
                                      selectedItemIndex = index;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        if (selectedTabIndex == 2)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: pdfFiles.length,
                              (context, index) {
                                final file = pdfFiles[index].path;
                                return ListTile(
                                  // shape: const RoundedRectangleBorder(
                                  //     // borderRadius: BorderRadius.circular(15),
                                  //     ),
                                  tileColor: selectedItemIndex == index
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                  title: Text(
                                    overflow: TextOverflow.ellipsis,
                                    pdfFiles[index].path.split('\\').last,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                  subtitle: Text(
                                    overflow: TextOverflow.ellipsis,
                                    pdfFiles[index].path,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                  leading: buildIcon(pdfFiles[index]),
                                  onTap: () {
                                    setState(() {
                                      selectedFile = file;
                                      selectedItemIndex = index;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        if (selectedTabIndex == 3)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: docFiles.length,
                              (context, index) {
                                final file = docFiles[index].path;
                                return ListTile(
                                  // shape: const RoundedRectangleBorder(
                                  //     // borderRadius: BorderRadius.circular(15),
                                  //     ),
                                  tileColor: selectedItemIndex == index
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                  title: Text(
                                    overflow: TextOverflow.ellipsis,
                                    docFiles[index].path.split('\\').last,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                  subtitle: Text(
                                    overflow: TextOverflow.ellipsis,
                                    docFiles[index].path,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                  leading: buildIcon(docFiles[index]),
                                  onTap: () {
                                    setState(() {
                                      selectedFile = file;
                                      selectedItemIndex = index;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        if (selectedTabIndex == 4)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: directories.length,
                              (context, index) {
                                final file = directories[index].path;
                                return ListTile(
                                  // shape: const RoundedRectangleBorder(
                                  //     // borderRadius: BorderRadius.circular(15),
                                  //     ),
                                  tileColor: selectedItemIndex == index
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                  title: Text(
                                    overflow: TextOverflow.ellipsis,
                                    directories[index].path.split('\\').last,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                  subtitle: Text(
                                    overflow: TextOverflow.ellipsis,
                                    directories[index].path,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                  leading: buildIcon(directories[index]),
                                  onTap: () {
                                    selectedFile = file;
                                    selectedItemIndex = index;
                                    ref
                                        .read(directoryProvider.notifier)
                                        .setThis(directories[index].path);
                                    // backPressLeft++;
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                        if (selectedTabIndex == 5)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: favourites.length,
                              (context, index) {
                                final file = favourites[index];
                                return ListTile(
                                  // shape: const RoundedRectangleBorder(
                                  //     // borderRadius: BorderRadius.circular(15),
                                  //     ),
                                  tileColor: selectedItemIndex == index
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null,
                                  title: Text(
                                    overflow: TextOverflow.ellipsis,
                                    favourites[index].split('\\').last,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                  subtitle: Text(
                                    overflow: TextOverflow.ellipsis,
                                    favourites[index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                  ),
                                  leading: buildIcon(favourites[index]),
                                  onTap: () async {
                                    selectedFile = file;
                                    selectedItemIndex = index;
                                    // if (!(await File(selectedFile!)
                                    //     .existsSync())) {
                                    //   ref
                                    //       .read(favoriteFileProvider.notifier)
                                    //       .removeFavorite(selectedFile!);
                                    // }
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                        if (selectedTabIndex == 6)
                          SliverList(
                            delegate: SliverChildListDelegate([
                              ListTile(
                                title: Text(
                                  overflow: TextOverflow.ellipsis,
                                  'App Theme',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                subtitle: Text(
                                  overflow: TextOverflow.ellipsis,
                                  'Change the current theme of the app',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                ),
                                trailing: PopupMenuButton(
                                  tooltip: 'Select theme',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                        ref
                                            .watch(themeProvider)
                                            .capitalizeFirstLetter(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'system',
                                      child: Text(
                                        'System',
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'light',
                                      child: Text(
                                        'light',
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'dark',
                                      child: Text(
                                        'dark',
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'system':
                                        ref
                                            .read(themeProvider.notifier)
                                            .set('system');
                                        break;
                                      case 'light':
                                        ref
                                            .read(themeProvider.notifier)
                                            .set('light');
                                        break;
                                      case 'dark':
                                        ref
                                            .read(themeProvider.notifier)
                                            .set('dark');
                                    }
                                  },
                                ),
                              ),
                              SwitchListTile(
                                title: Text(
                                  overflow: TextOverflow.ellipsis,
                                  'Wide Container',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                subtitle: Text(
                                  overflow: TextOverflow.ellipsis,
                                  'Increase the width of media explorer',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                ),
                                value: ref.watch(widthControllerProvider),
                                onChanged: (value) {
                                  ref
                                      .read(widthControllerProvider.notifier)
                                      .set(value);
                                },
                              ),
                              SwitchListTile(
                                title: Text(
                                  overflow: TextOverflow.ellipsis,
                                  'Editing Options for PDF',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                subtitle: Text(
                                  overflow: TextOverflow.ellipsis,
                                  'Enabling this will allow you to highlight, underline, copy text',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                ),
                                value: ref.watch(pdfOptionsProvider),
                                onChanged: (value) {
                                  ref
                                      .read(pdfOptionsProvider.notifier)
                                      .set(value);
                                },
                              ),
                            ]),
                          ),
                      ],
                    ),
                  ),
                SizedBox(width: size.width * 0.009),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          // height: size.width * 0.8,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            // color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          alignment: Alignment.center,
                          child: (selectedFile == null)
                              ? const Text('No file selected')
                              : PreviewScreen(
                                  filePath: selectedFile!,
                                  snackBarCallback: toggleSnackBar,
                                ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              ref.watch(directoryProvider),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.009,
                ),
              ],
            ),
          ),
          if (showSnackBar)
            Container(
              alignment: Alignment.centerLeft,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    snackBarText,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showSnackBar = false;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: (selectedFile != null)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  tooltip: 'Open file',
                  onPressed: () async =>
                      openFile('Start-Process "$selectedFile"'),
                  child: const Icon(Icons.launch_rounded),
                ),
                if (showSnackBar) SizedBox(height: 40)
              ],
            )
          : null,
    );
  }
}

Widget buildIcon(arg) {
  dynamic file = arg;
  if (file is String) {
    file = File(file);
  }
  if (file is File) {
    // return const Icon(Icons.file_copy);
    if (file.path.endsWith('.pdf')) {
      return const Icon(Bootstrap.file_pdf);
    } else if (file.path.endsWith('.doc') || file.path.endsWith('.docx')) {
      return const Icon(Bootstrap.file_word);
    } else if (file.path.endsWith('.xls') || file.path.endsWith('.xlsx')) {
      return const Icon(Bootstrap.file_excel);
    } else if (docExtensions.contains(file.path.split('.').last)) {
      return const Icon(Iconsax.document_outline);
    } else if (imageExtensions.contains(file.path.split('.').last)) {
      return Container(
        height: 40,
        width: 40,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.file(
          File(file.path),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Icon(Bootstrap.question);
    }
  } else if (file is Directory) {
    return const Icon(Iconsax.folder_outline);
  } else {
    return const Icon(Bootstrap.question);
  }
}
