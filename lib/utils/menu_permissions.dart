import 'dart:convert';
import 'package:aswp/views/production/list_page.dart';
import 'package:aswp/views/production/return_allocation_detail.dart';
import 'package:aswp/views/production/return_detailt.dart';
import 'package:aswp/views/stock/allocation_warehouse_detail.dart';
import 'package:flutter/material.dart';
import 'package:aswp/views/production/picking_detail.dart';
import 'package:aswp/views/production/picking_page.dart';
import 'package:aswp/views/production/return_detail.dart';
import 'package:aswp/views/production/return_page.dart';
import 'package:aswp/views/production/warehousing_detail.dart';
import 'package:aswp/views/production/warehousing_page.dart';
import 'package:aswp/views/purchase/purchase_return_detail.dart';
import 'package:aswp/views/purchase/purchase_return_page.dart';
import 'package:aswp/views/purchase/purchase_warehousing_detail.dart';
import 'package:aswp/views/purchase/purchase_warehousing_page.dart';
import 'package:aswp/views/stock/allocation_detail.dart';
import 'package:aswp/views/stock/allocation_page.dart';
import 'package:aswp/views/stock/ex_warehouse_detail.dart';
import 'package:aswp/views/stock/ex_warehouse_page.dart';
import 'package:aswp/views/stock/other_Inventory_detail.dart';
import 'package:aswp/views/stock/other_warehousing_detail.dart';
import 'package:aswp/views/stock/other_warehousing_page.dart';
import 'package:aswp/views/stock/scheme_Inventory_detail.dart';
import 'package:aswp/views/stock/stock_page.dart';

class MenuPermissions {
  static void getMenu() async {}

  static getMenuChild(item) {
    var list = jsonDecode(item)[0];
    print(list);
    list.removeAt(0);
    list.removeAt(0);
    list.removeAt(0);
    list.removeAt(0);
    print(list.length);
    var menu = [];
    menu.add({
      "icon": Icons.loupe,
      "text": "生产订单",
      "parentId": 1,
      "color": Colors.pink.withOpacity(0.7),
      "router": ListPage(),
      "source": '',
    });
    // menu.add({
    //   "icon": Icons.loupe,
    //   "text": "生产入库",
    //   "parentId": 1,
    //   "color": Colors.pink.withOpacity(0.7),
    //   "router": WarehousingPage(),
    //   "source": '',
    // });
    menu.add({
      "icon": Icons.loupe,
      "text": "生产领料",
      "parentId": 1,
      "color": Colors.pink.withOpacity(0.7),
      "router": PickingPage(),
      "source": '',
    });
    // menu.add({
    //   "icon": Icons.loupe,
    //   "text": "生产退料(有源单)",
    //   "parentId": 1,
    //   "color": Colors.pink.withOpacity(0.7),
    //   "router": ReturnPage(),
    //   "source": '',
    // });
    menu.add({
      "icon": Icons.loupe,
      "text": "生产退料",
      "parentId": 1,
      "color": Colors.pink.withOpacity(0.7),
      "router": ReturnAllocationDetail(),
      "source": '',
    }); menu.add({
      "icon": Icons.loupe,
      "text": "采购入库",
      "parentId": 5,
      "color": Colors.pink.withOpacity(0.7),
      "router": PurchaseWarehousingPage(),
      "source": '',
    });
    // menu.add({
    //   "icon": Icons.loupe,
    //   "text": "采购退货(有源单)",
    //   "parentId": 5,
    //   "color": Colors.pink.withOpacity(0.7),
    //   "router": PurchaseReturnPage(),
    //   "source": '',
    // });
    menu.add({
      "icon": Icons.loupe,
      "text": "采购退货",
      "parentId": 5,
      "color": Colors.pink.withOpacity(0.7),
      "router": PurchaseReturnDetail(),
      "source": '',
    }); menu.add({
      "icon": Icons.loupe,
      "text": "其他入库",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": OtherWarehousingDetail(),
      "source": '',
    });
    menu.add({
      "icon": Icons.loupe,
      "text": "其他出库",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": ExWarehouseDetail(),
      "source": '',
    });
    // menu.add({
    //   "icon": Icons.loupe,
    //   "text": "其他出库(有源单)",
    //   "parentId": 3,
    //   "color": Colors.pink.withOpacity(0.7),
    //   "router": ExWarehousePage(),
    //   "source": '',
    // });
    menu.add({
      "icon": Icons.loupe,
      "text": "调拨出库(有源单)",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": AllocationPage(),
      "source": '',
    });
    menu.add({
      "icon": Icons.loupe,
      "text": "调拨出库(无源单)",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": AllocationDetail(),
      "source": '',
    });
    menu.add({
      "icon": Icons.loupe,
      "text": "调拨入库",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": AllocationWarehouseDetail(),
      "source": '',
    });
    menu.add({
      "icon": Icons.loupe,
      "text": "方案盘点",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": SchemeInventoryDetail(),
      "source": '',
    });
    menu.add({
      "icon": Icons.loupe,
      "text": "库存查询",
      "parentId": 3,
      "color": Colors.pink.withOpacity(0.7),
      "router": StockPage(),
      "source": '',
    });
    // menu.add({
    //   "icon": Icons.loupe,
    //   "text": "现场盘点",
    //   "parentId": 3,
    //   "color": Colors.pink.withOpacity(0.7),
    //   "router": OtherInventoryDetail(),
    //   "source": '',
    // });
    return menu;
  }
}
