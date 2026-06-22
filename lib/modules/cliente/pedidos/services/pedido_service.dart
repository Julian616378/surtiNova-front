import '../../../../core/services/api_service.dart';
import '../../api/api.cliente.dart';

class PedidoService {
  Future<void> crearPedido({
    required int idTienda,
    required List<Map<String, dynamic>> items,
  }) async {
    await ApiService.post(
      ApiCliente.pedidos,
      {
        "id_tienda": idTienda,
        "items": items,
      },
    );
  }
}