from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import and_
from uuid import UUID
from .. dependencies import get_db, get_current_user
from .. models import Card, Column, Board, User
from .. schemas import CardCreate, CardUpdate,ReorderRequest,CardResponse

router = APIRouter(prefix="/cards")


@router.post("/",response_model=CardResponse)
def create_card(
    card: CardCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    column = db.query(Column).filter(Column.id == card.column_id).first()

    if not column:
        raise HTTPException(status_code=404, detail="Column not found")

    board = db.query(Board).filter(Board.id == column.board_id).first()

    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")

    current_count = db.query(Card).filter(Card.column_id == card.column_id).count()
    new_card = Card(
        title=card.title,
        description=card.description,
        column_id=card.column_id,
        due_date=card.due_date,
        order=current_count
    )

    db.add(new_card)
    db.commit()
    db.refresh(new_card)

    return new_card


@router.get("/{card_id}")
def get_card(
    card_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    card = db.query(Card).filter(Card.id == card_id).first()

    if not card:
        raise HTTPException(status_code=404, detail="Card not found")

    column = db.query(Column).filter(Column.id == card.column_id).first()
    board = db.query(Board).filter(Board.id == column.board_id).first()

    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")

    return card



@router.put("/{card_id}")
def update_card(
    card_id: UUID,
    data: CardUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    card = db.query(Card).filter(Card.id == card_id).first()

    if not card:
        raise HTTPException(status_code=404, detail="Card not found")

    column = db.query(Column).filter(Column.id == card.column_id).first()
    board = db.query(Board).filter(Board.id == column.board_id).first()

    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")

    if data.title:
        card.title = data.title

    if data.description:
        card.description = data.description

    if data.column_id:
        card.column_id = data.column_id
    
    if data.due_date:
        card.due_date=data.due_date

    db.commit()
    db.refresh(card)

    return card

@router.patch("/{card_id}/move")
def move_card(
    card_id:UUID,
    data:CardUpdate,  
    db:Session=Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    card= db.query(Card).filter(Card.id == card_id).first()
    if not card:
        raise HTTPException(status_code=404,detail="Card not found")
    
    column = db.query(Column).filter(Column.id == card.column_id).first()
    board = db.query(Board).filter(Board.id == column.board_id).first()
    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to move the card")
    
    if data.column_id is not None:
        card.column_id=data.column_id
    if data.order is not None:
        card.order = data.order
    if data.tags is not None:
        card.tags = data.tags
    if data.due_date is not None:
        card.due_date = data.due_date
    if data.description is not None:
        card.description = data.description
    if data.title is not None:
        card.title = data.title
        
    db.commit()
    db.refresh(card)
    return card
@router.patch("/{card_id}/reorder")
def reorder_card(card_id: UUID, data: ReorderRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    card = db.query(Card).filter(Card.id == card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card Not Found")

    old_column_id = card.column_id
    old_order = card.order
    if old_column_id == data.new_column_id and data.new_order > old_order:
        data.new_order -= 1

    if old_column_id == data.new_column_id:
        if data.new_order > old_order:
            db.query(Card).filter(
                Card.column_id == old_column_id,
                Card.order > old_order,
                Card.order <= data.new_order
            ).update({Card.order: Card.order - 1})
        elif data.new_order < old_order:
            db.query(Card).filter(
                Card.column_id == old_column_id,
                Card.order >= data.new_order,
                Card.order < old_order
            ).update({Card.order: Card.order + 1})
    else:
        db.query(Card).filter(
            Card.column_id == old_column_id,
            Card.order > old_order
        ).update({Card.order: Card.order - 1})

        db.query(Card).filter(
            Card.column_id == data.new_column_id,
            Card.order >= data.new_order
        ).update({Card.order: Card.order + 1})

    card.column_id = data.new_column_id
    card.order = data.new_order

    db.commit()
    db.refresh(card)
    return card

@router.delete("/{card_id}")
def delete_card(
    card_id: UUID,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    card = db.query(Card).filter(Card.id == card_id).first()

    if not card:
        raise HTTPException(status_code=404, detail="Card not found")

    column = db.query(Column).filter(Column.id == card.column_id).first()
    board = db.query(Board).filter(Board.id == column.board_id).first()

    if board.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")

    db.delete(card)
    db.commit()

    return {"message": "Card deleted"}