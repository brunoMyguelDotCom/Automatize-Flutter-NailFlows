import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/main.dart';

Future<void> abrirClientes(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 950);
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
  await tester.tap(find.text('Clientes').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tocar na cliente abre a ficha, nao o historico', (tester) async {
    await abrirClientes(tester);

    await tester.tap(find.text('Maria Silva'));
    await tester.pumpAndSettle();

    expect(find.text('Cliente'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'maria.silva@email.com'),
      findsOneWidget,
    );
    expect(find.text('Salvar alterações'), findsOneWidget);
  });

  testWidgets('botao de historico abre o historico da cliente', (tester) async {
    await abrirClientes(tester);

    await tester.tap(find.byTooltip('Histórico de atendimentos').first);
    await tester.pumpAndSettle();

    expect(find.text('Histórico'), findsOneWidget);
    expect(find.textContaining('atendimento'), findsWidgets);
  });

  testWidgets('cadastra uma cliente nova pelo botao', (tester) async {
    await abrirClientes(tester);

    await tester.tap(find.text('Nova cliente'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastrar'), findsOneWidget);

    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome da cliente'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Bruna Alves',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'bruna@email.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Telefone'),
      '44991112233',
    );
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(find.text('Bruna Alves'), findsOneWidget);
    expect(find.text('Cadastro atualizado'), findsOneWidget);
  });

  testWidgets('da para chegar no historico pela ficha', (tester) async {
    await abrirClientes(tester);

    await tester.tap(find.text('Juliana Prado'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Histórico de atendimentos'));
    await tester.pumpAndSettle();

    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Juliana Prado'), findsWidgets);
  });

  testWidgets('telefone salvo com +55 abre formatado na ficha', (tester) async {
    await abrirClientes(tester);

    await tester.tap(find.text('Maria Silva'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextFormField, '(44) 99812-4455'),
      findsOneWidget,
    );
  });

  testWidgets('telefone incompleto nao deixa cadastrar', (tester) async {
    await abrirClientes(tester);

    await tester.tap(find.text('Nova cliente'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome'),
      'Bruna Alves',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'bruna@email.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Telefone'),
      '4499',
    );
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(find.text('Telefone incompleto'), findsOneWidget);
  });
}
