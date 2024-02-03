import os
import sys
import time
import psycopg2
from openai import OpenAI

import prompter

client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    organization=os.getenv("OPENAI_ORGANIZATION_ID"),
)
ai_model = "gpt-4-0125-preview"


class Role:
    SYSTEM = "system"
    USER = "user"
    ASSISTANT = "assistant"


def message(role: str, content: str) -> dict:
    return {
        "role": role,
        "content": content
    }


def requires_followup(prompt: str) -> bool:
    response = client.chat.completions.create(
        model=ai_model,
        messages=[
            message(Role.SYSTEM, prompter.system_message()),
            message(Role.ASSISTANT, prompter.should_followup(prompt)),
        ],
        stream=False,
    )
    content = response.choices[0].message.content
    if "FALSE" in content.upper():
        return None
    return content


def generate_query(prompt: str, additional_info) -> str:
    messages = [message(Role.SYSTEM, prompter.system_message())]

    for info in additional_info:
        messages.append(message(Role.ASSISTANT, info["clarification"]))
        messages.append(message(Role.USER, info["response"]))

    messages.append(message(Role.ASSISTANT, prompter.select_prompt(prompt)))

    response = client.chat.completions.create(
        model=ai_model,
        messages=messages,
        stream=False,
    )
    return response.choices[0].message.content


def main():
    question = "Create a SQL query that returns all the tags for a given post id"

    additional_info = []
    while followup := requires_followup(question):
        print(followup)
        response = input("Response: ")
        additional_info.append({
            "clarification": followup,
            "response": response
        })

    result = generate_query(question, additional_info)
    print(result)


if __name__ == "__main__":
    main()
