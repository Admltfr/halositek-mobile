import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:halositek/app/data/network/api_client.dart';
import 'package:halositek/app/data/models/payment.dart';
import 'package:halositek/app/data/models/consultation_status.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService(this._apiClient);

  Future<ConsultationCheckStatus> checkConsultationStatus(
      String architectId) async {
    final response = await _apiClient.private.get(
      '/consultations/$architectId/check-status',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    debugPrint('\x1B[31m CHECK STATUS: ${response.data}\x1B[0m');

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'];
      if (raw is! Map) {
        throw Exception('Invalid consultation check status response');
      }
      return ConsultationCheckStatus.fromJson(
          Map<String, dynamic>.from(raw));
    }, 'Check Consultation Status');
  }

  Future<Payment> initiate({required String architectId}) async {
    final response = await _apiClient.private.post(
      '/consultations/payments/initiate',
      data: {'architect_id': architectId},
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    debugPrint('\x1B[31m ${response.data['errors']}\x1B[0m');

    return _apiClient.customResponse(
      response,
      () async {
        final raw = response.data?['data'];
        if (raw is! Map) {
          throw Exception('Invalid payment initiation response');
        }
        return Payment.fromJson(Map<String, dynamic>.from(raw));
      },
      'Initiate Payment',
      isCreated: true,
    );
  }

  Future<PaymentStatus> getStatus(String paymentId) async {
    final response = await _apiClient.private.get(
      '/consultations/payments/$paymentId/status',
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    debugPrint('\x1B[31m ${response.data['data']}\x1B[0m');

    return _apiClient.customResponse(response, () async {
      final raw = response.data?['data'];
      if (raw is! Map) {
        throw Exception('Invalid payment status response');
      }
      return PaymentStatus.fromJson(Map<String, dynamic>.from(raw));
    }, 'Get Payment Status');
  }
}
