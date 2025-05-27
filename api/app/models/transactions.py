from pydantic import BaseModel, Field, field_validator
from typing import List, Dict, Any, Optional
from datetime import date, timedelta, datetime
from decimal import Decimal
from uuid import UUID
from enum import Enum


class TransactionType(str, Enum):
    INCOME = "income"
    EXPENSE = "expense"
    TRANSFER = "transfer_in"
    TRANSFER_OUT = "transfer_out"

class Transaction(BaseModel):
    transaction_id: Optional[UUID] = None
    account_id: UUID
    description: str = Field(
        min_length=1,
        max_length=200,
        description="Brief description of the transaction",
        examples=["Groceries at Walmart", "Monthly Salary"],
        strip_whitespace=True
    )
    amount: Decimal = Field(ge=0, description="Transaction amount")
    transaction_type: TransactionType
    category_id: Optional[UUID] = None
    merchant_name: Optional[str] = Field(
        None,
        max_length=150,
        description="Name of the merchant"
    )
    notes: Optional[str] = None
    is_recurring: bool = False
    transaction_date: date = Field(default_factory=date.today)
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @field_validator('description')
    @classmethod
    def description_not_empty(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Description cannot be empty or contain only whitespace.")
        return value

    class Config:
        orm_mode = True