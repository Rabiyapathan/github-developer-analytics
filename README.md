# 📊 GitHub Developer Analytics

A full-stack project that uses the **GitHub REST API** to turn a GitHub profile's repository data into a simple analytics dashboard.

I built this project to get more comfortable with **APIs, JSON data, backend processing, and connecting a Flutter frontend with a Python backend**.

---

## ✨ What it does

Enter a GitHub username and the app fetches their public GitHub data and presents it in one place.

The dashboard currently shows:

* 👤 GitHub profile information
* 📁 Total public repositories
* ⭐ Total stars
* 🍴 Total forks
* 🐛 Open issues
* 💻 Language distribution
* 🏆 Most-starred repository
* 🕒 Recently updated repositories
* 📋 Repository details

---

## 🔄 How it works

The Flutter app sends a request to the Python backend.

The backend communicates with the GitHub REST API, processes the JSON response, and sends the required data back to Flutter.

```text
Flutter App
     ↓
Python / Flask Backend
     ↓
GitHub REST API
     ↓
JSON Response
     ↓
Data Processing
     ↓
Flutter Dashboard
```

---

## 🛠️ Tech Stack

| Technology      | Used for      |
| --------------- | ------------- |
| Flutter / Dart  | Frontend      |
| Python          | Backend logic |
| Flask           | Backend API   |
| GitHub REST API | GitHub data   |
| JSON            | Data exchange |
| HTTP            | Communication |

---

## 📈 Analytics

The project currently processes repository data to calculate:

* Total repositories
* Total stars
* Total forks
* Total open issues
* Programming language distribution
* Most-starred repository
* Recently updated repositories

---

## 📁 Project Structure

```text
github-developer-analytics/
├── backend/
│   ├── app.py
│   └── requirements.txt
│
├── frontend/
│   ├── lib/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── .env
└── .gitignore
```

---

## 🚀 Running the Project

### 1. Start the backend

```bash
cd backend
python app.py
```

The Flask server will run on:

```text
http://127.0.0.1:5000
```

### 2. Start the Flutter app

Open another terminal:

```bash
cd frontend
flutter run -d linux
```

Enter a GitHub username and start exploring the repository data.

---

## 💡 Why I built it

I didn't want to stop at simply fetching a GitHub username and displaying a few profile details.

The idea was to understand the complete flow of:

**API → JSON → Backend Processing → Frontend → Useful Information**

It also gave me hands-on practice with technologies I'm currently exploring for backend, cloud, and DevOps development.

---

## 🔮 What's next?

There are a few things I'd like to explore as the project grows:

* 📊 More detailed repository analytics
* 📈 Visual charts for the collected data
* 🔍 Better repository sorting and filtering
* 🔥 GitHub contribution analysis
* 🐳 Docker support
* ⚙️ GitHub Actions / CI-CD
* ☁️ Cloud deployment

---

## 👨‍💻 Author

**Rabiya Pathan**

Diploma Computer Engineering Student
Interested in **Cloud Computing, Networking & DevOps**

🔗 GitHub: **Rabiyapathan**

---

> Built while learning, experimenting, and turning API data into something useful. 🚀
