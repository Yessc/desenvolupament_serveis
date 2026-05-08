import 'package:flutter/material.dart';
import '../data/data_manager.dart';

class ResponsiveView extends StatefulWidget {
  const ResponsiveView({super.key});

  @override
  State<ResponsiveView> createState() => _ResponsiveViewState();
}

enum MobileViewState { categories, list }

class _ResponsiveViewState extends State<ResponsiveView> {
  final DataManager dataManager = DataManager();
  String selectedCategory = "Personajes";
  List<dynamic> items = [];
  Map<String, dynamic>? selectedItem;
  MobileViewState mobileState = MobileViewState.categories;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await dataManager.loadData();
    setState(() {
      items = dataManager.characters;
      isLoading = false;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      selectedItem = null;
      if (category == "Personajes") items = dataManager.characters;
      if (category == "Consolas") items = dataManager.consoles;
      if (category == "Juegos") items = dataManager.games;
      mobileState = MobileViewState.list;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: isDesktop ? null : _buildMobileAppBar(),
      body: isDesktop ? _buildDesktop() : _buildMobileBody(),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.redAccent,
      foregroundColor: Colors.white,
      title: Text(mobileState == MobileViewState.categories ? "Nintendo DB" : selectedCategory),
      leading: mobileState != MobileViewState.categories
          ? BackButton(onPressed: () => setState(() => mobileState = MobileViewState.categories))
          : null,
    );
  }

  Widget _buildMobileBody() {
    if (mobileState == MobileViewState.categories) {
      return ListView(
        children: [
          ListTile(title: const Text("Personajes"), onTap: () => _selectCategory("Personajes")),
          ListTile(title: const Text("Consolas"), onTap: () => _selectCategory("Consolas")),
          ListTile(title: const Text("Juegos"), onTap: () => _selectCategory("Juegos")),
        ],
      );
    }
    return _buildItemList();
  }

  Widget _buildDesktop() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            children: [
              _buildLeftPanel(),
              Expanded(child: _buildDetailPanel()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.redAccent,
      child: const Text("Nintendo DB", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: 300,
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "Personajes", child: Text("Personajes")),
                DropdownMenuItem(value: "Consolas", child: Text("Consolas")),
                DropdownMenuItem(value: "Juegos", child: Text("Juegos")),
              ],
              onChanged: (v) => v != null ? _selectCategory(v) : null,
            ),
          ),
          Expanded(child: _buildItemList()),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem == item;
        return ListTile(
          selected: isSelected,
          leading: Image.asset("assets/${item["image"]}", width: 40, errorBuilder: (c, e, s) => const Icon(Icons.gamepad)),
          title: Text(item["name"]),
          onTap: () {
            if (MediaQuery.of(context).size.width <= 600) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(item: item, category: selectedCategory)));
            } else {
              setState(() => selectedItem = item);
            }
          },
        );
      },
    );
  }

  Widget _buildDetailPanel() {
    if (selectedItem == null) return const Center(child: Text("Selecciona un elemento para ver el detalle"));
    return DetailContent(item: selectedItem!, category: selectedCategory);
  }
}

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final String category;
  const DetailScreen({super.key, required this.item, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item["name"]), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: DetailContent(item: item, category: category),
    );
  }
}

class DetailContent extends StatelessWidget {
  final Map<String, dynamic> item;
  final String category;
  const DetailContent({super.key, required this.item, required this.category});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Image.asset("assets/${item["image"]}", height: 250, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 100)),
            const SizedBox(height: 20),
            Text(item["name"], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (category == "Personajes") ...[
              Text("Juego Original: ${item["game"]}", style: const TextStyle(fontSize: 18)),
              Chip(label: Text("Color: ${item["color"]}"), backgroundColor: Colors.red.shade100),
            ],
            if (category == "Consolas") ...[
              Text("Lanzamiento: ${item["date"]}"),
              Text("Procesador: ${item["procesador"]}"),
              Text("Unidades vendidas: ${item["units_sold"]}"),
            ],
            if (category == "Juegos") ...[
              Text("${item["type"]} (${item["year"]})", style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 15),
              Text(item["plot"], textAlign: TextAlign.justify, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}