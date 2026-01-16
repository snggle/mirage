import 'package:equatable/equatable.dart';

abstract class AApiMethodDto extends Equatable {
  Map<String, dynamic> toJson();
}
