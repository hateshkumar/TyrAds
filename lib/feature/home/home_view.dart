import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tyrads/core/app_colors.dart';
import 'package:tyrads/widget/tyrads_texts.dart';

import '../../core/app_literals.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  late StreamController currentStepController;
  late StreamController currentStatusStepController;
  StreamController nativeDataController = StreamController.broadcast();
  static const campaignChannel = MethodChannel(kChannel);
  String currentContent = '';

  @override
  void initState() {
    super.initState();
    currentStepController = StreamController<int>.broadcast();
    currentStepController.sink.add(0);

    currentStatusStepController = StreamController<int>.broadcast();
    currentStatusStepController.sink.add(-1);

    callMethodChannel(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: TyrAdsText.headerText(
              text: 'TyrAds',
              fontSize: 20,
            )),
        // Here we have initialized the home widget
        body: StreamBuilder(
            stream: currentStepController.stream,
            initialData: 0,
            builder: (context, snapshot) {
              return StreamBuilder(
                  stream: currentStatusStepController.stream,
                  initialData: 0,
                  builder: (context, currentStatusSnapshot) {
                    return Container(
                      margin: EdgeInsets.only(
                          top: 30, left: MediaQuery.of(context).size.width / 8),
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildStepperTile(snapshot.data == 0, 0,
                                  currentStatusSnapshot.data > 1),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  callMethodChannel(0);
                                  currentStepController.sink.add(0);
                                  currentStatusStepController.sink.add(1);
                                },
                                child: buildContent(
                                    snapshot.data == 0,
                                    'Select campaign settings',
                                    snapshot.data, () {
                                  callMethodChannel(1);
                                  currentStepController.sink.add(
                                      snapshot.data == 2
                                          ? 0
                                          : snapshot.data! + 1);
                                  currentStatusStepController.sink.add(2);
                                }),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildStepperTile(snapshot.data == 1, 1,
                                  currentStatusSnapshot.data > 2),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  callMethodChannel(1);
                                  currentStepController.sink.add(1);
                                  currentStatusStepController.sink.add(2);
                                },
                                child: buildContent(snapshot.data == 1,
                                    'Create an ad group', snapshot.data, () {
                                  callMethodChannel(2);

                                  currentStepController.sink.add(
                                      snapshot.data == 2
                                          ? 0
                                          : snapshot.data! + 1);
                                  currentStatusStepController.sink.add(3);
                                }),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildStepperTile(snapshot.data == 2, 2,
                                  currentStatusSnapshot.data > 3),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  callMethodChannel(2);
                                  currentStepController.sink.add(2);
                                  currentStatusStepController.sink.add(3);
                                },
                                child: buildContent(snapshot.data == 2,
                                    'Create an ad', snapshot.data, () {
                                  callMethodChannel(0);
                                  currentStepController.sink.add(-1);
                                  currentStatusStepController.sink.add(4);
                                }, onBackPressed: () {
                                      callMethodChannel(2);
                                      currentStepController.sink.add(1);
                                  currentStatusStepController.sink.add(2);
                                }, subTitle: 'Last step'),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  });
            }));
  }

  Widget buildStepperTile(bool status, int? index, bool activeStatus) {
    return Container(
      child: Column(
        children: [
          Container(
            width: 25.0,
            height: 25.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: activeStatus || status
                  ? Colors.blueAccent
                  : Colors.grey.shade500,
            ),
            child: Center(
              child: activeStatus
                  ? Icon(
                      Icons.done,
                      size: 16,
                      color: APPColors.appWhite,
                    )
                  : Text((index! + 1).toString(),
                      style: TextStyle(color: Colors.white, fontSize: 14.0)),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Visibility(
              visible: index != 2,
              child: Container(
                width: 2,
                height: status
                    ? 'Today I planned to watch the match with my driver in the stadium instead of my kids. Normally we take our drivers and guards to the stadium but only to drop and pick us up back.'
                        .length
                        .toDouble()
                    : 20,
                color: Colors.grey.shade300,
              )),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget buildContent(
      bool status, String title, int? currentIndex, Function onContinuePressed,
      {String? subTitle, Function? onBackPressed}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TyrAdsText.subHeaderText(
          text: title,
          fontSize: 14,
          color: APPColors.appBlack,
          fontWeight: FontWeight.bold,
        ),
        subTitle != null
            ? TyrAdsText.subHeaderText(
                text: subTitle,
                fontSize: 14,
                color: APPColors.grey,
                fontWeight: FontWeight.bold,
              )
            : SizedBox.shrink(),
        SizedBox(height: 10),
        Visibility(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.70,
                child: StreamBuilder(
                    stream: nativeDataController.stream,
                    builder: (context, snapshot) {
                      return TyrAdsText.headerText(
                        text: currentContent,
                        fontSize: 14,
                        textAlign: TextAlign.start,
                        color: APPColors.appBlack,
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        onContinuePressed.call();
                      },
                      child: TyrAdsText.subHeaderText(
                        text: subTitle != null ? 'FINISH' : kCONTINUE,
                        color: APPColors.appWhite,
                      ),
                    ),
                    TextButton(
                      onPressed: onBackPressed == null
                          ? () {}
                          : () {
                              onBackPressed!.call();
                            },
                      child: TyrAdsText.subHeaderText(
                        text: kBACK,
                        color: subTitle != null
                            ? APPColors.appBlue
                            : APPColors.greyText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          visible: status,
        ),
      ],
    );
  }

  Future<void> getDataFromNativePlatform(String methodName) async {
    try {
      currentContent = await campaignChannel.invokeMethod(methodName);
      nativeDataController.sink
          .add(await campaignChannel.invokeMethod(methodName));

    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
    }
  }

  callMethodChannel(int currentStep) {
    if (currentStep == 0) {
      getDataFromNativePlatform(kCampaignMethod);
    }
    if (currentStep == 1) {
      getDataFromNativePlatform(kGroupMethod);
    }
    if (currentStep == 2) {
      getDataFromNativePlatform(kAddMethod);
    }
  }
}
