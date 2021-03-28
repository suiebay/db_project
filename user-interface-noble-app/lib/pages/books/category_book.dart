import 'package:flutter/material.dart';
import 'package:mds_reads/drawer.dart';
import 'package:mds_reads/pages/books/booksList.dart';

class CategoryBook extends StatefulWidget {
  @override
  _CategoryBookState createState() => _CategoryBookState();
}

class _CategoryBookState extends State<CategoryBook> {
  String title;

  final categoryNum = [
    '1\'st',
    '2\'nd',
    '3\'rd',
    '4\'th',
    '5\'th',
    '6\'th',
    '7\'th',
    'Additional Books'
  ];

  List<Color> colors = [
    Colors.green[300],
    Colors.green[500],
    Colors.green[300],
    Colors.green[500],
    Colors.green[300],
    Colors.green[500],
    Colors.green[300],
    Colors.green[500],
    Colors.blue[300],
    Colors.blue[500],
    Colors.blue[300],
    Colors.blue[500],
    Colors.blue[300],
    Colors.blue[500],
    Colors.pink[300],
    Colors.pink[500]
  ];

  Map colorsMap = Map<String, dynamic>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            drawer: MyDrawer(),
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Color(0xFF213A8F),
              title: Text(
                'Books Category',
              ),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  margin:
                      EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                  child: ListView.builder(
                      itemCount: categoryNum.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 100,
                          width: double.maxFinite,
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    colors[index * 2],
                                    colors[index * 2 + 1]
                                  ]),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BooksList(
                                      fromCategory: categoryNum[index]),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Container(
                                margin: EdgeInsets.only(left: 1),
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(categoryNum[index],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontFamily: "RobotoBold",
                                            )),
                                        SizedBox(height: 10),
                                        Text("Grade",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontFamily: "RobotoMedium",
                                            ))
                                      ],
                                    ),
                                    Spacer(),
                                    Container(
                                      height: 80,
                                      color: Colors.transparent,
                                      child: Image.asset(index == 0
                                          ? 'assets/1.png'
                                          : index == 1
                                              ? 'assets/2.png'
                                              : index == 2
                                                  ? 'assets/3.png'
                                                  : index == 3
                                                      ? 'assets/4.png'
                                                      : index == 4
                                                          ? 'assets/5.png'
                                                          : index == 5
                                                              ? 'assets/6.png'
                                                              : index == 6
                                                                  ? 'assets/7.png'
                                                                  : 'assets/subject5.png'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
