import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart'; // ajusta según tu ruta
import '../models/categoria_model.dart';
import '../models/producto_model.dart';
import '../../api/api.cliente.dart';

class CatalogoService {
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _auth(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  Future<List<CategoriaModel>> getCategorias(String token) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiCliente.categorias}';
      final res = await http
          .get(Uri.parse(url), headers: _auth(token))
          .timeout(const Duration(seconds: 10));

      debugPrint('CATEGORIAS [${res.statusCode}]: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = _extractList(data, ['data', 'categorias']);
        return list.map((e) => CategoriaModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('ERROR getCategorias: $e');
      return [];
    }
  }

  Future<List<ProductoModel>> getProductos(String token, {int? categoriaId, String? busqueda}) async {
    try {
      final params = <String, String>{};
      if (categoriaId != null) params['id_categoria'] = categoriaId.toString();
      if (busqueda != null && busqueda.isNotEmpty) params['busqueda'] = busqueda;

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiCliente.productos}')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      final res = await http
          .get(uri, headers: _auth(token))
          .timeout(const Duration(seconds: 10));

      debugPrint('PRODUCTOS [${res.statusCode}]: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = _extractList(data, ['data', 'productos']);
        return list.map((e) => ProductoModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('ERROR getProductos: $e');
      return [];
    }
  }

  Future<ProductoModel?> getProductoDetalle(String token, int id) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiCliente.productoDetalle(id)}';
      final res = await http
          .get(Uri.parse(url), headers: _auth(token))
          .timeout(const Duration(seconds: 10));

      debugPrint('PRODUCTO_DETALLE [$id] [${res.statusCode}]: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final json = (data is Map && data['data'] != null) ? data['data'] : data;
        return ProductoModel.fromJson(json);
      }
      return null;
    } catch (e) {
      debugPrint('ERROR getProductoDetalle: $e');
      return null;
    }
  }

  List _extractList(dynamic data, List<String> keys) {
    if (data is List) return data;
    for (final key in keys) {
      if (data is Map && data[key] is List) return data[key];
    }
    return [];
  }
}