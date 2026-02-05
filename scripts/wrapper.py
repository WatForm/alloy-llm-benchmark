#!/usr/bin/env python3
"""
Minimal version: Simple file concatenation.
"""

import sys

def main():
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} PREFIX CONTENT SUFFIX OUTPUT")
        sys.exit(1)
    
    prefix_file, content_file, suffix_file, output_file = sys.argv[1:5]
    
    try:
        # Read files
        with open(prefix_file, 'r') as f:
            prefix = f.read()
        
        with open(content_file, 'r') as f:
            content = f.read()
        
        with open(suffix_file, 'r') as f:
            suffix = f.read()
        
        # Write concatenated result
        with open(output_file, 'w') as f:
            f.write(prefix + content + suffix)
        
        print(f"Created: {output_file}")
        
    except FileNotFoundError as e:
        print(f"Error: File not found - {e.filename}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()