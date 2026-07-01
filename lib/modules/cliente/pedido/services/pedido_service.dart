import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../api/api.cliente.dart';
import '../models/pedido_model.dart';

class PedidoService {
  final _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _auth(String token) => {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

  Future<PedidoModel?> crearPedido(
    String token,
    int idTienda,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final body = jsonEncode({
        "id_tienda": idTienda,
        "items": items,
      });

      debugPrint("BODY: $body");

      final res = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiCliente.pedidos}'),
            headers: _auth(token),
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('CREAR_PEDIDO [${res.statusCode}]: ${res.body}');

    if (res.statusCode == 201) {
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  return PedidoModel.fromJson(data); // ✅ el JSON completo ES el pedido
}

      return null;
    } catch (e) {
      debugPrint('ERROR crearPedido: $e');
      return null;
    }
  }

  Future<List<PedidoModel>> getPedidos(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiCliente.pedidos}'),
            headers: _auth(token),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('GET_PEDIDOS [${res.statusCode}]: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['data'] as List? ?? [];
        return list.map((e) => PedidoModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('ERROR getPedidos: $e');
      return [];
    }
  }
}