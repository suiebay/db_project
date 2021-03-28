import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/injection_container.dart';
import 'package:mds_reads/pages/config/cubit/config_cubit.dart';

class ConfigPage extends StatelessWidget {
  Box box = Hive.box('config');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF213A8F),
      body: SafeArea(
        child: BlocProvider<ConfigCubit>(
          create: (_) => getIt<ConfigCubit>()..getConfig(),
          child: BlocBuilder<ConfigCubit, ConfigState>(
            builder: (context, state) {
              if(state is ConfigLoading) {
                return SpinKitCircle(
                  color: Colors.white,
                  size: 40,
                );
              }
              if(state is ConfigFailure) {
                return Center(child: Text(state.message));
              }
              if(state is ConfigSuccess) {
                return Column(
                  children: [
                    Spacer(),
                    Expanded(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.configs.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              child: CupertinoButton(
                                padding: EdgeInsets.all(0),
                                pressedOpacity: 0.8,
                                onPressed: () {
                                  box.put('url', state.configs[index].url);
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: Container(
                                  height: 60,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6)
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${state.configs[index].title}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'RobotoMedium',
                                        fontSize: 20,
                                        color: Color(0xFF213A8F),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Spacer(),
                  ],
                );
              }
              return Offstage();
            }
          ),
        ),
      )
    );
  }
}
