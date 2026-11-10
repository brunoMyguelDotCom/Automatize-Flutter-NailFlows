import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/autenticacao.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/main.dart';

/// Faz o papel do Supabase Auth nos testes, sem internet.
class AutenticacaoFalsa implements Autenticacao {
  AutenticacaoFalsa({this.logado = false});

  static const email = 'cris@exemplo.com';
  static const senha = 'senha-de-teste';

  @override
  bool logado;
  int saidas = 0;
  final _mudancas = StreamController<bool>.broadcast();

  @override
  Stream<bool> get mudancas => _mudancas.stream;

  @override
  Future<void> entrar(String email, String senha) async {
    if (email.trim() != AutenticacaoFalsa.email ||
        senha != AutenticacaoFalsa.senha) {
      throw FalhaNoLogin(traduzirErroDoLogin('Invalid login credentials'));
    }
    logado = true;
    _mudancas.add(true);
  }

  @override
  Future<void> sair() async {
    saidas++;
    logado = false;
    _mudancas.add(false);
  }

  /// Simula a sessão vencendo ou o logout feito em outra aba.
  void encerrarSessao() {
    logado = false;
    _mudancas.add(false);
  }
}

Future<void> abrirApp(WidgetTester tester, AutenticacaoFalsa auth) async {
  tester.view.physicalSize = const Size(1280, 1100);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    NailsFlowApp(
      autenticacao: auth,
      fonte: FonteDeDados(
        repositorio: AgendaRepositoryFalso(atraso: Duration.zero),
        descricao: 'Dados de exemplo',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> preencher(WidgetTester tester, String email, String senha) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
  await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), senha);
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('o app abre no login, nao na agenda', (tester) async {
    await abrirApp(tester, AutenticacaoFalsa());

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Agenda'), findsNothing);
  });

  testWidgets('com sessao guardada, abre direto no painel', (tester) async {
    await abrirApp(tester, AutenticacaoFalsa(logado: true));

    expect(find.text('Agenda'), findsWidgets);
    expect(find.text('Entrar'), findsNothing);
  });

  testWidgets('nao entra com campo vazio', (tester) async {
    await abrirApp(tester, AutenticacaoFalsa());

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o e-mail'), findsOneWidget);
    expect(find.text('Informe a senha'), findsOneWidget);
  });

  testWidgets('avisa quando a senha esta errada', (tester) async {
    await abrirApp(tester, AutenticacaoFalsa());

    await preencher(tester, AutenticacaoFalsa.email, 'errada');

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.text('Agenda'), findsNothing);
  });

  testWidgets('entra com os dados certos e sai pelos ajustes', (tester) async {
    final auth = AutenticacaoFalsa();
    await abrirApp(tester, auth);

    await preencher(tester, AutenticacaoFalsa.email, AutenticacaoFalsa.senha);
    expect(find.text('Agenda'), findsWidgets);

    await tester.tap(find.text('Ajustes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair do painel'));
    await tester.pumpAndSettle();

    expect(auth.saidas, 1);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('volta para o login quando a sessao acaba', (tester) async {
    final auth = AutenticacaoFalsa(logado: true);
    await abrirApp(tester, auth);

    auth.encerrarSessao();
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
  });

  test('traduz os erros do Supabase', () {
    expect(
      traduzirErroDoLogin('Invalid login credentials'),
      'E-mail ou senha incorretos.',
    );
    expect(
      traduzirErroDoLogin('Email not confirmed'),
      'Esse e-mail ainda não foi confirmado no Supabase.',
    );
  });
}
