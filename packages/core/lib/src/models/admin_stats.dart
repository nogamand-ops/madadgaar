class AdminDashboardStats {
  final int activeRequests;
  final int onlineHelpers;
  final int todaysOrders;
  final int todaysRevenue;
  final int todaysCommission;
  final int completedJobsAllTime;
  final double cancellationRatePct;

  const AdminDashboardStats({
    required this.activeRequests,
    required this.onlineHelpers,
    required this.todaysOrders,
    required this.todaysRevenue,
    required this.todaysCommission,
    required this.completedJobsAllTime,
    required this.cancellationRatePct,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) => AdminDashboardStats(
        activeRequests: (json['activeRequests'] as num).toInt(),
        onlineHelpers: (json['onlineHelpers'] as num).toInt(),
        todaysOrders: (json['todaysOrders'] as num).toInt(),
        todaysRevenue: (json['todaysRevenue'] as num).toInt(),
        todaysCommission: (json['todaysCommission'] as num).toInt(),
        completedJobsAllTime: (json['completedJobsAllTime'] as num).toInt(),
        cancellationRatePct: (json['cancellationRatePct'] as num).toDouble(),
      );
}

/// Unit-economics view for the admin business-analytics screen.
/// Always clearly labeled as demo data — never presented as real traction.
class AdminAnalytics {
  final String period;
  final int orders;
  final int gmv;
  final int madadgaarRevenue;
  final int helperPayouts;
  final int averageOrderValue;
  final double averageResponseTimeMin;
  final double completionRatePct;
  final double cancellationRatePct;
  final double takeRatePct;
  final bool isDemoData;

  const AdminAnalytics({
    required this.period,
    required this.orders,
    required this.gmv,
    required this.madadgaarRevenue,
    required this.helperPayouts,
    required this.averageOrderValue,
    required this.averageResponseTimeMin,
    required this.completionRatePct,
    required this.cancellationRatePct,
    required this.takeRatePct,
    required this.isDemoData,
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) => AdminAnalytics(
        period: json['period'] as String,
        orders: (json['orders'] as num).toInt(),
        gmv: (json['gmv'] as num).toInt(),
        madadgaarRevenue: (json['madadgaarRevenue'] as num).toInt(),
        helperPayouts: (json['helperPayouts'] as num).toInt(),
        averageOrderValue: (json['averageOrderValue'] as num).toInt(),
        averageResponseTimeMin: (json['averageResponseTimeMin'] as num).toDouble(),
        completionRatePct: (json['completionRatePct'] as num).toDouble(),
        cancellationRatePct: (json['cancellationRatePct'] as num).toDouble(),
        takeRatePct: (json['takeRatePct'] as num).toDouble(),
        isDemoData: json['isDemoData'] as bool? ?? true,
      );
}

class HelperEarnings {
  final int today;
  final int week;
  final int total;
  final int completedJobs;
  final int availableBalance;

  const HelperEarnings({
    required this.today,
    required this.week,
    required this.total,
    required this.completedJobs,
    required this.availableBalance,
  });

  factory HelperEarnings.fromJson(Map<String, dynamic> json) => HelperEarnings(
        today: (json['today'] as num).toInt(),
        week: (json['week'] as num).toInt(),
        total: (json['total'] as num).toInt(),
        completedJobs: (json['completedJobs'] as num).toInt(),
        availableBalance: (json['availableBalance'] as num).toInt(),
      );
}
