from sqlalchemy import Column as SQLColumn, String, DateTime,ForeignKey,Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.db import Base

class User(Base):
    __tablename__ = "users"

    id = SQLColumn(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = SQLColumn(String, unique=True, index=True, nullable=False)
    password_hash = SQLColumn(String, nullable=False)
    created_at = SQLColumn(DateTime, default=datetime.utcnow)
    boards = relationship("Board", back_populates="owner")

class Board(Base):
    __tablename__ = "boards"

    id = SQLColumn(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = SQLColumn(String, nullable=False)
    owner_id = SQLColumn(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    owner = relationship("User", back_populates="boards")
    created_at = SQLColumn(DateTime, default=datetime.utcnow)
    columns = relationship( "Column",back_populates="board",cascade="all, delete-orphan")

class Column(Base):
    __tablename__ = "columns"
    id = SQLColumn(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = SQLColumn(String, nullable=False)
    board_id = SQLColumn(UUID(as_uuid=True), ForeignKey("boards.id"), nullable=False)
    board = relationship("Board", back_populates="columns")
    created_at = SQLColumn(DateTime, default=datetime.utcnow)
    cards = relationship("Card",back_populates="column",cascade="all, delete-orphan")

class Card(Base):
    __tablename__ = "cards"

    id = SQLColumn(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = SQLColumn(String, nullable=False)
    description = SQLColumn(String, nullable=True)
    order=SQLColumn(Integer,default=0)
    tags=SQLColumn(String,nullable=True)
    due_date=SQLColumn(DateTime,nullable=True)
    column_id=SQLColumn(UUID(as_uuid=True),ForeignKey("columns.id"))
    created_at = SQLColumn(DateTime, server_default=func.now())
    column=relationship("Column",back_populates="cards")
    