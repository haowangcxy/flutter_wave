library flutter_wave;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FrameUnit {
  double c = 0;
  double d = 0;
  double b = 0;
  double t = 0;
}

class LineData {
  double x = 0;
  double y = 0;
  double width = 0;
  double height = 0;
  double lastHeight = 0;
  List<FrameUnit> timelist = [];
}

class FlutterWave extends StatefulWidget {
  double width;
  double height;
  double volume;
  Color? color;
  FlutterWave(
      {Key? key,
      this.width = 300,
      this.height = 70,
      this.volume = 0,
      this.color})
      : super(key: key);

  @override
  _FlutterWaveState createState() => _FlutterWaveState();
}

const int MIN_BUF_SIZE = 62;
const double DRAW_INTERVAL = 0.016;
const NORMAL_COLOR = Color(0xFF2f91fe);
const DISABLE_COLOR = Color(0x802f91fe);

class _FlutterWaveState extends State<FlutterWave> {
  //.h
  double mLineWidth = 1;
  double mStepWidth = 3;
  bool stopAnimation = false;

  void refreshWaverData() {}

  //.m
  int mLineCount = 0;
  double mBaseWidth = 0;
  bool mInited = false;
  double mViewWidth = 0;
  double mViewHeight = 0;
  double mMinHeight = 2;
  int mLowMode = 0;
  double mDenominator = 0;
  List mSv = [];
  List<double> mEh = [];
  List mLoc = [];
  Map mRandomCaches = {};
  Map mHeightCaches = {};
  List lineData = [];
  double soundValue = 0;

  Ticker? _ticker;
  double content = 1;
  List paintArr = [];
  int test = 5;
  Timer? t = null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.color,
      body: Container(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: MyPainter(d: lineData),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mViewWidth = widget.width;
    mViewHeight = widget.height;
    mLineCount = mViewWidth ~/ (mLineWidth + mStepWidth);
    mDenominator = pow(mLineCount, 4).toDouble();
    setupData();

    // _ticker = Ticker((i) {
    // setValue(this.soundValue);
    // test++;
    //   if (test > 1) {
    //     test = 0;
    //     setValue(Random().nextInt(30).toDouble());
    //   drawVolume();
    //   }
    // });
    // _ticker?.start();
    start();
  }

  void start() {
    t = Timer.periodic(Duration(milliseconds: 8), (timer) {
      test++;
      if (test > 1) {
        test = 0;
        // setValue(Random().nextInt(30).toDouble());
        setValue(widget.volume);
        drawVolume();
      }
    });
  }

  void setupData() {
    List array = [];
    int start = (mViewWidth - ((mLineWidth + mStepWidth) * mLineCount)) ~/ 2;
    for (var i = 0; i < mLineCount; i++) {
      LineData data = LineData();
      data.x = start.toDouble();
      data.y = mViewHeight / 2;
      data.width = mLineWidth;
      data.height = mMinHeight;
      data.timelist = [];
      array.add(data);
      start += (mLineWidth + mStepWidth).toInt();
    }
    lineData = array;
  }

  void setPowerValue(double volume) {
    this.soundValue = volume;
    // if (!this.stopAnimation && !(_ticker?.isActive ?? false)) {

    // }
  }

  void setValue(double volume) {
    if (volume < 20) {
      volume = 0;
    }
    mSv = [];
    mEh = [];
    mLoc = [];

    double input = volume / 100.0;
    if (input > 0.6) input = 0.6;

    double half = mLineCount / 2.0;
    double si = input;
    if (si < 0.1) {
      if (mLowMode > 0 && mLowMode < 3) {
        mLowMode++;
        return;
      }
      mLowMode = 0;
      mLowMode++;
      si = 0.1;
      input = 0.05;
    } else {
      input += 2.0;
      mLowMode = 0;
    }

    for (var i = 0; i < mLineCount; i++) {
      if (i < half) {
        bool ret = _randomBool(
            (si * (getRandomValue(i) / mDenominator + 0.05) * 100).toInt());
        mSv.add(ret);
      } else {
        bool ret = _randomBool(
            (si * (getRandomValue(i - mLineCount) / mDenominator + 0.05) * 100)
                .toInt());
        mSv.add(ret);
      }
    }
    int sss = 0;
    for (var i = 0; i < mSv.length; i++) {
      if (mSv[i]) {
        sss++;
      }
    }

    int m = 20 * input.toInt() + Random().nextInt(3) - 1;
    m = m <= 0 ? 1 : m;

    double standH = pow(input, 0.333) * mViewHeight * 0.8;
    for (var i = 0; i < m; i++) {
      if (i < half) {
        double value = standH * (getRandomValue(i) / mDenominator + 0.05) * 10;
        mEh.add(value);
      } else {
        double value = standH *
            (getRandomValue(i - mLineCount) / mDenominator + 0.05) *
            10;
        mEh.add(value);
      }
    }

    int loc = 0;
    for (var i = 0; i < mLineCount; i++) {
      if (mSv[i]) {
        mLoc.add(i);
        loc++;
      }
    }

    if (loc > 1) {
      int chc = min(30, loc);
      for (var i = 0; i < chc; i++) {
        int s1 = Random().nextInt(loc);
        int s2 = Random().nextInt(loc);
        if (s1 == s2) {
          s2 = (s2 + 1) % loc;
        }
        int t = mLoc[s1];
        mLoc[s1] = mLoc[s2];
        mLoc[s2] = t;
      }
    }

    int factm = min(m, loc);
    for (var i = 0; i < mLineCount; i++) {
      double fh = mMinHeight;
      for (var j = 0; j < factm; j++) {
        fh += mEh[j] * getHeightValue((mLoc[j] - i).abs());
      }
      double height = mViewHeight / 2;
      if (fh > height) {
        fh = height;
      }

      LineData line = lineData[i];
      List<FrameUnit> timelist = line.timelist;
      if ((fh - line.lastHeight).abs() >= 1) {
        double t = 0.135;
        if (fh < line.lastHeight) {
          t = 0.3;
        }

        FrameUnit fu = FrameUnit();
        fu.c = fh - line.lastHeight;
        fu.d = t;
        fu.b = 0;
        fu.t = 0;
        timelist.add(fu);
      }
      line.lastHeight = fh;
      line.timelist = timelist;
    }
  }

