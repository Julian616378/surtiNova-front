import 'package:flutter/material.dart';
import '../models/pedido_model.dart';
import '../services/pedido_service.dart';
import '../../catalogo/controllers/catalogo_controller.dart';

class PedidoController extends ChangeNotifier {
  final PedidoService _service = PedidoService();

  List<PedidoModel> pedidos = [];
  bool cargando = false;
  bool enviando = false;
  String? error;

  Future<PedidoModel?> confirmarPedido(
    String token,
    int idTienda,
    CatalogoController carritoCtrl,
  ) async {
    if (carritoCtrl.carrito.isEmpty) return null;

    enviando = true;
    error = null;
    notifyListeners();

    final items = carritoCtrl.carrito.entries
        .map(
          (e) => {
            'id_producto': e.key,
            'cantidad': e.value,
          },
        )
        .toList();

    final pedido = await _service.crearPedido(
      token,
      idTienda,
      items,
    );

    if (pedido != null) {
      carritoCtrl.carrito.clear();
      carritoCtrl.notifyListeners();
      pedidos.insert(0, pedido);
    } else {
      error = 'No se pudo crear el pedido. Intenta de nuevo.';
    }

    enviando = false;
    notifyListeners();
    return pedido;
  }

  Future<void> cargarPedidos(String token) async {
    cargando = true;
    notifyListeners();

    pedidos = await _service.getPedidos(token);

    cargando = false;
    notifyListeners();
  }
}