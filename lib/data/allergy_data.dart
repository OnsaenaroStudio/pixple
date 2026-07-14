import '../models/allergy_info.dart';

const allergyList = [
  AllergyInfo(
    title: "메밀",
    emoji: "🌾",
    description: "메밀 단백질에 의해 발생하는 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란", "복통"],
    avoidFoods: ["메밀국수", "막국수", "메밀전병"],
    alternatives: ["밀국수", "쌀국수"],
  ),
  
  AllergyInfo(
    title: "땅콩",
    emoji: "🥜",
    description: "땅콩에 의해 발생하는 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란", "아나필락시스"],
    avoidFoods: ["땅콩", "땅콩버터", "땅콩소스"],
    alternatives: ["해바라기씨버터"],
  ),
  
  AllergyInfo(
    title: "대두",
    emoji: "🫘",
    description: "대두 단백질에 의해 발생하는 알레르기입니다.",
    symptoms: ["발진", "복통", "구토"],
    avoidFoods: ["간장", "두부", "된장", "콩국"],
    alternatives: ["코코넛아미노", "병아리콩"],
  ),
  
  AllergyInfo(
    title: "밀",
    emoji: "🌾",
    description: "밀 단백질(글루텐 포함)에 의해 발생하는 알레르기입니다.",
    symptoms: ["복통", "두드러기", "호흡곤란"],
    avoidFoods: ["빵", "국수", "파스타"],
    alternatives: ["쌀", "귀리(가능 시)", "옥수수"],
  ),
  
  AllergyInfo(
    title: "고등어",
    emoji: "🐟",
    description: "고등어 단백질에 의해 발생하는 알레르기입니다.",
    symptoms: ["발진", "구토", "호흡곤란"],
    avoidFoods: ["고등어구이", "고등어조림"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "게",
    emoji: "🦀",
    description: "게에 의해 발생하는 갑각류 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["게", "게살", "게맛살"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "새우",
    emoji: "🦐",
    description: "새우에 의해 발생하는 갑각류 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["새우", "새우젓", "새우튀김"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "돼지고기",
    emoji: "🐷",
    description: "돼지고기 단백질에 의해 발생하는 알레르기입니다.",
    symptoms: ["복통", "발진"],
    avoidFoods: ["삼겹살", "햄", "소시지"],
    alternatives: ["닭고기", "소고기"],
  ),
  
  AllergyInfo(
    title: "복숭아",
    emoji: "🍑",
    description: "복숭아에 의해 발생하는 과일 알레르기입니다.",
    symptoms: ["입안 가려움", "발진"],
    avoidFoods: ["복숭아", "복숭아주스"],
    alternatives: ["사과"],
  ),
  
  AllergyInfo(
    title: "토마토",
    emoji: "🍅",
    description: "토마토에 의해 발생하는 알레르기입니다.",
    symptoms: ["입안 가려움", "발진"],
    avoidFoods: ["토마토", "케첩", "토마토소스"],
    alternatives: ["파프리카"],
  ),
  
  AllergyInfo(
    title: "아황산류",
    emoji: "🧪",
    description: "식품 보존제로 사용되는 아황산류에 의한 알레르기입니다.",
    symptoms: ["천식", "호흡곤란"],
    avoidFoods: ["건과일", "와인"],
    alternatives: ["무첨가 제품"],
  ),
  
  AllergyInfo(
    title: "호두",
    emoji: "🌰",
    description: "호두에 의해 발생하는 견과류 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["호두", "호두과자"],
    alternatives: ["해바라기씨"],
  ),
  
  AllergyInfo(
    title: "닭고기",
    emoji: "🐔",
    description: "닭고기 단백질에 의해 발생하는 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["치킨", "닭고기"],
    alternatives: ["소고기"],
  ),
  
  AllergyInfo(
    title: "소고기",
    emoji: "🥩",
    description: "소고기 단백질에 의해 발생하는 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["소고기", "불고기"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "오징어",
    emoji: "🦑",
    description: "오징어에 의해 발생하는 해산물 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["오징어", "오징어튀김"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "조개류",
    emoji: "🦪",
    description: "조개류 전반에 대한 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["조개", "굴", "홍합"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "잣",
    emoji: "🌰",
    description: "잣에 의해 발생하는 견과류 알레르기입니다.",
    symptoms: ["발진", "호흡곤란"],
    avoidFoods: ["잣", "잣죽"],
    alternatives: ["해바라기씨"],
  ),
  
  AllergyInfo(
    title: "아몬드",
    emoji: "🌰",
    description: "아몬드에 의해 발생하는 견과류 알레르기입니다.",
    symptoms: ["발진", "호흡곤란"],
    avoidFoods: ["아몬드", "아몬드밀크"],
    alternatives: ["귀리우유"],
  ),
  
  AllergyInfo(
    title: "캐슈넛",
    emoji: "🥜",
    description: "캐슈넛에 의해 발생하는 견과류 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["캐슈넛"],
    alternatives: ["해바라기씨"],
  ),
  
  AllergyInfo(
    title: "피스타치오",
    emoji: "🥜",
    description: "피스타치오 알레르기입니다.",
    symptoms: ["발진", "호흡곤란"],
    avoidFoods: ["피스타치오"],
    alternatives: ["해바라기씨"],
  ),
  
  AllergyInfo(
    title: "헤이즐넛",
    emoji: "🌰",
    description: "헤이즐넛 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["헤이즐넛"],
    alternatives: ["해바라기씨"],
  ),
  
  AllergyInfo(
    title: "피칸",
    emoji: "🌰",
    description: "피칸 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["피칸"],
    alternatives: ["해바라기씨"],
  ),
  
  AllergyInfo(
    title: "마카다미아",
    emoji: "🥜",
    description: "마카다미아 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["마카다미아"],
    alternatives: ["해바라기씨"],
  ),
  
  AllergyInfo(
    title: "브라질너트",
    emoji: "🥜",
    description: "브라질너트 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["브라질너트"],
    alternatives: ["해바라기씨"],
  ),
  
  AllergyInfo(
    title: "참깨",
    emoji: "⚪",
    description: "참깨 알레르기입니다.",
    symptoms: ["발진", "호흡곤란"],
    avoidFoods: ["참기름", "깨"],
    alternatives: ["올리브유"],
  ),
  
  AllergyInfo(
    title: "겨자",
    emoji: "🟡",
    description: "겨자 알레르기입니다.",
    symptoms: ["발진", "호흡곤란"],
    avoidFoods: ["머스터드"],
    alternatives: ["마요네즈"],
  ),
  
  AllergyInfo(
    title: "샐러리",
    emoji: "🥬",
    description: "샐러리 알레르기입니다.",
    symptoms: ["입안 가려움", "발진"],
    avoidFoods: ["샐러리"],
    alternatives: ["오이"],
  ),
  
  AllergyInfo(
    title: "키위",
    emoji: "🥝",
    description: "키위 알레르기입니다.",
    symptoms: ["입안 가려움", "발진"],
    avoidFoods: ["키위"],
    alternatives: ["사과"],
  ),
  
  AllergyInfo(
    title: "코코넛",
    emoji: "🥥",
    description: "코코넛 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["코코넛", "코코넛밀크"],
    alternatives: ["귀리우유"],
  ),
  
  AllergyInfo(
    title: "랍스터",
    emoji: "🦞",
    description: "랍스터 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["랍스터"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "굴",
    emoji: "🦪",
    description: "굴 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["굴"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "홍합",
    emoji: "🦪",
    description: "홍합 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["홍합"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "조개",
    emoji: "🐚",
    description: "조개 알레르기입니다.",
    symptoms: ["두드러기", "호흡곤란"],
    avoidFoods: ["조개"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "연어",
    emoji: "🍣",
    description: "연어 알레르기입니다.",
    symptoms: ["발진", "호흡곤란"],
    avoidFoods: ["연어"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "참치",
    emoji: "🐟",
    description: "참치 알레르기입니다.",
    symptoms: ["발진", "호흡곤란"],
    avoidFoods: ["참치"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "대구",
    emoji: "🐟",
    description: "대구 알레르기입니다.",
    symptoms: ["발진", "호흡곤란"],
    avoidFoods: ["대구"],
    alternatives: ["닭고기"],
  ),
  
  AllergyInfo(
    title: "젤라틴",
    emoji: "🍮",
    description: "젤라틴 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["젤리", "마시멜로"],
    alternatives: ["한천"],
  ),
  
  AllergyInfo(
    title: "귀리",
    emoji: "🌾",
    description: "귀리 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["오트밀"],
    alternatives: ["쌀"],
  ),
  
  AllergyInfo(
    title: "보리",
    emoji: "🌾",
    description: "보리 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["보리", "맥아"],
    alternatives: ["쌀"],
  ),
  
  AllergyInfo(
    title: "호밀",
    emoji: "🌾",
    description: "호밀 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["호밀빵"],
    alternatives: ["쌀"],
  ),
  
  AllergyInfo(
    title: "옥수수",
    emoji: "🌽",
    description: "옥수수 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["옥수수", "콘시럽"],
    alternatives: ["쌀"],
  ),
  
  AllergyInfo(
    title: "병아리콩",
    emoji: "🫘",
    description: "병아리콩 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["후무스"],
    alternatives: ["렌틸콩"],
  ),
  
  AllergyInfo(
    title: "렌틸콩",
    emoji: "🫘",
    description: "렌틸콩 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["렌틸콩"],
    alternatives: ["병아리콩"],
  ),
  
  AllergyInfo(
    title: "완두단백",
    emoji: "🫛",
    description: "완두단백 알레르기입니다.",
    symptoms: ["발진", "복통"],
    avoidFoods: ["식물성 단백질 제품"],
    alternatives: ["쌀단백"],
  ),
  
  AllergyInfo(
    title: "MSG",
    emoji: "🧂",
    description: "MSG에 민감한 경우 나타날 수 있는 반응입니다.",
    symptoms: ["두통", "홍조"],
    avoidFoods: ["조미료", "가공식품"],
    alternatives: ["천연조미료"],
  ),
  
  AllergyInfo(
    title: "인공감미료",
    emoji: "🍬",
    description: "일부 인공감미료에 민감한 경우 발생할 수 있습니다.",
    symptoms: ["두통", "복통"],
    avoidFoods: ["제로음료", "무설탕 식품"],
    alternatives: ["꿀"],
  ),
  
  AllergyInfo(
    title: "카페인",
    emoji: "☕",
    description: "카페인 민감 반응입니다.",
    symptoms: ["두근거림", "불면"],
    avoidFoods: ["커피", "에너지음료"],
    alternatives: ["디카페인"],
  ),
];
