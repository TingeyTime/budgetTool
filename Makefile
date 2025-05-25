.PHONY: preview all api frontend

api:
	cd api && uvicorn main:app --reload

frontend:
	cd frontend && streamlit run app.py

all: 
	$(MAKE) -j2 api frontend

preview:
	-docker-compose up --build