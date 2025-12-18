<img width="2816" height="1536" alt="BetterTune Logo" src="https://github.com/user-attachments/assets/704034b2-1de2-4e48-9bd7-e55035652cb2" />

# BetterTune

A modern, beautiful, and feature-rich Jellyfin music client built with Flutter.

BetterTune aims to provide a premium audio experience for Jellyfin users, featuring a clean UI inspired by modern design principles, service-oriented architecture, and seamless integration.

## Features

### 🎨 Modern UI & UX

- **Jellyfin-Inspired Theme**: A deep blue and dark theme that feels at home with the Jellyfin ecosystem.
- **Light & Dark Mode**: Fully supported dynamic theming.
- **Clean Architecture**: Built with a scalable Service-Oriented Architecture.

### 🔐 Authentication

- **Easy Onboarding**: Simple setup screen for your Jellyfin Server URL, Username, and Password.
- **Persistent Session**: Auto-login functionality using secure storage.
- **Real-Time Validation**: Validates credentials directly against your Jellyfin server.

### 🎵 Player & Library

- **Music Library**: Browse Songs, Albums, Artists, and Playlists.
- **Queue Management**: Drag-and-drop reordering, shuffle (Fisher-Yates), and repeat modes.
- **Selection Mode**: Multi-select support for bulk actions (Add to Playlist/Queue).
- **Playlists**: Create and manage playlists directly from the app.

## Architecture

BetterTune uses a modular Service-Oriented Architecture to separate concerns and ensure scalability:

- **AuthService**: Manages authentication state and session persistence.
- **SongsService**: Handles fetching and caching of music data (Tracks, Albums, Artists).
- **PlaylistService**: Manages playlist CRUD operations.
- **ApiClient**: A centralized HTTP client that handles request headers and Jellyfin authorization.

## Getting Started

### Download Release

Checkout the latest release : [Here](https://github.com/OpyrusDevOp/BetterTune/releases)

### BUILD FROM SOURCE

1. **Clone the repository**

    ```bash
    git clone https://github.com/OpyrusDevOp/bettertune.git
    ```

2. **Install Dependencies**

    ```bash
    flutter pub get
    ```

3. **Run the app**

    ```bash
    flutter run
    ```
