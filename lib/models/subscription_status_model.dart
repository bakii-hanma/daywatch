import 'plan_model.dart';

class UserSubscriptionStatusModel {
  final String? planId;
  final String? status;
  final String? endDate;
  final bool isTrialPeriod;
  final int daysRemaining;
  final int totalDays;
  final int daysUsed;
  final String? message;
  final PlanApiModel? plan;

  UserSubscriptionStatusModel({
    this.planId,
    this.status,
    this.endDate,
    this.isTrialPeriod = false,
    this.daysRemaining = 0,
    this.totalDays = 30,
    this.daysUsed = 0,
    this.message,
    this.plan,
  });

  factory UserSubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    PlanApiModel? parsedPlan;
    if (json['plan'] != null && json['plan'] is Map<String, dynamic>) {
      parsedPlan = PlanApiModel.fromJson(json['plan'] as Map<String, dynamic>);
    }

    return UserSubscriptionStatusModel(
      planId: json['planId']?.toString(),
      status: json['status']?.toString(),
      endDate: json['endDate']?.toString(),
      isTrialPeriod: json['isTrialPeriod'] == true ||
          json['isTrialPeriod'] == 1 ||
          json['isTrialPeriod']?.toString().toLowerCase() == 'true',
      daysRemaining: json['daysRemaining'] is int
          ? json['daysRemaining'] as int
          : int.tryParse(json['daysRemaining']?.toString() ?? '') ?? 0,
      totalDays: json['totalDays'] is int
          ? json['totalDays'] as int
          : int.tryParse(json['totalDays']?.toString() ?? '') ?? 30,
      daysUsed: json['daysUsed'] is int
          ? json['daysUsed'] as int
          : int.tryParse(json['daysUsed']?.toString() ?? '') ?? 0,
      message: json['message']?.toString(),
      plan: parsedPlan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'status': status,
      'endDate': endDate,
      'isTrialPeriod': isTrialPeriod,
      'daysRemaining': daysRemaining,
      'totalDays': totalDays,
      'daysUsed': daysUsed,
      'message': message,
      'plan': plan?.toJson(),
    };
  }
}
