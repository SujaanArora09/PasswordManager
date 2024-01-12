import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:passwordmanager/components/credentials_card.dart';
import 'package:passwordmanager/database/credentials.dart';
import 'package:passwordmanager/screens/add_credentials_page.dart';
import 'package:passwordmanager/screens/local_auth_page.dart';
import 'package:passwordmanager/screens/settings_page.dart';
import 'package:passwordmanager/theme/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFolderId = 'All';
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).appBarTheme.systemOverlayStyle!.statusBarColor,
        statusBarIconBrightness: Theme.of(context).appBarTheme.systemOverlayStyle!.statusBarIconBrightness,
        systemNavigationBarColor: Theme.of(context).appBarTheme.systemOverlayStyle!.systemNavigationBarColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).appBarTheme.systemOverlayStyle!.systemNavigationBarIconBrightness,
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCredentialsPage(),
              ),
            );
          },
          child: Icon(
            Icons.add_rounded,
            color: Theme.of(context).primaryTextTheme.bodySmall?.color,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocalAuthPage(),
                          ),
                        );
                      },
                      child: Icon(
                              Icons.fingerprint_rounded,
                              color: Theme.of(context).primaryTextTheme.headlineMedium?.color,
                              size: 30,
                             ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PassWords',
                        style: Theme.of(context).primaryTextTheme.headlineMedium,
                        textAlign: TextAlign.start,

                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_rounded, size: 30),
                    ),

                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: searchController,
                  textCapitalization: TextCapitalization.none,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                searchController.text = "";
                              });
                            },
                            icon: const Icon(Icons.clear_rounded))
                        : const SizedBox(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    hintText: 'Search',
                    hintStyle: Theme.of(context).primaryTextTheme.bodySmall!.copyWith(fontSize: 16),
                  ),
                  style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: Hive.box<bool>('folders').listenable(),
                        builder: (context, _, __) {
                          Set<String?> folders =
                              Hive.box<Credentials>(credentialsBoxName).values.map((e) => e.folderId).toSet();
                          if (folders.isEmpty) folders.add("All");
                          List<Widget> tabs = folders.map((e) => Tab(text: e)).toList();
                          return DefaultTabController(
                            length: folders.length,
                            child: TabBar(
                              tabs: tabs,
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              onTap: (value) {
                                setState(() {
                                  selectedFolderId = folders.elementAt(value) ?? 'All';
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<Credentials>(credentialsBoxName).listenable(),
                    builder: (context, box, _) {
                      if (box.values.isEmpty) {
                        return const Center(
                          child: Text('No login details present :)'),
                        );
                      }

                      List<Credentials> sortedValues = box.values.toList()
                        ..sort((o1, o2) => o2.key.toString().compareTo(o1.key.toString()));

                      sortedValues = sortedValues
                          .where((cred) => cred.name.toLowerCase().contains(searchController.text.trim().toLowerCase()))
                          .toList();
                      if (selectedFolderId != "All") {
                        sortedValues = sortedValues.where((cred) => cred.folderId == selectedFolderId).toList();
                      }

                      if (sortedValues.isEmpty) {
                        return const Center(
                          child: Text('No match found :)'),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: Text("${sortedValues.length} Credentials"),
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: sortedValues.length,
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              itemBuilder: (context, index) {
                                return CredentialCard(credentials: sortedValues[index]);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
