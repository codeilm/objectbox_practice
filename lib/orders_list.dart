import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_practice/entities.dart';

class OrdersList extends StatefulWidget {
  final List<ShopOrder> orders;
  final Store store;
  final void Function(int, bool) onSort;
  const OrdersList(
      {required this.orders, required this.store, required this.onSort});

  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: [
              DataColumn(label: Text('ID'), onSort: _onSort),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price'), onSort: _onSort),
              DataColumn(label: Text(''))
            ],
            rows: widget.orders
                .map((order) => DataRow(cells: [
                      DataCell(Text('${order.id}')),
                      DataCell(Text('${order.customer.target?.name}'),
                          onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Material(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: order.customer.target!.orders
                                      .map((_) => ListTile(
                                            leading: Text('${_.id}'),
                                            title: Text(
                                                '${_.customer.target!.name}'),
                                            trailing: Text('\$ ${_.price}'),
                                          ))
                                      .toList(),
                                ),
                              );
                            });
                      }),
                      DataCell(Text('${order.price}')),
                      DataCell(Icon(Icons.delete), onTap: () {
                        widget.store.box<ShopOrder>().remove(order.id);
                      }),
                    ]))
                .toList()),
      ),
    );
  }

  void _onSort(int index, bool ascending) {
    setState(() {
      _sortColumnIndex = index;
      _sortAscending = ascending;
      widget.onSort(index, ascending);
    });
  }
}
