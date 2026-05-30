from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session,joinedload
from uuid import UUID
from ..dependencies import get_db, get_current_user
from ..models import Column, Board, User
from ..schemas import ColumnCreate

router = APIRouter(prefix="/columns")



@router.post("/")
def create_column(
    column: ColumnCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    board = db.query(Board).filter(Board.id == column.board_id).first()

    if not board:
        raise HTTPException(status_code=404, detail="Board not found")

    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")

    new_column = Column(
        name=column.name,
        board_id=column.board_id
    )

    db.add(new_column)
    db.commit()
    db.refresh(new_column)

    return new_column



@router.get("/{board_id}")
def get_columns(
    board_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    board = db.query(Board).filter(Board.id == board_id).first()

    if not board:
        raise HTTPException(status_code=404, detail="Board not found")

    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")

    columns = db.query(Column).options(joinedload(Column.cards)).filter(Column.board_id == board_id).all()
    return columns

@router.put("/{column_id}")
def update_column(
    column_id: UUID,
    column_data: ColumnCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    db_column = db.query(Column).filter(Column.id == column_id).first()
    
    if not db_column:
        raise HTTPException(status_code=404, detail="Column not found")
    board = db.query(Board).filter(Board.id == db_column.board_id).first()
    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")
 
    db_column.name = column_data.name
    db.commit()
    db.refresh(db_column)
    return db_column

@router.delete("/{column_id}")
def delete_column(
    column_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    column = db.query(Column).filter(Column.id == column_id).first()

    if not column:
        raise HTTPException(status_code=404, detail="Column not found")

    board = db.query(Board).filter(Board.id == column.board_id).first()

    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")

    db.delete(column)
    db.commit()

    return {"message": "Column deleted"}