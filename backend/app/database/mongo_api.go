package database

import (
	"context"
	"fmt"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var mongoClient *mongo.Client

type University struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Name      string             `bson:"name" json:"name"`
	Country   string             `bson:"country" json:"country"`
	TimeStamp time.Time          `bson:"timestamp" json:"timestamp"`

	ExtraData map[string]interface{} `bson:",extraelements" json:"extra_data,omitempty"`
}

type Profession struct {
	Name            string    `json:"name" bson:"name"`
	Description     string    `json:"description" bson:"description"`
	EgeSubjects     []string  `json:"ege_subjects" bson:"ege_subjects"`
	MBTITypes       string    `json:"mbti_types" bson:"mbti_types"`
	Interests       []string  `json:"interests" bson:"interests"`
	Values          []string  `json:"values" bson:"values"`
	Role            string    `json:"role" bson:"role"`
	Place           string    `json:"place" bson:"place"`
	Style           string    `json:"style" bson:"style"`
	EducationLevel  string    `json:"education_level" bson:"education_level"`
	SalaryRange     string    `json:"salary_range" bson:"salary_range"`
	GrowthProspects string    `json:"growth_prospects" bson:"growth_prospects"`
	TimeStamp       time.Time `bson:"timestamp" json:"timestamp"`
}

type Questionnaire struct {
	UserID           int             `json:"user_id" bson:"user_id"`
	Class            string          `json:"class" bson:"class"`
	Region           string          `json:"region" bson:"region"`
	AvgGrade         string          `json:"avg_grade" bson:"avg_grade"`
	FavoriteSubjects []string        `json:"favorite_subjects" bson:"favorite_subjects"`
	HardSubjects     []string        `json:"hard_subjects" bson:"hard_subjects"`
	SubjectScores    map[string]int  `json:"subject_scores" bson:"subject_scores"`
	Interests        []string        `json:"interests" bson:"interests"`
	Values           []string        `json:"values" bson:"values"`
	MBTIScores       map[string]int  `json:"mbti_scores" bson:"mbti_scores"`
	WorkPreferences  WorkPreferences `json:"work_preferences" bson:"work_preferences"`
	TimeStamp        time.Time       `bson:"timestamp" json:"timestamp"`
}

type WorkPreferences struct {
	Role    string `json:"role" bson:"role"`
	Place   string `json:"place" bson:"place"`
	Style   string `json:"style" bson:"style"`
	Exclude string `json:"exclude" bson:"exclude"`
}

type ProfessionRec struct {
	UserID           int                `json:"user_id" bson:"user_id"`
	ProfessionPredic []ProfessionPredic `json:"profession_predic" bson:"profession_predic"`
	TimeStamp        time.Time          `bson:"timestamp" json:"timestamp"`
}

type ProfessionPredic struct {
	Name        string   `json:"name"`
	Score       float64  `json:"score"`
	Positives   []string `json:"positives"`
	Negatives   []string `json:"negatives"`
	Description string   `json:"description"`
}

type Tutor struct {
	UserID     int       `json:"user_id" bson:"user_id"`
	Cource     int       `json:"cource" bson:"cource"`
	University []string  `json:"university" bson:"university"`
	Interests  []string  `json:"interests" bson:"interests"`
	TimeStamp  time.Time `bson:"timestamp" json:"timestamp"`
}

func ConnectMongo(uri string) (*mongo.Client, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(uri))
	if err != nil {
		return nil, err
	}

	err = client.Ping(ctx, nil)
	if err != nil {
		return nil, err
	}

	log.Println("Successfully connected to MongoDB!")
	mongoClient = client
	return client, nil
}

func CheckConnection(client *mongo.Client) error {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	err := client.Ping(ctx, nil)
	if err != nil {
		return err
	}

	log.Println("Connected is working now")
	return nil
}

func AddUniversity(data map[string]interface{}) error {
	collection := mongoClient.Database("smartify").Collection("universities")
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	uni := University{
		ExtraData: make(map[string]interface{}),
	}
	for key, value := range data {
		switch key {
		case "name":
			if name, ok := value.(string); ok {
				uni.Name = name
			}
		case "country":
			if country, ok := value.(string); ok {
				uni.Country = country
			}
		default:
			uni.ExtraData[key] = value
		}
	}
	if uni.Name == "" || uni.Country == "" {
		return fmt.Errorf("name or country are empty")
	}
	data["timestamp"] = time.Now()
	_, err := collection.InsertOne(ctx, data)
	if err != nil {
		return err
	}
	log.Println("Successfully inserted university!")
	return nil
}

