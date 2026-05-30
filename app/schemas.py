from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from uuid import UUID

class UserCreate(BaseModel):
    email: str
    password: str 

class UserLogin(BaseModel):
    email: str
    password: str
    
class BoardCreate(BaseModel):
    name: str

class BoardUpdate(BaseModel):
    name:str

class ColumnCreate(BaseModel):
    name: str
    board_id: UUID

class CardCreate(BaseModel):
    title: str
    description: str = None
    column_id: UUID
    due_date:datetime
    
class CardResponse(BaseModel):
    id: UUID
    title:str
    description:str
    column_id: UUID
    order: int
    due_date:Optional[datetime]=None
    created_at: datetime
    
    class config:
        from_attributes = True
        
class CardUpdate(BaseModel):
    column_id: Optional[UUID] = None
    title: str = None
    description:str = None
    order:Optional [int] = None
    tags:Optional [str] = None
    due_date:datetime = None
    
class ReorderRequest(BaseModel):
    new_column_id : UUID
    new_order: Optional[int]=None
