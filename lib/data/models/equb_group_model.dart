import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_utils.dart';
import 'equb_package_model.dart';

part 'equb_group_model.g.dart';

@JsonSerializable()
class EqubGroupModel {
  @JsonKey(fromJson: asString)
  final String? id;
  @JsonKey(fromJson: asString)
  final String? name;
  @JsonKey(fromJson: asStringNonNull)
  final String packageId;
  @JsonKey(fromJson: asString)
  final String? status;
  @JsonKey(fromJson: asDouble)
  final double? riskReserve;
  @JsonKey(fromJson: asDateTime)
  final DateTime? startDate;
  @JsonKey(fromJson: asInt)
  final int? currentCycle;
  @JsonKey(fromJson: asInt)
  final int? memberCount;
  @JsonKey(fromJson: asInt)
  final int? totalCycles;
  @JsonKey(name: 'EqubPackage')
  final EqubPackageModel? package;
  @JsonKey(fromJson: asDateTime)
  final DateTime? createdAt;
  @JsonKey(fromJson: asDateTime)
  final DateTime? updatedAt;

  EqubGroupModel({
    this.id,
    this.name,
    required this.packageId,
    this.status,
    this.riskReserve,
    this.startDate,
    this.currentCycle,
    this.memberCount,
    this.totalCycles,
    this.package,
    this.createdAt,
    this.updatedAt,
  });

  factory EqubGroupModel.fromJson(Map<String, dynamic> json) =>
      _$EqubGroupModelFromJson(json);
  Map<String, dynamic> toJson() => _$EqubGroupModelToJson(this);
}
