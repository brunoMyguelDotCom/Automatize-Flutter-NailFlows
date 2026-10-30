import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'dados/fonte_de_dados.dart';
import 'tema/tema.dart';
import 'telas/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final fonte = await escolherFonteDeDados();
  runApp(NailsFlowApp(fonte: fonte));
}

class NailsFlowApp extends StatefulWidget {
  const NailsFlowApp({
    super.key,
    required this.fonte,
    this.jaAutenticado = false,
  });

  final FonteDeDados fonte;
  final bool jaAutenticado;

  @override
  State<NailsFlowApp> createState() => _NailsFlowAppState();
}

class _NailsFlowAppState extends State<NailsFlowApp> {
  late bool _autenticado = widget.jaAutenticado;

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
      home: _autenticado
          ? Painel(
              fonte: widget.fonte,
              aoSair: () => setState(() => _autenticado = false),
            )
          : LoginPage(aoEntrar: () => setState(() => _autenticado = true)),
    );
  }
}
