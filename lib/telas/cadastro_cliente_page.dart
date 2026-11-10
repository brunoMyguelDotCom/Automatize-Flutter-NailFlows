import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../dados/cadastro_por_convite.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';
import '../util/telefone.dart';
import '../util/whatsapp.dart';
import '../widgets/campo_formulario.dart';

/// App aberto pelo link de cadastro. É separado do painel: a cliente não faz
/// login e só vê o formulário.
class CadastroClienteApp extends StatelessWidget {
  const CadastroClienteApp({
    super.key,
    required this.token,
    required this.convites,
  });

  final String token;
  final CadastroPorConvite convites;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro · $nomeDaProfissional',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: temaNailsFlow(),
      // Com "home", o Flutter troca o endereço para /#/ e o token some: se a
      // cliente atualizasse a página, cairia no login do painel. Abrindo a
      // tela com o nome da rota original, o endereço continua com o token.
      onGenerateInitialRoutes: (rota) => [_rota(rota)],
      onGenerateRoute: (configuracao) => _rota(configuracao.name),
    );
  }

  Route<void> _rota(String? nome) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: nome),
      builder: (context) =>
          CadastroClientePage(token: token, convites: convites),
    );
  }
}

class CadastroClientePage extends StatefulWidget {
  const CadastroClientePage({
    super.key,
    required this.token,
    required this.convites,
  });

  final String token;
  final CadastroPorConvite convites;

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

enum _Etapa { validando, invalido, preenchendo, cadastrado }

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formulario = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _email = TextEditingController();

  _Etapa _etapa = _Etapa.validando;
  bool _enviando = false;
  String? _motivoDoLinkInvalido;
  String? _erro;

  // Quando a API diz que o e-mail ou o telefone já existe, o erro aparece
  // embaixo do campo até a cliente mudar o valor.
  String? _emailRecusado;
  String? _telefoneRecusado;
  String? _mensagemDoCampo;

  @override
  void initState() {
    super.initState();
    _validar();
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _validar() async {
    try {
      await widget.convites.validar(widget.token);
      if (!mounted) return;
      setState(() => _etapa = _Etapa.preenchendo);
    } on FalhaNoCadastro catch (falha) {
      if (!mounted) return;
      setState(() {
        _etapa = _Etapa.invalido;
        _motivoDoLinkInvalido = falha.mensagem;
      });
    }
  }

  Future<void> _cadastrar() async {
    if (!_formulario.currentState!.validate()) return;

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      await widget.convites.cadastrar(
        widget.token,
        nome: _nome.text.trim(),
        email: _email.text.trim(),
        telefone: _telefone.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _etapa = _Etapa.cadastrado;
        _enviando = false;
      });
    } on FalhaNoCadastro catch (falha) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        if (falha.linkInvalido) {
          _etapa = _Etapa.invalido;
          _motivoDoLinkInvalido = falha.mensagem;
        } else if (falha.campo == 'email') {
          _emailRecusado = _email.text.trim();
          _mensagemDoCampo = falha.mensagem;
        } else if (falha.campo == 'phone') {
          _telefoneRecusado = _telefone.text.trim();
          _mensagemDoCampo = falha.mensagem;
        } else {
          _erro = falha.mensagem;
        }
      });
      _formulario.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
              children: [
                Text(nomeDaProfissional, style: estiloTitulo(cor: vinho)),
                const Text(
                  'NAIL DESIGNER',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 3,
                    color: dourado,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                ..._conteudo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _conteudo() {
    switch (_etapa) {
      case _Etapa.validando:
        return const [
          SizedBox(height: 60),
          Center(child: CircularProgressIndicator(color: vinho)),
        ];
      case _Etapa.invalido:
        return [
          Text('Esse link não vale mais', style: estiloTitulo(tamanho: 24)),
          const SizedBox(height: 12),
          Text(
            '${_motivoDoLinkInvalido ?? 'Link inválido'}. O link de cadastro '
            'vale por 6 horas e serve para um cadastro só. Peça um novo para '
            'a $nomeDaProfissional.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: textoApoio,
            ),
          ),
        ];
      case _Etapa.cadastrado:
        return [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: rosa,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: vinho, size: 30),
          ),
          const SizedBox(height: 18),
          Text('Cadastro feito!', style: estiloTitulo(tamanho: 26)),
          const SizedBox(height: 12),
          Text(
            'Obrigada, ${_nome.text.trim().split(' ').first}! A '
            '$nomeDaProfissional já recebeu seus dados e vai combinar o '
            'horário com você pelo WhatsApp.',
            style: const TextStyle(fontSize: 15, height: 1.5, color: texto),
          ),
        ];
      case _Etapa.preenchendo:
        return _formularioDeCadastro();
    }
  }

  List<Widget> _formularioDeCadastro() {
    return [
      Text('Faça seu cadastro', style: estiloTitulo(tamanho: 26)),
      const SizedBox(height: 8),
      const Text(
        'Preencha seus dados para agendar. O e-mail é para o convite do '
        'Google Agenda, assim o horário fica na sua agenda.',
        style: TextStyle(fontSize: 14, height: 1.45, color: textoApoio),
      ),
      const SizedBox(height: 20),
      Form(
        key: _formulario,
        child: Column(
          children: [
            CampoFormulario(
              controlador: _nome,
              rotulo: 'Nome completo',
              icone: Icons.person_outline_rounded,
              validador: (valor) =>
                  (valor ?? '').trim().length < 2 ? 'Informe seu nome' : null,
            ),
            CampoFormulario(
              controlador: _telefone,
              rotulo: 'WhatsApp',
              dica: '(44) 99999-9999',
              icone: Icons.phone_outlined,
              teclado: TextInputType.phone,
              formatadores: [
                FilteringTextInputFormatter.digitsOnly,
                TelefoneOuCelularInputFormatter(),
              ],
              validador: (valor) {
                final texto = (valor ?? '').trim();
                if (!telefoneCompleto(texto)) {
                  return 'Informe o WhatsApp com DDD';
                }
                if (_telefoneRecusado != null && texto == _telefoneRecusado) {
                  return _mensagemDoCampo;
                }
                return null;
              },
            ),
            CampoFormulario(
              controlador: _email,
              rotulo: 'E-mail',
              dica: 'voce@gmail.com',
              icone: Icons.mail_outline_rounded,
              teclado: TextInputType.emailAddress,
              validador: (valor) {
                final texto = (valor ?? '').trim();
                if (!texto.contains('@') || !texto.contains('.')) {
                  return 'Informe um e-mail válido';
                }
                if (_emailRecusado != null && texto == _emailRecusado) {
                  return _mensagemDoCampo;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      if (_erro != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            _erro!,
            style: const TextStyle(
              color: recusado,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed: _enviando ? null : _cadastrar,
          style: FilledButton.styleFrom(backgroundColor: vinho),
          icon: _enviando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: const Text(
            'Fazer meu cadastro',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'Seus dados ficam só com a profissional, para os seus agendamentos.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.5, color: textoApoio),
      ),
    ];
  }
}
