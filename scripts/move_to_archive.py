import os
import shutil
from datetime import datetime
from pathlib import Path

def create_archive_structure(archive_dir, original_path):
    """Recreate the original directory structure in the archive."""
    try:
        relative_path = os.path.dirname(original_path)
        archive_path = os.path.join(archive_dir, relative_path)
        os.makedirs(archive_path, exist_ok=True)
        return archive_path
    except Exception as e:
        print(f"Error creating archive structure: {str(e)}")
        return None

def move_to_archive(filepath, archive_dir, reason):
    """Move a file to the archive directory, preserving its directory structure."""
    try:
        if not os.path.exists(filepath):
            print(f"Source file does not exist: {filepath}")
            return False
            
        # Get the relative path from the workspace root
        root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        try:
            relative_path = os.path.relpath(filepath, root_dir)
        except ValueError:
            print(f"File {filepath} is not within the workspace")
            return False
        
        # Create timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Create new filename with timestamp
        filename = os.path.basename(filepath)
        base, ext = os.path.splitext(filename)
        new_filename = f"{base}_{timestamp}{ext}"
        
        # Create archive path maintaining directory structure
        archive_subdir = os.path.join(archive_dir, os.path.dirname(relative_path))
        os.makedirs(archive_subdir, exist_ok=True)
        
        # Full path for archived file
        new_filepath = os.path.join(archive_subdir, new_filename)
        
        # Move file
        print(f"Moving {filepath} to {new_filepath}")
        shutil.move(filepath, new_filepath)
        
        # Log the move
        log_move(filepath, new_filepath, reason)
        
        return True
    except Exception as e:
        print(f"Error moving {filepath}: {str(e)}")
        return False

def log_move(original_path, archive_path, reason):
    """Log file movements to a log file."""
    try:
        root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        log_dir = os.path.join(root_dir, 'archive')
        os.makedirs(log_dir, exist_ok=True)
        log_file = os.path.join(log_dir, 'archive_log.txt')
        
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] Moved:\n  From: {original_path}\n  To: {archive_path}\n  Reason: {reason}\n\n"
        
        with open(log_file, 'a') as f:
            f.write(log_entry)
    except Exception as e:
        print(f"Error logging move: {str(e)}")

def process_duplicates_report(report_file):
    """Process the duplicates report and move files to archive."""
    if not os.path.exists(report_file):
        print(f"Report file not found: {report_file}")
        return
        
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    archive_dir = os.path.join(root_dir, 'archive')
    os.makedirs(archive_dir, exist_ok=True)
    
    try:
        with open(report_file, 'r') as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading report file: {str(e)}")
        return
    
    # Process content-identical files
    try:
        content_section = content.split("1. Content-identical files:")[1].split("2. Similarly named files:")[0]
        duplicate_sets = content_section.strip().split("\nDuplicate set")[1:]
        
        for duplicate_set in duplicate_sets:
            files = [line.strip("  - ").strip() for line in duplicate_set.split("\n") if line.strip().startswith("  - ")]
            if files:
                # Keep the file with the shortest path (assuming it's in the most logical location)
                files.sort(key=len)
                keep_file = files[0]
                print(f"\nKeeping: {keep_file}")
                for file_to_move in files[1:]:
                    print(f"Moving duplicate to archive: {file_to_move}")
                    move_to_archive(file_to_move, archive_dir, "Content duplicate of " + keep_file)
    except Exception as e:
        print(f"Error processing content-identical files: {str(e)}")
    
    # Process similarly named files
    try:
        similar_section = content.split("2. Similarly named files:")[1]
        similar_sets = similar_section.strip().split("\nPotential duplicates")[1:]
        
        for similar_set in similar_sets:
            files = [line.strip("  - ").strip() for line in similar_set.split("\n") if line.strip().startswith("  - ")]
            if files:
                # Keep the file without 'kopie', 'copy', or 'backup' in the name
                files.sort(key=lambda x: 'kopie' in x.lower() or 'copy' in x.lower() or 'backup' in x.lower())
                keep_file = files[0]
                print(f"\nKeeping: {keep_file}")
                for file_to_move in files[1:]:
                    print(f"Moving similar file to archive: {file_to_move}")
                    move_to_archive(file_to_move, archive_dir, "Similar name to " + keep_file)
    except Exception as e:
        print(f"Error processing similarly named files: {str(e)}")

def main():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    report_file = os.path.join(root_dir, 'duplicate_files_report.txt')
    
    if not os.path.exists(report_file):
        print("Please run find_duplicates.py first to generate the duplicates report.")
        return
    
    print("Starting archival process...")
    process_duplicates_report(report_file)
    print("\nArchival process completed. Check archive_log.txt for details.")

if __name__ == "__main__":
    main() 