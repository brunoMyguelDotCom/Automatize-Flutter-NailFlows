import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nailsflow/dados/agenda_repository_api.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/dados/google_agenda.dart';
import 'package:nailsflow/telas/ajustes_page.dart';

GoogleAgenda _servicoFalso({bool ligada = true, bool semRede = false}) {
  final rotas = ligada
      ? '"/agendamentos/": {}, "/auth/google/connect": {}'
      : '"/agendamentos/": {}';
  return GoogleAgenda(
    urlBase: 'http://teste',
    cliente: MockClient((pedido) async {
      if (semRede) throw http.ClientException('sem rede');
      expect(pedido.url.path, '/openapi.json');
      return http.Response('{"paths": {$rotas}}', 200);
    }),
  );
}

FonteDeDados _fonteApi() => FonteDeDados(
  repositorio: AgendaRepositoryApi(urlBase: 'http://teste'),
  descricao: 'API em http://teste',
);

Future<void> _abrirAjustes(
  WidgetTester tester,
  GoogleAgenda servico, {
  FonteDeDados? fonte,
}) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: AjustesPage(fonte: fonte ?? _fonteApi(), googleAgenda: servico),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('integracao ligada quando a API tem a rota de conexao', () async {
    expect(await _servicoFalso().integracaoLigada(), isTrue);
  });

  test('integracao desligada quando a API roda com o mock', () async {
    expect(await _servicoFalso(ligada: false).integracaoLigada(), isFalse);
  });

  test('aponta para a rota de conexao da API', () {
    expect(
      _servicoFalso().enderecoDeConexao.toString(),
      'http://teste/auth/google/connect',
    );
  });

  test('avisa quando nao alcanca o servidor', () async {
    expect(
      () => _servicoFalso(semRede: true).integracaoLigada(),
      throwsA(isA<FalhaDaApi>()),
    );
  });

  testWidgets('convida a conectar quando a integracao esta ligada', (
    tester,
  ) async {
    await _abrirAjustes(tester, _servicoFalso());

    expect(
      find.text('Toque para conectar a agenda da profissional'),
      findsOneWidget,
    );
  });

  testWidgets('mostra desligado quando a API roda sem o Google', (
    tester,
  ) async {
    await _abrirAjustes(tester, _servicoFalso(ligada: false));

    expect(find.text('Integração desligada na API'), findsOneWidget);
  });

  testWidgets('nao consulta o Google com dados de exemplo', (tester) async {
    await _abrirAjustes(
      tester,
      _servicoFalso(semRede: true),
      fonte: FonteDeDados(
        repositorio: AgendaRepositoryFalso(),
        descricao: 'Dados de exemplo',
      ),
    );

    expect(
      find.text('Disponível quando o painel estiver ligado à API'),
      findsOneWidget,
    );
  });
}
