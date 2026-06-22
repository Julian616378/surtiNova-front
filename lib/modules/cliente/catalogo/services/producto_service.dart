import '../../api/api.cliente.dart';
import '../../../../core/services/api_service.dart';

class ProductoService {
  Future<dynamic> obtenerProductos() async {
    final response = await ApiService.get(
      ApiCliente.productos,
    );

    return response.data;
  }
}