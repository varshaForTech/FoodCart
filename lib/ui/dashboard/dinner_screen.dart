import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodcart/models/MenuModel.dart';
import 'package:foodcart/utils/screen_utils/flutter_screenutil.dart';
import 'package:foodcart/utils/storage/Database.dart';

class Dinner extends StatefulWidget {

  final Function onUpdated; // CallBack Function

  Dinner({this.onUpdated});

  @override
  _DinnerState createState() => _DinnerState();
}

class _DinnerState extends State<Dinner> with AutomaticKeepAliveClientMixin<Dinner> {
  List<MenuItemModel> _menuItemList = List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    /*_menuItemList.add(MenuItemModel(
        image:
        "https://www.papithaskitchen.com/wp-content/uploads/2019/03/Erra-karam-dosa-1.jpg",
        description: "1 piece with chutny",
        itemName: "Karam Dosa",
        price: "20",
        itemCount: 0,
        time: "7:00 PM - 10:30 PM"));

    _menuItemList.add(MenuItemModel(
        image: "https://www.indianhealthyrecipes.com/wp-content/uploads/2016/09/cheese-dosai-recipe.jpg",
        description: "1 piece with cheese & ghee",
        itemName: "Special Dosa",
        price: "40",
        itemCount: 0,
        time: "7:00 PM - 10:30 PM"));

    _menuItemList.add(MenuItemModel(
        image:
        "https://udupi-recipes.com/wp-content/uploads/2013/12/set-dosa-recipe-1-500x375.jpg",
        description: "3 piece with chutny",
        itemName: "Set Dosa",
        price: "25",
        itemCount: 0,
        time: "7:00 PM - 10:30 PM"));

    _menuItemList.add(MenuItemModel(
        image:
        "https://i2.wp.com/www.vegrecipesofindia.com/wp-content/uploads/2016/07/curd-rice-5.jpg",
        description: "1 cup 200Grams rice with pickle",
        itemName: "Curd Rice",
        price: "25",
        itemCount: 0,
        time: "7:00 PM - 10:30 PM"));*/

    _loadInitialData();

    super.initState();
  }

  void _loadInitialData() async {
    setState(() {
      isApiLoading = true;
    });
    Firestore.instance
        .collection("MenuItems")
        .where("type", isEqualTo: "4")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      if (snapshot.documents.length > 0) {
        print("-----${snapshot.documents.length}");
        List<DocumentSnapshot> list = snapshot.documents;
        for (int i = 0; i < list.length; i++) {
          DocumentSnapshot document = list[i];
          print(document);
          _menuItemList.add(MenuItemModel.fromJson(document.data));
        }
      }

      setState(() {
        isApiLoading = false;
      });
    });

  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  bool isApiLoading = false;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 360, height: 760, allowFontScaling: true);

    return Scaffold(
      key: _scaffoldKey,
      body: isApiLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _menuItemList.length == 0
              ? Center(
                  child: Text("No Menu items available"),
                )
              : ListView.builder(
                  itemCount: _menuItemList.length,
                  itemBuilder: (context, index) {
                    return MenuItemRow(_menuItemList[index], callback: (bool value) {
                      if (value) {
                        _menuItemList[index].itemCount++;
                      } else {
                        _menuItemList[index].itemCount--;
                      }
                      _doDbOperations(_menuItemList[index],index, value);
                      setState(() {});
                      return value;
                    });
                  }),
    );
  }

  void _doDbOperations(MenuItemModel item,int index, bool value) async {
    List<Map<String, dynamic>> _selectedFav = new List();
    List<dynamic> _tempList = await DB.checkItem(item);
    if (_tempList.length <= 0) {
      // insert
      DB.insertMenuItem(item);
    } else {
      //update
      DB.updateItemValue(item);
    }

    List<Map<String, dynamic>> _checkList = await DB.checkItem(item);
    if (item.itemCount <= 0) {
      DB.deleteOneMenuItem(item);
    }

    setState(() {});
  }

}

typedef changeValue = bool Function(bool);

class MenuItemRow extends StatelessWidget {
  MenuItemModel _menuItemModel;
  changeValue callback;

  MenuItemRow(this._menuItemModel, {this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
        child: Container(
          decoration:
              BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
          width: double.maxFinite,
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200], borderRadius: BorderRadius.circular(10.w)),
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0.w),
                      child: CachedNetworkImage(
                        imageUrl: _menuItemModel.image,
                        fit: BoxFit.fill,
                        height: 100.h,
                        placeholder: (context, url) {
                          return Image.asset(
                            'images/food_place.png',
                            height: 60.h,
                            width: 60.w,
                            fit: BoxFit.scaleDown,
                          );
                        },
                      ),
                    ),
                  )),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _menuItemModel.itemName,
                        style: TextStyle(
                            color: Colors.black, fontSize: 20.ssp, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _menuItemModel.description,
                        style: TextStyle(fontSize: 15.ssp, color: Colors.teal),
                        maxLines: 2,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h, bottom: 2.h),
                        child: Text(
                          _menuItemModel.time,
                          style: TextStyle(fontSize: 13.ssp, color: Colors.orange),
                          maxLines: 1,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              "\u20B9 ${_menuItemModel.price}",
                              style: TextStyle(fontSize: 20.ssp, color: Colors.orange),
                              maxLines: 1,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                _menuItemModel.itemCount != 0
                                    ? IconButton(
                                        icon: new Icon(Icons.remove),
                                        onPressed: () {
                                          callback(false);
                                        })
                                    : new Container(),
                                Text(_menuItemModel.itemCount.toString()),
                                IconButton(
                                    icon: new Icon(Icons.add),
                                    onPressed: () {
                                      callback(true);
                                    }),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
