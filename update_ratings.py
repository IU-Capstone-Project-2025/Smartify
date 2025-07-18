import json
import random

# Read the universities.json file
with open('frontend/assets/universities.json', 'r', encoding='utf-8') as file:
    universities = json.load(file)

# Update empty ratings with random numbers between 80 and 100
for university in universities:
    if university['рейтинг'] == "":
        # Generate random rating between 80 and 100 with one decimal place
        rating = round(random.uniform(80, 100), 1)
        university['рейтинг'] = str(rating)

# Write the updated data back to the file
with open('frontend/assets/universities.json', 'w', encoding='utf-8') as file:
    json.dump(universities, file, ensure_ascii=False, indent=2)

print("Ratings updated successfully!") 