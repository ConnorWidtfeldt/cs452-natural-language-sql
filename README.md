# CS452 Natural Language SQL Project
by Connor Widtfeldt

The CS452 Natural Language SQL Project aims to bridge the gap between natural language questions and SQL queries using AI, specifically leveraging OpenAI's GPT models. This project includes a PostgreSQL database setup, a Python backend for processing and converting natural language into SQL, and a Ruby script for generating mock data to populate the database.

## Prerequisites

**Note:** This developed on a Ubuntu 22 install. So your mileage may vary.

Before you get started, ensure you have the following installed on your system:

- Docker and Docker Compose
- Python 3.10 or higher
- Ruby 3.0 or higher (for data generation)
- Bundler (for Ruby dependencies)

## Setup

1. **Clone the repository:**

```bash
git clone https://github.com/ConnorWidtfeldt/cs452-natural-language-sql.git
cd cs452-natural-language-sql
```

2. **Environment Variables:**

Create a `.env` file in the root directory with your OpenAI api key and organization id:

```
OPENAI_API_KEY=<your_openai_api_key_here>
OPENAI_ORGANIZATION_ID=<your_openai_organization_id_here>
```

3. **Python Virtual Environment and Dependencies:**

Setup a Python virtual environment and install dependencies:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Alternatively you can run `make venv requirements` if you have make installed.

4. **Docker Container for Postgre:**

Launch the Postgre container:

```bash
docker compose up -d
```

5. **Ruby Environment Setup:**

Ensure Bundler is installed and then install Ruby dependencies for data generation:

```bash
bundle install
```

6. **Generate Mock Data:**

Populate the database with mock data:

```bash
ruby generate_data.rb
```
or `make generate_data`

## Usage

After setup, you can run the project to convert natural language questions into SQL queries and execute them against the Postgre database.

```bash
source venv/bin/activate  # If not already activated
python main.py
```

## Project Structure

- [`compose.yaml`](compose.yaml): Docker Compose file for setting up Postgre.
- [`main.py`](main.py): The main Python script interfacing with OpenAI and executing SQL queries.
- [`Makefile`](Makefile): Defines tasks for setting up and running the project.
- [`requirements.txt`](requirements.txt): Python dependencies for the project.
- [`schema.sql`](schema.sql): SQL schema for the database.
- [`generate_data.rb`](generate_data.rb): Ruby script to generate and populate the database with mock data.

## Make Commands

The project comes with a Makefile for convenience:

- `make all`: Runs all setup targets and then runs the main script.
- `make setup`: Prepares the environment, including virtual environment, Docker, and Ruby dependencies.
- `make reset`: Cleans the environment and reruns the setup.
- `make clean`: Removes all components related to the project setup, including Docker containers and the virtual environment.
- `make run`: Executes the main project script.
