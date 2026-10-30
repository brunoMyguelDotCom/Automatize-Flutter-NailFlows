import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/main.dart';
import 'package:nailsflow/util/datas.dart';

Future<void> abrirAgenda(WidgetTester tester) async {
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
  testWidgets('as setas andam uma semana para cada lado', (tester) async {
    await abrirAgenda(tester);
    final hoje = DateTime.now();

    expect(find.text(diaPorExtenso(hoje)), findsOneWidget);

    await tester.tap(find.byTooltip('Próxima semana'));
    await tester.pumpAndSettle();
    expect(
      find.text(diaPorExtenso(hoje.add(const Duration(days: 7)))),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Semana anterior'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Semana anterior'));
    await tester.pumpAndSettle();
    expect(
      find.text(diaPorExtenso(hoje.subtract(const Duration(days: 7)))),
      findsOneWidget,
    );
  });

  testWidgets('o botao de hoje volta para o dia de hoje', (tester) async {
    await abrirAgenda(tester);
    final hoje = DateTime.now();

    await tester.tap(find.byTooltip('Próxima semana'));
    await tester.pumpAndSettle();
    expect(find.text('Hoje'), findsOneWidget);

    await tester.tap(find.text('Hoje'));
    await tester.pumpAndSettle();
    expect(find.text(diaPorExtenso(hoje)), findsOneWidget);
    expect(find.text('Hoje'), findsNothing);
  });

  testWidgets('o calendario abre e leva para a data escolhida', (tester) async {
    await abrirAgenda(tester);

    await tester.tap(find.byTooltip('Escolher uma data'));
    await tester.pumpAndSettle();

    expect(find.text('Ir para uma data'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets('mostra o intervalo da semana que esta na tela', (tester) async {
    await abrirAgenda(tester);
    final dias = semanaDe(DateTime.now());

    final esperado = dias.first.month == dias.last.month
        ? '${dias.first.day} a ${dias.last.day} de ${mesPorExtenso(dias.last)}'
        : '${dias.first.day} de ${mesPorExtenso(dias.first)} a '
              '${dias.last.day} de ${mesPorExtenso(dias.last)}';

    expect(find.text(esperado), findsOneWidget);
  });
}
