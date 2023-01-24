import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/booking_confirmation.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/invoice.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/login/get_started.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/translations/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Otp extends StatefulWidget {
  const Otp({Key? key}) : super(key: key);

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  String otpNumber = ''; //otp number
  List otpText = []; //otp number as list for 6 boxes
  List otpPattern = [1, 2, 3, 4, 5, 6]; //list to create number of input box
  var resendTime = 60; //otp resend time
  late Timer timer; //timer for resend time
  String _error =
      ''; //otp error string to show if error occurs in otp validation
  TextEditingController otpController =
      TextEditingController(); //otp textediting controller
  TextEditingController first = TextEditingController();
  TextEditingController second = TextEditingController();
  TextEditingController third = TextEditingController();
  TextEditingController fourth = TextEditingController();
  TextEditingController fifth = TextEditingController();
  TextEditingController sixth = TextEditingController();
  bool _loading = false; //loading screen showing
  @override
  void initState() {
    _loading = false;
    timers();
    otpFalse();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel;
    super.dispose();
  }

  //navigate
  navigate(verify) {
    if (verify == true) {
      if (userRequestData.isNotEmpty && userRequestData['is_completed'] == 1) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Invoice()),
            (route) => false);
      } else if (userRequestData.isNotEmpty &&
          userRequestData['is_completed'] != 1) {
        Future.delayed(const Duration(seconds: 2), () {
          if (userRequestData['is_rental'] == true) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => BookingConfirmation(
                          type: 1,
                        )),
                (route) => false);
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BookingConfirmation()),
                (route) => false);
          }
        });
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
            (route) => false);
      }
    } else if (verify == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const GetStarted()));
    } else {
      _error = verify.toString();
      setState(() {
        _loading = false;
      });
    }
  }

  //otp is false
  otpFalse() async {
    if (phoneAuthCheck == false) {
      _loading = true;
      otpController.text = '123456';
      otpNumber = otpController.text;
      var verify = await verifyUser(phnumber);

      navigate(verify);
    }
  }

  //auto verify otp

  verifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      // Sign the user in (or link) with the credential
      await FirebaseAuth.instance.signInWithCredential(credentials);

      var verify = await verifyUser(phnumber);
      navigate(verify);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-verification-code') {
        setState(() {
          otpController.clear();
          otpNumber = '';
          _error = languages[choosenLanguage]['text_otp_error'];
        });
      }
    }
  }

// running resend otp timer
  timers() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTime != 0) {
        if (mounted) {
          setState(() {
            resendTime--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Material(
      color: page,
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              if (credentials != null) {
                _loading = true;
                verifyOtp();
              }
              return Stack(
                children: [
                  Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      height: 600,
                      width: 320,
                      child: Column(
                        children: [
                          SizedBox(
                            height: media.height * 0.04,
                          ),
                          Container(
                              color: topBar,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(Icons.arrow_back)),
                                ],
                              )),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: media.height * 0.02,
                                ),
                                SizedBox(
                                  width: media.width * 1,
                                  child: Center(
                                    child: Text(
                                      "Enter your passcode",
                                      style: TextStyle(
                                          fontFamily: 'Inter-Regular',
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: textColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text(
                                    "We’ve sent the code to the email on your \ndevice",
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Inter-Regular',
                                        fontSize: 14,
                                        color: textColor.withOpacity(0.3)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                    child: Image.asset(
                                        'assets/images/enterotp.png')),
                                SizedBox(height: media.height * 0.04),

                                //otp text box
                                Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 8),
                                  child: Pinput(
                                    controller: otpController,
                                    length: 6,
                                    // defaultPinTheme: defaultPinTheme,
                                    focusedPinTheme: focusedPinTheme,
                                    // submittedPinTheme: submittedPinTheme,

                                    showCursor: true,
                                    onCompleted: (pin) {
                                      otpNumber = pin;
                                    },
                                    onChanged: (value) {
                                      otpNumber = value;
                                    },
                                  ),
                                ),
                                SizedBox(height: media.height * 0.02),
                                Container(
                                  height: 13,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Code expires in : ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                      ),
                                      Text(
                                        '00 : 56 ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: themeM1,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: media.height * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Didn’t receive code?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Inter-Regular',
                                      ),
                                    ),
                                    Text(
                                      ' Resend Code',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeM1,
                                        fontFamily: 'Inter-Regular',
                                      ),
                                    ),
                                  ],
                                ),

                                //otp error
                                (_error != '')
                                    ? Container(
                                        width: media.width * 0.8,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(
                                            top: media.height * 0.02),
                                        child: Text(
                                          _error,
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * sixteen,
                                              color: Colors.red),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: media.height * 0.03,
                                ),
                                Container(
                                  padding: EdgeInsets.all(media.width * 0.04),
                                  alignment: Alignment.center,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (otpNumber.length == 6) {
                                        setState(() {
                                          _loading = true;
                                          _error = '';
                                        });
                                        //firebase code send false
                                        if (phoneAuthCheck == false) {
                                          var verify =
                                              await verifyUser(phnumber);

                                          navigate(verify);
                                        } else {
                                          // firebase code send true
                                          try {
                                            PhoneAuthCredential credential =
                                                PhoneAuthProvider.credential(
                                                    verificationId: verId,
                                                    smsCode: otpNumber);

                                            // Sign the user in (or link) with the credential
                                            await FirebaseAuth.instance
                                                .signInWithCredential(
                                                    credential);

                                            var verify =
                                                await verifyUser(phnumber);
                                            navigate(verify);
                                          } on FirebaseAuthException catch (error) {
                                            if (error.code ==
                                                'invalid-verification-code') {
                                              setState(() {
                                                otpController.clear();
                                                otpNumber = '';
                                                _error =
                                                    languages[choosenLanguage]
                                                        ['text_otp_error'];
                                              });
                                            }
                                          }
                                        }
                                        setState(() {
                                          _loading = false;
                                        });
                                      } else if (phoneAuthCheck == true &&
                                          resendTime == 0 &&
                                          otpNumber.length != 6) {
                                        setState(() {
                                          setState(() {
                                            resendTime = 60;
                                          });
                                          timers();
                                        });
                                        phoneAuth(countries[phcode]
                                                ['dial_code'] +
                                            phnumber);
                                      }
                                    },
                                    // text: (otpNumber.length == 6)
                                    //     ? languages[choosenLanguage]
                                    //         ['text_verify']
                                    //     : (resendTime == 0)
                                    //         ? languages[choosenLanguage]
                                    //             ['text_resend_code']
                                    //         : languages[choosenLanguage]
                                    //                 ['text_resend_code'] +
                                    //             ' ' +
                                    //             resendTime.toString(),
                                    // color: (resendTime != 0 &&
                                    //         otpNumber.length != 6)
                                    //     ? underline
                                    //     : null,
                                    // borcolor: (resendTime != 0 &&
                                    //         otpNumber.length != 6)
                                    //     ? underline
                                    //     : null,
                                    child: Text(
                                      'Verify Code',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Inter-SemiBold',
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize:
                                      const Size.fromHeight(55), // NEW
                                      primary: page,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(15.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  //no internet
                  (internet == false)
                      ? Positioned(
                          top: 0,
                          child: NoInternet(onTap: () {
                            setState(() {
                              internetTrue();
                            });
                          }))
                      : Container(),

                  //loader
                  (_loading == true)
                      ? Positioned(
                          top: 0,
                          child: SizedBox(
                            height: media.height * 1,
                            width: media.width * 1,
                            child: const Loading(),
                          ))
                      : Container()
                ],
              );
            }),
      ),
    );
  }
}
