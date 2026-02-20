import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_utils.dart';
import 'equb_package_model.dart';

part 'equb_group_model.g.dart';

@JsonSerializable()
class EqubGroupModel {
  @JsonKey(fromJson: JsonUtils.asString)
  final String? id;
  @JsonKey(fromJson: JsonUtils.asString)
  final String? name;
  @JsonKey(fromJson: JsonUtils.asStringNonNull)
  final String packageId;
  @JsonKey(fromJson: JsonUtils.asString)
  final String? status;
  @JsonKey(fromJson: JsonUtils.asDouble)
  final double? riskReserve;
  @JsonKey(fromJson: JsonUtils.asDateTime)
  final DateTime? startDate;
  @JsonKey(fromJson: JsonUtils.asInt)
  final int? currentCycle;
  @JsonKey(fromJson: JsonUtils.asInt)
  final int? memberCount;
  @JsonKey(fromJson: JsonUtils.asInt)
  final int? totalCycles;
  @JsonKey(name: 'EqubPackage')
  final EqubPackageModel? package;
  @JsonKey(fromJson: JsonUtils.asDateTime)
  final DateTime? createdAt;
  @JsonKey(fromJson: JsonUtils.asDateTime)
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
