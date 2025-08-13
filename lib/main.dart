import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = DressUpGame();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220,
              child: DressUpUI(game: game),
            ),
          ),
        ],
      ),
    ),
  ));
}

class DressUpGame extends FlameGame {
  late final SpriteComponent body;
  late final SpriteComponent hair;
  late final SpriteComponent dress;
  late final SpriteComponent shoes;
  late final SpriteComponent earrings;

  String currentCategory = 'hair';
  final Map<String, List<String>> items = {
    'hair': [],
    'dress': [],
    'shoes': [],
    'earrings': [],
  };

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(Vector2(1080, 1920));
    body = SpriteComponent()
      ..sprite = await loadSprite('assets/base/body_01.png')
      ..size = Vector2(1024, 1536)
      ..position = Vector2(50, 200);
    add(body);

    hair = SpriteComponent(size: body.size, position: body.position);
    dress = SpriteComponent(size: body.size, position: body.position);
    shoes = SpriteComponent(size: body.size, position: body.position);
    earrings = SpriteComponent(size: body.size, position: body.position);

    add(hair);
    add(dress);
    add(shoes);
    add(earrings);

    await _loadItems();

    await changeItem('hair', items['hair']!.first);
    await changeItem('dress', items['dress']!.first);
    await changeItem('shoes', items['shoes']!.first);
    await changeItem('earrings', items['earrings']!.first);
  }

  Future<void> _loadItems() async {
    final jsonStr = await rootBundle.loadString('assets/items.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    data.forEach((key, value) {
      items[key] = (value as List).map((e) => 'assets/$key/$e').toList();
    });
  }

  Future<void> changeItem(String category, String assetPath) async {
    final sprite = await loadSprite(assetPath);
    switch (category) {
      case 'hair':
        hair.sprite = sprite; break;
      case 'dress':
        dress.sprite = sprite; break;
      case 'shoes':
        shoes.sprite = sprite; break;
      case 'earrings':
        earrings.sprite = sprite; break;
    }
  }
}

class DressUpUI extends StatefulWidget {
  final DressUpGame game;
  const DressUpUI({super.key, required this.game});
  @override
  State<DressUpUI> createState() => _DressUpUIState();
}

class _DressUpUIState extends State<DressUpUI> {
  String get current => widget.game.currentCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(.9),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _cat('Saç', 'hair'),
          _cat('Elbise', 'dress'),
          _cat('Ayakkabı', 'shoes'),
          _cat('Küpe', 'earrings'),
          const Divider(),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 6, crossAxisSpacing: 6),
              padding: const EdgeInsets.all(8),
              itemCount: widget.game.items[current]!.length,
              itemBuilder: (ctx, i) {
                final asset = widget.game.items[current]![i];
                return InkWell(
                  onTap: () => widget.game.changeItem(current, asset),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(asset, fit: BoxFit.contain),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _cat(String label, String key) {
    final selected = widget.game.currentCategory == key;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          setState(() => widget.game.currentCategory = key);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.pinkAccent : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black87,
        ),
        child: Align(alignment: Alignment.centerLeft, child: Text(label)),
      ),
    );
  }
}