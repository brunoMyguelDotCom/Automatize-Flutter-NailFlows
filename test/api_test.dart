import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nailsflow/dados/agenda_repository_api.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/modelos/agendamento.dart';

const String agendamentoDaApi = '''
{
  "client": {"name": "Maria Silva", "email": "maria@email.com", "phone": "+55 44 99812-4455"},
  "service": "Molde F1",
  "start_time": "2026-10-20T14:00:00",
  "duration_minutes": 150,
  "sync_state": {"google_event_id": "google_5919f34d", "status": "Pending", "last_synced": null},
  "id": "fbce9c42-8430-4ef2-bc9e-7efb9adea481",
  "end_time": "2026-10-20T16:30:00"
}
''';

const String clienteDaApi = '''
{
  "name": "Maria Silva",
  "email": "maria@email.com",
  "phone": "+55 44 99812-4455",
  "id": "c5ee7e9d-1598-44a9-87fb-d4250685f3c8",
  "created_at": "2026-10-18T02:30:36.402919Z"
}
''';

void main() {
  test('entende o agendamento no formato que a API devolve hoje', () {
    final agendamento = Agendamento.fromJson(
      jsonDecode(agendamentoDaApi) as Map<String, dynamic>,
    );

    expect(agendamento.cliente.nome, 'Maria Silva');
    expect(agendamento.servico.nome, 'Molde F1');
    expect(agendamento.duracaoMinutos, 150);
    expect(agendamento.inicio.hour, 14);
    expect(agendamento.fim.hour, 16);
    expect(agendamento.fim.minute, 30);
    expect(agendamento.statusConvite, StatusConvite.pendente);
    expect(agendamento.situacao, SituacaoAtendimento.agendado);
  });

  test('lista agendamentos do dia mandando o filtro de data', () async {
    late Uri chamada;
    final repositorio = AgendaRepositoryApi(
      urlBase: 'http://localhost:8000',
      cliente: MockClient((requisicao) async {
        chamada = requisicao.url;
        return http.Response(
          '[$agendamentoDaApi]',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final lista = await repositorio.listarAgendamentos(
      inicio: DateTime(2026, 10, 20),
      fim: DateTime(2026, 10, 20, 23, 59, 59),
    );

    expect(chamada.path, '/agendamentos/');
    expect(chamada.queryParameters['start_date'], '2026-10-20T00:00:00.000');
    expect(chamada.queryParameters['end_date'], '2026-10-20T23:59:59.000');
    expect(lista, hasLength(1));
    expect(lista.first.cliente.primeiroNome, 'Maria');
  });

  test('lista clientes cadastradas na API', () async {
    final repositorio = AgendaRepositoryApi(
      urlBase: 'http://localhost:8000',
      cliente: MockClient((requisicao) async {
        return http.Response(
          '[$clienteDaApi]',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final clientes = await repositorio.listarClientes();

    expect(clientes, hasLength(1));
    expect(clientes.first.iniciais, 'MS');
    expect(clientes.first.telefone, '+55 44 99812-4455');
  });

  test('erro do servidor vira mensagem para a tela', () async {
    final repositorio = AgendaRepositoryApi(
      urlBase: 'http://localhost:8000',
      cliente: MockClient((requisicao) async {
        return http.Response(
          '{"detail": "Agendamento não encontrado"}',
          404,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    expect(
      () => repositorio.listarAgendamentos(),
      throwsA(
        isA<FalhaDaApi>().having(
          (e) => e.mensagem,
          'mensagem',
          'Agendamento não encontrado',
        ),
      ),
    );
  });

  test('usa a API quando ela responde', () async {
    final fonte = await escolherFonteDeDados(
      cliente: MockClient((requisicao) async {
        return http.Response('{"message": "ok"}', 200);
      }),
    );

    expect(fonte.ehApi, isTrue);
    expect(fonte.descricao, contains('API em'));
  });

  test('cai nos dados de exemplo quando a API nao responde', () async {
    final fonte = await escolherFonteDeDados(
      cliente: MockClient((requisicao) async {
        throw const SocketException('sem servidor');
      }),
    );

    expect(fonte.ehApi, isFalse);
    expect(fonte.repositorio, isA<AgendaRepositoryFalso>());
    expect(fonte.descricao, contains('não respondeu'));
  });
}
