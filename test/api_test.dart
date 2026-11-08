import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nailsflow/dados/agenda_repository_api.dart';
import 'package:nailsflow/dados/agenda_repository_falso.dart';
import 'package:nailsflow/dados/fonte_de_dados.dart';
import 'package:nailsflow/modelos/agendamento.dart';
import 'package:nailsflow/modelos/cliente.dart';
import 'package:nailsflow/modelos/dados_do_agendamento.dart';
import 'package:nailsflow/modelos/servico.dart';

// Formato real de GET /agendamentos/ (back em 08/11/2026).
const String agendamentoDaApi = '''
{
  "service_id": "5abb0e39-46a4-4201-8b2d-045a14452db7",
  "start_time": "2026-10-20T17:00:00Z",
  "duration_minutes": 150,
  "id": "fbce9c42-8430-4ef2-bc9e-7efb9adea481",
  "client_id": "c5ee7e9d-1598-44a9-87fb-d4250685f3c8",
  "sync_state": {"google_event_id": "fbce9c4284304ef2", "status": "Pending", "last_synced": null},
  "active": true,
  "client": {"name": "Maria Silva", "email": "maria@email.com", "phone": "+55 44 99812-4455"},
  "service": {"id": "5abb0e39-46a4-4201-8b2d-045a14452db7", "name": "Molde F1", "duration_minutes": 150, "active": true},
  "end_time": "2026-10-20T19:30:00Z"
}
''';

const String servicoDaApi = '''
{"id": "5abb0e39-46a4-4201-8b2d-045a14452db7", "name": "Molde F1", "duration_minutes": 150, "active": true}
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
    final inicioEmUtc = DateTime.utc(2026, 10, 20, 17);

    expect(agendamento.cliente.nome, 'Maria Silva');
    expect(agendamento.cliente.id, 'c5ee7e9d-1598-44a9-87fb-d4250685f3c8');
    expect(agendamento.servico.nome, 'Molde F1');
    expect(agendamento.servico.id, '5abb0e39-46a4-4201-8b2d-045a14452db7');
    expect(agendamento.duracaoMinutos, 150);
    expect(agendamento.inicio.isUtc, isFalse);
    expect(agendamento.inicio, inicioEmUtc.toLocal());
    expect(
      agendamento.fim,
      inicioEmUtc.add(const Duration(minutes: 150)).toLocal(),
    );
    expect(agendamento.statusConvite, StatusConvite.pendente);
    expect(agendamento.situacao, SituacaoAtendimento.agendado);
  });

  test('agendamento com active false aparece como cancelado', () {
    final json = jsonDecode(agendamentoDaApi) as Map<String, dynamic>;
    json['active'] = false;

    expect(Agendamento.fromJson(json).situacao, SituacaoAtendimento.cancelado);
  });

  test('cria agendamento mandando so os ids', () async {
    late Map<String, dynamic> enviado;
    final repositorio = AgendaRepositoryApi(
      urlBase: 'http://localhost:8000',
      cliente: MockClient((requisicao) async {
        enviado = jsonDecode(requisicao.body) as Map<String, dynamic>;
        return http.Response(agendamentoDaApi, 201);
      }),
    );
    final servico = Servico.fromJson(
      jsonDecode(servicoDaApi) as Map<String, dynamic>,
    );

    await repositorio.criarAgendamento(
      DadosDoAgendamento(
        cliente: Cliente(
          id: 'cli-1',
          nome: 'Maria Silva',
          email: 'maria@email.com',
        ),
        servico: servico,
        inicio: DateTime(2026, 10, 20, 14),
        duracaoMinutos: servico.duracaoMinutos,
      ),
    );

    expect(enviado, {
      'client_id': 'cli-1',
      'service_id': '5abb0e39-46a4-4201-8b2d-045a14452db7',
      'start_time': '2026-10-20T14:00:00.000',
      'duration_minutes': 150,
    });
  });

  test('lista, cria e desativa servicos na API', () async {
    final chamadas = <String>[];
    final repositorio = AgendaRepositoryApi(
      urlBase: 'http://localhost:8000',
      cliente: MockClient((requisicao) async {
        chamadas.add('${requisicao.method} ${requisicao.url.path}');
        if (requisicao.method == 'GET') {
          return http.Response('[$servicoDaApi]', 200);
        }
        if (requisicao.method == 'DELETE') {
          return http.Response(
            '{"detail": "Serviço inativado com sucesso"}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        expect(jsonDecode(requisicao.body), {
          'name': 'Spa dos pés',
          'duration_minutes': 45,
          'active': true,
        });
        return http.Response(servicoDaApi, 201);
      }),
    );

    final servicos = await repositorio.listarServicos();
    await repositorio.criarServico(
      Servico(id: '', nome: 'Spa dos pés', duracaoMinutos: 45),
    );
    await repositorio.desativarServico(servicos.first.id);

    expect(servicos.single.nome, 'Molde F1');
    expect(chamadas, [
      'GET /servicos/',
      'POST /servicos/',
      'DELETE /servicos/5abb0e39-46a4-4201-8b2d-045a14452db7',
    ]);
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
