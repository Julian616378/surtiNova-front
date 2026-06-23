import '../../api/api.cliente.dart';
import '../../../../core/services/api_service.dart';

class ProductoService {
  Future<dynamic> obtenerProductos({
    String buscar = '',
  }) async {
    String url = ApiCliente.productos;

    if (buscar.isNotEmpty) {
      url = "${ApiCliente.productos}?buscar=$buscar";
    }

    final response = await ApiService.get(url);

    return response.data;
  }
}