enum PaymentMethod { cod, easypaisa, jazzcash }

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cod => 'Cash on Delivery',
        PaymentMethod.easypaisa => 'Easypaisa',
        PaymentMethod.jazzcash => 'JazzCash',
      };

  String get wire => name;
}

class Payment {
  final String id;
  final String requestId;
  final String method;
  final String status; // pending | authorized | paid | failed | refunded
  final int amount;
  final bool simulated;
  final DateTime createdAt;
  final DateTime? paidAt;

  const Payment({
    required this.id,
    required this.requestId,
    required this.method,
    required this.status,
    required this.amount,
    required this.simulated,
    required this.createdAt,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        requestId: json['requestId'] as String,
        method: json['method'] as String,
        status: json['status'] as String,
        amount: (json['amount'] as num).toInt(),
        simulated: json['simulated'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
      );
}