  void drawVolume() {
    for (var i = 0; i < mLineCount; i++) {
      LineData line = lineData[i];
      List timeList = line.timelist;
      double dy = 0;
      for (var j = 0; j < timeList.length; j++) {
        FrameUnit fu = timeList[j];
        fu.t += DRAW_INTERVAL;
        double onceDy = 0.0;
        if (fu.t > fu.d) {
          onceDy = fu.c - fu.b;
          timeList.removeAt(j);
          j--;
        } else {
          onceDy = quartInOutWithT(fu.t, 0, fu.c, fu.d);
          double last = fu.b;
          fu.b = onceDy;
          onceDy -= last;
        }
        dy += onceDy;
      }
      if (dy != 0) {
        double lh = line.height + dy;
        if (lh < mMinHeight) {
          lh = mMinHeight;
        }
        line.height = lh;
      } else if (timeList.length == 0) {
        line.height = mMinHeight;
      }
    }
    setState(() {});
  }

/**
     * //随机交换位置
    - (void)drawVolume {
    self.levelPath = [UIBezierPath bezierPath];
    
    for (int i = 0; i < _mLineCount; i++) {
        
            dy += onceDy;
        }
        if (dy != 0) {
            float lh = line.height + dy;
            if (lh < _mMinHeight) {
                lh = _mMinHeight;
            }
            line.height = lh;
        }
        else if (timelist.count == 0) {
//            float lh = line.height;
//            if (lh < _mMinHeight) {
                line.height = _mMinHeight;
//            }
        }
        [_levelPath moveToPoint:CGPointMake(line.x, line.y - line.height / 2)];
        [_levelPath addLineToPoint:CGPointMake(line.x, line.y + line.height / 2)];
    }
    self.levelLayer.path = _levelPath.CGPath;
}
     */

  double getRandomValue(int key) {
    if (mHeightCaches[key] != null && mRandomCaches[key] >= 0) {
      return mRandomCaches[key];
    }
    double value = 18 * pow(key, 4).toDouble();
    mRandomCaches[key] = value;
    return value;
  }

  double getHeightValue(int key) {
    if (mHeightCaches[key] != null && mHeightCaches[key] >= 0) {
      return mHeightCaches[key];
    }

    double value = pow(0.5, key).toDouble();
    mRandomCaches[key] = value;
    return value;
  }

  bool _randomBool(int precent) {
    if (precent <= 0) return false;
    if (precent >= 100) return true;
    return Random().nextInt(1000) < 10 * precent;
  }

  double quartInOutWithT(double t, double b, double c, double d) {
    return -c / 2 * (cos(pi * t / d) - 1) + b;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _ticker?.stop();
    _ticker?.dispose();
    t?.cancel();
    t = null;
  }
}

class MyPainter extends CustomPainter {
  List? d;
  MyPainter({this.d});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill
      ..color = Color(0XFF6861DD)
      ..invertColors = false;
    // Rect rect=Rect.fromPoints(Offset(size.width/2, 0), Offset(0.0, size.height/2));
    // canvas.drawRect(rect, paint);
    //  rect=Rect.fromPoints(Offset(size.width/3, 0), Offset(0.0, size.height/3));
    // canvas.drawRect(rect, paint..color=Colors.red);
    // rect=Rect.fromPoints(Offset(0, 0), Offset(size.width/4, size.height/4));
    // canvas.drawRect(rect, paint..color=Colors.blue);
    // canvas.drawPoints(pointMode, points, paint)
    for (var i = 0; i < (d?.length ?? 0); i++) {
      LineData l = d?[i];
      canvas.drawLine(Offset(l.x, l.y - l.height / 2),
          Offset(l.x, l.y + l.height / 2), paint);
    }
    // canvas.drawLine(Offset(22 * d, 22 * d), Offset(33 * d, 44 * d), paint);
    // canvas.drawLine(Offset(33 * d, 33 * d), Offset(55 * d, 55 * d), paint);
  }

  //在实际场景中正确利用此回调可以避免重绘开销，本示例我们简单的返回true
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
