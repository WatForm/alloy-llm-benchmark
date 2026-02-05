import sys
from openai import OpenAI

def main():
    # Check for correct number of arguments
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    # Read API key
    with open("./secret/key", "r") as f:
        key = f.read()

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
        response = client.chat.completions.create(
            model="gpt-5-mini",
            messages=[{"role": "user", "content": prompt}]
        )
        output_text = response.choices[0].message.content
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