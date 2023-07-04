import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:watermeter/model/user.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/repository/xidian_ids/ehall/score_session.dart';

class ScoreController extends GetxController {
  bool isGet = false;
  String? error;
  late String currentSemester;
  late List<Score> scoreTable;
  late List<bool> isSelected;

  bool isSelectMod = false;
  Set<String> semester = {};
  Set<String> statuses = {};
  Set<String> unPassedSet = {};
  double notCoreClass = 0.0;

  /// User could see the place only if they pressed easter egg five times.
  int presscount = 0;
  bool allowDetail = false;

  void addCount() {
    if (presscount < 4) {
      presscount++;
    } else {
      if (allowDetail == false) {
        allowDetail = true;
      }
    }
  }

  static const notFinish = "(成绩没登完)";
  static const notCoreClassType = "公共任选";
  static const notFirstTime = "(非初修)";

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  /// Exclude these from counting avgs
  /// 1. CET-4 and CET-6
  /// 2. Teacher have not finish uploading scores
  /// 3. Have score below 60 but passed.
  /// 4. Not first time learning this, but still failed.
  bool _evalCount(Score eval) => !(eval.name.contains("国家英语四级") ||
      eval.name.contains("国家英语六级") ||
      eval.name.contains(notFinish) ||
      (eval.score < 60 && !unPassedSet.contains(eval.name)) ||
      (eval.name.contains(notFirstTime) && eval.score < 60));

  double evalCredit(bool isAll) {
    double totalCredit = 0.0;
    for (var i = 0; i < isSelected.length; ++i) {
      if (((isSelected[i] == true && isAll == false) || isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalCredit += scoreTable[i].credit;
      }
    }
    return totalCredit;
  }

  /// [isGPA] true for the GPA, false for the avgScore
  double evalAvg(bool isAll, {bool isGPA = false}) {
    double totalScore = 0.0;
    double totalCredit = evalCredit(isAll);
    for (var i = 0; i < isSelected.length; ++i) {
      if (((isSelected[i] == true && isAll == false) || isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalScore += (isGPA ? scoreTable[i].gpa : scoreTable[i].score) *
            scoreTable[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore / totalCredit : 0.0;
  }

  List<Score> get toShow {
    /// If I write "whatever = scores.scoreTable", every change I made to "whatever"
    /// also applies to scores.scoreTable. Since reference whatsoever.
    List<Score> whatever = List.from(scoreTable);
    if (chosenSemester != "") {
      whatever.removeWhere((element) => element.year != chosenSemester);
    }
    if (chosenStatus != "") {
      whatever.removeWhere((element) => element.status != chosenStatus);
    }
    return whatever;
  }

  String get unPassed {
    if (unPassedSet.isEmpty) {
      return "没有";
    }
    return unPassedSet.join(",");
  }

  // ignore: non_constant_identifier_names
  Future<Compose> getDetail(String? JXBID, String XNXQDM) async {
    if (JXBID == null) {
      return Compose();
    } else {
      return await ScoreFile().getDetail(JXBID, XNXQDM);
    }
  }

  // ignore: non_constant_identifier_names
  Future<ScorePlace> getPlaceInClass(String? JXBID, String XNXQDM) async {
    if (JXBID == null) {
      return ScorePlace();
    } else {
      return await ScoreFile().getPlaceInClass(JXBID, XNXQDM);
    }
  }

  // ignore: non_constant_identifier_names
  Future<ScorePlace> getPlaceInGrade(String? KCM, String XNXQDM) async {
    if (KCM == null) {
      return ScorePlace();
    } else {
      return await ScoreFile().getPlaceInGrade(KCM, XNXQDM);
    }
  }

  @override
  void onInit() {
    currentSemester = user["currentSemester"]!;
    super.onInit();
  }

  @override
  void onReady() async {
    get(semesterStr: currentSemester);
    update();
  }

  Future<void> get({String? semesterStr}) async {
    isGet = false;
    error = "正在加载";
    try {
      /// Init scorefile
      scoreTable = await ScoreFile().get();
      isSelected = List<bool>.generate(scoreTable.length, (int index) => false);
      semester = {for (var i in scoreTable) i.year};
      statuses = {for (var i in scoreTable) i.status};

      for (var i in scoreTable) {
        /// The score has not uploaded completely
        if (i.isPassed == "-1") {
          i.name += notFinish;
          continue;
        }

        /// Passed notCoreClass credit. Meet graduate requirement.
        if (i.status == notCoreClassType && i.isPassed == '1') {
          notCoreClass += i.credit;
        }

        /// When think about the unpassed classes,
        /// we do not consider the not core class.
        if (i.isPassed != '1' &&
            i.isPassed != "-1" &&
            i.status != notCoreClassType &&
            !unPassedSet.contains(i.name)) {
          unPassedSet.add(i.name);
          continue;
        }

        /// Whatever score is, if not passed in the first time, count as 60.
        /// Please take a note of it.
        if (unPassedSet.contains(i.name)) {
          if (i.isPassed == '1') {
            i.score = 60;
            unPassedSet.remove(i.name);
          }
          i.name += notFirstTime;
        }
      }
      isGet = true;
      error = null;
      chosenSemester = semester.last;
    } on DioException catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "ScoreController",
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
    } on GetScoreFailedException catch (e) {
      developer.log("没有获取到成绩：$e", name: "ScoreSession");
      error = "没有获取到成绩：$e";
    } catch (e) {
      developer.log("未知故障：$e", name: "ScoreSession");
      error = e.toString();
    }
    update();
  }
}
