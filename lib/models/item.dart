class Item {
  String? itmId;
  String? itmOwnerId;
  String? itmName;
  String? itmType;
  String? itmDes;
  String? itmPrice;
  String? itmQty;
  String? itmState;
  String? itmLocality;
  String? itmLatitude;
  String? itmLongitude;
  String? itmDate;

  Item(
      {this.itmId,
      this.itmOwnerId,
      this.itmName,
      this.itmType,
      this.itmDes,
      this.itmPrice,
      this.itmQty,
      this.itmState,
      this.itmLocality,
      this.itmLatitude,
      this.itmLongitude,
      this.itmDate});

  Item.fromJson(Map<String, dynamic> json) {
    itmId = json['itm_id'];
    itmOwnerId = json['itm_owner_id'];
    itmName = json['itm_name'];
    itmType = json['itm_type'];
    itmDes = json['itm_des'];
    itmPrice = json['itm_price'];
    itmQty = json['itm_qty'];
    itmState = json['itm_state'];
    itmLocality = json['itm_locality'];
    itmLatitude = json['itm_latitude'];
    itmLongitude = json['itm_longitude'];
    itmDate = json['itm_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['itm_id'] = itmId;
    data['itm_owner_id'] = itmOwnerId;
    data['itm_name'] = itmName;
    data['itm_type'] = itmType;
    data['itm_des'] = itmDes;
    data['itm_price'] = itmPrice;
    data['itm_qty'] = itmQty;
    data['itm_state'] = itmState;
    data['itm_locality'] = itmLocality;
    data['itm_latitude'] = itmLatitude;
    data['itm_longitude'] = itmLongitude;
    data['itm_date'] = itmDate;
    return data;
  }
}
