import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mds_reads/pages/books/books_information.dart';
import 'package:mds_reads/pages/quiz/controllers/quiz_bloc/quiz_bloc.dart';

import '../../../injection_container.dart';

class QuizView extends StatefulWidget {
  final BooksInformation bookData;

  const QuizView({Key key, this.bookData}) : super(key: key);

  @override
  _QuizViewState createState() => _QuizViewState();
}

class GG {
  static int currentPage = 0;
}

class _QuizViewState extends State<QuizView> {
  CarouselController buttonCarouselController = CarouselController();


  int currentPage = 0;

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  Timer _timer;
  int _start = 1800;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = <Widget>[];

    buttons.clear();
    for(int i = 0; i < 20; i++) {
      buttons.add(
        InkWell(
          onTap: () {
            buttonCarouselController.jumpToPage(i);
          },
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
                color: currentPage == i ? Colors.white : Colors.grey[400].withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(3))
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontFamily: 'RobotoMedium',
                  fontSize: 15,
                  color: currentPage != i ? Colors.white : Color(0xFF213A8F),
                ),
              ),
            ),
          ),
        )
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF213A8F),
      body: Container(
        child: BlocProvider(
          create: (_) => getIt<QuizBloc>()..add(QuizLoaded(widget.bookData.bookId)),
          child: BlocConsumer<QuizBloc, QuizState>(
            listener: (context, state) {
              if (state is QuizSuccess) {
                // setState(() {
                //   hello(state.quiz.length);
                // });
              }
            },
            builder: (context, state) {
              if (state is QuizLoading) {
                return Center(child: CupertinoActivityIndicator(radius: 25,));
              }

              if (state is QuizFailure) {
                return Center(child: Text(state.message));
              }

              if (state is QuizSuccess) {
                return Column(
                  children: [
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: SafeArea(
                        bottom: false,
                        child: Stack(
                          children: [
                            Stack(
                              children: [
                                Container(height: 30, color: Color(0xFF213A8F)),
                                Container(
                                  height: 30,
                                  width: (MediaQuery.of(context).size.width - 96) / 1800 * (1800 - _start),
                                  decoration:  BoxDecoration(
                                    color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 30,
                              decoration:  BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                border: Border.all(color: Colors.white, width: 2),
                                color: Color(0xFF213A8F)
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 23,),
                                  Spacer(),
                                  // SizedBox(width: 5),
                                  Text(
                                    '${(_start ~/ 60).toString().length == 1 ? '0${_start ~/ 60}' : '${_start ~/ 60}'}:${(_start % 60).toString().length == 1 ? '0${_start % 60}' : '${_start % 60}'}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'RobotoBold',
                                        color: Colors.white
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 5,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 80,
                      child: GridView.count(
                        padding: EdgeInsets.all(0),
                        crossAxisCount: 10,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        children: buttons,
                      ),
                    ),
                    SizedBox(height: 16,),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      height: MediaQuery.of(context).size.height - 136 - MediaQuery.of(context).padding.top,
                      width: MediaQuery.of(context).size.width,
                      decoration:  BoxDecoration(
                          color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0))
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            Text(
                              widget.bookData.title,
                              style: TextStyle(
                                  fontSize: 26,
                                  fontFamily: 'RobotoMedium',
                                  color: Color(0xFF213A8F)
                              ),
                            ),
                            SizedBox(height: 10,),
                            CarouselSlider.builder(
                                carouselController: buttonCarouselController,
                                options: CarouselOptions(
                                    enlargeCenterPage: true,
                                    height: MediaQuery.of(context).size.height
                                        - 252 - MediaQuery.of(context).padding.vertical,
                                    viewportFraction: 1,
                                    enableInfiniteScroll: false,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        currentPage = index;
                                      });
                                    }
                                ),
                                itemCount: state.quiz.length,
                                itemBuilder: (context, index, realIndex) {
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 32,
                                            left: 16,
                                            right: 16,
                                            bottom: 16),
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              23, 40, 23, 40),
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          // height: MediaQuery.of(context).size.height / 2,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            //new Color.fromRGBO(255, 0, 0, 0.0),
                                            borderRadius: BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey[400],
                                                blurRadius: 5.0,
                                                offset: Offset(1.0,
                                                    1.0), // shadow direction: bottom right
                                              )
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  '${state.quiz[index].description}'
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        child: Container(
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/testOval.png',
                                                  height: 60,
                                                ),
                                                Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      fontFamily: 'RobotoMedium',
                                                      color: Color(0xFF213A8F)
                                                  ),
                                                )
                                              ],
                                            )
                                        ),
                                      ),
                                      Positioned(
                                        right: 16,
                                        top: 80,
                                        child: Container(
                                          height: 34,
                                          width: 82,
                                          decoration: BoxDecoration(
                                              color: Color(0xFF213A8F),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10.0),
                                                  bottomLeft: Radius.circular(10.0)
                                              )
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${state.quiz[index].type == 1 ? 2
                                                  : state.quiz[index].type == 2 ? 3
                                                  : state.quiz[index].type == 3 ? 5
                                                  : state.quiz[index].type == 4 ? 4
                                                  : state.quiz[index].type == 5 ? 4 : 0} Points',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontFamily: 'RobotoRegular'
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      buttonCarouselController.previousPage();
                                    },
                                    child: Container(
                                      height: 44,
                                      width: 125,
                                      decoration: BoxDecoration(
                                        color: Colors.white, //new Color.fromRGBO(255, 0, 0, 0.0),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey[400],
                                            blurRadius: 5.0,
                                            offset: Offset(1.0, 1.0), // shadow direction: bottom right
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_ios,
                                              color: Color(0xFF213A8F),
                                            ),
                                            Spacer(),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Previous",
                                                  style: TextStyle(
                                                      fontFamily: 'RobotoMedium',
                                                      color: Color(0xFF213A8F),
                                                      fontSize: 20
                                                  ),
                                                ),
                                                SizedBox(height: 2,),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      buttonCarouselController.nextPage();
                                    },
                                    child: Container(
                                      height: 44,
                                      width: 125,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF213A8F), //new Color.fromRGBO(255, 0, 0, 0.0),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey[100],
                                            blurRadius: 1.0, // shadow direction: bottom right
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(width: 25,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Next",
                                                  style: TextStyle(
                                                      fontFamily: 'RobotoMedium',
                                                      color: Colors.white,
                                                      fontSize: 20
                                                  ),
                                                ),
                                                SizedBox(height: 2,)
                                              ],
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }

              return Offstage();
            },
          ),
        ),
      ),
    );
  }
}

