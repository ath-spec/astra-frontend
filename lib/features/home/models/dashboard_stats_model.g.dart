// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeRevenue: (json['activeRevenue'] as num).toDouble(),
      pendingOrders: (json['pendingOrders'] as num).toInt(),
      systemHealth: (json['systemHealth'] as num).toDouble(),
      recentActivity: (json['recentActivity'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
  _$DashboardStatsImpl instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'activeRevenue': instance.activeRevenue,
  'pendingOrders': instance.pendingOrders,
  'systemHealth': instance.systemHealth,
  'recentActivity': instance.recentActivity,
};
