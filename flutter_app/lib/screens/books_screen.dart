import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livros')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Tela de livros reservada.')),
    );
  }
}
