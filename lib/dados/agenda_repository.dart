import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../modelos/servico.dart';

abstract class AgendaRepository {
  Future<List<Agendamento>> listarAgendamentos({
    DateTime? inicio,
    DateTime? fim,
  });

  Future<List<Servico>> listarServicos();

  Future<List<Cliente>> listarClientes();

  Future<Cliente> criarCliente(Cliente cliente);

  Future<Cliente> atualizarCliente(String id, Cliente cliente);

  Future<void> excluirCliente(String id);
}
