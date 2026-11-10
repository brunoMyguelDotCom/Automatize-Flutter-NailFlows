import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/dados/agenda_repository_api.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/modelos/agendamento.dart';
import 'package:nailsflow/modelos/cliente.dart';
import 'package:nailsflow/modelos/dados_do_agendamento.dart';
import 'package:nailsflow/modelos/servico.dart';
import 'package:nailsflow/telas/agendamento_form_page.dart';

/// Repositório que responde como a API quando o horário já está ocupado.
class _ApiComConflito extends AgendaRepositoryFalso {
  _ApiComConflito({required this.idNoErro, required this.existente})
    : super(atraso: Duration.zero, comAgendamentosDeExemplo: false);

  final String idNoErro;
  final Agendamento existente;

  @override
  Future<List<Agendamento>> listarAgendamentos({
    DateTime? inicio,
    DateTime? fim,
  }) async => [existente];

  @override
  Future<Agendamento> criarAgendamento(DadosDoAgendamento dados) async {
    throw FalhaDaApi(
      'Este horário coincide com um agendamento já existente (ID: $idNoErro)',
    );
  }
}

Future<void> _tentarMarcar(WidgetTester tester, _ApiComConflito api) async {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final amanha = DateTime.now().add(const Duration(days: 1));
  await tester.pumpWidget(
    MaterialApp(
      home: AgendamentoFormPage(repositorio: api, diaSugerido: amanha),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byType(DropdownButtonFormField<Cliente>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Renata Lima').last);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(DropdownButtonFormField<Servico>));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('Blindagem').last);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Marcar atendimento'));
  await tester.pumpAndSettle();
}

void main() {
  final amanha = DateTime.now().add(const Duration(days: 1));
  final existente = Agendamento(
    id: '640b4f3d-4990-4b6b-a1f6-86785de95c2e',
    cliente: Cliente(id: 'cli-9', nome: 'Julia Merlos', email: 'j@email.com'),
    servico: Servico(id: 'svc-9', nome: 'Banho de Gel', duracaoMinutos: 90),
    inicio: DateTime(amanha.year, amanha.month, amanha.day, 9),
    duracaoMinutos: 90,
  );

  testWidgets('conflito mostra o nome da cliente e o horario, sem o id', (
    tester,
  ) async {
    await _tentarMarcar(
      tester,
      _ApiComConflito(idNoErro: existente.id, existente: existente),
    );

    expect(
      find.text('Já existe atendimento de Julia das 09:00 às 10:30.'),
      findsOneWidget,
    );
    expect(find.textContaining('640b4f3d'), findsNothing);
  });

  testWidgets('sem achar o outro atendimento, esconde o id mesmo assim', (
    tester,
  ) async {
    await _tentarMarcar(
      tester,
      _ApiComConflito(idNoErro: 'outro-id', existente: existente),
    );

    expect(
      find.text('Esse horário coincide com outro atendimento.'),
      findsOneWidget,
    );
  });
}
