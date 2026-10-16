import 'package:flutter/material.dart';

/// 프로젝트 페이지 전용 색상 (홈과 달리 항상 다크).
abstract final class ProjectColors {
  static const bg = Color(0xFF0B0D10);
  static const card = Color(0xFF14181D);
  static const line = Color(0xFF242A31);
  static const text = Color(0xFFEEF1F4);
  static const muted = Color(0xFF9AA5B1);
  static const accent = Color(0xFF4CC2FF);
}

/// 카드 ↔ 상세 화면 제목. 히어로 비행 중 두 스타일 사이를 보간한다.
const cardTitleStyle = TextStyle(
    fontSize: 18,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: ProjectColors.text);

const detailTitleStyle = TextStyle(
    fontSize: 22,
    height: 1.4,
    fontWeight: FontWeight.w800,
    color: ProjectColors.text);
