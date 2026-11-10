import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nailsflow/dados/agenda_repository_api.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/cadastro_por_convite.dart';
import 'package:nailsflow/telas/cadastro_cliente_page.dart';
import 'package:nailsflow/telas/clientes_page.dart';
import 'package:nailsflow/telas/link_de_cadastro_dialog.dart';

const _json = {'content-type': 'application/json; charset=utf-8'};

/// API de convites simulada, no formato do PR #8 do back.
CadastroPorConvite _apiDeConvites({
  int validacao = 200,
  int cadastro = 201,
  String? campoRepetido,
  List<http.Request>? pedidos,
}) {
  return CadastroPorConvite(
    urlBase: 'http://api',
    tokenAdmin: 'segredo',
    cliente: MockClient((pedido) async {
      pedidos?.add(pedido);
      final caminho = pedido.url.path;
      if (pedido.method == 'POST' && caminho == '/registration-links') {
        return http.Response(
          '{"url": "http://painel/#/cadastro/tok123", '
          '"expires_at": "2026-11-10T08:38:43+00:00"}',
          201,
          headers: _json,
        );
      }
      if (pedido.method == 'GET') {
        return validacao == 200
            ? http.Response('{"valid": true}', 200, headers: _json)
            : http.Response(
                '{"detail": "Link expirado"}',
                validacao,
                headers: _json,
              );
      }
      if (cadastro == 409) {
        final rotulo = campoRepetido == 'email' ? 'E-mail' : 'Telefone';
        return http.Response(
          '{"detail": "$rotulo já cadastrado", "field": "$campoRepetido"}',
          409,
          headers: _json,
        );
      }
      return http.Response(
        '{"message": "Cadastro realizado", "client": {}}',
        cadastro,
        headers: _json,
      );
    }),
  );
}

Future<void> _abrirCadastro(WidgetTester tester, CadastroPorConvite api) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: CadastroClientePage(token: 'tok123', convites: api),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _preencher(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nome completo'),
    'Julia Merlos',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'WhatsApp'),
    '44998124455',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'E-mail'),
    'julia@gmail.com',
  );
  await tester.tap(find.text('Fazer meu cadastro'));
  await tester.pumpAndSettle();
}

void main() {
  group('link', () {
    test('acha o token no link com # e no link com caminho', () {
      expect(
        tokenDoLinkDeCadastro(Uri.parse('http://painel/#/cadastro/tok123')),
        'tok123',
      );
      expect(
        tokenDoLinkDeCadastro(Uri.parse('http://painel/cadastro/tok123')),
        'tok123',
      );
      expect(tokenDoLinkDeCadastro(Uri.parse('http://painel/')), isNull);
    });
  });

  group('API de convites', () {
    test('gerar link manda o token de administrador', () async {
      final pedidos = <http.Request>[];
      final convite = await _apiDeConvites(pedidos: pedidos).gerarLink();

      expect(pedidos.single.headers['Authorization'], 'Bearer segredo');
      expect(convite.link, 'http://painel/#/cadastro/tok123');
      expect(convite.expiraEm.isUtc, isFalse);
    });

    test('link expirado vira falha de link invalido', () async {
      expect(
        () => _apiDeConvites(validacao: 410).validar('tok123'),
        throwsA(
          isA<FalhaNoCadastro>()
              .having((f) => f.linkInvalido, 'linkInvalido', isTrue)
              .having((f) => f.mensagem, 'mensagem', 'Link expirado'),
        ),
      );
    });

    test('cadastro manda nome, e-mail e telefone', () async {
      final pedidos = <http.Request>[];
      await _apiDeConvites(pedidos: pedidos).cadastrar(
        'tok123',
        nome: 'Julia',
        email: 'julia@gmail.com',
        telefone: '(44) 99812-4455',
      );

      expect(pedidos.single.url.path, '/registration-links/tok123/register');
      expect(pedidos.single.headers.containsKey('Authorization'), isFalse);
      expect(jsonDecode(pedidos.single.body), {
        'name': 'Julia',
        'email': 'julia@gmail.com',
        'phone': '(44) 99812-4455',
      });
    });
  });

  test('o painel manda o token nas rotas administrativas', () async {
    late http.Request pedido;
    final repositorio = AgendaRepositoryApi(
      urlBase: 'http://api',
      tokenAdmin: 'segredo',
      cliente: MockClient((requisicao) async {
        pedido = requisicao;
        return http.Response('[]', 200);
      }),
    );

    await repositorio.listarServicos();

    expect(pedido.headers['Authorization'], 'Bearer segredo');
  });

  group('pagina da cliente', () {
    testWidgets('cadastra e agradece', (tester) async {
      await _abrirCadastro(tester, _apiDeConvites());
      await _preencher(tester);

      expect(find.text('Cadastro feito!'), findsOneWidget);
      expect(find.textContaining('Obrigada, Julia!'), findsOneWidget);
    });

    testWidgets('e-mail repetido aparece embaixo do campo', (tester) async {
      await _abrirCadastro(
        tester,
        _apiDeConvites(cadastro: 409, campoRepetido: 'email'),
      );
      await _preencher(tester);

      expect(find.text('E-mail já cadastrado'), findsOneWidget);
      expect(find.text('Cadastro feito!'), findsNothing);
    });

    testWidgets('link expirado nao mostra o formulario', (tester) async {
      await _abrirCadastro(tester, _apiDeConvites(validacao: 410));

      expect(find.text('Esse link não vale mais'), findsOneWidget);
      expect(find.text('Fazer meu cadastro'), findsNothing);
    });
  });

  group('painel da Cris', () {
    testWidgets('Clientes tem o botao de link de cadastro', (tester) async {
      tester.view.physicalSize = const Size(1200, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: ClientesPage(
            repositorio: AgendaRepositoryFalso(atraso: Duration.zero),
            convites: _apiDeConvites(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Link de cadastro'));
      await tester.pumpAndSettle();

      expect(find.text('http://painel/#/cadastro/tok123'), findsOneWidget);
    });

    testWidgets('com dados de exemplo o botao nao aparece', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ClientesPage(
            repositorio: AgendaRepositoryFalso(atraso: Duration.zero),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Link de cadastro'), findsNothing);
    });

    testWidgets('manda o link no WhatsApp com a mensagem', (tester) async {
      Uri? aberto;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkDeCadastroDialog(
              convites: _apiDeConvites(),
              abrirLink: (uri) async {
                aberto = uri;
                return true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('WhatsApp'));
      await tester.pumpAndSettle();

      expect(aberto?.host, 'wa.me');
      expect(
        aberto?.queryParameters['text'],
        contains('http://painel/#/cadastro/tok123'),
      );
    });
  });
}
