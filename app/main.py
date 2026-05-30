from fastapi import FastAPI
from app.db import engine, Base
from app.routes import auth,user,board,column,card
from fastapi.middleware.cors import CORSMiddleware
from app.models import User,Board,Column,Card


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

Base.metadata.create_all(bind=engine)

@app.get("/")
def root():
    return {"message": "Kanban API Running "}

app.include_router(auth.router)
app.include_router(user.router)
app.include_router(board.router)
app.include_router(column.router)
app.include_router(card.router)
