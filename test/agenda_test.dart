import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/main.dart';
import 'package:nailsflow/widgets/cartao_atendimento.dart';

Future<void> abrirPainel(
  WidgetTester tester, {
  Size tamanho = const Size(1280, 950),
}) async {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    NailsFlowApp(repositorio: AgendaRepositoryFalso(atraso: Duration.zero)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('agenda do dia abre com os atendimentos de hoje', (tester) async {
    await abrirPainel(tester);

    expect(find.byType(CartaoAtendimento), findsNWidgets(4));
    expect(find.text('Maria Silva'), findsOneWidget);
    expect(find.textContaining('Molde F1'), findsWidgets);
    expect(find.text('Confirmado'), findsNWidgets(2));
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Recusado'), findsOneWidget);
  });

  testWidgets('nenhum valor em reais aparece na agenda', (tester) async {
    await abrirPainel(tester);

    expect(find.textContaining('R\$'), findsNothing);
  });

  testWidgets('tocar no cartao abre o detalhe do atendimento', (tester) async {
    await abrirPainel(tester);

    await tester.tap(find.text('Maria Silva'));
    await tester.pumpAndSettle();

    expect(find.text('Atendimento'), findsOneWidget);
    expect(find.text('Duração'), findsOneWidget);
    expect(find.text('maria.silva@email.com'), findsOneWidget);
  });

  testWidgets('a navegacao troca de area', (tester) async {
    await abrirPainel(tester);

    await tester.tap(find.text('Serviços').last);
    await tester.pumpAndSettle();
    expect(find.text('Duração de 2h30'), findsOneWidget);

    await tester.tap(find.text('Clientes').last);
    await tester.pumpAndSettle();
    expect(find.text('Patrícia Nunes'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cam');
    await tester.pumpAndSettle();
    expect(find.text('Camila Ferreira'), findsOneWidget);
    expect(find.text('Patrícia Nunes'), findsNothing);
  });

  testWidgets('tela estreita usa a barra inferior', (tester) async {
    await abrirPainel(tester, tamanho: const Size(420, 900));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });
}
