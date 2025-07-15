import json

# ------------------------------------------
# MBTI Descriptions
# ------------------------------------------
MBTI_DESCRIPTIONS = {
    "INTJ": {
        "name": "Стратег",
        "description": "Новатор-перфекционист, комфортно работает в одиночестве. Уверен в своих идеях, логичен и организован. Часто выбирает профессии: стратег, исследователь, инженер, архитектор, аналитик.",
        "example": "Гендальф Серый (Властелин колец)"
    },
    "INTP": {
        "name": "Учёный",
        "description": "Аналитичный, любознательный, склонен к теоретизированию. Прекрасно решает абстрактные задачи. Подходит для профессий: программист, математик, учёный, инженер, аналитик.",
        "example": "Альберт Эйнштейн"
    },
    "ENTP": {
        "name": "Полемист",
        "description": "Харизматичный и находчивый мыслитель. Любит спорить, развивать идеи и находить нестандартные решения. Идеален для профессий: предприниматель, маркетолог, стартапер, юрист, политтехнолог.",
        "example": "Тирион Ланнистер"
    },
    "ENTJ": {
        "name": "Командир",
        "description": "Целеустремлённый лидер, рационален и напорист. Организует команды и добивается результата. Часто работает: управляющим, топ-менеджером, юристом, военным, стратегом.",
        "example": "Стив Джобс"
    },
    "INFJ": {
        "name": "Активист",
        "description": "Интроверт с развитой интуицией, глубоко понимающий других. Ценит мораль, стремится к справедливости. Подходит: психолог, писатель, педагог, коуч, благотворитель.",
        "example": "Мартин Лютер Кинг"
    },
    "INFP": {
        "name": "Посредник",
        "description": "Мечтательный, спокойный, ориентирован на ценности и смыслы. Творческая душа, склонен к помощи другим. Подходит: писатель, художник, арт-директор, педагог, философ.",
        "example": "Амели Пулен"
    },
    "ENFP": {
        "name": "Борец",
        "description": "Энергичный энтузиаст с ярким воображением. Любит креатив и свободу, вдохновляет других. Часто становится: режиссёром, дизайнером, журналистом, коучем, педагогом.",
        "example": "Квентин Тарантино"
    },
    "ENFJ": {
        "name": "Тренер",
        "description": "Харизматичный, интуитивный лидер, вдохновляющий других. Отличный мотиватор и коммуникатор. Профессии: оратор, преподаватель, HR, психолог, политик.",
        "example": "Опра Уинфри"
    },
    "ISTJ": {
        "name": "Администратор",
        "description": "Надёжный, структурированный и ответственный. Ценит порядок и правила. Подходит: бухгалтер, юрист, военный, архивариус, администратор.",
        "example": "Джордж Вашингтон"
    },
    "ISFJ": {
        "name": "Защитник",
        "description": "Сочетает внимание к людям и долгу. Преданный и заботливый. Часто работает: медсестрой, учителем, менеджером, HR-специалистом, библиотекарем.",
        "example": "Елизавета II"
    },
    "ESTJ": {
        "name": "Менеджер",
        "description": "Практичный и ответственный. Любит чёткость и структуру. Руководит с уверенностью. Подходит: руководитель, администратор, военный, финансист.",
        "example": "Дуайт Шрут (Офис)"
    },
    "ESFJ": {
        "name": "Консул",
        "description": "Дружелюбный и заботливый, отличный командный игрок. Предпочитает личные связи и стабильность. Часто работает: организатор мероприятий, продавец, педагог, консультант.",
        "example": "Моника Геллер (Друзья)"
    },
    "ISTP": {
        "name": "Виртуоз",
        "description": "Независимый и изобретательный. Отлично решает практические задачи. Любит эксперименты. Подходит: инженер, механик, айтишник, пилот, архитектор.",
        "example": "Джеймс Бонд"
    },
    "ISFP": {
        "name": "Артист",
        "description": "Дружелюбный и чувствительный. Творчески самовыражается и помогает другим. Часто работает: дизайнер, медик, педагог, художник, флорист.",
        "example": "Фрида Кало"
    },
    "ESTP": {
        "name": "Делец",
        "description": "Обожает экстрим и решает проблемы на ходу. Любит динамику. Часто выбирает: предпринимательство, спорт, маркетинг, продажи, аварийные службы.",
        "example": "д’Артаньян"
    },
    "ESFP": {
        "name": "Развлекатель",
        "description": "Открытый, артистичный и весёлый. Обожает публику и живое общение. Идеален для профессий: актёр, музыкант, ведущий, PR-менеджер, преподаватель.",
        "example": "Элтон Джон"
    }
}


