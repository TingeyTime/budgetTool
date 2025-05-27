from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional
from datetime import date, datetime
from uuid import UUID, uuid4
from decimal import Decimal

class BudgetPeriod(BaseModel):
    budget_period_id: Optional[UUID] = Field(default_factory=uuid4)
    period_name: str = Field(
        max_length=100,
        description='Name of the budget period, e.g., "May 2025", "Q2 2025"'
    )
    start_date: date
    end_date: date
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @field_validator('period_name')
    @classmethod
    def period_name_not_empty(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Period name cannot be empty or contain only whitespace.")
        return value.strip()

    @model_validator(mode='after')
    def check_dates(self) -> 'BudgetPeriod':
        if self.start_date and self.end_date and self.end_date < self.start_date:
            raise ValueError("End date must be on or after start date.")
        return self

    class Config:
        from_attributes = True

class Budget(BaseModel):
    budget_id: Optional[UUID] = Field(default_factory=uuid4)
    budget_period_id: UUID
    category_id: UUID
    allocated_amount: Decimal = Field(
        ge=0,
        description="The amount allocated for this budget item."
    )
    notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

