import 'package:flutter/material.dart';

import 'app.dart';
import 'dados/agenda_repository.dart';
import 'dados/agenda_repository_api.dart';
import 'dados/agenda_repository_falso.dart';
import 'dados/api_config.dart';
import 'tema/tema.dart';

void main() {
  final AgendaRepository repositorio = ApiConfig.usarApi
      ? AgendaRepositoryApi()
      : AgendaRepositoryFalso();

  runApp(NailsFlowApp(repositorio: repositorio));
}

class NailsFlowApp extends StatelessWidget {
  const NailsFlowApp({super.key, required this.repositorio});

  final AgendaRepository repositorio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NailsFlow',
      debugShowCheckedModeBanner: false,
      theme: temaNailsFlow(),
      home: Painel(repositorio: repositorio),
    );
  }
}
