import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dados/fonte_de_dados.dart';
import '../dados/google_agenda.dart';
import '../tema/cores.dart';

class AjustesPage extends StatelessWidget {
  const AjustesPage({
    super.key,
    required this.fonte,
    this.aoSair,
    this.googleAgenda,
  });

  final FonteDeDados fonte;
  final VoidCallback? aoSair;
  final GoogleAgenda? googleAgenda;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            const _Grupo('Expediente'),
            const _Item(
              icone: Icons.calendar_month_rounded,
              titulo: 'Dias e horários de atendimento',
              detalhe: 'A combinar com a profissional',
              aDefinir: true,
            ),
            const _Item(
              icone: Icons.timer_outlined,
              titulo: 'Intervalo entre atendimentos',
              detalhe: 'A combinar com a profissional',
              aDefinir: true,
            ),
            const SizedBox(height: 22),
            const _Grupo('Integrações'),
            if (fonte.ehApi)
              _ItemGoogle(servico: googleAgenda)
            else
              const _Item(
                icone: Icons.event_available_rounded,
                titulo: 'Google Agenda',
                detalhe: 'Disponível quando o painel estiver ligado à API',
                aDefinir: true,
              ),
            _Item(
              icone: Icons.cloud_outlined,
              titulo: 'Origem dos dados',
              detalhe: fonte.descricao,
              aDefinir: !fonte.ehApi,
            ),
            const SizedBox(height: 22),
            const _Grupo('Sobre'),
            const _Item(
              icone: Icons.info_outline_rounded,
              titulo: 'NailsFlow',
              detalhe: 'Painel de agenda · versão de desenvolvimento',
            ),
            if (aoSair != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: aoSair,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sair do painel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: recusado,
                    side: const BorderSide(color: recusadoFundo),
                  ),
                ),
              ),
            ],
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
    this.aoTocar,
    this.fim,
  });

  final IconData icone;
  final String titulo;
  final String detalhe;
  final bool aDefinir;
  final VoidCallback? aoTocar;
  final Widget? fim;

  @override
  Widget build(BuildContext context) {
    final cartao = Container(
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
          if (fim != null)
            fim!
          else if (aDefinir)
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

    if (aoTocar == null) return cartao;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: cartao,
      ),
    );
  }
}

class _ItemGoogle extends StatefulWidget {
  const _ItemGoogle({this.servico});

  final GoogleAgenda? servico;

  @override
  State<_ItemGoogle> createState() => _ItemGoogleState();
}

class _ItemGoogleState extends State<_ItemGoogle> {
  static const IconData _icone = Icons.event_available_rounded;

  late final GoogleAgenda _servico = widget.servico ?? GoogleAgenda();

  bool _carregando = true;
  bool _ligada = false;
  bool _abriuAutorizacao = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _consultar();
  }

  Future<void> _consultar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final ligada = await _servico.integracaoLigada();
      if (!mounted) return;
      setState(() {
        _ligada = ligada;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro.toString();
        _carregando = false;
      });
    }
  }

  Future<void> _conectar() async {
    final aberto = await launchUrl(
      _servico.enderecoDeConexao,
      webOnlyWindowName: '_blank',
    );
    if (!mounted) return;

    setState(() {
      _abriuAutorizacao = aberto;
      _erro = aberto
          ? null
          : 'Não foi possível abrir a página do Google. '
                'Permita pop-ups para este endereço e tente de novo.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const _Item(
        icone: _icone,
        titulo: 'Google Agenda',
        detalhe: 'Consultando a API...',
        fim: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: vinho),
        ),
      );
    }

    if (_erro != null) {
      return _Item(
        icone: _icone,
        titulo: 'Google Agenda',
        detalhe: _erro!,
        aoTocar: _consultar,
        fim: const Icon(Icons.refresh_rounded, size: 20, color: recusado),
      );
    }

    if (!_ligada) {
      return const _Item(
        icone: _icone,
        titulo: 'Google Agenda',
        detalhe: 'Integração desligada na API',
        aDefinir: true,
      );
    }

    // A API ainda não informa se a agenda ficou conectada, então depois de
    // abrir a autorização o painel só orienta e deixa abrir de novo.
    if (_abriuAutorizacao) {
      return _Item(
        icone: _icone,
        titulo: 'Google Agenda',
        detalhe:
            'Autorize na aba que abriu. Para trocar de conta, toque de novo.',
        aoTocar: _conectar,
        fim: const Icon(Icons.open_in_new_rounded, size: 20, color: vinho),
      );
    }

    return _Item(
      icone: _icone,
      titulo: 'Google Agenda',
      detalhe: 'Toque para conectar a agenda da profissional',
      aoTocar: _conectar,
      fim: const Icon(Icons.chevron_right_rounded, size: 20, color: textoApoio),
    );
  }
}
