import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/acesso.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/main.dart';

Future<void> abrirApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 1100);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    NailsFlowApp(
      fonte: FonteDeDados(
        repositorio: AgendaRepositoryFalso(atraso: Duration.zero),
        descricao: 'Dados de exemplo',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('o app abre no login, nao na agenda', (tester) async {
    await abrirApp(tester);

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Agenda'), findsNothing);
  });

  testWidgets('nao entra com campo vazio', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe o e-mail'), findsOneWidget);
    expect(find.text('Informe a senha'), findsOneWidget);
  });

  testWidgets('avisa quando a senha esta errada', (tester) async {
    await abrirApp(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      Acesso.emailProvisorio,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      'errada',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.text('Agenda'), findsNothing);
  });

  testWidgets('entra com os dados certos e sai pelos ajustes', (tester) async {
    await abrirApp(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      Acesso.emailProvisorio,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      Acesso.senhaProvisoria,
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Agenda'), findsWidgets);

    await tester.tap(find.text('Ajustes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair do painel'));
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
  });
}
