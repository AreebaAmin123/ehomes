class DeliverySlotModel {
  final bool success;
  final List<DeliverySlot> slots;

  DeliverySlotModel({
    required this.success,
    required this.slots,
  });

  factory DeliverySlotModel.fromJson(Map<String, dynamic> json) {
    return DeliverySlotModel(
      success: json['success'] ?? false,
      slots: (json['slots'] as List<dynamic>?)
              ?.map((slot) => DeliverySlot.fromJson(slot))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'slots': slots.map((slot) => slot.toJson()).toList(),
    };
  }
}

class DeliverySlot {
  final String date;
  final String day;
  final int slotId;
  final String slotType;
  final String startTime;
  final String endTime;
  final String status;

  DeliverySlot({
    required this.date,
    required this.day,
    required this.slotId,
    required this.slotType,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory DeliverySlot.fromJson(Map<String, dynamic> json) {
    return DeliverySlot(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
      slotId: int.tryParse(json['slot_id']?.toString() ?? '0') ?? 0,
      slotType: json['slot_type'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'slot_id': slotId,
      'slot_type': slotType,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
    };
  }
}
