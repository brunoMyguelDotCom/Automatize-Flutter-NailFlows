import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/main.dart';
import 'package:nailsflow/widgets/cartao_atendimento.dart';

void main() {
  testWidgets('agenda do dia abre com os atendimentos de hoje', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NailsFlowApp(repositorio: AgendaRepositoryFalso(atraso: Duration.zero)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CartaoAtendimento), findsNWidgets(4));
    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.text('Molde F1'), findsOneWidget);
    expect(find.text('Confirmado'), findsNWidgets(2));
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Recusado'), findsOneWidget);
  });

  testWidgets('dia sem atendimento mostra o estado vazio', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      NailsFlowApp(repositorio: AgendaRepositoryFalso(atraso: Duration.zero)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Dia anterior'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Dia anterior'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum atendimento nesse dia'), findsOneWidget);
    expect(find.text('Hoje'), findsOneWidget);
  });
}
