import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import 'receipt_translations.dart';

class ReceiptPdfService {
  static Future<Map<String, dynamic>?> fetchOrderDetails(int orderId) async {
    debugPrint('🔍 Starting fetchOrderDetails for orderId: $orderId');
    final url = Uri.parse('${Urls.baseUrl}/owner/orders/$orderId/');
    final token = await SharedPreferencesHelper.getAccessToken();

    debugPrint('🌐 URL: $url');
    debugPrint('🔑 Token: ${token?.substring(0, 20)}...');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Successfully fetched order details');
        debugPrint('📋 Order data: $data');
        return data;
      } else {
        debugPrint('❌ Error fetching order: ${response.statusCode}');
        debugPrint('❌ Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 Exception while fetching order: $e');
      return null;
    }
  }

  static Future<Uint8List> generateReceipt(
    Map<String, dynamic> orderData,
  ) async {
    debugPrint('📄 Starting PDF generation');
    debugPrint('📄 Order data keys: ${orderData.keys.toList()}');

    final pdf = pw.Document();

    // Get current language
    final languageCode = await SharedPreferencesHelper.getLanguage();
    final locale = languageCode.toLowerCase() == 'de' ? 'de' : 'en';
    final t = ReceiptTranslations(locale);
    debugPrint('🌍 Receipt language: $locale');

    final restaurant = orderData['restaurant'] ?? {};
    final orderItems = orderData['order_items'] as List? ?? [];

    debugPrint('🏪 Restaurant: ${restaurant['resturent_name']}');
    debugPrint('📦 Number of items: ${orderItems.length}');

    // Format date
    final createdAt = orderData['created_at'] != null
        ? DateTime.parse(orderData['created_at'])
        : DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

    debugPrint('📅 Order date: $formattedDate');
    debugPrint('👤 Customer: ${orderData['customer_name']}');
    debugPrint('💰 Total: ${orderData['total_price']}');

    // Generate QR code for website if available
    pw.ImageProvider? qrImage;
    if (restaurant['website'] != null &&
        restaurant['website'].toString().isNotEmpty) {
      try {
        final qrValidationResult = qr_flutter.QrValidator.validate(
          data: restaurant['website'],
          version: qr_flutter.QrVersions.auto,
          errorCorrectionLevel: qr_flutter.QrErrorCorrectLevel.L,
        );

        if (qrValidationResult.status == qr_flutter.QrValidationStatus.valid) {
          final qrCode = qrValidationResult.qrCode!;
          final painter = qr_flutter.QrPainter.withQr(
            qr: qrCode,
            gapless: true,
            embeddedImageStyle: null,
            embeddedImage: null,
          );

          final picData = await painter.toImageData(200);
          if (picData != null) {
            qrImage = pw.MemoryImage(picData.buffer.asUint8List());
            debugPrint('✅ QR code generated for website');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Failed to generate QR code: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          2.25 * PdfPageFormat.inch, // 80mm (3.15 inches) width
          double.infinity, // Auto height based on content
          marginAll: 10,
        ),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Restaurant Header
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        restaurant['resturent_name'] ?? 'Restaurant',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        restaurant['address'] ?? '',
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        restaurant['phone_number_1'] ?? '',
                        style: const pw.TextStyle(fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      ),
                      if (qrImage != null) ...[
                        pw.SizedBox(height: 6),
                        pw.Container(
                          width: 40,
                          height: 40,
                          child: pw.Image(qrImage),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          t.scanWebsite,
                          style: const pw.TextStyle(fontSize: 6),
                          textAlign: pw.TextAlign.center,
                        ),
                      ] else if (restaurant['website'] != null)
                        pw.Text(
                          restaurant['website'],
                          style: const pw.TextStyle(fontSize: 6),
                          textAlign: pw.TextAlign.center,
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),

                // Receipt Title
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    t.orderReceipt,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 6),

                // Order Info
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${t.order} #${orderData['id']}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${t.date}: $formattedDate',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${t.type}: ${t.getOrderType(orderData['order_type'] ?? '')}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${t.customer}: ${orderData['customer_name']}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${t.phone}: ${orderData['phone']}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${t.email}: ${orderData['email']}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),

                if (orderData['address'] != null)
                  pw.Text(
                    '${t.address}: ${orderData['address']}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),

                // Delivery Information
                if (orderData['delivery_area_json'] != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${t.getOrderType('delivery')}: ${orderData['delivery_area_json']['postalcode'] ?? ''}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  if (orderData['delivery_area_json']['estimated_delivery_time'] !=
                      null)
                    pw.Text(
                      'Est. Time: ${orderData['delivery_area_json']['estimated_delivery_time']} min',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                ],

                pw.SizedBox(height: 6),
                pw.Divider(),

                // Order Items Header
                pw.Text(
                  t.items,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.Divider(),

                // Order Items
                ...orderItems.map((item) {
                  final itemJson = item['item_json'] ?? {};
                  final itemName = itemJson['name'] ?? 'Unknown Item';
                  final quantity = item['quantity'] ?? 1;
                  final price =
                      double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                  final total = price * quantity;
                  final extras = item['extras']?.toString() ?? '';
                  final instructions =
                      item['special_instructions']?.toString() ?? '';

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '$quantity x $itemName',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                      if (extras.isNotEmpty && extras != 'no')
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4, top: 1),
                          child: pw.Text(
                            '+ $extras',
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ),
                      if (instructions.isNotEmpty && instructions != 'no')
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4, top: 1),
                          child: pw.Text(
                            '${t.note}: $instructions',
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                        ),
                      pw.SizedBox(height: 4),
                    ],
                  );
                }).toList(),

                pw.Divider(),
                pw.SizedBox(height: 4),

                // Calculate subtotal from items
                () {
                  double itemsSubtotal = 0.0;
                  for (var item in orderItems) {
                    final quantity = item['quantity'] ?? 1;
                    final price =
                        double.tryParse(item['price']?.toString() ?? '0') ??
                        0.0;
                    itemsSubtotal += price * quantity;
                  }

                  // Subtotal and Delivery Fee (if needed)
                  if (orderData['delivery_area_json'] != null &&
                      orderData['delivery_area_json']['delivery_fee'] != null) {
                    return pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              '${t.getOrderType('subtotal')}:',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                            pw.Text(
                              '\$${itemsSubtotal.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Delivery Fee:',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                            pw.Text(
                              '\$${orderData['delivery_area_json']['delivery_fee'].toString()}',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Divider(thickness: 1),
                        pw.SizedBox(height: 4),
                      ],
                    );
                  }
                  return pw.SizedBox.shrink();
                }(),

                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${t.totalLabel}:',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '\$${orderData['total_price'] ?? '0.00'}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 6),

                // Order Notes
                if (orderData['order_notes'] != null &&
                    orderData['order_notes'].toString().isNotEmpty)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Divider(),
                      pw.Text(
                        '${t.notes}:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        orderData['order_notes'],
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                      pw.SizedBox(height: 4),
                    ],
                  ),

                // Allergy Info
                if (orderData['allergy'] != null &&
                    orderData['allergy'].toString().isNotEmpty &&
                    orderData['allergy'].toString().toLowerCase() != 'no')
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${t.allergy}:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        orderData['allergy'],
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                      pw.SizedBox(height: 4),
                    ],
                  ),

                // Footer
                pw.Divider(),
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Column(
                    children: [
                      pw.Text(
                        t.thankYou,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${t.status}: ${t.getStatusText(orderData['status'] ?? '')}',
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printReceipt(int orderId) async {
    debugPrint('🖨️ Starting printReceipt for orderId: $orderId');

    try {
      // Fetch order details
      debugPrint('📥 Fetching order details...');
      final orderData = await fetchOrderDetails(orderId);

      if (orderData == null) {
        debugPrint('❌ Order data is null');
        throw Exception('Failed to fetch order details');
      }

      debugPrint('✅ Order data fetched successfully');

      // Generate PDF
      debugPrint('📄 Generating PDF...');
      final pdfBytes = await generateReceipt(orderData);
      debugPrint(
        '✅ PDF generated successfully, size: ${pdfBytes.length} bytes',
      );

      // Try to print or share PDF
      debugPrint('🖨️ Attempting to open print dialog...');

      try {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async {
            debugPrint('📐 Layout format: ${format.width}x${format.height}');
            return pdfBytes;
          },
        );
        debugPrint('✅ Print dialog opened successfully');
      } catch (printError) {
        debugPrint('⚠️ Print dialog failed: $printError');
        debugPrint('💾 Attempting to share PDF instead...');

        // Try sharing as fallback
        try {
          await Printing.sharePdf(
            bytes: pdfBytes,
            filename: 'order_${orderId}_receipt.pdf',
          );
          debugPrint('✅ PDF shared successfully');
        } catch (shareError) {
          debugPrint('❌ Share failed: $shareError');

          // Last resort: save to external storage and open
          debugPrint('💾 Attempting to save to external storage...');

          // Request storage permission for Android 12 and below
          if (Platform.isAndroid) {
            final status = await Permission.storage.request();
            debugPrint('📋 Storage permission status: $status');
          }

          // Get external storage directory (Downloads)
          Directory? directory;
          if (Platform.isAndroid) {
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              directory = await getExternalStorageDirectory();
            }
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          if (directory == null) {
            throw Exception('Could not access storage directory');
          }

          final fileName = 'order_${orderId}_receipt.pdf';
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);

          await file.writeAsBytes(pdfBytes);
          debugPrint('✅ PDF saved to: $filePath');

          // Try to open the PDF file
          try {
            debugPrint('📱 Opening PDF file...');
            final result = await OpenFile.open(filePath);
            debugPrint(
              '📱 Open file result: ${result.type} - ${result.message}',
            );

            if (result.type != ResultType.done) {
              throw Exception('Could not open PDF: ${result.message}');
            }
          } catch (openError) {
            debugPrint('⚠️ Could not open file: $openError');
            // File was saved but couldn't be opened - still a success
            throw Exception('PDF saved to Downloads folder: $fileName');
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('🚨 Error in printReceipt: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }
}
