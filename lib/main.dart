import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'dados/api_config.dart';
import 'dados/autenticacao.dart';
import 'dados/cadastro_por_convite.dart';
import 'dados/fonte_de_dados.dart';
import 'telas/cadastro_cliente_page.dart';
import 'tema/tema.dart';
import 'telas/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Link de cadastro (painel/#/cadastro/<token>): abre só o formulário da
  // cliente, sem login e sem o resto do painel.
  final tokenDoCadastro = tokenDoLinkDeCadastro(Uri.base);
  if (tokenDoCadastro != null) {
    runApp(
      CadastroClienteApp(
        token: tokenDoCadastro,
        convites: CadastroPorConvite(),
      ),
    );
    return;
  }

  // Login do painel pelo Supabase Auth. A sessão fica guardada no
  // navegador: quem já entrou não precisa digitar a senha de novo.
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    publishableKey: ApiConfig.supabaseChave,
  );

  final fonte = await escolherFonteDeDados();
  runApp(NailsFlowApp(fonte: fonte, autenticacao: AutenticacaoSupabase()));
}

class NailsFlowApp extends StatefulWidget {
  const NailsFlowApp({
    super.key,
    required this.fonte,
    this.autenticacao,
    this.jaAutenticado = false,
  });

  final FonteDeDados fonte;

  /// Null só nos testes que já entram direto no painel.
  final Autenticacao? autenticacao;
  final bool jaAutenticado;

  @override
  State<NailsFlowApp> createState() => _NailsFlowAppState();
}

class _NailsFlowAppState extends State<NailsFlowApp> {
  late bool _autenticado =
      widget.jaAutenticado || (widget.autenticacao?.logado ?? false);
  StreamSubscription<bool>? _sessao;

  @override
  void initState() {
    super.initState();
    // Guardião do painel: sem sessão no Supabase, só aparece o login.
    _sessao = widget.autenticacao?.mudancas.listen((logado) {
      if (mounted) setState(() => _autenticado = logado);
    });
  }

  @override
  void dispose() {
    _sessao?.cancel();
    super.dispose();
  }

  Future<void> _sair() async {
    await widget.autenticacao?.sair();
    if (mounted) setState(() => _autenticado = false);
  }

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
          ? Painel(fonte: widget.fonte, aoSair: _sair)
          : LoginPage(
              autenticacao: widget.autenticacao,
              aoEntrar: () => setState(() => _autenticado = true),
            ),
    );
  }
}
