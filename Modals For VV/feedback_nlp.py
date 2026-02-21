import nltk
from nltk.sentiment import SentimentIntensityAnalyzer
nltk.download("vader_lexicon")
sia = SentimentIntensityAnalyzer()
ACADEMIC_NEGATIVE_PATTERNS = {
    "deficiency": {
        "keywords": ["lack", "lacks", "missing", "insufficient", "inadequate"],
        "weight": 0.4
    },
    "imbalance": {
        "keywords": ["too much", "too many", "very less", "not enough"],
        "weight": 0.3
    },
    "expectation_gap": {
        "keywords": ["could be better", "expected more", "needs improvement"],
        "weight": 0.2
    },
    "process_issue": {
        "keywords": ["fast", "rushed", "unclear", "confusing"],
        "weight": 0.2
    }
}
ACADEMIC_ANCHORS = [
    "theory", "syllabus", "content", "workload",
    "assignment", "assignments",
    "exam", "exams",
    "lab", "labs",
    "practical", "practicals"
]
TOPICS = {
    "Labs / Practicals": ["lab", "practical", "hands-on", "experiment"],
    "Teaching Quality": ["teaching", "explanation", "clarity", "understand"],
    "Teaching Pace": ["fast", "slow", "speed", "rushed"],
    "Theory Load": ["theory", "theoretical", "concept"],
    "Syllabus Coverage": ["syllabus", "content", "portion", "coverage"],
    "Assessment & Exams": ["exam", "test", "evaluation", "assessment"],
    "Course Difficulty": ["difficult", "hard", "easy", "complex"],
    "Resources & Materials": ["notes", "slides", "material", "resources"],
    "Student Engagement": ["boring", "interesting", "engaging", "interactive"]
}
def academic_dissatisfaction_score(text: str):
    text = text.lower()
    score = 0.0
    reasons = []
    for category, data in ACADEMIC_NEGATIVE_PATTERNS.items():
        for phrase in data["keywords"]:
            if phrase in text:
                if category == "imbalance":
                    if any(anchor in text for anchor in ACADEMIC_ANCHORS):
                        score += data["weight"]
                        reasons.append(category)
                else:
                    score += data["weight"]
                    reasons.append(category)
                break
    return score, reasons
def detect_topics(text: str):
    text = text.lower()
    detected = []
    for topic, keywords in TOPICS.items():
        for word in keywords:
            if word in text:
                detected.append(topic)
                break
    return detected
def analyze_feedback(text: str):
    vader_scores = sia.polarity_scores(text)
    vader_compound = vader_scores["compound"]
    acad_score, reasons = academic_dissatisfaction_score(text)
    topics = detect_topics(text)
    if vader_compound >= 0.3 and acad_score >= 0.3:
        sentiment = "Mixed"
    elif vader_compound >= 0.4:
        sentiment = "Positive"
    elif vader_compound <= -0.05:
        sentiment = "Negative"
    elif acad_score >= 0.3:
        sentiment = "Negative"
    else:
        sentiment = "Neutral"
    return {
        "sentiment": sentiment,
        "vader_score": round(vader_compound, 3),
        "academic_score": round(acad_score, 3),
        "reasons": reasons,
        "topics": topics
    }
if __name__ == "__main__":
    test_feedbacks = [
        "I love this class too much",
        "The course has too much theory",
        "The subject is good but it lacks practical classes",
        "Labs were engaging and very useful",
        "The syllabus is okay"
    ]
    for feedback in test_feedbacks:
        result = analyze_feedback(feedback)
        print("\nFeedback:", feedback)
        print("Sentiment:", result["sentiment"])
        print("VADER Score:", result["vader_score"])
        print("Academic Score:", result["academic_score"])
        print("Reasons:", result["reasons"])
        print("Topics:", result["topics"])
