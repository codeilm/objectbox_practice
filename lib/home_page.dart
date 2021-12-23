import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_practice/entities.dart';
import 'package:objectbox_practice/objectbox.g.dart';
import 'package:objectbox_practice/orders_list.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Store _store;
  late Customer _customer;
  late Stream<List<ShopOrder>> _stream;

  bool hasStoreInitialized = false;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      _store = Store(getObjectBoxModel(), directory: dir.path + '/mydb');
      setState(() {
        _stream = _store
            .box<ShopOrder>()
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find());
        hasStoreInitialized = true;
      });
    });
    _setNewCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store App'),
        actions: [
          IconButton(
              onPressed: _setNewCustomer, icon: Icon(CupertinoIcons.person)),
          IconButton(
              onPressed: _addOrder, icon: Icon(CupertinoIcons.money_dollar)),
        ],
      ),
      body: hasStoreInitialized
          ? StreamBuilder<List<ShopOrder>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return OrdersList(
                    orders: snapshot.data!,
                    store: _store,
                    onSort: (index, ascending) {
                      final queryBuilder = _store.box<ShopOrder>().query();
                      queryBuilder.order(
                          index == 0 ? ShopOrder_.id : ShopOrder_.price,
                          flags: ascending ? 0 : Order.descending);
                      setState(() {
                        _stream = queryBuilder
                            .watch(triggerImmediately: true)
                            .map((query) => query.find());
                      });
                    },
                  );
                } else {
                  return Center(child: Text('Loading Data ...'));
                }
              })
          : Center(child: Text('Initializing store')),
    );
  }

  void _setNewCustomer() {
    _customer = Customer(name: faker.person.firstName());
  }

  void _addOrder() {
    final ShopOrder _order =
        ShopOrder(price: faker.randomGenerator.integer(500, min: 100));
    _order.customer.target = _customer;
    _store.box<ShopOrder>().put(_order);
  }
}
