import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:suprsend_flutter_sdk/suprsend.dart';
import 'package:suprsend_flutter_sdk/log_levels.dart';
// import 'package:uni_links/uni_links.dart';

import 'package:suprsend_flutter_inbox/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suprsend_flutter_inbox/store.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _userId = "";
  String? _subsId;

  var _propertyKey = "";
  var _propertyValue = "";
  var _propertyDistinctId = "";
  var _propertyMobileNumber = "";
  var _propertyEmail = "";

  final propKeyController = TextEditingController();
  final propValueController = TextEditingController();
  final propDistinctIdController = TextEditingController();
  final propMobileNumberController = TextEditingController();
  final propEmailController = TextEditingController();

  final _userLoginFormKey = GlobalKey<FormState>();
  final _userPropertySetUnsetFormKey = GlobalKey<FormState>();
  final _userMobileFormKey = GlobalKey<FormState>();
  final _userEmailFormKey = GlobalKey<FormState>();

  late final StreamSubscription _linkSub;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    propKeyController.addListener(() {
      _propertyKey = propKeyController.text.toString();
    });

    propValueController.addListener(() {
      _propertyValue = propValueController.text.toString();
    });

    propDistinctIdController.addListener(() {
      _propertyDistinctId = propDistinctIdController.text.toString();
    });

    propMobileNumberController.addListener(() {
      _propertyMobileNumber = propMobileNumberController.text.toString();
    });

    propEmailController.addListener(() {
      _propertyEmail = propEmailController.text.toString();
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    await initUniLinks();

    suprsend.setLogLevel(LogLevels.VERBOSE);

    var hashMap = HashMap<String, Object>();
    hashMap["flutter_runtime_version"] = Platform.version.replaceAll("\"", "'");
    suprsend.setSuperProperties(hashMap);

    var countsMap = HashMap<String, int>();
    countsMap["app_open_count"] = 1;

    suprsend.user.increment(countsMap);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> initUniLinks() async {
    // ... check initialLink
    // try {
    // final initialLink = await getInitialLink();
    // Parse the link and warn the user, if it is not correct,
    // but keep in mind it could be `null`.
    // if (initialLink != null) {
    // print("Initial Link received: $initialLink");
    // }
    // } on PlatformException catch (exception) {
    // Handle exception by warning the user their action did not succeed
    // print("Initial Link error occurred: $exception");
    // }

    // Attach a listener to the stream
    // _linkSub = linkStream.listen((String? link) {
    //   // Parse the link and warn the user, if it is not correct
    //   if (link != null) {
    //     print("Link stream event received: $link");
    //   }
    // }, onError: (err) {
    //   // Handle exception by warning the user their action did not succeed
    //   print("Link stream event error occurred: $err");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SuprSendProvider(
        workspaceKey: "your workspace key",
        workspaceSecret: "your workspace secret",
        distinctId: "distinct id",
        subscriberId: "subscriber id",
        child: MaterialApp(
            home: Scaffold(
          appBar: AppBar(
            title: Text('Suprsend Client App: $_platformVersion'),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: _userPropertySetUnsetFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(children: const <Widget>[
                    Expanded(
                        flex: 10,
                        child: Center(
                          heightFactor: 1.5,
                          child: Text(
                            "",
                            textAlign: TextAlign.center,
                          ),
                        )),
                  ]),
                  Row(children: const <Widget>[
                    Expanded(
                        flex: 10,
                        child: Center(
                          heightFactor: 2.5,
                          child: Text(
                            "Testing SS Flutter Plugin",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.6,
                          ),
                        )),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                        flex: 10,
                        child: Center(
                          heightFactor: 2.5,
                          child: Text(
                            "Distinct ID: $_userId",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1,
                          ),
                        )),
                  ]),
                  Row(children: const <Widget>[
                    Expanded(
                        flex: 10,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(14, 6, 12, 0),
                            child: Text(
                              "User Login form",
                              textAlign: TextAlign.start,
                              textScaleFactor: 1.2,
                            ))),
                  ]),
                  Form(
                      key: _userLoginFormKey,
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                        Row(children: <Widget>[
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 6, 6),
                              child: TextFormField(
                                controller: propDistinctIdController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Distinct ID';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Distinct ID',
                                ),
                              ),
                            ),
                          ),
                        ]),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 60),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    child: OutlinedButton(
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 12),
                                        child: Text(
                                          "Login with Distinct ID",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.2,
                                        ),
                                      ),
                                      onPressed: () async {
                                        log("Clicked login button");
                                        var validationResult = _userLoginFormKey
                                            .currentState!
                                            .validate();
                                        log("_propertyDistinctId == $_propertyDistinctId");
                                        log("propDistinctIdController.text.toString() == ${propDistinctIdController.text.toString()}");
                                        if (validationResult) {
                                          if (_propertyDistinctId.isNotEmpty) {
                                            setState(() {
                                              log("Before _userId == $_userId");
                                              _userId = _propertyDistinctId;
                                              log("After _userId == $_userId");
                                            });
                                            var hashMap =
                                                HashMap<String, Object>();
                                            hashMap["User_ID"] = _userId;

                                            var countsMap =
                                                HashMap<String, int>();
                                            countsMap["Login_count"] = 1;
                                            suprsend.user.increment(countsMap);

                                            suprsend
                                                .setSuperProperties(hashMap);
                                            suprsend
                                                .identify(_propertyDistinctId);
                                          } else {
                                            print(
                                                "Property Distinct ID must not be empty when calling login()!");
                                          }
                                        } else {
                                          print(
                                              "There are validation errors with your Property Key!");
                                        }
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        )
                      ])),
                  Row(children: const <Widget>[
                    Expanded(
                        flex: 10,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(14, 6, 12, 0),
                            child: Text(
                              "User Property Set/Unset form",
                              textAlign: TextAlign.start,
                              textScaleFactor: 1.2,
                            ))),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 6, 6),
                        child: TextFormField(
                          controller: propKeyController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter property key';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Property key',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 12, 12, 6),
                        child: TextFormField(
                          controller: propValueController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Property value',
                          ),
                        ),
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 60),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: OutlinedButton(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 12),
                                  child: Text(
                                    "Set Property",
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1.2,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_userPropertySetUnsetFormKey.currentState!
                                      .validate()) {
                                    if (_propertyValue.isNotEmpty) {
                                      Map<String, Object> props = HashMap();
                                      props[_propertyKey] = _propertyValue;
                                      suprsend.user.set(props);
                                    } else {
                                      print(
                                          "Property Value must not be empty when calling set()!");
                                    }
                                  } else {
                                    print(
                                        "There are validation errors with your Property Key!");
                                  }
                                },
                              ),
                            )),
                        Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: OutlinedButton(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 12),
                                  child: Text(
                                    "Unset Property",
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1.2,
                                  ),
                                ),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blueAccent[600])),
                                onPressed: () {
                                  if (_userPropertySetUnsetFormKey.currentState!
                                      .validate()) {
                                    var list = [_propertyKey];
                                    suprsend.user.unSet(list);
                                  } else {
                                    print(
                                        "There are validation errors with your Property Value!");
                                  }
                                },
                              ),
                            ))
                      ],
                    ),
                  ),
                  Row(children: const <Widget>[
                    Expanded(
                        flex: 10,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(14, 6, 12, 0),
                            child: Text(
                              "Mobile Number Set/Unset form",
                              textAlign: TextAlign.start,
                              textScaleFactor: 1.2,
                            ))),
                  ]),
                  Form(
                      key: _userMobileFormKey,
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                        Row(children: <Widget>[
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 6, 6),
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: propMobileNumberController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Mobile number';
                                  }
                                  String mobileInput =
                                      value.replaceAll(" ", "");
                                  int limit = 10;
                                  if (mobileInput.contains("+")) {
                                    limit = 14;
                                  }
                                  if (mobileInput.length > limit ||
                                      mobileInput.length < 10) {
                                    return 'Please enter a valid 10 digit Mobile number';
                                  }
                                  String digits =
                                      mobileInput.replaceAll("+", "");
                                  var number = double.tryParse(digits);
                                  if (number == null) {
                                    return 'Please enter a valid 10 digit Mobile number';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Mobile number',
                                ),
                              ),
                            ),
                          ),
                        ]),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    child: OutlinedButton(
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 12),
                                        child: Text(
                                          "Set SMS Number",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.2,
                                        ),
                                      ),
                                      onPressed: () {
                                        var validationResult =
                                            _userMobileFormKey.currentState!
                                                .validate();
                                        log("_propertyMobileNumber == $_propertyMobileNumber");
                                        log("propMobileNumberController.text.toString() == ${propMobileNumberController.text.toString()}");
                                        if (validationResult) {
                                          if (_propertyMobileNumber
                                              .isNotEmpty) {
                                            String mobile =
                                                _propertyMobileNumber;
                                            if (!mobile.contains("+91")) {
                                              mobile =
                                                  "+91" + _propertyMobileNumber;
                                            }
                                            suprsend.user.setSms(mobile);
                                          } else {
                                            print(
                                                "Mobile number must not be empty when calling setSMS()!");
                                          }
                                        } else {
                                          print(
                                              "There are validation errors with your Property Mobile number!");
                                        }
                                      },
                                    ),
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    child: OutlinedButton(
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 12),
                                        child: Text(
                                          "Unset SMS Number",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.2,
                                        ),
                                      ),
                                      onPressed: () {
                                        var validationResult =
                                            _userMobileFormKey.currentState!
                                                .validate();
                                        log("_propertyMobileNumber == $_propertyMobileNumber");
                                        log("propMobileNumberController.text.toString() == ${propMobileNumberController.text.toString()}");
                                        if (validationResult) {
                                          if (_propertyMobileNumber
                                              .isNotEmpty) {
                                            String mobile =
                                                _propertyMobileNumber;
                                            if (!mobile.contains("+91")) {
                                              mobile =
                                                  "+91" + _propertyMobileNumber;
                                            }
                                            suprsend.user.unSetSms(mobile);
                                          } else {
                                            print(
                                                "Mobile number must not be empty when calling unSetSMS()!");
                                          }
                                        } else {
                                          print(
                                              "There are validation errors with your Property Mobile number!");
                                        }
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 60),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    child: OutlinedButton(
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 12),
                                        child: Text(
                                          "Set Whatsapp Number",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.1,
                                        ),
                                      ),
                                      onPressed: () {
                                        var validationResult =
                                            _userMobileFormKey.currentState!
                                                .validate();
                                        log("_propertyMobileNumber == $_propertyMobileNumber");
                                        log("propMobileNumberController.text.toString() == ${propMobileNumberController.text.toString()}");
                                        if (validationResult) {
                                          if (_propertyMobileNumber
                                              .isNotEmpty) {
                                            String mobile =
                                                _propertyMobileNumber;
                                            if (!mobile.contains("+91")) {
                                              mobile =
                                                  "+91" + _propertyMobileNumber;
                                            }
                                            suprsend.user.setWhatsApp(mobile);
                                          } else {
                                            print(
                                                "Mobile number must not be empty when calling setWhatsApp()!");
                                          }
                                        } else {
                                          print(
                                              "There are validation errors with your Property Mobile number!");
                                        }
                                      },
                                    ),
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    child: OutlinedButton(
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 12),
                                        child: Text(
                                          "Unset Whatsapp Number",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.1,
                                        ),
                                      ),
                                      onPressed: () {
                                        var validationResult =
                                            _userMobileFormKey.currentState!
                                                .validate();
                                        log("_propertyMobileNumber == $_propertyMobileNumber");
                                        log("propMobileNumberController.text.toString() == ${propMobileNumberController.text.toString()}");
                                        if (validationResult) {
                                          if (_propertyMobileNumber
                                              .isNotEmpty) {
                                            String mobile =
                                                _propertyMobileNumber;
                                            if (!mobile.contains("+91")) {
                                              mobile =
                                                  "+91" + _propertyMobileNumber;
                                            }
                                            suprsend.user.unSetWhatsApp(mobile);
                                          } else {
                                            print(
                                                "Mobile number must not be empty when calling unSetWhatsApp()!");
                                          }
                                        } else {
                                          print(
                                              "There are validation errors with your Property Mobile number!");
                                        }
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        )
                      ])),
                  Row(children: const <Widget>[
                    Expanded(
                        flex: 10,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(14, 6, 12, 0),
                            child: Text(
                              "Email ID Set/Unset form",
                              textAlign: TextAlign.start,
                              textScaleFactor: 1.2,
                            ))),
                  ]),
                  Form(
                      key: _userEmailFormKey,
                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                        Row(children: <Widget>[
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 6, 6),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: propEmailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter email ID';
                                  }
                                  String emailInput = value.trim();

                                  if (!emailInput.contains("@")) {
                                    return 'Please enter a valid email ID';
                                  }
                                  if (!emailInput.contains(".")) {
                                    return 'Please enter a valid email ID';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Email ID',
                                ),
                              ),
                            ),
                          ),
                        ]),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 60),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    child: OutlinedButton(
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 12),
                                        child: Text(
                                          "Set Email",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.2,
                                        ),
                                      ),
                                      onPressed: () {
                                        var validationResult = _userEmailFormKey
                                            .currentState!
                                            .validate();
                                        log("_propertyEmail == $_propertyEmail");
                                        log("propEmailController.text.toString() == ${propEmailController.text.toString()}");
                                        if (validationResult) {
                                          if (_propertyEmail.isNotEmpty) {
                                            suprsend.user
                                                .setEmail(_propertyEmail);
                                          } else {
                                            print(
                                                "Email must not be empty when calling setEmail()!");
                                          }
                                        } else {
                                          print(
                                              "There are validation errors with your Property Email!");
                                        }
                                      },
                                    ),
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    child: OutlinedButton(
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 12),
                                        child: Text(
                                          "Unset Email",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.2,
                                        ),
                                      ),
                                      onPressed: () {
                                        var validationResult = _userEmailFormKey
                                            .currentState!
                                            .validate();
                                        log("_propertyEmail == $_propertyEmail");
                                        log("propEmailController.text.toString() == ${propEmailController.text.toString()}");
                                        if (validationResult) {
                                          if (_propertyEmail.isNotEmpty) {
                                            suprsend.user
                                                .unSetEmail(_propertyEmail);
                                          } else {
                                            print(
                                                "Email must not be empty when calling unSetEmail()!");
                                          }
                                        } else {
                                          print(
                                              "There are validation errors with your Property Email!");
                                        }
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ])),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 0),
                              child: OutlinedButton(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 12),
                                  child: Text(
                                    "Clear All Inputs",
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1.2,
                                  ),
                                ),
                                onPressed: () {
                                  propDistinctIdController.clear();
                                  propKeyController.clear();
                                  propValueController.clear();
                                  propMobileNumberController.clear();
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 60),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 0),
                              child: OutlinedButton(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 12),
                                  child: Text(
                                    "Logout",
                                    textAlign: TextAlign.center,
                                    textScaleFactor: 1.2,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _userId = "";
                                    _subsId = "";
                                  });
                                  suprsend
                                      .unSetSuperProperty("Platform_Version");
                                  suprsend.unSetSuperProperty("User_ID");
                                  suprsend.flush();
                                  suprsend.reset();
                                },
                              ),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 6, 60),
                    child: Row(
                      children: const <Widget>[InboxBell()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }

  @override
  void dispose() {
    propKeyController.dispose();
    propValueController.dispose();
    propDistinctIdController.dispose();
    propMobileNumberController.dispose();
    propEmailController.dispose();
    _linkSub.cancel();
    super.dispose();
  }
}

