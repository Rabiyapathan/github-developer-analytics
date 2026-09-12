from flask import Flask
from flask_cors import CORS
import requests
import os
from dotenv import load_dotenv


# Load configuration values from the .env file.
load_dotenv()

app = Flask(__name__)

# Allow the Flutter frontend to communicate with this Flask backend.
CORS(app)


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

# GitHub API base URL.
# Keeping this in .env makes the backend easier to configure.
GITHUB_API_URL = os.getenv(
    "GITHUB_API_URL",
    "https://api.github.com"
)

# Maximum time to wait for a response from GitHub.
REQUEST_TIMEOUT = int(
    os.getenv("REQUEST_TIMEOUT", 10)
)


# ---------------------------------------------------------
# GitHub API Helpers
# ---------------------------------------------------------

def get_github_user(username):
    """Fetch basic profile information for a GitHub user."""

    url = f"{GITHUB_API_URL}/users/{username}"

    try:
        response = requests.get(
            url,
            timeout=REQUEST_TIMEOUT
        )

    except requests.exceptions.RequestException:
        return {
            "error": "Unable to connect to GitHub API"
        }, 503

    # GitHub returns 404 when the username does not exist.
    if response.status_code == 404:
        return {
            "error": "GitHub user not found"
        }, 404

    # Handle other unsuccessful GitHub responses.
    if response.status_code != 200:
        return {
            "error": "GitHub API request failed",
            "status_code": response.status_code
        }, 502

    return response.json(), 200


def get_github_repositories(username):
    """Fetch public repositories for a GitHub user."""

    url = f"{GITHUB_API_URL}/users/{username}/repos"

    try:
        response = requests.get(
            url,
            timeout=REQUEST_TIMEOUT
        )

    except requests.exceptions.RequestException:
        return {
            "error": "Unable to connect to GitHub API"
        }, 503

    # GitHub returns 404 when the username does not exist.
    if response.status_code == 404:
        return {
            "error": "GitHub user not found"
        }, 404

    # Handle other unsuccessful GitHub responses.
    if response.status_code != 200:
        return {
            "error": "GitHub API request failed",
            "status_code": response.status_code
        }, 502

    return response.json(), 200


# ---------------------------------------------------------
# Routes
# ---------------------------------------------------------

@app.route("/")
def home():
    """Simple health-check endpoint."""

    return "GitHub Developer Analytics API is running!"


@app.route("/api/github/<username>")
def github_user(username):
    """Return basic GitHub profile information."""

    user, status_code = get_github_user(username)

    if status_code != 200:
        return user, status_code

    return {
        "username": user["login"],
        "name": user["name"],
        "followers": user["followers"],
        "following": user["following"],
        "public_repositories": user["public_repos"]
    }


@app.route("/api/github/<username>/repositories")
def github_repositories(username):
    """Analyze a user's public GitHub repositories."""

    repos, status_code = get_github_repositories(username)

    if status_code != 200:
        return repos, status_code

    # -----------------------------------------------------
    # Calculate repository statistics
    # -----------------------------------------------------

    total_stars = 0
    total_forks = 0
    total_open_issues = 0

    repositories = []
    languages = {}

    for repo in repos:

        language = repo["language"]

        # Count how many repositories use each language.
        if language is not None:
            languages[language] = (
                languages.get(language, 0) + 1
            )

        # Calculate overall repository statistics.
        total_stars += repo["stargazers_count"]
        total_forks += repo["forks_count"]
        total_open_issues += repo["open_issues_count"]

        # Keep only the repository information
        # required by the Flutter dashboard.
        repositories.append({
            "name": repo["name"],
            "language": repo["language"],
            "stars": repo["stargazers_count"],
            "forks": repo["forks_count"],
            "open_issues": repo["open_issues_count"]
        })

    # -----------------------------------------------------
    # Find the repository with the most stars
    # -----------------------------------------------------

    most_starred = None

    for repo in repos:
        if (
            most_starred is None
            or repo["stargazers_count"]
            > most_starred["stargazers_count"]
        ):
            most_starred = repo

    # -----------------------------------------------------
    # Find the three most recently updated repositories
    # -----------------------------------------------------

    recent_repositories = sorted(
        repos,
        key=lambda repo: repo["updated_at"],
        reverse=True
    )[:3]

    # -----------------------------------------------------
    # Send analytics to the Flutter frontend as JSON
    # -----------------------------------------------------

    return {
        "username": username,

        "total_repositories": len(repositories),

        "total_stars": total_stars,

        "total_forks": total_forks,

        "total_open_issues": total_open_issues,

        "languages": languages,

        "most_starred_repository": {
            "name": most_starred["name"],
            "stars": most_starred["stargazers_count"]
        },

        "recent_repositories": [
            {
                "name": repo["name"],
                "updated_at": repo["updated_at"]
            }
            for repo in recent_repositories
        ],

        "repositories": repositories
    }


# ---------------------------------------------------------
# Start Flask Development Server
# ---------------------------------------------------------

if __name__ == "__main__":
    app.run(debug=True)