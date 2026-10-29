import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/main.dart';

Future<void> abrirFormulario(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 1100);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    NailsFlowApp(
      fonte: FonteDeDados(
        repositorio: AgendaRepositoryFalso(
          atraso: Duration.zero,
          comAgendamentosDeExemplo: false,
        ),
        descricao: 'Dados de exemplo',
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Novo atendimento'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('o seletor de hora abre na digitacao, em 24 horas', (
    tester,
  ) async {
    await abrirFormulario(tester);

    await tester.tap(find.byIcon(Icons.schedule_rounded));
    await tester.pumpAndSettle();

    // no modo digitacao existem dois campos: hora e minuto
    expect(find.byType(TextField), findsNWidgets(2));
    // em 24 horas nao existe o seletor AM/PM
    expect(find.text('AM'), findsNothing);
    expect(find.text('PM'), findsNothing);
  });

  testWidgets('aceita um horario digitado em 24 horas', (tester) async {
    await abrirFormulario(tester);

    await tester.tap(find.byIcon(Icons.schedule_rounded));
    await tester.pumpAndSettle();

    final campos = find.byType(TextField);
    await tester.enterText(campos.first, '14');
    await tester.enterText(campos.last, '30');
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('14:30'), findsOneWidget);
    expect(find.textContaining('Valor inválido'), findsNothing);
  });
}
