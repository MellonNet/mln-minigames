import "package:mln_shared/utils.dart";

class Attachment {
  final int itemID;
  final String name;
  final int qty;

  Attachment.fromJson(Json json) :
    itemID = json["item_id"],
    name = json["name"],
    qty = json["qty"];
}
