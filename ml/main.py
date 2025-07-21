from fastapi import FastAPI, Request
from AI.AI import process_student
import json


with open("database/professions.json", "r", encoding="utf-8") as f:
    PROFESSIONS = json.load(f)

app = FastAPI()

@app.post("/recommend")
async def recommend(req: Request):
    student = await req.json()
    print(student)
    top5 = process_student(student, PROFESSIONS)
    print(top5)
    return top5