func AddProfession(profession Profession) error {
	collection := mongoClient.Database("smartify").Collection("professions")
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	if profession.TimeStamp.IsZero() {
		profession.TimeStamp = time.Now()
	}

	var existing Profession
	err := collection.FindOne(ctx, bson.M{"name": profession.Name}).Decode(&existing)

	if err == mongo.ErrNoDocuments {
		_, err := collection.InsertOne(ctx, profession)
		if err != nil {
			return err
		}
		log.Println("Successfully inserted profession!")
		return nil
	} else if err != nil {
		return err
	} else if profession.TimeStamp.After(existing.TimeStamp) {
		_, updateErr := collection.ReplaceOne(ctx, bson.M{"name": profession.Name}, profession)
		log.Println("Successfully updated profession")
		return updateErr
	}
	log.Println("Profession not updated: older timestamp")
	return nil
}

func AddQuestionnaire(questionnaire Questionnaire) error {
	collection := mongoClient.Database("smartify").Collection("dataset_career_test")
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	if questionnaire.TimeStamp.IsZero() {
		questionnaire.TimeStamp = time.Now()
	}

	var existing Profession
	err := collection.FindOne(ctx, bson.M{"user_id": questionnaire.UserID}).Decode(&existing)

	if err == mongo.ErrNoDocuments {
		_, err1 := collection.InsertOne(ctx, questionnaire)
		if err1 != nil {
			return err1
		}
		log.Println("Successfully inserted questionnaire!")
		return nil
	} else if err != nil {
		return err
	} else if questionnaire.TimeStamp.After(existing.TimeStamp) {
		_, updateErr := collection.ReplaceOne(ctx, bson.M{"user_id": questionnaire.UserID}, questionnaire)
		if updateErr != nil {
			return updateErr
		}
		log.Println("Successfully updated questionnaire!")
		return nil
	}

	log.Println("Questionnaire not updated: older timestamp")
	return nil
}

func AddProfessionRecommendation(p ProfessionRec) error {
	collection := mongoClient.Database("smartify").Collection("profession_recommendation")
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	if p.TimeStamp.IsZero() {
		p.TimeStamp = time.Now()
	}

	var existing Profession
	err := collection.FindOne(ctx, bson.M{"user_id": p.UserID}).Decode(&existing)

	if err == mongo.ErrNoDocuments {
		_, err1 := collection.InsertOne(ctx, p)
		if err1 != nil {
			return err1
		}
		log.Println("Successfully inserted Profession Recommendation!")
		return nil
	} else if err != nil {
		return err
	} else if p.TimeStamp.After(existing.TimeStamp) {
		_, updateErr := collection.ReplaceOne(ctx, bson.M{"user_id": p.UserID}, p)
		if updateErr != nil {
			return updateErr
		}
		log.Println("Successfully updated Profession Recommendation!")
		return nil
	}

	log.Println("Profession Recommendation not updated: older timestamp")
	return nil
}

func AddTutor(t Tutor) error {
	collection := mongoClient.Database("smartify").Collection("tutors")
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	if t.TimeStamp.IsZero() {
		t.TimeStamp = time.Now()
	}

	var existing Tutor
	err := collection.FindOne(ctx, bson.M{"user_id": t.UserID}).Decode(&existing)

	if err == mongo.ErrNoDocuments {
		_, err1 := collection.InsertOne(ctx, t)
		if err1 != nil {
			return err1
		}
		log.Println("Successfully inserted tutor!")
		return nil
	} else if err != nil {
		return err
	} else if t.TimeStamp.After(existing.TimeStamp) {
		_, updateErr := collection.ReplaceOne(ctx, bson.M{"user_id": t.UserID}, t)
		if updateErr != nil {
			return updateErr
		}
		log.Println("Successfully updated tutor!")
		return nil
	}

	log.Println("Tutor not updated: older timestamp")
	return nil
}

func GetTutor(userID int) (Tutor, error) {
	collection := mongoClient.Database("smartify").Collection("tutors")
	ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
	defer cancel()

	var existing Tutor
	err := collection.FindOne(ctx, bson.M{"user_id": userID}).Decode(&existing)

	if err != nil {
		return existing, err
	}

	if err != mongo.ErrNoDocuments {
		log.Println("No tutor information")
		return existing, nil
	}

	log.Println("Successfully get tutor information")
	return existing, nil
}
