// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupportMessageModelAdapter extends TypeAdapter<SupportMessageModel> {
  @override
  final int typeId = 21;

  @override
  SupportMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupportMessageModel(
      id: fields[0] as int,
      senderType: fields[1] as String,
      senderId: fields[2] as int,
      message: fields[3] as String,
      fileUrl: fields[4] as String?,
      createdAt: fields[5] as String,
      senderName: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SupportMessageModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderType)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.fileUrl)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.senderName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
