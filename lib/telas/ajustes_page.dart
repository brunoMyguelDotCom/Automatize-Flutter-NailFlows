import 'package:flutter/material.dart';

import '../tema/cores.dart';

class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: const [
            _Grupo('Expediente'),
            _Item(
              icone: Icons.calendar_month_rounded,
              titulo: 'Dias e horários de atendimento',
              detalhe: 'A combinar com a profissional',
              aDefinir: true,
            ),
            _Item(
              icone: Icons.timer_outlined,
              titulo: 'Intervalo entre atendimentos',
              detalhe: 'A combinar com a profissional',
              aDefinir: true,
            ),
            SizedBox(height: 22),
            _Grupo('Integrações'),
            _Item(
              icone: Icons.event_available_rounded,
              titulo: 'Google Agenda',
              detalhe: 'Ainda não conectado',
              aDefinir: true,
            ),
            _Item(
              icone: Icons.cloud_outlined,
              titulo: 'Servidor',
              detalhe: 'Usando dados de exemplo no próprio navegador',
              aDefinir: true,
            ),
            SizedBox(height: 22),
            _Grupo('Sobre'),
            _Item(
              icone: Icons.info_outline_rounded,
              titulo: 'NailsFlow',
              detalhe: 'Painel de agenda · versão de desenvolvimento',
            ),
          ],
        ),
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: vinho,
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icone,
    required this.titulo,
    required this.detalhe,
    this.aDefinir = false,
  });

  final IconData icone;
  final String titulo;
  final String detalhe;
  final bool aDefinir;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: linha),
      ),
      child: Row(
        children: [
          Icon(icone, size: 20, color: vinho),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: texto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalhe,
                  style: const TextStyle(fontSize: 13, color: textoApoio),
                ),
              ],
            ),
          ),
          if (aDefinir)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: pendenteFundo,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'a definir',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: pendente,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
