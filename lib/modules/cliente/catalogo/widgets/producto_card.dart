import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../../shared/theme/app_theme.dart';

class ProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback  onTap;
  final VoidCallback  onAgregar;

  const ProductoCard({super.key, required this.producto, required this.onTap, required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0,2))]),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: producto.imagen != null
                ? Image.network(producto.imagen!, width: 72, height: 72, fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => _placeholder())
                : _placeholder(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textDark)),
                  if (producto.descripcion != null) ...[
                    const SizedBox(height: 2),
                    Text(producto.descripcion!, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 6),
                  Text('\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.priceOrange)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.stockGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(producto.enStock ? 'En stock' : 'Sin stock',
                      style: TextStyle(fontSize: 11, color: producto.enStock ? AppTheme.stockGreen : Colors.red, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            // Botón +
            GestureDetector(
              onTap: producto.enStock ? onAgregar : null,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: producto.enStock ? AppTheme.primary : Colors.grey[300], shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 72, height: 72, color: const Color(0xFFF0F0F0),
    child: const Icon(Icons.image, color: Colors.grey, size: 32),
  );
}