import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: temaNailsFlow(),
      home: Painel(fonte: fonte),
    );
  }
}
