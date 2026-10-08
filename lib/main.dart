import 'package:flutter/material.dart';

import 'app.dart';
import 'dados/agenda_repository.dart';
import 'dados/agenda_repository_falso.dart';
import 'tema/tema.dart';

void main() {
  final AgendaRepository repositorio = AgendaRepositoryFalso();
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
