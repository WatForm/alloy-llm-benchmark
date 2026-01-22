#!/usr/bin/env python3
"""
Alloy Model Scoring Script

Compares an LLM-generated Alloy file against an original reference file
and outputs a score based on Alloy Diff equivalence checking.

Usage:
    python score.py <original_file> <generated_file>
"""

import subprocess
import sys
from pathlib import Path

# Configuration constants
SCOPE = 3
SOLVER = "sat4j"
TIMEOUT = 300  # 5 minutes
JAR_PATH = Path(__file__).parent / "alloy-diff.jar"


def compute_alloy_diff_score(original_file: str, generated_file: str) -> dict:
    """
    Compute equivalence score using Alloy Diff.
    
    Args:
        original_file: Path to the original Alloy file
        generated_file: Path to the generated Alloy file
        
    Returns:
        dict: Contains 'score' and 'max_score'
    """
    original_path = Path(original_file)
    generated_path = Path(generated_file)
    
    # Validate input files
    if not original_path.exists():
        raise FileNotFoundError(f"Original file not found: {original_file}")
    if not generated_path.exists():
        raise FileNotFoundError(f"Generated file not found: {generated_file}")
    if not JAR_PATH.exists():
        raise FileNotFoundError(f"Alloy Diff JAR not found at: {JAR_PATH}")
    
    # Run alloy-diff
    cmd = [
        "java",
        "-cp", str(JAR_PATH),
        "org.alloytools.alloy.diff.ModuleDiff",
        str(original_path),
        str(generated_path),
        "Equivalence",
        str(SCOPE),
        "false",
        SOLVER
    ]
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=TIMEOUT
        )
        
        output = result.stdout + result.stderr
        
        # Check if models are equivalent
        equivalent = "The two modules are equivalent." in output
        
        return {
            'score': 1 if equivalent else 0,
            'max_score': 1
        }
        
    except subprocess.TimeoutExpired:
        return {
            'score': 0,
            'max_score': 1
        }
    except Exception:
        return {
            'score': 0,
            'max_score': 1
        }


def main():
    if len(sys.argv) != 3:
        print("Usage: python score.py <original_file> <generated_file>", file=sys.stderr)
        return 1
    
    original_file = sys.argv[1]
    generated_file = sys.argv[2]
    
    try:
        result = compute_alloy_diff_score(original_file, generated_file)
        print(f"{result['score']}/{result['max_score']}")
        return 0
        
    except FileNotFoundError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
