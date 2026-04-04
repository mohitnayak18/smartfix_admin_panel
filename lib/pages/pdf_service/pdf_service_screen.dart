import 'dart:convert' show base64;
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class PDFService {
  
  Future<Uint8List?> generatePDFBytes(Map<String, dynamic> order) async {
    try {
      final pdfDoc = pw.Document(compress: true);

      // Load fonts
      pw.Font? regularFont;
      pw.Font? boldFont;

      try {
        final regularFontData = await rootBundle.load("assets/fonts/Poppins/Poppins-Regular.ttf");
        regularFont = pw.Font.ttf(regularFontData);
        
        final boldFontData = await rootBundle.load("assets/fonts/Poppins/Poppins-Bold.ttf");
        boldFont = pw.Font.ttf(boldFontData);
      } catch (e) {
        print("Font loading failed: $e");
      }

      // Helper functions
      String safe(dynamic value) {
        if (value == null) return 'N/A';
        if (value is String) return value.isEmpty ? 'N/A' : value;
        if (value is num) return value.toString();
        return value.toString();
      }

      String formatCurrency(dynamic amount) {
        if (amount == null) return '₹ 0.00';
        double value = amount is double ? amount : double.tryParse(amount.toString()) ?? 0;
        return '₹ ${value.toStringAsFixed(2)}';
      }

      String formatDate(dynamic dateValue) {
        if (dateValue == null) return 'N/A';
        
        try {
          DateTime? dateTime;
          
          if (dateValue is Timestamp) {
            dateTime = dateValue.toDate();
          } else if (dateValue is String) {
            dateTime = DateTime.parse(dateValue);
          } else if (dateValue is DateTime) {
            dateTime = dateValue;
          }
          
          if (dateTime != null) {
            return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
          }
        } catch (e) {
          print('Error formatting date: $e');
        }
        
        return dateValue.toString();
      }

      // Extract order details
      String orderId = safe(order['orderNumber'] ?? order['orderId'] ?? order['id'] ?? 'N/A');
      String customerName = safe(order['customerName'] ?? order['userName'] ?? order['name'] ?? 'Customer');
      String customerPhone = safe(order['customerPhone'] ?? order['phone'] ?? order['userPhone'] ?? 'N/A');
      String customerEmail = safe(order['customerEmail'] ?? order['email'] ?? order['userEmail'] ?? 'N/A');
      String orderDate = formatDate(order['createdAt'] ?? order['orderDate']);
      String orderStatus = safe(order['status'] ?? 'Pending');

      double totalAmount = 0;
      if (order['totalAmount'] is num) {
        totalAmount = (order['totalAmount'] as num).toDouble();
      } else if (order['finalAmount'] is num) {
        totalAmount = (order['finalAmount'] as num).toDouble();
      } else {
        totalAmount = double.tryParse(order['totalAmount']?.toString() ?? '0') ?? 0;
      }
      
      // Format address
      String billingAddress = 'N/A';
      if (order['address'] != null) {
        var addr = order['address'];
        if (addr is Map) {
          List<String> addressParts = [];
          if (addr['address'] != null && addr['address'].toString().isNotEmpty) 
            addressParts.add(addr['address']);
          if (addr['street'] != null && addr['street'].toString().isNotEmpty) 
            addressParts.add(addr['street']);
          if (addr['city'] != null && addr['city'].toString().isNotEmpty) 
            addressParts.add(addr['city']);
          if (addr['state'] != null && addr['state'].toString().isNotEmpty) 
            addressParts.add(addr['state']);
          if (addr['pincode'] != null && addr['pincode'].toString().isNotEmpty) 
            addressParts.add(addr['pincode']);
          
          billingAddress = addressParts.join(', ');
          if (billingAddress.isEmpty) billingAddress = addr.toString();
        } else {
          billingAddress = addr.toString();
        }
      }

      // Process items
      List items = order['items'] ?? [];
      List<pw.TableRow> itemRows = [];

      for (int index = 0; index < items.length; index++) {
        var item = items[index];
        
         String title = '';
  String serviceName = '';
  String model = '';
  
  if (item['title'] != null && item['title'].toString().isNotEmpty) {
    title = item['title'].toString();
  }
  
  if (item['serviceName'] != null && item['serviceName'].toString().isNotEmpty) {
    serviceName = item['serviceName'].toString();
  }
  
  if (item['model'] != null && item['model'].toString().isNotEmpty) {
    model = item['model'].toString();
  }

        int quantity = 1;
        if (item['quantity'] is num) {
          quantity = (item['quantity'] as num).toInt();
        } else if (item['qty'] is num) {
          quantity = (item['qty'] as num).toInt();
        }
        
        double price = 0;
        if (item['price'] is num) {
          price = (item['price'] as num).toDouble();
        } else if (item['unitPrice'] is num) {
          price = (item['unitPrice'] as num).toDouble();
        }
        
        double itemTotal = price * quantity;
        
        itemRows.add(
          pw.TableRow(
            decoration: index.isEven 
                ? pw.BoxDecoration(color: pdf.PdfColors.grey50)
                : pw.BoxDecoration(color: pdf.PdfColors.white),
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text('$title - $serviceName ($model)', style: const pw.TextStyle(fontSize: 10))),
              // pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(serviceName, style: const pw.TextStyle(fontSize: 10))),
              // pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(modelname, style: const pw.TextStyle(fontSize: 10))),
              pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(quantity.toString(), style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center)),
              pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(formatCurrency(price), style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
              pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(formatCurrency(itemTotal), style:  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
            ],
          ),
        );
      }

      // Calculate totals
      double subtotal = totalAmount / 1.1;
      double tax = totalAmount - subtotal;

      // Build PDF
      pdfDoc.addPage(
        pw.Page(
          pageFormat: pdf.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          theme: pw.ThemeData.withFont(
            base: regularFont ?? pw.Font.helvetica(),
            bold: boldFont ?? pw.Font.helveticaBold(),
          ),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "SMARTFIX TECHNOLOGY",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: pdf.PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Mobile Repair Service",
                      style: pw.TextStyle(fontSize: 10, color: pdf.PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(height: 1, width: double.infinity, color: pdf.PdfColors.grey300),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      "ORDER RECEIPT",
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: pdf.PdfColors.blue800),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 25),

              // Billed To & Receipt Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: pdf.PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("BILLED TO", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          pw.Text(customerName, style:  pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text(billingAddress, style: const pw.TextStyle(fontSize: 9)),
                          pw.Text("Phone: $customerPhone", style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: pdf.PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("RECEIPT INFO", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          _buildReceiptRow("ReceiptId #", orderId),
                          _buildReceiptRow("Date", orderDate),
                          _buildReceiptRow("Status", orderStatus.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Items Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: pdf.PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: const pw.BoxDecoration(
                        color: pdf.PdfColors.blue800,
                        borderRadius: pw.BorderRadius.only(topLeft: pw.Radius.circular(5), topRight: pw.Radius.circular(5)),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(flex: 3, child: pw.Text("DESCRIPTION", style:  pw.TextStyle(color: pdf.PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
                          pw.Expanded(flex: 1, child: pw.Text("Quantity", style:  pw.TextStyle(color: pdf.PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center)),
                          pw.Expanded(flex: 1, child: pw.Text("PRICE", style:  pw.TextStyle(color: pdf.PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right)),
                          pw.Expanded(flex: 1, child: pw.Text("TOTAL", style:  pw.TextStyle(color: pdf.PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    ),
                    pw.Table(columnWidths: {0: const pw.FlexColumnWidth(3), 1: const pw.FlexColumnWidth(1), 2: const pw.FlexColumnWidth(1), 3: const pw.FlexColumnWidth(1)}, children: itemRows),
                  ],
                ),
              ),

              pw.SizedBox(height: 15),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: pdf.PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      children: [
                        _buildTotalRow("Subtotal", formatCurrency(subtotal)),
                        _buildTotalRow("Tax (10%)", formatCurrency(tax)),
                        pw.Divider(),
                        _buildTotalRow("TOTAL", formatCurrency(totalAmount), isBold: true),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Simple Notes
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: pdf.PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                  color: pdf.PdfColors.grey50,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("NOTES", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "• 30-day warranty on all repairs\n"
                      "• Keep this receipt for warranty claims\n"
                      "• Backup your data before service\n\n"
                      "Thank you for choosing SmartFix Tech!",
                      style: const pw.TextStyle(fontSize: 9, height: 1.4),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 15),

              // Footer
              pw.Center(
                child: pw.Text(
                  "Contact: +91 98765 43210 | smartfixtech3@gmail.com",
                  style: pw.TextStyle(fontSize: 8, color: pdf.PdfColors.grey500),
                ),
              ),
            ],
          ),
        ),
      );

      return await pdfDoc.save();
      
    } catch (e) {
      print('PDF Generation Error: $e');
      return null;
    }
  }

  pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: pdf.PdfColors.grey600)),
          pw.Text(value, style:  pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: isBold ? 11 : 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: isBold ? 12 : 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: isBold ? pdf.PdfColors.green700 : pdf.PdfColors.black)),
        ],
      ),
    );
  }

  // Method to download PDF
  Future<void> generateAndSavePDF(Map<String, dynamic> order) async {
    final bytes = await generatePDFBytes(order);
    if (bytes == null) {
      Get.snackbar('Error', 'Failed to generate PDF', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    await _savePDF(bytes, order);
  }

  // Method to share PDF via WhatsApp
  // Add this method to share PDF via WhatsApp
Future<void> sharePDFViaWhatsApp(Map<String, dynamic> orderData, String phoneNumber) async {
  try {
    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final PDFService pdfService = PDFService();
    
    // Generate PDF
    final Uint8List? bytes = await pdfService.generatePDFBytes(orderData);
    
    if (bytes == null || bytes.isEmpty) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to generate PDF',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print("PDF Generated - Size: ${bytes.length} bytes");

    String orderId = orderData['orderId'] ?? orderData['orderNumber'] ?? 'ORDER';
    String customerName = orderData['customerName'] ?? orderData['userName'] ?? 'Customer';
    String totalAmount = orderData['finalAmount']?.toString() ?? '0';

    Get.back(); // Close loader

    // ================== DOWNLOAD PDF ==================
    
    // Create blob from PDF bytes
    final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create download link and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "receipt_$orderId.pdf")
      ..style.display = 'none';
    
    // Append to body, click, then remove
    html.document.body?.append(anchor);
    anchor.click();
    
    // Clean up
    Future.delayed(const Duration(milliseconds: 500), () {
      html.Url.revokeObjectUrl(url);
      anchor.remove();
    });

    print("PDF Download triggered for: receipt_$orderId.pdf");

    // ================== OPEN WHATSAPP ==================
    
    // Clean phone number
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (!cleanPhone.startsWith('91')) {
      cleanPhone = '91$cleanPhone';
    }

    // Create WhatsApp message
    String message = """
📱 *SmartFix Tech - Receipt*

Hello $customerName,

📋 Order ID: $orderId
💰 Amount: ₹$totalAmount

📎 Please attach the downloaded receipt PDF.

Thank you for choosing SmartFix Tech! 🙏
""";

    // Open WhatsApp
    final whatsappUrl = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
    
    await launchUrl(
      Uri.parse(whatsappUrl),
      mode: LaunchMode.externalApplication,
    );

    Get.snackbar(
      'Success',
      'PDF downloaded! Please attach it in WhatsApp',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
    
  } catch (e) {
    Get.back();
    print('WhatsApp Share Error: $e');
    Get.snackbar(
      'Error',
      'Failed to share: ${e.toString()}',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
  Future<void> _savePDF(Uint8List bytes, Map<String, dynamic> order) async {
    String orderId = order['orderId'] ?? order['id'] ?? 'ORDER';
    
    if (kIsWeb) {
      try {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..download = 'receipt_$orderId.pdf'
          ..style.display = 'none';
        
        html.document.body?.append(anchor);
        anchor.click();
        
        Future.delayed(const Duration(milliseconds: 100), () {
          html.Url.revokeObjectUrl(url);
          anchor.remove();
        });
        
        Get.snackbar(
          'Success',
          'Receipt downloaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        final base64Data = base64.encode(bytes);
        final dataUrl = 'data:application/pdf;base64,$base64Data';
        html.window.open(dataUrl, '_blank');
        
        Get.snackbar('Success', 'Receipt opened in new tab', backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/receipt_$orderId.pdf');
      await file.writeAsBytes(bytes);
      
      Get.snackbar('Success', 'Receipt saved to: ${file.path}', backgroundColor: Colors.white, colorText: Colors.black);
    }
  }
}