# ------------------------------------------
# Определение MBTI
# ------------------------------------------
def determine_mbti(mbti_scores):
    def invert(score): return 8 - score
    direct_ei = {11, 12, 19, 28}
    scales = {
        'EI': [11, 12, 14, 19, 28],
        'SN': [26, 31, 32, 34],
        'TF': [13, 17, 18, 24, 27],
        'JP': [15, 20, 22, 25, 33]
    }

    ei = [invert(mbti_scores[f'q{i}']) if i not in direct_ei else mbti_scores[f'q{i}'] for i in scales['EI']]
    sn = [mbti_scores[f'q{i}'] for i in scales['SN']]
    tf = [mbti_scores[f'q{i}'] for i in scales['TF']]
    jp = [mbti_scores[f'q{i}'] for i in scales['JP']]

    mbti = ''
    mbti += 'I' if sum(ei) / len(ei) >= 4 else 'E'
    mbti += 'N' if sum(sn) / len(sn) >= 4 else 'S'
    mbti += 'F' if sum(tf) / len(tf) >= 4 else 'T'
    mbti += 'J' if sum(jp) / len(jp) >= 4 else 'P'

    return mbti


# ------------------------------------------
# Оценка профессии
# ------------------------------------------
def score_profession_normalized(student, profession):
    total_score = 0
    reasons, negatives = [], []

    subj_scores = student["subject_scores"]
    required_subjects = [s.replace(" (базовый)", "").replace(" (профильный)", "").strip() for s in profession["ege_subjects"]]
    max_subj_score = len(required_subjects) * 5

    # Subjects (35%)
    subj_sum = 0
    matched_subjects = []
    for subj in required_subjects:
        mark = subj_scores.get(subj)
        if mark:
            subj_sum += mark
            matched_subjects.append(f"{subj} ({mark})")
            if mark <= 2:
                negatives.append(f"{subj} — низкий балл ({mark})")
        else:
            negatives.append(f"{subj} — отсутствует в твоих предметах")

    if matched_subjects:
        reasons.append(f"Подходящие предметы и оценки: {', '.join(matched_subjects)}")

    subj_score_norm = (subj_sum / max_subj_score) if max_subj_score else 0
    total_score += subj_score_norm * 35

    # MBTI (20%)
    mbti_match = student["mbti_type"]["code"] in profession["mbti_types"].replace(" ", "").split(",")
    if mbti_match:
        reasons.append(f"Твой MBTI ({student['mbti_type']['code']}) подходит под эту профессию.")
        total_score += 20
    else:
        negatives.append(f"MBTI {student['mbti_type']['code']} может не совпадать с типичными для этой профессии.")

    # Interests (15%)
    interest_match = set(student["interests"]) & set(profession.get("interests", []))
    interest_score = len(interest_match) / len(profession.get("interests", []) or [1])
    if interest_match:
        reasons.append(f"Интересы совпадают: {', '.join(interest_match)}.")
    total_score += interest_score * 15

    # Values (15%)
    value_match = set(student["values"]) & set(profession.get("values", []))
    value_score = len(value_match) / len(profession.get("values", []) or [1])
    if value_match:
        reasons.append(f"Ценности совпадают: {', '.join(value_match)}.")
    total_score += value_score * 15

    # Preferences (10%)
    pref = student["work_preferences"]
    match_count = 0
    for k in ["role", "place", "style"]:
        if profession.get(k) == pref.get(k):
            match_count += 1
            reasons.append(f"Предпочтение по {k} совпадает: {profession[k]}")
    total_score += (match_count / 3) * 10

    # Exclusions (-25% per conflict)
    exclusions = pref.get("exclude", [])
    if isinstance(exclusions, str):
        exclusions = [exclusions]
    
    for ex in exclusions:
        if ex in profession.get("interests", []) or ex in profession.get("role", ""):
            total_score -= 25
            negatives.append(f"Ты хочешь избежать: {ex}, но профессия это подразумевает!")

    total_score = max(min(total_score, 100), 0)
    return round(total_score, 2), reasons, negatives


# ------------------------------------------
# Основная точка входа
# ------------------------------------------
def process_student(student, professions):
    mbti_scores = student.get("mbti_scores", {})
    mbti_type = determine_mbti(mbti_scores)
    description = MBTI_DESCRIPTIONS.get(mbti_type, {
        "name": "Неизвестный тип",
        "description": "Описание отсутствует.",
        "example": "-"
    })

    student["mbti_type"] = {
        "code": mbti_type,
        "name": description["name"],
        "description": description["description"],
        "example": description["example"]
    }
    if "mbti_scores" in student:
        del student["mbti_scores"]

    scored_professions = []
    for prof in professions:
        score, pos, neg = score_profession_normalized(student, prof)
        scored_professions.append({
            "name": prof["name"],
            "score": score,
            "positives": pos,
            "negatives": neg,
            "description": prof["description"]
        })

    scored_professions.sort(key=lambda x: x["score"], reverse=True)
    top5 = scored_professions[:5]
    return top5

# ------------------------------------------
# Для теста отдельным запуском
# ------------------------------------------
if __name__ == "__main__":
    with open("database/dataset_career_test.json", "r", encoding="utf-8") as f:
        students = json.load(f)
    with open("database/professions.json", "r", encoding="utf-8") as f:
        professions = json.load(f)
    student = students[0]  # выбери нужного студента
    top5 = process_student(student, professions)
    with open("database/profession_recommendations.json", "w", encoding="utf-8") as f:
        json.dump(top5, f, ensure_ascii=False, indent=2)
    print("✅ Рекомендации сохранены.")
