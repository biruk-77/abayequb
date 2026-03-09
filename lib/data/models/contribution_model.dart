// lib/data/models/contribution_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_utils.dart';

part 'contribution_model.g.dart';

@JsonSerializable()
class ContributionModel {
  @JsonKey(fromJson: asInt)
  final int? id;
  @JsonKey(fromJson: asInt)
  final int? groupId;
  @JsonKey(fromJson: asInt)
  final int? userId;
  @JsonKey(fromJson: asInt)
  final int? cycleNumber;
  @JsonKey(fromJson: asDouble)
  final double? amount;
  @JsonKey(fromJson: asDateTime)
  final DateTime? dueDate;
  @JsonKey(fromJson: asDateTime)
  final DateTime? paidDate;
  @JsonKey(fromJson: asString)
  final String? status;
  @JsonKey(fromJson: asInt)
  final int? transactionId;
  @JsonKey(name: 'EqubGroup')
  final ContributionGroupInfo? groupInfo;
  @JsonKey(fromJson: asInt)
  final int? daysRemaining;

  ContributionModel({
    this.id,
    this.groupId,
    this.userId,
    this.cycleNumber,
    this.amount,
    this.dueDate,
    this.paidDate,
    this.status,
    this.transactionId,
    this.groupInfo,
    this.daysRemaining,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionModelToJson(this);
}

@JsonSerializable()
class ContributionGroupInfo {
  @JsonKey(fromJson: asInt)
  final int? id;
  @JsonKey(fromJson: asString)
  final String? name;

  ContributionGroupInfo({this.id, this.name});

  factory ContributionGroupInfo.fromJson(Map<String, dynamic> json) =>
      _$ContributionGroupInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionGroupInfoToJson(this);
}
