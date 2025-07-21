## ER Diagram: `users` and `refresh_tokens`

This diagram represents the data model for a user authentication system, consisting of two tables: `users` and `refresh_tokens`.

### Entities

#### **users**
- Stores user account details.
- Key fields:
  - `id`: Unique user ID (Primary Key).
  - `email`: User's email address, unique and validated with a regex pattern.
  - `password_hash`: Hashed password.
  - `first_name`, `last_name`, `middle_name`: User’s name information.
  - `date_of_birth`: User’s date of birth, must be later than `1900-01-01`.
  - `created_at`: Timestamp when the user was created.
  - `last_login`: Timestamp of the user’s last login.
  - `is_active`: Indicates whether the user account is active.
  - `user_role`: Role of the user (student, tutor, or administrator).

#### **refresh_tokens**
- Stores refresh tokens used for session management and re-authentication.
- Key fields:
  - `id`: Unique token record ID (Primary Key).
  - `user_id`: Foreign key referencing `users.id`.
  - `token`: The refresh token string.
  - `expires_at`: When the token expires.
  - `created_at`: When the token was created.

### Relationships
- **users.id → refresh_tokens.user_id**  
  One user can have multiple refresh tokens (one-to-many relationship).

---

## PlantUML Diagram: Database Domain Model

This UML diagram describes domain entities used in the system, representing a data model for educational and career recommendations.

### Entities

#### **University**
- Represents a university entity.
- Fields:
  - `ID`: Unique university identifier.
  - `Name`, `Country`: University details.
  - `TimeStamp`: Record creation/update time.
  - `ExtraData`: Additional data as a flexible key-value store.

#### **UniversityMongo**
- An extended university entity with additional fields for storing information from MongoDB.
- Fields include:
  - `Link`, `Region`, `City`
  - `FoundationYear`, `Dormitory`
  - Various flags like `IsState`, `IsAccredited`
  - Ratings, student counts, price information
  - Contact details like `Phone` and `Address`
  - Lists like `Faculties` and maps like `PassingScores`

#### **Profession**
- Describes a profession.
- Fields:
  - `Name`, `Description`
  - `EgeSubjects`, `MBTITypes`
  - `Interests`, `Values`
  - `Role`, `Place`, `Style`
  - `EducationLevel`, `SalaryRange`
  - `GrowthProspects`
  - `TimeStamp`

#### **Questionnaire**
- Captures user questionnaire data for career guidance.
- Fields:
  - `UserID`: Associated user.
  - School class, region, average grade
  - Lists of favorite and difficult subjects
  - `SubjectScores`: Map of subjects to scores
  - `Interests`, `Values`
  - `MBTIScores`: Map of MBTI results
  - Embedded object: `WorkPreferences`
  - `TimeStamp`

#### **WorkPreferences**
- Embedded within Questionnaire.
- Fields:
  - `Role`, `Place`, `Style`, `Exclude`

#### **ProfessionRec**
- Stores profession recommendations for users.
- Fields:
  - `UserID`
  - List of predicted professions: `ProfessionPredic`
  - `TimeStamp`

#### **ProfessionPredic**
- Represents an individual predicted profession.
- Fields:
  - `Name`, `Score`
  - Positive and negative aspects
  - `Description`
  - `Subsphere`

#### **Tutor**
- Captures data about tutors.
- Fields:
  - `UserID`
  - `Cource` (likely intended as “Course”)
  - List of universities
  - `Interests`
  - `TimeStamp`

#### **User_trackers**
- Stores tracking information for users.
- Fields:
  - `UserID`
  - `Trackers`: list of trackers
  - `TimeStamp`

#### **Teacher**
- Represents information about a teacher.
- Fields:
  - `Name`, `Subject`
  - `Level`, `Price`
  - `City`, `Rating`
  - `AvatarURL`, `Link`
  - `TimeStamp`

### Relationships

- **Questionnaire → WorkPreferences**  
  A Questionnaire contains exactly one WorkPreferences object.

- **ProfessionRec → ProfessionPredic**  
  A ProfessionRec contains multiple predicted professions.