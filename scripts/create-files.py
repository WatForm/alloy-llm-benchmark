#!/usr/bin/env python3
"""
Process Alloy (.als) files based on configuration in config.json
"""

import json
import os
import sys
import argparse
from pathlib import Path
import shutil


def load_config(config_path):
    """Load configuration from JSON file"""
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        return config
    except FileNotFoundError:
        print(f"Error: Config file not found at {config_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in config file: {e}")
        sys.exit(1)


def find_als_files(input_folder):
    """Recursively find all .als files in the input folder"""
    als_files = []
    input_path = Path(input_folder)
    
    if not input_path.exists():
        print(f"Error: Input folder '{input_folder}' does not exist")
        sys.exit(1)
    
    # Walk through directory recursively
    for root, dirs, files in os.walk(input_folder):
        for file in files:
            if file.lower().endswith('.als'):
                full_path = Path(root) / file
                als_files.append(full_path)
    
    return als_files


def create_output_folders(config):
    """Create output folders if they don't exist"""
    folders = ['english-summary-folder', 'reconstruction-response-folder']
    
    for folder_key in folders:
        folder_path = config.get(folder_key)
        if folder_path:
            path = Path(folder_path)
            path.mkdir(parents=True, exist_ok=True)
            print(f"Created/verified output folder: {path}")


def create_mirror_files(als_files, config):
    """Create mirror files in output folders"""
    input_folder = Path(config['input-folder'])
    output_english_folder = Path(config['english-summary-folder'])
    output_alloy_folder = Path(config['reconstruction-response-folder'])
    
    created_files = []
    
    for als_file in als_files:
        # Calculate relative path from input folder
        try:
            rel_path = als_file.relative_to(input_folder)
        except ValueError:
            # If file is not relative to input folder, use its name only
            rel_path = Path(als_file.name)
        
        # Create corresponding paths in output folders
        english_file = output_english_folder / rel_path.with_suffix('.md')
        alloy_file = output_alloy_folder / rel_path.with_suffix('.md')
        
        # Create parent directories if they don't exist
        english_file.parent.mkdir(parents=True, exist_ok=True)
        alloy_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Create empty files
        english_file.touch()
        alloy_file.touch()
        
        created_files.append({
            'original': str(als_file),
            'english': str(english_file),
            'alloy': str(alloy_file)
        })
        
        print(f"Created: {english_file}")
        print(f"Created: {alloy_file}")
    
    return created_files


def main():
    parser = argparse.ArgumentParser(
        description='Process Alloy (.als) files based on configuration'
    )
    parser.add_argument(
        'config',
        help='Path to config.json file'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be created without actually creating files'
    )
    
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    
    # Find all .als files
    als_files = find_als_files(config['input-folder'])
    
    if not als_files:
        print(f"No .als files found in {config['input-folder']}")
        sys.exit(0)
    
    print(f"Found {len(als_files)} .als file(s):")
    for file in als_files:
        print(f"  - {file}")
    
    # Create output folders
    if not args.dry_run:
        create_output_folders(config)
    
    # Create mirror files
    if args.dry_run:
        print("\nDRY RUN - Files that would be created:")
        input_folder = Path(config['input-folder'])
        output_english_folder = Path(config['english-summary-folder'])
        output_alloy_folder = Path(config['reconstruction-response-folder'])
        
        for als_file in als_files:
            try:
                rel_path = als_file.relative_to(input_folder)
            except ValueError:
                rel_path = Path(als_file.name)
            
            english_file = output_english_folder / rel_path.with_suffix('.md')
            alloy_file = output_alloy_folder / rel_path.with_suffix(".md")
            
            print(f"  English: {english_file}")
            print(f"  Alloy: {alloy_file}")
            print()
    else:
        print("\nCreating mirror files...")
        created_files = create_mirror_files(als_files, config)
        print(f"\nSuccessfully created {len(created_files) * 2} mirror files")


if __name__ == "__main__":
    main()