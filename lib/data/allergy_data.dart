import '../models/allergy_info.dart';

const allergyList = [
  AllergyInfo(
    title: "우유",
    emoji: "🥛",
    description: "우유 단백질에 의해 발생하는 알레르기입니다.",
    symptoms: [
      "두드러기",
      "복통",
      "구토",
      "호흡곤란",
    ],
    avoidFoods: [
      "우유",
      "치즈",
      "버터",
      "요거트",
    ],
    alternatives: [
      "두유",
      "오트밀크",
      "아몬드밀크",
    ],
  ),

  AllergyInfo(
    title: "계란",
    emoji: "🥚",
    description: "계란 흰자 단백질에 의해 발생하는 알레르기입니다.",
    symptoms: [
      "가려움",
      "발진",
      "복통",
    ],
    avoidFoods: [
      "계란",
      "마요네즈",
      "케이크",
    ],
    alternatives: [
      "두부",
      "아마씨",
    ],
  ),
];