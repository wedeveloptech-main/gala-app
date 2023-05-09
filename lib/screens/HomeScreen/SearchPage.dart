import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myapp/Models/SearchData.dart';
import 'package:myapp/constants/color.dart';
import 'package:myapp/screens/HomeScreen/SearchData.dart';
import 'package:myapp/services/api_service.dart';

/*class SearchPage extends StatefulWidget {
  final String product;
  const SearchPage({Key? key, required this.product}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  FetchSearchList _searchList = FetchSearchList();
  var query;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }


    @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SearchData>>(
        future: _searchList.getsearchList(query: query),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<SearchData>? data = snapshot.data;
          return ListView.builder(
              itemCount: data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${data?[index].data}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data?[index].data}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${data?[index].data}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ])
                    ],
                  ),
                );
              });
        });
}

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Search User'),
    );
  }
}*/

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  //late Future<SearchData> futureSearchDataModel;
  late Future<SearchData> futureSearchData;
  String searchString = "";
  final name = TextEditingController();
  final _searchKey = GlobalKey<FormState>();

  @override
  initState() {
    //futureSearchDataModel = fetchSearchDataModel();
    futureSearchData = fetchSearchData(String);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:  BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
      ),
      /*body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                  width: 1.sw - 20.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(11, 189, 180, 1),
                          style: BorderStyle.solid)),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Search your data',
                        contentPadding: EdgeInsets.all(15),
                        border: InputBorder.none),
                    onChanged: (value) {},
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) => _runFilter(value),
                  decoration: const InputDecoration(
                      labelText: 'Search', suffixIcon: Icon(Icons.search)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: _foundUsers.isNotEmpty
                      ? ListView.builder(
                    itemCount: _foundUsers.length,
                    itemBuilder: (context, index) => Card(
                      key: ValueKey(_foundUsers[index]["id"]),
                      color: Colors.amberAccent,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: Text(
                          _foundUsers[index]["id"].toString(),
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(_foundUsers[index]['name']),
                        subtitle: Text(
                            '${_foundUsers[index]["age"].toString()} years old'),
                      ),
                    ),
                  )
                      : const Text(
                    'No results found',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),*/
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 6.h,),
            Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: kblue
                ),
                width: 100.w,
                height: 5.h,
              ),
            ),
            SizedBox(height: 16.h,),
            /*TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),*/
            FutureBuilder<SearchData>(
                future: futureSearchData,
                builder: (context, snapshot) {
                  return Expanded(
                    child: Form(
                      key: _searchKey,
                      child: TextFormField(
                        controller: name,
                        textCapitalization: TextCapitalization.words,
                        autocorrect: true,
                        onChanged: (value) {},
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Value is required';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          if (_searchKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SearchDataList(
                                      nameHolder: name.text,

                                    ),
                              ),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Search here..",
                          hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                          fillColor: Colors.white,
                          filled: true,
                          suffixIcon: IconButton(
                              onPressed: () {
                                if (_searchKey.currentState!.validate()) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SearchDataList(
                                                nameHolder: name.text,))
                                  ).then((value) {
                                    // This code will run after the SearchDataList page is popped off the navigation stack
                                    name.clear();
                                  });
                                }
                              },
                              icon: Icon(Icons.search, size: 30.r, color: kblue,)),
                          //enabledBorder: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                width: 2, color: kgrey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                width: 2, color: kgrey),
                          ),
                          /*focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: kgrey,),
                            //borderRadius: BorderRadius.circular(50.0),
                          ),*/
                        ),
                      ),
                    ),
                  );
                }

            ),
            /*Expanded(
              child: FutureBuilder<SearchData>(
                future: futureSearchDataModel,
                builder: (context, snapshot) {
                  /*if (snapshot.hasData) {
      return Expanded(
        child: _foundUsers.isNotEmpty
              ? ListView.builder(
          itemCount: snapshot.data!.data.length,
          itemBuilder: (context, index) => Card(
              key: ValueKey(snapshot.data!.data[index].prodName.toString()),
              //color: Colors.amberAccent,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 35.r,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(snapshot.data!.data[index].thumb.toString(),),
                ),
                title: Text(snapshot.data!.data[index].prodName),
                /*subtitle: Text(
                            '${_foundUsers[index]["age"].toString()} years old'),*/
              ),
          ),
        )
              : const Text(
          'No results found',
          style: TextStyle(fontSize: 24),
        ),
      );
    }
    else if (snapshot.hasError) {
    return Text('${snapshot.error}');
    }

    // By default, show a loading spinner.
    return const Center(
    child: SizedBox(
    height: 50.0,
    width: 50.0,
    child: CircularProgressIndicator(),
    ),
    );*/
                  if (snapshot.hasData) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: snapshot.data!.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return snapshot.data!.data[index].prodName
                            .toLowerCase()
                            .contains(searchString)
                            ? ListTile(
                          leading: Image.network(
                            snapshot.data!.data[index].thumb.toString(),
                          height: 100.h,
                          width: 100.w,),
                          title: Text(snapshot.data!.data[index].prodName),
                        )
                            : Container();
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return snapshot.data!.data[index].prodName
                            .toLowerCase()
                            .contains(searchString)
                            ? Divider()
                            : Container();
                      },
                    );

                      /*ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data!.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return snapshot.data!.data[index].prodName
                              .toLowerCase()
                              .contains(searchString)
                              ? GestureDetector(
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (
                                      BuildContext context) {
                                    return Center(
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                            //padding: EdgeInsets.all(15),
                                            height: 300.h,
                                            width: MediaQuery.of(context).size.width * 0.9.w,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(5.r),
                                              child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
                                            )
                                        ),
                                      ),
                                    );
                                  });
                            },
                                child: ListTile(
                            leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  snapshot.data!.data[index].thumb.toString(),),
                            ),
                            title: Text(snapshot.data!.data[index].prodName),
                          ),
                              )
                              : Container();
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return snapshot.data!.data[index].prodName
                              .toLowerCase()
                              .contains(searchString)
                              ? Divider()
                              : Container();
                        },
                      );*/

                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  }
                  return const Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(),
                    ),
                  );
                },

                /*child: Expanded(
                  child: _foundUsers.isNotEmpty
                      ? ListView.builder(
                    itemCount: _foundUsers.length,
                    itemBuilder: (context, index) => Card(
                      key: ValueKey(_foundUsers[index]["id"]),
                      //color: Colors.amberAccent,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: Text(
                          _foundUsers[index]["id"].toString(),
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(_foundUsers[index]['name']),
                        /*subtitle: Text(
                            '${_foundUsers[index]["age"].toString()} years old'),*/
                      ),
                    ),
                  )
                      : const Text(
                    'No results found',
                    style: TextStyle(fontSize: 24),
                  ),
                ),*/
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}


//onTap: (){
//                             showDialog(
//                                 context: context,
//                                 builder: (
//                                     BuildContext context) {
//                                   return Center(
//                                     child: Material(
//                                       type: MaterialType.transparency,
//                                       child: Container(
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(10),
//                                             color: Colors.white,
//                                           ),
//                                           //padding: EdgeInsets.all(15),
//                                           height: 300.h,
//                                           width: MediaQuery.of(context).size.width * 0.9.w,
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(5.r),
//                                             child: Image.network(snapshot.data!.data[index].thumb.toString(), fit: BoxFit.cover,),
//                                           )
//                                       ),
//                                     ),
//                                   );
//                                 });
//                           },