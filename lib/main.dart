import 'package:flutter/material.dart';

import 'app.dart';
import 'dados/fonte_de_dados.dart';
import 'tema/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final fonte = await escolherFonteDeDados();
  runApp(NailsFlowApp(fonte: fonte));
}

class NailsFlowApp extends StatelessWidget {
  const NailsFlowApp({super.key, required this.fonte});

  final FonteDeDados fonte;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NailsFlow',
      debugShowCheckedModeBanner: false,
      theme: temaNailsFlow(),
      home: Painel(fonte: fonte),
    );
  }
}
