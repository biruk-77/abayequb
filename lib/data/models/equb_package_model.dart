import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_utils.dart';

part 'equb_package_model.g.dart';

enum EqubPackageStatus {
  @JsonValue('active') active,
  @JsonValue('completed') completed,
  @JsonValue('pending') pending,
}

enum EqubSchedule {
  @JsonValue('daily') daily,
  @JsonValue('weekly') weekly,
  @JsonValue('monthly') monthly,
}

@JsonSerializable()
class EqubPackageModel {
  @JsonKey(fromJson: asStringNonNull)
  final String id;
  @JsonKey(fromJson: asString)
  final String? name;
  @JsonKey(fromJson: asString)
  final String? iconPath;
  @JsonKey(fromJson: asDouble)
  final double? contributionAmount;
  final EqubSchedule? schedule;
  @JsonKey(fromJson: asInt)
  final int? groupSize;
  @JsonKey(fromJson: asDouble)
  final double? feePercentage;
  final EqubPackageStatus? status;
  @JsonKey(fromJson: asDouble)
  final double? targetAmount;
  @JsonKey(fromJson: asInt)
  final int? currentRound;

  EqubPackageModel({
    required this.id,
    this.name,
    this.iconPath,
    this.contributionAmount,
    this.schedule,
    this.groupSize,
    this.feePercentage,
    this.status = EqubPackageStatus.active,
    this.targetAmount,
    this.currentRound,
  });

  factory EqubPackageModel.fromJson(Map<String, dynamic> json) => _$EqubPackageModelFromJson(json);
  Map<String, dynamic> toJson() => _$EqubPackageModelToJson(this);
}
