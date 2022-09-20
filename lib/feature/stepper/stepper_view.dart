import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tyrads/core/app_colors.dart';
import 'package:tyrads/widget/tyrads_texts.dart';

import '../../core/app_literals.dart';

class StepperView extends StatefulWidget {
  const StepperView({Key? key}) : super(key: key);

  @override
  StepperViewState createState() => StepperViewState();
}

class StepperViewState extends State<StepperView> {
  late StreamController currentStepController;
  StreamController nativeDataController = StreamController.broadcast();
  static const campaignChannel = MethodChannel(kChannel);
  late int _currentStep = 0;
  bool hasCampaign = false;
  bool hasGroup = false;
  bool hasAdd = false;

  @override
  void initState() {
    super.initState();
    currentStepController = StreamController<bool>.broadcast();
    currentStepController.sink.add(false);
    callMethodChannel(_currentStep);
  }

  @override
  Widget build(BuildContext context) {
    stepList() => [
          Step(
              isActive: hasCampaign,
              state: hasCampaign && _currentStep !=0 ?StepState.complete : StepState.indexed,
              title: TyrAdsText.subHeaderText(
                text: kSetting,
                fontSize: 14,
                color: _currentStep == 0 || hasCampaign ? APPColors.appBlack : APPColors.grey,
                fontWeight: FontWeight.bold,
              ),
              content: StreamBuilder(
                  stream: nativeDataController.stream,
                  builder: (context, snapshot) {
                    return TyrAdsText.headerText(
                      text: !snapshot.hasData ? '' : snapshot.data,
                      fontSize: 12,
                      textAlign: TextAlign.start,
                      color: APPColors.appBlack,
                    );
                  })),
          Step(
            isActive:hasGroup,
            state: hasGroup && _currentStep !=1? StepState.complete : StepState.indexed,
            title: TyrAdsText.subHeaderText(
              text: kGroup,
              fontSize: 14,
              color: _currentStep == 1 || hasGroup? APPColors.appBlack : APPColors.grey,
              fontWeight: FontWeight.bold,
            ),
            content: StreamBuilder(
                stream: nativeDataController.stream,
                builder: (context, snapshot) {
                  return TyrAdsText.headerText(
                      text: !snapshot.hasData ? '' : snapshot.data,
                      fontSize: 12,
                      textAlign: TextAlign.start,
                      color: APPColors.appBlack);
                }),
          ),
          Step(
              isActive: hasAdd,
              state: hasAdd && _currentStep !=2? StepState.complete : StepState.indexed,
              title: TyrAdsText.subHeaderText(
                text: kAdd,
                fontSize: 14,
                color: _currentStep == 2 || hasAdd ? APPColors.appBlack : APPColors.grey,
                fontWeight: FontWeight.bold,
              ),
              subtitle: TyrAdsText.subHeaderText(
                text: kLast,
                fontSize: 12,
                color: APPColors.grey,
                fontWeight: FontWeight.bold,
              ),
              content: StreamBuilder(
                  stream: nativeDataController.stream,
                  builder: (context, snapshot) {
                    return TyrAdsText.headerText(
                        text: !snapshot.hasData ? '' : snapshot.data,
                        fontSize: 12,
                        textAlign: TextAlign.start,
                        color: APPColors.appBlack);
                  }))
        ];

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: TyrAdsText.headerText(
              text: 'TyrAds',
              fontSize: 20,
            )),
        // Here we have initialized the stepper widget
        body: StreamBuilder(
            stream: currentStepController.stream,
            builder: (context, snapshot) {
              return Stepper(
                currentStep: _currentStep,
                onStepTapped: (int step) async {
                  currentStepController.sink.add(true);
                  _currentStep = step;
                  callMethodChannel(step);
                },
                steps: stepList(),
                controlsBuilder:
                    (BuildContext context, ControlsDetails controls) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: controls.onStepContinue,
                          child: TyrAdsText.subHeaderText(
                            text: kCONTINUE,
                            color: APPColors.appWhite,
                          ),
                        ),
                        TextButton(
                          onPressed: controls.onStepCancel,
                          child: TyrAdsText.subHeaderText(
                            text: kBACK,
                            color: _currentStep == 0
                                ? APPColors.greyText
                                : APPColors.appBlue,
                            fontWeight: _currentStep == 0
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onStepContinue: () {
                  if (_currentStep < stepList().length - 1) {
                    _currentStep += 1;
                  } else {
                    _currentStep = 0;
                  }
                  callMethodChannel(_currentStep);
                  currentStepController.sink.add(true);
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    _currentStep -= 1;
                  } else {
                    _currentStep = 0;
                  }
                  currentStepController.sink.add(true);
                },
              );
            }));
  }

  Future<void> getDataFromNativePlatform(String methodName) async {
    try {
      nativeDataController.sink
          .add(await campaignChannel.invokeMethod(methodName));
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
    }
  }

  callMethodChannel(int currentStep) {
    if (_currentStep == 0) {
      hasCampaign = true;
      getDataFromNativePlatform(kCampaignMethod);
    }
    if (_currentStep == 1) {
      hasCampaign = true;
      hasGroup = true;
      getDataFromNativePlatform(kGroupMethod);
    }
    if (_currentStep == 2) {
      hasGroup = true;
      hasAdd = true;

      getDataFromNativePlatform(kAddMethod);
    }
    setState(() {});
  }
}
