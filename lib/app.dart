import 'package:flutter/material.dart';

import 'dados/agenda_repository.dart';
import 'tema/cores.dart';
import 'telas/agenda_page.dart';
import 'telas/ajustes_page.dart';
import 'telas/clientes_page.dart';
import 'telas/servicos_page.dart';

class Painel extends StatefulWidget {
  const Painel({super.key, required this.repositorio});

  final AgendaRepository repositorio;

  @override
  State<Painel> createState() => _PainelState();
}

class _PainelState extends State<Painel> {
  int _area = 0;

  static const List<_Area> _areas = [
    _Area('Agenda', Icons.event_note_outlined, Icons.event_note_rounded),
    _Area('Clientes', Icons.people_outline_rounded, Icons.people_rounded),
    _Area('Serviços', Icons.spa_outlined, Icons.spa_rounded),
    _Area('Ajustes', Icons.tune_outlined, Icons.tune_rounded),
  ];

  Widget _conteudo() {
    switch (_area) {
      case 1:
        return ClientesPage(repositorio: widget.repositorio);
      case 2:
        return ServicosPage(repositorio: widget.repositorio);
      case 3:
        return const AjustesPage();
      default:
        return AgendaPage(repositorio: widget.repositorio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricoes) {
        final largo = restricoes.maxWidth >= 900;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: largo ? 24 : 16,
            title: Row(
              children: [
                Image.asset(
                  'assets/imagens/logo.png',
                  height: 26,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(width: 14),
                Container(width: 1, height: 20, color: Colors.white24),
                const SizedBox(width: 14),
                Text(_areas[_area].nome),
              ],
            ),
          ),
          floatingActionButton: _area == 0
              ? FloatingActionButton.extended(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Novo atendimento: ainda não implementado'),
                      backgroundColor: vinhoEscuro,
                    ),
                  ),
                  backgroundColor: vinho,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Novo atendimento'),
                )
              : null,
          bottomNavigationBar: largo
              ? null
              : NavigationBar(
                  selectedIndex: _area,
                  onDestinationSelected: (indice) =>
                      setState(() => _area = indice),
                  backgroundColor: superficie,
                  indicatorColor: rosa,
                  destinations: _areas
                      .map(
                        (area) => NavigationDestination(
                          icon: Icon(area.icone),
                          selectedIcon: Icon(area.icomeAtivo, color: vinho),
                          label: area.nome,
                        ),
                      )
                      .toList(),
                ),
          body: Row(
            children: [
              if (largo)
                NavigationRail(
                  selectedIndex: _area,
                  onDestinationSelected: (indice) =>
                      setState(() => _area = indice),
                  backgroundColor: superficie,
                  indicatorColor: rosa,
                  labelType: NavigationRailLabelType.all,
                  selectedLabelTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: vinho,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    fontSize: 12,
                    color: textoApoio,
                  ),
                  destinations: _areas
                      .map(
                        (area) => NavigationRailDestination(
                          icon: Icon(area.icone, color: textoApoio),
                          selectedIcon: Icon(area.icomeAtivo, color: vinho),
                          label: Text(area.nome),
                        ),
                      )
                      .toList(),
                ),
              if (largo) const VerticalDivider(width: 1, color: linha),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: _conteudo(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Area {
  const _Area(this.nome, this.icone, this.icomeAtivo);

  final String nome;
  final IconData icone;
  final IconData icomeAtivo;
}
