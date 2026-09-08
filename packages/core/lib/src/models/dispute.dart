import 'service_request.dart';

class Dispute {
  final String id;
  final String requestId;
  final String raisedBy;
  final String reason;
  final String status;
  final String? resolutionNote;
  final DateTime createdAt;
  final ServiceRequest? request;

  const Dispute({
    required this.id,
    required this.requestId,
    required this.raisedBy,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.resolutionNote,
    this.request,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) => Dispute(
        id: json['id'] as String,
        requestId: json['requestId'] as String,
        raisedBy: json['raisedBy'] as String,
        reason: json['reason'] as String,
        status: json['status'] as String,
        resolutionNote: json['resolutionNote'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        request: json['request'] != null ? ServiceRequest.fromJson(json['request'] as Map<String, dynamic>) : null,
      );
}
