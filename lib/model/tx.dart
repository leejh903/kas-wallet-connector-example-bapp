class TransactionResult {
  final String from;
  final int gas;
  final String gasPrice;
  final String input;
  final int nonce;
  final String rlp;
  final String status;
  final String transactionHash;
  final int typeInt;
  final String value;
  final String to;

  TransactionResult({
    required this.to,
    required this.from,
    required this.gas,
    required this.gasPrice,
    required this.input,
    required this.nonce,
    required this.rlp,
    required this.status,
    required this.transactionHash,
    required this.typeInt,
    required this.value,
  });

  factory TransactionResult.fromJson(Map<String, dynamic> json) {
    return TransactionResult(
      from: json['from'],
      gas: json['gas'],
      gasPrice: json['gasPrice'],
      input: json['input'],
      nonce: json['nonce'],
      rlp: json['rlp'],
      status: json['status'],
      transactionHash: json['transactionHash'],
      typeInt: json['typeInt'],
      value: json['value'],
      to: json['to'],
    );
  }
}
