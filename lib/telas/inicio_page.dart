import 'package:flutter/material.dart';

import '../dados/autenticacao.dart';
import '../dados/fonte_de_dados.dart';
import '../main.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';

/// Primeira tela do painel: procura a API e só depois abre o login.
/// No site publicado a API pode estar dormindo, então mostra que está
/// esperando em vez de deixar a tela em branco.
class InicioDoPainel extends StatefulWidget {
  const InicioDoPainel({
    super.key,
    required this.autenticacao,
    this.escolherFonte = escolherFonteDeDados,
  });

  final Autenticacao autenticacao;

  /// Trocado nos testes para não depender de rede.
  final Future<FonteDeDados> Function() escolherFonte;

  @override
  State<InicioDoPainel> createState() => _InicioDoPainelState();
}

class _InicioDoPainelState extends State<InicioDoPainel> {
  FonteDeDados? _fonte;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _procurarApi();
  }

  Future<void> _procurarApi() async {
    setState(() => _erro = null);
    try {
      final fonte = await widget.escolherFonte();
      if (mounted) setState(() => _fonte = fonte);
    } catch (erro) {
      if (mounted) setState(() => _erro = erro.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final fonte = _fonte;
    if (fonte != null) {
      return NailsFlowApp(fonte: fonte, autenticacao: widget.autenticacao);
    }

    return MaterialApp(
      title: 'NailsFlow',
      debugShowCheckedModeBanner: false,
      theme: temaNailsFlow(),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: gradienteVinho),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/imagens/logo.png',
                  height: 80,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
                const SizedBox(height: 28),
                if (_erro == null) ...[
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 18),
                  const Text(
                    'Acordando o servidor…',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Na primeira vez do dia pode levar até um minuto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ] else ...[
                  Text(
                    _erro!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _procurarApi,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: vinho,
                    ),
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
