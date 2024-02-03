def system_message() -> str:
    with open("schema.sql") as f:
        schema = f.read()

    return f"""
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
    {schema}
    """


def should_followup(prompt: str) -> str:
    return f"""
    Does the following request have any additional requirements?
    Are there any unknown variables that need to be provided or any other information that would be helpful to know?
    What would prevent this request from returning with executable SQL code?
    If there are any variables that need to be provided, respond with the variable name and the type of data it should be.

    If not, respond with exactly "FALSE" and nothing else.
    Otherwise, return a response that would help clarify the request.

    Not the the actual request will be provided in the next prompt. So DO NOT respond with SQL code here.
    """


def user_prompt(prompt: str) -> str:
    return f"""
    When answering this question, provide only the SQL query that would answer the question.
    Do not include any other information in your response.

    Translate this question into a SQL query:
    {prompt}
    """

def friendly_response_prompt(results: str) -> str:
    return f"""
    Generate a friendly response based on these results:
    
    {results}
    """
