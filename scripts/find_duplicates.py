import os
import hashlib
from collections import defaultdict
import shutil
from pathlib import Path

def calculate_file_hash(filepath):
    """Calculate MD5 hash of file content."""
    hash_md5 = hashlib.md5()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def find_duplicate_files(root_dir):
    """Find duplicate files based on content and similar names."""
    # Dictionary to store files by size
    size_dict = defaultdict(list)
    # Dictionary to store files by hash
    hash_dict = defaultdict(list)
    # Dictionary to store similar named files
    name_dict = defaultdict(list)
    
    # Skip .git directory and archive directory
    skip_dirs = {'.git', 'archive', 'venv', '__pycache__'}
    
    # Walk through directory
    for dirpath, dirnames, filenames in os.walk(root_dir):
        # Skip specified directories
        dirnames[:] = [d for d in dirnames if d not in skip_dirs]
        
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            
            # Skip if file is a symbolic link
            if os.path.islink(filepath):
                continue
                
            # Get file size
            file_size = os.path.getsize(filepath)
            size_dict[file_size].append(filepath)
            
            # Store similar named files
            base_name = filename.lower().replace('kopie', '').replace('copy', '').replace('backup', '').strip()
            name_dict[base_name].append(filepath)
    
    # Find duplicates by content
    for size, size_files in size_dict.items():
        if len(size_files) > 1:
            for filepath in size_files:
                file_hash = calculate_file_hash(filepath)
                hash_dict[file_hash].append(filepath)
    
    return hash_dict, name_dict

def write_report(hash_dict, name_dict, output_file):
    """Write duplicate findings to a report file."""
    with open(output_file, 'w') as f:
        f.write("=== Duplicate Files Report ===\n\n")
        
        f.write("1. Content-identical files:\n")
        for file_hash, files in hash_dict.items():
            if len(files) > 1:
                f.write(f"\nDuplicate set (identical content):\n")
                for filepath in files:
                    f.write(f"  - {filepath}\n")
        
        f.write("\n2. Similarly named files:\n")
        for base_name, files in name_dict.items():
            if len(files) > 1:
                f.write(f"\nPotential duplicates (similar names):\n")
                for filepath in files:
                    f.write(f"  - {filepath}\n")

def main():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    archive_dir = os.path.join(root_dir, 'archive')
    
    # Ensure archive directory exists
    os.makedirs(archive_dir, exist_ok=True)
    
    # Find duplicates
    hash_dict, name_dict = find_duplicate_files(root_dir)
    
    # Write report
    report_path = os.path.join(root_dir, 'duplicate_files_report.txt')
    write_report(hash_dict, name_dict, report_path)
    
    print(f"Report generated at: {report_path}")

if __name__ == "__main__":
    main() 