class InboxBell extends HookWidget {
  const InboxBell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bellData = useBell();
    print("rerendered bell");
    return Expanded(
        flex: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          child: OutlinedButton(
            child: Text("Unread ${bellData["unSeenCount"]} notifications"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InboxNotifications()),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (newcontext) =>
              //         BlocProvider<SuprSendStoreCubit>.value(
              //       value: BlocProvider.of<SuprSendStoreCubit>(context),
              //       child: const InboxNotifications(),
              //     ),
              //   ),
              // );
            },
          ),
        ));
  }
}

class InboxNotifications extends HookWidget {
  const InboxNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifData = useNotifications();

    useNewNotificationListener((data) {
      print("NEW DATA ${data.length}");
      const snackBar = SnackBar(
        content: Text('Got new notifications'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    useEffect(() {
      notifData["markAllSeen"]();
    }, []);

    if (notifData["notifications"] != null &&
        notifData["notifications"].length > 0) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
          ),
          body: ListView.builder(
            itemCount: notifData["notifications"].length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) {
              final notifMessage = notifData["notifications"][index];
              return ListTile(
                title: Text(
                    '${notifMessage["message"]["header"]} ${notifMessage["seen_on"] != null ? '' : "*"}'),
                subtitle: Text('${notifMessage["message"]["text"]}'),
                onTap: () {
                  notifData["markClicked"](notifMessage["n_id"]);
                },
              );
            },
          ));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
          ),
          body: const Text("NO DATA", textDirection: TextDirection.ltr));
    }
  }
}
