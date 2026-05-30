from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
from ..dependencies import get_db, get_current_user
from ..models import Board, Column, Card, User
from ..schemas import BoardCreate

router = APIRouter(prefix="/boards")


@router.post("/")
def create_board(
    board: BoardCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    new_board = Board(
        name=board.name,
        owner_id=current_user.id
    )

    db.add(new_board)
    db.commit()
    db.refresh(new_board)

    return new_board


@router.get("/")
def get_boards(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    boards = db.query(Board).filter(Board.owner_id == current_user.id).all()

    board_list = []
    for board in boards:
        columns = db.query(Column).filter(Column.board_id == board.id).all()
        serialized_columns = []
        for column in columns:
            cards = db.query(Card).filter(Card.column_id == column.id).order_by(Card.order).all()
            serialized_columns.append({
                "id": str(column.id),
                "name": column.name,
                "boardId": str(column.board_id),
                "cards": [
                    {
                        "id": str(card.id),
                        "title": card.title,
                        "description": card.description,
                        "order": card.order,
                        "columnId": str(card.column_id),
                    }
                    for card in cards
                ],
            })

        board_list.append({
            "id": str(board.id),
            "name": board.name,
            "columns": serialized_columns,
        })

    return board_list

@router.patch("/{board_id}")
def update_board(
    board_id:UUID,
    board_data:BoardCreate,
    db:Session=Depends(get_db),
    current_user:User=Depends(get_current_user)
):
    db_board = db.query(Board).filter(Board.id == board_id).first()
    if not db_board:
        raise HTTPException(status_code=404,detail="Board not found")
    if db_board.owner_id != current_user.id:
        raise HTTPException(status_code=403,detail="Not authorized to rename this board")
    db_board.name = board_data.name
    db.commit()
    db.refresh(db_board)
    return db_board

@router.delete("/{board_id}")
def delete_board(
    board_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    board = db.query(Board).filter(Board.id == board_id).first()

    if not board:
        raise HTTPException(status_code=404, detail="Board not found")

    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")

    db.delete(board)
    db.commit()

    return {"message": "Board deleted"}