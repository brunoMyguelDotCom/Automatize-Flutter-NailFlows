import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nailsflow/modelos/agendamento.dart';
import 'package:nailsflow/modelos/cliente.dart';
import 'package:nailsflow/modelos/servico.dart';
import 'package:nailsflow/telas/aviso_whatsapp_page.dart';
import 'package:nailsflow/util/whatsapp.dart';

Agendamento _agendamento({String? telefone = '(44) 99812-4455'}) {
  return Agendamento(
    id: 'agd-1',
    cliente: Cliente(
      id: 'cli-1',
      nome: 'Julia R Merlos',
      email: 'julia@email.com',
      telefone: telefone,
    ),
    servico: Servico(id: 'svc-1', nome: 'Banho de Gel', duracaoMinutos: 90),
    inicio: DateTime(2026, 11, 7, 16),
    duracaoMinutos: 90,
  );
}

Future<void> _abrir(
  WidgetTester tester,
  Agendamento agendamento, {
  Future<bool> Function(Uri)? abrirLink,
}) async {
  tester.view.physicalSize = const Size(900, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: AvisoWhatsappPage(agendamento: agendamento, abrirLink: abrirLink),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('monta a mensagem com servico, dia da semana e hora', () {
    final texto = mensagemDeConfirmacao(_agendamento());

    expect(texto, startsWith('Cris Merlos\n'));
    expect(texto, contains('Oie Julia,'));
    expect(texto, contains('Banho de Gel em 07/11/2026 (sábado) às 16:00'));
    expect(texto, contains('1 - Confirmar\n2 - Cancelar'));
  });

  test('numero do WhatsApp leva o 55 e so digitos', () {
    expect(numeroParaWhatsapp('(44) 99812-4455'), '5544998124455');
    expect(numeroParaWhatsapp('+55 44 99812-4455'), '5544998124455');
    expect(numeroParaWhatsapp('9981'), isNull);
    expect(numeroParaWhatsapp(null), isNull);
  });

  test('link do WhatsApp leva o texto codificado', () {
    final link = linkDoWhatsapp('5544998124455', 'Oi, tudo bem?\n1 - Sim');

    expect(link.host, 'wa.me');
    expect(link.path, '/5544998124455');
    expect(link.queryParameters['text'], 'Oi, tudo bem?\n1 - Sim');
  });

  testWidgets('abre o WhatsApp com a mensagem editada', (tester) async {
    Uri? aberto;
    await _abrir(
      tester,
      _agendamento(),
      abrirLink: (uri) async {
        aberto = uri;
        return true;
      },
    );

    expect(find.textContaining('Oie Julia'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Oi Julia, confirma?');
    await tester.tap(find.text('Abrir no WhatsApp'));
    await tester.pumpAndSettle();

    expect(aberto?.path, '/5544998124455');
    expect(aberto?.queryParameters['text'], 'Oi Julia, confirma?');
  });

  testWidgets('sem telefone so deixa copiar', (tester) async {
    await _abrir(tester, _agendamento(telefone: null));

    expect(find.textContaining('não tem telefone completo'), findsOneWidget);
    final botao = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Abrir no WhatsApp'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );
    expect(botao.onPressed, isNull);
  });
}
