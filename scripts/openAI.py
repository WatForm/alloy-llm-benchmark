import sys
import os
import re
import time
import random
from openai import OpenAI


def extract_retry_seconds(error: Exception) -> float | None:
    text = str(error)
    match = re.search(r"try again in\s*([0-9]+(?:\.[0-9]+)?)s", text, re.IGNORECASE)
    if match:
        return float(match.group(1))
    return None


def call_openai_with_retries(
    client: OpenAI,
    prompt: str,
    max_attempts: int,
    base_delay: float,
    max_delay: float,
) -> str:
    for attempt in range(1, max_attempts + 1):
        try:
            response = client.chat.completions.create(
                model="gpt-5.4",
                messages=[{"role": "user", "content": prompt}],
            )
            return response.choices[0].message.content
        except Exception as error:
            if attempt >= max_attempts:
                raise

            hinted_wait = extract_retry_seconds(error)
            backoff_wait = min(max_delay, base_delay * (2 ** (attempt - 1)))
            wait_seconds = max(hinted_wait or 0.0, backoff_wait) + random.uniform(0.0, 0.4)

            print(
                f"OpenAI call failed on attempt {attempt}/{max_attempts}: {error}. "
                f"Retrying in {wait_seconds:.2f}s...",
                file=sys.stderr,
                flush=True,
            )
            time.sleep(wait_seconds)

def main():
    # Check for correct number of arguments
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    max_attempts = int(os.getenv("OPENAI_MAX_ATTEMPTS", "8"))
    base_delay = float(os.getenv("OPENAI_RETRY_BASE_DELAY", "1.0"))
    max_delay = float(os.getenv("OPENAI_RETRY_MAX_DELAY", "20.0"))

    if max_attempts < 1:
        print("Error: OPENAI_MAX_ATTEMPTS must be at least 1")
        sys.exit(1)

    # Read API key
    with open("./secret/key", "r") as f:
        key = f.read().strip()

    # Read prompt from input file
    try:
        with open(input_file, "r") as f:
            prompt = f.read()
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found")
        sys.exit(1)

    # Initialize OpenAI client
    client = OpenAI(api_key=key)

    # Get response from OpenAI
    print("Calling OpenAI API (this may take a while)...", flush=True)
    try:
        output_text = call_openai_with_retries(
            client=client,
            prompt=prompt,
            max_attempts=max_attempts,
            base_delay=base_delay,
            max_delay=max_delay,
        )
        print("Received response from OpenAI", flush=True)
    except Exception as e:
        print(f"Error calling OpenAI API: {str(e)}")
        sys.exit(1)

    # Write output to file
    try:
        with open(output_file, "w") as f:
            f.write(output_text)
        print(f"Successfully wrote output to {output_file}")
    except IOError as e:
        print(f"Error writing to output file: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()