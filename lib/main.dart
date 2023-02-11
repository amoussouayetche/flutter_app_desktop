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
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  //creation d'un tableau favoris pour stocker les mot favoris
  var favorites = <WordPair>[];
  //creation d'une methode pour gerer l'enregistrement
  void toggleFavorite() {
    if (favorites.contains(current)) {
      //supprime le mot du tableau si ca sy trouve deja
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    //dans les deux cas, ca appel ca
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
    // LayoutBuilder, Builder, redimenssion les fenetre en tenant compte de l'espace, appareil en mode portait ou autres
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
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
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                // on affecte la vue a la deuxieme moitie de l'ecran
                child: page,
              ),
            ),
          ],
        ),
      );
    });
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
        ],
      ),
    );
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

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
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //obtient l'etat actuel de l'appli
    var appState = context.watch<MyAppState>();
    //si favoris vide, affiche un message centre pas de favoris
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }
    //sinon affiche une liste derourable
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          //resume, vous aves 5 favoris par exemple
          child: Text('you have' '${appState.favorites.length} favorites: '),
        ),
        // parcours les favoris et construit listTile pour chaque favoris trouvé
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          )
      ],
    );
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
