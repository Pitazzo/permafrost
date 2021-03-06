import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:permafrost/core/enums/order_critera.dart';
import 'package:permafrost/core/models/fridge/compartment.dart';
import 'package:permafrost/core/models/fridge/item.dart';

import 'package:permafrost/core/redux/app_state.dart';
import 'package:permafrost/ui/widgets/items/item_list.dart';

class ItemListConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
        model: ViewModel(),
        builder: (context, model) {
          return ItemList(items: model.items, compartments: model.compartments);
        });
  }
}

class ViewModel extends BaseModel<AppState> {
  ViewModel();

  List<Item> items;
  List<Compartment> compartments;

  ViewModel.buid({@required this.items, @required this.compartments})
      : super(equals: [items, compartments]);

  @override
  BaseModel fromStore() {
    List<Item> items = state.fridge.items.toList();
    if (state.searchCriteria.trim() != "") {
      items = items
          .where((item) => item.name
              .toLowerCase()
              .contains(state.searchCriteria.toLowerCase()))
          .toList();
    }
    Function(Item, Item) sortFunction;
    switch (state.orderCritera) {
      case OrderCriteria.ALPHABETIC:
        sortFunction = (item1, item2) => item1.name.compareTo(item2.name);
        break;
      case OrderCriteria.ENTRY_DATE:
        sortFunction = (item1, item2) {
          if (item1.entryDate.isAfter(item2.entryDate)) {
            return 1;
          }
          return -1;
        };
        break;
      case OrderCriteria.EXPIRY_DATE:
        sortFunction = (item1, item2) {
          if (item1.expiryDate.isAfter(item2.expiryDate)) {
            return 1;
          }
          return -1;
        };
        break;
    }

    items.sort(sortFunction);

    return ViewModel.buid(
        compartments: state.fridge.compartments, items: items);
  }
}
