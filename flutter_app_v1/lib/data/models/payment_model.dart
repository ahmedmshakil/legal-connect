class PaymentModel {
  final String? id;
  final String? payerId;
  final String? payeeId;
  final String? meetingId;
  final double? amount;
  final String? status;
  final String? paymentMethod;
  final String? transactionId;
  final String? paymentDate;
  final String? releaseAt;
  final String? payerName;
  final String? payeeName;
  final String? createdAt;
  final String? updatedAt;

  PaymentModel({
    this.id,
    this.payerId,
    this.payeeId,
    this.meetingId,
    this.amount,
    this.status,
    this.paymentMethod,
    this.transactionId,
    this.paymentDate,
    this.releaseAt,
    this.payerName,
    this.payeeName,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString(),
      payerId: json['payerId']?.toString(),
      payeeId: json['payeeId']?.toString(),
      meetingId: json['meetingId']?.toString(),
      amount: json['amount']?.toDouble(),
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      paymentDate: json['paymentDate'],
      releaseAt: json['releaseAt'],
      payerName: json['payerName'],
      payeeName: json['payeeName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
