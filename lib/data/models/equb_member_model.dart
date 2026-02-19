import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/json_utils.dart';

part 'equb_member_model.g.dart';

@JsonSerializable()
class EqubMemberModel {
  @JsonKey(fromJson: asString)
  final String? id;
  @JsonKey(fromJson: asStringNonNull)
  final String groupId;
  @JsonKey(fromJson: asStringNonNull)
  final String userId;
  @JsonKey(fromJson: asString)
  final String? status;
  @JsonKey(fromJson: asInt)
  final int? payoutOrder;
  @JsonKey(fromJson: asDateTime)
  final DateTime? joinedAt;

  EqubMemberModel({
    this.id,
    required this.groupId,
    required this.userId,
    this.status,
    this.payoutOrder,
    this.joinedAt,
  });

  factory EqubMemberModel.fromJson(Map<String, dynamic> json) => _$EqubMemberModelFromJson(json);
  Map<String, dynamic> toJson() => _$EqubMemberModelToJson(this);
}
