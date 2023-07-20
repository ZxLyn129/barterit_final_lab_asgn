class OrderDetails {
  String? orderdetailId;
  String? orderBill;
  String? itemId;
  String? itemName;
  String? itemPrice;
  String? orderdetailQty;
  String? orderdetailPaid;
  String? buyerId;
  String? buyerName;
  String? sellerId;
  String? sellerName;
  String? orderStatus;
  String? deliveryAddress;
  String? orderdetailDate;
  String? orderShipDate;
  String? orderCompleteDate;

  OrderDetails(
      {this.orderdetailId,
      this.orderBill,
      this.itemId,
      this.itemName,
      this.itemPrice,
      this.orderdetailQty,
      this.orderdetailPaid,
      this.buyerId,
      this.buyerName,
      this.sellerId,
      this.sellerName,
      this.orderStatus,
      this.deliveryAddress,
      this.orderdetailDate,
      this.orderShipDate,
      this.orderCompleteDate});

  OrderDetails.fromJson(Map<String, dynamic> json) {
    orderdetailId = json['order_id'];
    orderBill = json['order_bill'];
    itemId = json['item_id'];
    itemName = json['itm_name'];
    itemPrice = json['itm_price'];
    orderdetailQty = json['order_qty'];
    orderdetailPaid = json['order_paid'];
    buyerId = json['buyer_id'];
    buyerName = json['buyer_name'];
    sellerId = json['seller_id'];
    sellerName = json['seller_name'];
    orderStatus = json['order_status'];
    deliveryAddress = json['delivery_address'];
    orderdetailDate = json['order_date'];
    orderShipDate = json['ship_date'];
    orderCompleteDate = json['complete_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderdetailId;
    data['order_bill'] = orderBill;
    data['item_id'] = itemId;
    data['itm_name'] = itemName;
    data['itm_price'] = itemPrice;
    data['order_qty'] = orderdetailQty;
    data['order_paid'] = orderdetailPaid;
    data['buyer_id'] = buyerId;
    data['buyer_name'] = buyerName;
    data['seller_id'] = sellerId;
    data['seller_name'] = sellerName;
    data['order_status'] = orderStatus;
    data['delivery_address'] = deliveryAddress;
    data['order_date'] = orderdetailDate;
    data['ship_date'] = orderShipDate;
    data['complete_date'] = orderCompleteDate;
    return data;
  }
}
