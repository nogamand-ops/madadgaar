import '../models/models.dart';
import 'api_client.dart';

/// Typed methods over [ApiClient]. Screens call this, never `ApiClient`
/// directly, so request/response shapes only ever need to change in one
/// place.
class MadadgaarApi {
  final ApiClient client;
  MadadgaarApi(this.client);

  // ---- auth ---------------------------------------------------------------
  Future<String> requestOtp(String phone) async {
    final res = await client.post('/api/auth/request-otp', body: {'phone': phone});
    return res['demoOtp'] as String;
  }

  Future<({String token, AppUser user})> verifyOtp({
    required String phone,
    required String otp,
    String? role,
    String? name,
  }) async {
    final res = await client.post('/api/auth/verify-otp', body: {
      'phone': phone,
      'otp': otp,
      if (role != null) 'role': role,
      if (name != null) 'name': name,
    });
    client.setToken(res['token'] as String);
    return (token: res['token'] as String, user: AppUser.fromJson(res['user'] as Map<String, dynamic>));
  }

  // ---- users / notifications ------------------------------------------------
  Future<AppUser> getUser(String id) async => AppUser.fromJson(await client.get('/api/users/$id'));

  Future<List<AppNotification>> notifications(String userId) async {
    final res = await client.get('/api/users/$userId/notifications') as List;
    return res.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markNotificationsRead(String userId) => client.post('/api/users/$userId/notifications/read-all');

  Future<List<Rating>> ratingsFor(String userId) async {
    final res = await client.get('/api/users/$userId/ratings') as List;
    return res.map((e) => Rating.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---- customers / vehicles -------------------------------------------------
  Future<CustomerProfile> customerProfile(String customerId) async =>
      CustomerProfile.fromJson(await client.get('/api/customers/$customerId'));

  Future<List<Vehicle>> vehicles(String customerId) async {
    final res = await client.get('/api/customers/$customerId/vehicles') as List;
    return res.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Vehicle> addVehicle(String customerId, Vehicle vehicle) async =>
      Vehicle.fromJson(await client.post('/api/customers/$customerId/vehicles', body: vehicle.toJson()));

  Future<void> removeVehicle(String customerId, String vehicleId) =>
      client.delete('/api/customers/$customerId/vehicles/$vehicleId');

  // ---- helpers ---------------------------------------------------------------
  Future<List<HelperProfile>> listHelpers({String? city, String? service, String? verificationStatus}) async {
    final res = await client.get('/api/helpers', query: {
      'city': city,
      'service': service,
      'verificationStatus': verificationStatus,
    }) as List;
    return res.map((e) => HelperProfile.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<HelperProfile> getHelper(String id) async => HelperProfile.fromJson(await client.get('/api/helpers/$id'));

  Future<HelperEarnings> helperEarnings(String id) async =>
      HelperEarnings.fromJson(await client.get('/api/helpers/$id/earnings'));

  Future<HelperProfile> registerHelper(Map<String, dynamic> body) async =>
      HelperProfile.fromJson(await client.post('/api/helpers', body: body));

  Future<HelperProfile> updateHelper(String id, Map<String, dynamic> patch) async =>
      HelperProfile.fromJson(await client.patch('/api/helpers/$id', body: patch));

  Future<HelperProfile> setHelperVerification(String id, String status) async =>
      HelperProfile.fromJson(await client.patch('/api/helpers/$id/verification', body: {'status': status}));

  Future<HelperEarnings> withdrawEarnings(String id, int amount) async =>
      HelperEarnings.fromJson(await client.post('/api/helpers/$id/withdraw', body: {'amount': amount}));

  // ---- cities / services -------------------------------------------------------
  Future<List<City>> cities() async {
    final res = await client.get('/api/cities') as List;
    return res.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<City> updateCity(String id, Map<String, dynamic> patch) async =>
      City.fromJson(await client.patch('/api/cities/$id', body: patch));

  Future<List<MadadgaarService>> services() async {
    final res = await client.get('/api/services') as List;
    return res.map((e) => MadadgaarService.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---- pricing -------------------------------------------------------------------
  Future<List<PricingRule>> pricingRules({String? cityId}) async {
    final res = await client.get('/api/pricing', query: {'cityId': cityId}) as List;
    return res.map((e) => PricingRule.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PricingRule> updatePricingRule(String cityId, String serviceKey, Map<String, dynamic> patch) async =>
      PricingRule.fromJson(await client.patch('/api/pricing/$cityId/$serviceKey', body: patch));

  Future<PriceEstimate> estimatePrice({
    required String cityId,
    required String serviceKey,
    required Map<String, dynamic> details,
    required double lat,
    required double lng,
  }) async =>
      PriceEstimate.fromJson(await client.post('/api/pricing/estimate', body: {
        'cityId': cityId,
        'serviceKey': serviceKey,
        'details': details,
        'location': {'lat': lat, 'lng': lng},
      }));

  // ---- requests --------------------------------------------------------------------
  Future<ServiceRequest> createRequest({
    required String serviceKey,
    required Map<String, dynamic> details,
    required double lat,
    required double lng,
    String? address,
    required String cityId,
    String? clientRequestId,
  }) async =>
      ServiceRequest.fromJson(await client.post('/api/requests', body: {
        'serviceKey': serviceKey,
        'details': details,
        'location': {'lat': lat, 'lng': lng, if (address != null) 'address': address},
        'cityId': cityId,
        if (clientRequestId != null) 'clientRequestId': clientRequestId,
      }));

  Future<ServiceRequest> getRequest(String id) async => ServiceRequest.fromJson(await client.get('/api/requests/$id'));

  Future<List<ServiceRequest>> listRequests({String? customerId, String? helperId, String? status}) async {
    final res = await client.get('/api/requests', query: {
      'customerId': customerId,
      'helperId': helperId,
      'status': status,
    }) as List;
    return res.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ServiceRequest> acceptRequest(String id) async => ServiceRequest.fromJson(await client.post('/api/requests/$id/accept'));

  Future<void> declineRequest(String id) => client.post('/api/requests/$id/decline');

  Future<ServiceRequest> retrySearch(String id) async => ServiceRequest.fromJson(await client.post('/api/requests/$id/retry-search'));

  Future<ServiceRequest> updateRequestStatus(String id, String status) async =>
      ServiceRequest.fromJson(await client.patch('/api/requests/$id/status', body: {'status': status}));

  Future<ServiceRequest> cancelRequest(String id, {required String cancelledBy, required String reason}) async =>
      ServiceRequest.fromJson(await client.post('/api/requests/$id/cancel', body: {'cancelledBy': cancelledBy, 'reason': reason}));

  // ---- chat --------------------------------------------------------------------------
  Future<List<ChatMessage>> messages(String requestId) async {
    final res = await client.get('/api/requests/$requestId/messages') as List;
    return res.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChatMessage> sendMessage(String requestId, String text, {bool isQuickMessage = false}) async =>
      ChatMessage.fromJson(await client.post('/api/requests/$requestId/messages', body: {'text': text, 'isQuickMessage': isQuickMessage}));

  // ---- rating / payment / disputes -----------------------------------------------------
  Future<Rating> submitRating(String requestId, {required String toUserId, required int stars, String review = ''}) async =>
      Rating.fromJson(await client.post('/api/requests/$requestId/rating', body: {'toUserId': toUserId, 'stars': stars, 'review': review}));

  Future<Payment> pay(String requestId, String method) async =>
      Payment.fromJson(await client.post('/api/requests/$requestId/payment', body: {'method': method}));

  Future<Payment?> getPayment(String requestId) async {
    try {
      return Payment.fromJson(await client.get('/api/requests/$requestId/payment'));
    } catch (_) {
      return null;
    }
  }

  Future<Payment> markCashCollected(String requestId) async =>
      Payment.fromJson(await client.post('/api/requests/$requestId/payment/mark-collected'));

  Future<Dispute> raiseDispute(String requestId, String reason) async =>
      Dispute.fromJson(await client.post('/api/requests/$requestId/disputes', body: {'reason': reason}));

  // ---- admin -----------------------------------------------------------------------------
  Future<AdminDashboardStats> adminDashboard() async => AdminDashboardStats.fromJson(await client.get('/api/admin/dashboard'));

  Future<AdminAnalytics> adminAnalytics({String period = 'today'}) async =>
      AdminAnalytics.fromJson(await client.get('/api/admin/analytics', query: {'period': period}));

  Future<List<dynamic>> adminCustomers() async => await client.get('/api/admin/customers') as List;

  Future<List<ServiceRequest>> adminRequests({String? status, String? cityId}) async {
    final res = await client.get('/api/admin/requests', query: {'status': status, 'cityId': cityId}) as List;
    return res.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Payment>> adminPayments() async {
    final res = await client.get('/api/admin/payments') as List;
    return res.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Dispute>> adminDisputes() async {
    final res = await client.get('/api/admin/disputes') as List;
    return res.map((e) => Dispute.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Dispute> resolveDispute(String id, {required String status, String? note}) async =>
      Dispute.fromJson(await client.patch('/api/admin/disputes/$id', body: {'status': status, 'resolutionNote': note}));
}
