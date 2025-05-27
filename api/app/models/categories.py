from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional
from datetime import date, datetime
from uuid import UUID, uuid4
from decimal import Decimal



class Category(BaseModel):
    category_id: Optional[UUID] = Field(default_factory=uuid4)
    category_name: str = Field(max_length=100)
    parent_category_id: Optional[UUID] = None
    notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    @field_validator('category_name')
    @classmethod
    def category_name_not_empty(cls, value: str) -> str:
        if not value.strip():
            raise ValueError("Category name cannot be empty or contain only whitespace.")
        return value.strip()

    class Config:
        from_attributes = True