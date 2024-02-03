from __future__ import annotations
from dotenv import load_dotenv
from enum import Enum
from functools import wraps
from openai import OpenAI
from typing import Callable, TypedDict
import os
import sys
import textwrap
import psycopg2
import psycopg2.extras


load_dotenv()


class Role(str, Enum):
    SYSTEM = "system"
    USER = "user"
    ASSISTANT = "assistant"


class Message(TypedDict):
    role: Role
    content: str


IntoMessage = Message | Callable[..., Message]


def into_message(value: IntoMessage) -> Message:
    if callable(value):
        return value()
    return value


class ChatGpt:
    client: OpenAI
    quick: bool
    model: str

    def __init__(self):
        self.client = OpenAI(
            api_key=os.getenv("OPENAI_API_KEY"),
            organization=os.getenv("OPENAI_ORGANIZATION_ID"),
        )
        self.quick = False
        self.model = "gpt-3.5-turbo-0125" if self.quick else "gpt-4-0125-preview"

    def ask(self, *messages: IntoMessage) -> str:
        messages = [into_message(message) for message in messages]
        response = self.client.chat.completions.create(
            model=self.model,
            messages=messages,
            stream=True,
        )
        result = ""
        for chunk in response:
            content = chunk.choices[0].delta.content
            if content:
                result += content
                sys.stdout.write(content)
                sys.stdout.flush()
            else:
                sys.stdout.write("\n\n")
        return result


class Database:
    @staticmethod
    def execute(query: str):
        conn = psycopg2.connect(
            dbname="cs452",
            user="cs452",
            password="cs452",
            host="localhost",
            port=15432,
        )
        cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cursor.execute(query)
        try:
            results = cursor.fetchall()
            results = [dict(row) for row in results]
        except psycopg2.ProgrammingError as e:
            if "no results to fetch" in str(e):
                conn.commit()
                cursor.close()
                conn.close()
                return "Query executed successfully. No results to fetch."
            else:
                raise e
        conn.commit()
        cursor.close()
        conn.close()
        return results


def message(role: Role):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            parts = func(*args, **kwargs)
            content = '\n'.join([textwrap.dedent(part) for part in parts])
            return Message(role=role, content=content)
        return wrapper
    return decorator


@message(Role.SYSTEM)
def system_message() -> Message:
    yield """
        You will be generated SQL queries based on input for a postgres 16 database:
        
        When responding, try to follow this style guide:
        - All SQL keywords and functions should be uppercase
        - Identifiers should be quoted
        - Avoid using aliases unless there are multiple of the same table in the query, in which case append a number to the table name
        - Never abbreviate names
        - All queries should be immediately executable, so don't include any comments or variables that are not defined in the query
        - Keep the response as clean and concise as possible, but aim for fast execution time
        - Don't include any non-sql code like Markdown code blocks
        - If there are more than one columns, put each on a new line for readability
        - Always use snake case for column names in select statements

        Here is the database schema:
    """
    with open("schema.sql") as f:
        yield f.read()


@message(Role.USER)
def question_message(question: str) -> Message:
    yield """
        When answering this question, provide only the SQL query that would answer the question.
        Do not include any other information in your response.

        Translate this question into a SQL query:
    """
    yield question


@message(Role.ASSISTANT)
def friendly_response_message(question: str, results) -> Message:
    yield "Given the following prompt:"
    yield question
    yield "The following results were generated:"

    if isinstance(results, list):
        # make it easier for chatgpt to analyze by including index numbers
        for i, result in enumerate(results):
            yield f"Row {i}: {result}"
    else:
        yield str(results)
    
    yield """
        Create a user-friendly interpretation of the results.
        Avoid using any SQL code, jargon, or special characters.
        A non-technical person should be able to understand the response.
        Still try to be detailed.
        If it makes sense for the generated data, create a table of the data in a human-readable format.
        The output will be displayed on a console, so don't include markdown.
        If a table is shown, try to use box drawing characters.
        If many rows are return, also include a summary of the data.
        If data is truncated, include both ends of the range.
    """


def main():
    chat = ChatGpt()

    question = """
        Get a list of artist whose posts have received the most favorites in the past month. 
        Get the name of each artist, not their ID.
        Include the total number of favorites for each artist and sort them in descending order.
        Limit to the top 5 artists.
    """

    query = chat.ask(
        system_message,
        question_message(question),
    )

    if not query:
        print("No query was generated.")
        return

    results = Database.execute(query)

    if not results:
        print("No database results were returned.")
        return

    chat.ask(
        system_message,
        friendly_response_message(question, results),
    )


if __name__ == "__main__":
    main()
