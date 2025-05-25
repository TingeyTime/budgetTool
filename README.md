# Budget Tool

A full-stack personal budgeting application designed to help you manage your finances effectively. This tool provides expense tracking, budget planning, and financial reporting capabilities through an intuitive web interface.

## ✨ Key Features

* **Expense Tracking:** Easily record and categorize your daily expenses
* **Budget Planning:** Set and manage monthly budgets by category
* **Financial Reports:** Generate visual reports and insights about your spending habits
* **Data Export:** Export your financial data in various formats (CSV, PDF)

## 🚀 Technologies

* **Frontend:** [Streamlit](https://streamlit.io/) - For building interactive data apps and dashboards.
* **API:** [FastAPI](https://fastapi.tiangolo.com/) - A modern, fast (high-performance) web framework for building APIs with Python 3.7+ based on standard Python type hints.
* **Database:** [PostgreSQL](https://www.postgresql.org/) - A powerful, open-source object-relational database system.

## 📁 Project Structure

The project is organized into the following directories:

* `./api/`: Contains the FastAPI application, handling all business logic and data interactions.
* `./db/`: Contains PostgreSQL-related configurations, potentially including schema definitions and initial data scripts.
* `./frontend/`: Contains the Streamlit application, providing the user interface.

Each of these directories includes its own `Dockerfile` for containerization during development.

## 📦 Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. The setup process typically takes about 10-15 minutes.

### Prerequisites

Ensure you have the following installed:

* [Docker Desktop](https://www.docker.com/products/docker-desktop/) (v20.10.0 or higher)
* [Make](https://www.gnu.org/software/make/) (v4.0 or higher)
* At least 2GB of free RAM for running all services

### Environment Variables

This project uses a `.env` file to manage environment variables for database credentials and service ports.

1.  **Create a `.env` file:** In the **root directory** of the project, create a file named `.env`.

2.  **Add the following variables:** Copy the content below into your newly created `.env` file. Replace the placeholder values with your desired settings.

    ```env
    # Database Configuration
    POSTGRES_DB=your_database_name
    POSTGRES_USER=your_db_user
    POSTGRES_PASSWORD=your_db_password
    DB_HOST=db # This should match the service name in docker-compose.yml

    # Service Ports
    FRONTEND_PORT=8501
    API_PORT=8000
    ```

    **Important:** Do **not** commit your `.env` file to version control. It should be ignored by Git (add `.env` to your `.gitignore` file).


### Development Setup

1.  **Clone the repository:**

2.  **Build and run the services with Docker Compose:**
    The `docker-compose.yml` in the root directory will orchestrate the startup of all services (database, API, and frontend).

    ```bash
    make preview
    ```
    This command will:
    * Build the Docker images for the `api` and `frontend` services (if not already built or changes detected).
    * Start the PostgreSQL database container.
    * Start the FastAPI service.
    * Start the Streamlit frontend service.

3.  **Access the applications:**
    Once all services are up and running, you can access them at the following URLs:

    * **Streamlit Frontend:** `http://localhost:8501` (default Streamlit port)
    * **FastAPI Documentation (Swagger UI):** `http://localhost:8000/docs` (default FastAPI port)

## 🛠️ Development Workflow

* **API Development:** Make changes within the `api/` directory. FastAPI will typically auto-reload with `uvicorn` if configured within its Dockerfile or entrypoint script.
* **Frontend Development:** Make changes within the `frontend/` directory. Streamlit applications will auto-reload when file changes are detected.
* **Database Migrations:** (Future enhancement) Implement a proper migration strategy (e.g., Alembic for FastAPI) for managing database schema changes.

## 🔒 Security

For security concerns or vulnerability reports, please create an issue with the "security" label or contact the maintainers directly.

## 🙏 Acknowledgments

* Thanks to all contributors who have helped shape this project