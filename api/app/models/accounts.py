from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime
from decimal import Decimal
from uuid import UUID, uuid4
from enum import Enum

class AccountType(str, Enum):
    CHECKING = "checking"
    SAVINGS = "savings"
    CREDIT_CARD = "credit_card"
    CASH = "cash"
    INVESTMENT = "investment"
    LOAN = "loan"
    OTHER = "other"

class Account(BaseModel):
    account_id: Optional[UUID] | None = Field(default_factory=uuid4)
    account_name: str = Field(
        max_length=100,
        description="Unique name of the account"
    )
    account_type: AccountType
    currency: Decimal = Field(
        default="USD",
        description="ISO 4217 currency code"
    )
    notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @field_validator('account_name')
    @classmethod
    def account_name_not_empty(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Account name cannot be empty or contain only whitespace.")
        return value.strip()

    @field_validator('currency')
    @classmethod
    def validate_currency_code(cls, value: str) -> str:
        if not value.isalpha() or not value.isupper():
            raise ValueError("Currency code must be 3 uppercase letters.")
        return value

    class Config:
        from_attributes = True
        use_enum_values = True