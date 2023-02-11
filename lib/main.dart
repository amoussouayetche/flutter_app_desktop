import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  //ajout, ca genere de nouveaux mots

  // app avancé
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  //creation d'un tableau favoris pour stocker les mot favoris
  var favorites = <WordPair>[];
  //creation d'une methode pour gerer l'enregistrement
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      //supprime le mot du tableau si ca sy trouve deja
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    //dans les deux cas, ca appel ca
    notifyListeners();
  }

  //app avancé
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// _ rend la classe privée
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // app avance
    var colorScheme = Theme.of(context).colorScheme;
    //faire defiler les pages selon la selection
    // Placeholder() marke la parge comme pas terminer en affifancht enveloppe
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = MainPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    //app avance
    //Le conteneur de la page en cours, avec sa couleur de fond
    // et une animation de commutation subtile.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );
    // LayoutBuilder, Builder, redimenssion les fenetre en tenant compte de l'espace, appareil en mode portait ou autres
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        //app avance
        if (constraints.maxWidth < 450) {
          // Utilisez une mise en page plus adaptée aux mobiles avec BottomNavigationBar
          // sur des écrans étroits.
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(
                child: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.favorite), label: 'Favorites'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.back_hand), label: 'Back_hand'),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              )
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  //extended affichage des labals(true pour afficher, fase, contrains pour poser une condition d'affichage)
                  //600 pixekxel
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.back_hand),
                      label: Text('back_hand'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    //setState assure que l'etat est mis a jour semblable a notifylisteners
                    setState(() {
                      selectedIndex = value;
                    });
                    print('selected: $value');
                  },
                ),
              ),
              Expanded(child: mainArea),
            ],
          );
        }
      }),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(
            height: 10,
          ),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 20),
          child: MergeSemantics(
              child: Wrap(
            children: [
              Text(
                pair.first,
                style: style.copyWith(fontWeight: FontWeight.w200),
              ),
              Text(
                pair.second,
                style: style.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // app avance
    var theme = Theme.of(context);
    //obtient l'etat actuel de l'appli
    var appState = context.watch<MyAppState>();
    //si favoris vide, affiche un message centre pas de favoris
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }
    //sinon affiche une liste derourable
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        //resume, vous aves 5 favoris par exemple
        child: Text('you have' '${appState.favorites.length} favorites: '),
      ),
      Expanded(
          child: GridView(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 400 / 80,
        ),
        children: [
          for (var pair in appState.favorites)
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                color: theme.colorScheme.primary,
                onPressed: () {
                  appState.removeFavorite(pair);
                },
              ),
              title: Text(
                pair.asLowerCase,
                semanticsLabel: pair.asPascalCase,
              ),
            )
        ],
      ))
    ]);
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Text('My main page'),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
          key: _key,
          reverse: true,
          padding: EdgeInsets.only(top: 100),
          initialItemCount: appState.history.length,
          itemBuilder: (context, index, animation) {
            final pair = appState.history[index];
            return SizeTransition(
              sizeFactor: animation,
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    appState.toggleFavorite(pair);
                  },
                  icon: appState.favorites.contains(pair)
                      ? Icon(Icons.favorite, size: 12)
                      : SizedBox(),
                  label: Text(
                    pair.asLowerCase,
                    semanticsLabel: pair.asPascalCase,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
