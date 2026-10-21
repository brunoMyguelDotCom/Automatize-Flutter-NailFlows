import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/main.dart';
import 'package:nailsflow/modelos/cliente.dart';
import 'package:nailsflow/modelos/servico.dart';
import 'package:nailsflow/widgets/cartao_atendimento.dart';

Future<void> abrirPainel(
  WidgetTester tester, {
  bool comAgendamentos = true,
}) async {
  tester.view.physicalSize = const Size(1280, 1100);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    NailsFlowApp(
      fonte: FonteDeDados(
        repositorio: AgendaRepositoryFalso(
          atraso: Duration.zero,
          comAgendamentosDeExemplo: comAgendamentos,
        ),
        descricao: 'Dados de exemplo',
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> irParaAmanha(WidgetTester tester) async {
  final amanha = DateTime.now().add(const Duration(days: 1));
  await tester.tap(find.text('${amanha.day}').last);
  await tester.pumpAndSettle();
}

Future<void> escolherCliente(WidgetTester tester, String nome) async {
  await tester.tap(find.byType(DropdownButtonFormField<Cliente>));
  await tester.pumpAndSettle();
  await tester.tap(find.text(nome).last);
  await tester.pumpAndSettle();
}

Future<void> escolherServico(WidgetTester tester, String nome) async {
  await tester.tap(find.byType(DropdownButtonFormField<Servico>));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining(nome).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('marca um atendimento novo pelo botao', (tester) async {
    await abrirPainel(tester, comAgendamentos: false);
    await irParaAmanha(tester);

    await tester.tap(find.text('Novo atendimento'));
    await tester.pumpAndSettle();

    await escolherCliente(tester, 'Renata Lima');
    await escolherServico(tester, 'Blindagem');

    await tester.tap(find.text('Marcar atendimento'));
    await tester.pumpAndSettle();

    expect(find.text('Atendimento marcado'), findsOneWidget);
    expect(find.byType(CartaoAtendimento), findsOneWidget);
    expect(find.text('Renata Lima'), findsOneWidget);
  });

  testWidgets('avisa quando o horario ja esta ocupado', (tester) async {
    await abrirPainel(tester, comAgendamentos: false);
    await irParaAmanha(tester);

    await tester.tap(find.text('Novo atendimento'));
    await tester.pumpAndSettle();

    await escolherCliente(tester, 'Renata Lima');
    await escolherServico(tester, 'Blindagem');
    await tester.tap(find.text('Marcar atendimento'));
    await tester.pumpAndSettle();

    // deixa o aviso de confirmacao sumir antes de usar o botao de novo
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Novo atendimento'));
    await tester.pumpAndSettle();
    await escolherCliente(tester, 'Maria Silva');
    await escolherServico(tester, 'Blindagem');
    await tester.tap(find.text('Marcar atendimento'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Já existe atendimento'), findsOneWidget);
  });

  testWidgets('cancela um atendimento pelo detalhe', (tester) async {
    await abrirPainel(tester);
    final antes = find.byType(CartaoAtendimento).evaluate().length;

    await tester.tap(find.text('Maria Silva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('será removido'), findsOneWidget);
    await tester.tap(find.text('Cancelar atendimento').last);
    await tester.pumpAndSettle();

    expect(find.byType(CartaoAtendimento), findsNWidgets(antes - 1));
    expect(find.text('Maria Silva'), findsNothing);
  });

  testWidgets('cadastra e exclui um servico', (tester) async {
    await abrirPainel(tester);
    await tester.tap(find.text('Serviços').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Novo serviço'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do serviço'),
      'Spa dos pés',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Duração em minutos'),
      '45',
    );
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(find.text('Spa dos pés'), findsOneWidget);
    expect(find.text('Duração de 45min'), findsOneWidget);

    await tester.tap(find.text('Spa dos pés'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir serviço'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();

    expect(find.text('Spa dos pés'), findsNothing);
  });
}
