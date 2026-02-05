import re
from typing import List, Dict, Optional


def extract_code_from_string(content: str, 
                           include_language: bool = False,
                           join_with: str = "\n\n") -> str:
    """
    Extract code from triple backtick sections in a string.
    
    Args:
        content: Input string containing markdown/code blocks
        include_language: If True, includes language specification as a comment
        join_with: String to join multiple code blocks with
        
    Returns:
        String containing only the code from triple backtick sections,
        with everything else removed.
    """
    # Pattern to match triple backtick code blocks
    # Handles: ```python\ncode\n```, ```\ncode\n```, ```python code```, etc.
    pattern = r'```\s*(\w+)?\s*\n(.*?)\n```'
    
    # Find all matches
    matches = re.findall(pattern, content, re.DOTALL)
    
    if not matches:
        return ""
    
    extracted_blocks = []
    
    for language, code in matches:
        code = code.strip()
        
        if include_language and language:
            # Add language as comment if specified
            code = f"# Language: {language}\n{code}"
        
        extracted_blocks.append(code)
    
    return join_with.join(extracted_blocks)


