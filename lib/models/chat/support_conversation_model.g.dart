// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_conversation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupportConversationModelAdapter
    extends TypeAdapter<SupportConversationModel> {
  @override
  final int typeId = 20;

  @override
  SupportConversationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupportConversationModel(
      id: fields[0] as int,
      customerName: fields[1] as String,
      adminName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SupportConversationModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.adminName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportConversationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
