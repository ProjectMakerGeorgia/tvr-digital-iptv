# Project Blueprint

## Overview

This document outlines the plan for developing a Flutter application that includes user authentication against an external API.

## Features

### Implemented

*   **User Authentication:**
    *   Created a login screen with username and password fields.
    *   Implemented an authentication service to handle the login process against the IPTV API.
    *   Created a user model to manage user data (ID, username, email, token).
    *   Upon successful login, the user is navigated to a home screen.
    *   The home screen displays a personalized welcome message with the user's name and email.
    *   Added a logout button to the home screen.
    *   Implemented error handling for incorrect login credentials.
*   **State Management:**
    *   Used the `provider` package to manage the application's authentication state.

### Current Task: None

## Project Structure

```
.
├── lib
│   ├── auth_service.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── user_model.dart
│   └── main.dart
├── pubspec.yaml
└── blueprint.md
```
