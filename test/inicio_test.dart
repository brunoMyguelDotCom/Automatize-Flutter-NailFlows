import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/autenticacao.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/telas/inicio_page.dart';

class AutenticacaoDeslogada implements Autenticacao {
  @override
  bool get logado => false;

  @override
  Stream<bool> get mudancas => const Stream.empty();

  @override
  Future<void> entrar(String email, String senha) async {}

  @override
  Future<void> sair() async {}
}

void main() {
  test('API publicada fora do ar nao cai nos dados de exemplo', () async {
    expect(
      () => escolherFonteDeDados(
        publicada: true,
        cliente: MockClient((_) async => throw const SocketException('off')),
      ),
      throwsA(isA<ServidorForaDoAr>()),
    );
  });

  test('API local fora do ar continua caindo nos dados de exemplo', () async {
    final fonte = await escolherFonteDeDados(
      publicada: false,
      cliente: MockClient((_) async => throw const SocketException('off')),
    );
    expect(fonte.ehApi, isFalse);
  });

  test('API publicada que responde e usada normalmente', () async {
    final fonte = await escolherFonteDeDados(
      publicada: true,
      cliente: MockClient((_) async => http.Response('{}', 200)),
    );
    expect(fonte.ehApi, isTrue);
  });

  testWidgets('mostra a espera e depois abre o login', (tester) async {
    final procura = Completer<FonteDeDados>();
    await tester.pumpWidget(
      InicioDoPainel(
        autenticacao: AutenticacaoDeslogada(),
        escolherFonte: () => procura.future,
      ),
    );
    await tester.pump();
    expect(find.text('Acordando o servidor…'), findsOneWidget);

    procura.complete(
      FonteDeDados(
        repositorio: AgendaRepositoryFalso(atraso: Duration.zero),
        descricao: 'teste',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('se o servidor nao acordar, deixa tentar de novo', (
    tester,
  ) async {
    var tentativas = 0;
    await tester.pumpWidget(
      InicioDoPainel(
        autenticacao: AutenticacaoDeslogada(),
        escolherFonte: () async {
          tentativas++;
          throw ServidorForaDoAr();
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('O servidor não respondeu'), findsOneWidget);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();
    expect(tentativas, 2);
  });
}
