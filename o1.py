from github import Github
import requests
import os
from urllib.parse import urlparse
from pathlib import Path

def download_image(url, save_dir):
    """Download image and save to specified directory"""
    try:
        response = requests.get(url)
        if response.status_code == 200:
            # Extract filename from URL
            filename = os.path.join(save_dir, os.path.basename(urlparse(url).path))
            with open(filename, 'wb') as f:
                f.write(response.content)
            print(f"Successfully downloaded: {filename}")
            return True
    except Exception as e:
        print(f"Download failed: {url}")
        print(f"Error: {str(e)}")
        return False

def get_victoria_peak_photos():
    # Set your GitHub token
    token = os.environ.get('GITHUB_TOKEN')
    if not token:
        raise ValueError("Please set the GITHUB_TOKEN environment variable")

    # Create Github instance
    g = Github(token)

    # Specify repository and issue
    repo = g.get_repo("Caulfield3/CityuISM")
    issue = repo.get_issue(number=1)

    # Create save directory
    save_dir = "victoria_peak_photos"
    os.makedirs(save_dir, exist_ok=True)

    # Extract image URLs from issue body
    body = issue.body
    
    # In Markdown, images are formatted as ![alt](url)
    # We need to extract all image URLs
    import re
    image_urls = re.findall(r'!\[.*?\]\((.*?)\)', body)

    if not image_urls:
        print("No image URLs found")
        return

    # Download all images
    for url in image_urls:
        download_image(url, save_dir)

    print(f"Download complete! Images saved in {save_dir} directory")

if __name__ == "__main__":
    try:
        get_victoria_peak_photos()
    except Exception as e:
        print(f"Program execution error: {str(e)}")
