import json
import os
import sys
import time
import psycopg2
import psycopg2.extras
from openai import OpenAI

import prompter

gotta_go_fast = False

client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    organization=os.getenv("OPENAI_ORGANIZATION_ID"),
)
ai_model = "gpt-3.5-turbo-0125" if gotta_go_fast else "gpt-4-0125-preview"


class Role:
    SYSTEM = "system"
    USER = "user"
    ASSISTANT = "assistant"


def message(role: str, content: str) -> dict:
    return {
        "role": role,
        "content": content
    }


def ask_the_question(question: str) -> str:
    response = client.chat.completions.create(
        model=ai_model,
        messages=[
            message(Role.SYSTEM, prompter.system_message()),
            message(Role.ASSISTANT, prompter.user_prompt(question)),
        ],
        stream=True,
    )

    query = ""
    for chunk in response:
        content = chunk.choices[0].delta.content
        if content:
            query += content
            sys.stdout.write(content)
            sys.stdout.flush()
        else:
            sys.stdout.write("\n\n")

    return query


def run_query(query: str):
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


def friendly_response(question, results):
    pretty_results = str(results)

    response = client.chat.completions.create(
        model=ai_model,
        messages=[
            message(Role.SYSTEM, prompter.system_message()),
            message(Role.ASSISTANT, prompter.friendly_response_prompt(question, pretty_results)),
        ],
        stream=True,
    )

    for chunk in response:
        content = chunk.choices[0].delta.content
        if content:
            sys.stdout.write(content)
            sys.stdout.flush()
        else:
            sys.stdout.write("\n\n")


def main():
    question = """
        Get all posts (and their score) that have the tag "mountain" with a score higher than 2.
        Sort by score then by creation date.
    """

    query = ask_the_question(question)

    if not query:
        print("No query was generated.")
        return

    results = run_query(query)
    if not results:
        print("No results were returned.")
        return
    
    friendly_response(question, results)


if __name__ == "__main__":
    main()
