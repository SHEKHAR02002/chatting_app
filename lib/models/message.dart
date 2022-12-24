class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createon;

  MessageModel(
      {this.messageid, this.sender, this.text, this.seen, this.createon});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createon = map["createon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createon": createon,
    };
  }
}
