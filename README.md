# Dollar Blue - README

<div align="center">
<img src="https://github.com/SebasYa/DollarBlue/blob/main/DollarBlue/Assets.xcassets/AppIcon.appiconset/1024.png?raw=true" alt="Icono de la Aplicación" width="300">
</div>

- **Swift** ![Swift](https://img.shields.io/badge/Swift-FA7343?logo=swift&logoColor=white&style=flat)
- **SwiftUI** ![SwiftUI](https://img.shields.io/badge/SwiftUI-00BFFF?logo=swift&logoColor=white&style=flat)
- **Combine** ![Combine](https://img.shields.io/badge/Combine-ff4b4b?logo=swift&logoColor=white&style=flat)
- **Xcode** ![Xcode](https://img.shields.io/badge/Xcode-1575F9?style=for-the-badge&logo=xcode&logoColor=white&style=flat)

## Description

DollarBlue is an iOS application that allows users to get the current exchange rates of the dollar in Argentina. This app displays different exchange rates, provides an intuitive and user-friendly interface, and includes a calculator for currency conversion.

<img src="https://github.com/SebasYa/DollarBlue/blob/main/DollarBlueGif.gif" alt="App Demo" width="250"/> <img src="https://github.com/SebasYa/DollarBlue/blob/main/WatchGit.gif" alt="App Demo" width="200"/>


## Features

- **Exchange Rate Display**: Shows current exchange rates for various dollar types (blue, official, tourist, etc.).
- **Real-Time Updates**: Fetches and displays the latest exchange rates from reliable sources.
- **Intuitive Interface**: Clean and easy-to-use design for an optimal user experience.
- **Dark Mode**: Change & Save dark and light modes with a button.
- **Currency Conversion Calculator**: Allows users to convert between pesos and dollars with a simple button click.
- **@Observable**: Employs Swift’s modern @Observable property wrapper for efficient state management and enhanced reactivity within the application.
- **URLSession**: Utilizes URLSession for handling network requests, ensuring robust and secure data fetching from remote servers.
- **UserDefaults**: Leverages UserDefaults to persist user preferences and application settings for a consistent user experience across sessions.

## Error Handling

The application incorporates comprehensive error handling mechanisms to maintain a seamless user experience. In the event of network connectivity issues or data retrieval failures, users are promptly informed via user-friendly alerts, ensuring they are aware of any problems and can take appropriate action.

## Installation

1. **Clone the repository**:

    ```bash
    git clone https://github.com/SebasYa/DollarBlue.git
    ```

2. **Open the project in Xcode**:
    - Navigate to the cloned project directory and open `DollarBlue.xcodeproj`.

3. **Run the application**:
    - Select your target device and run the application.

## Usage

1. **App Launch**:
    - On launching the app, you will see a list of current dollar exchange rates.

2. **Refresh Rates**:
    - The app automatically fetches the latest rates on startup. You can manually refresh the rates by pulling down the list.

3. **Currency Conversion**:
    - Use the built-in calculator to convert between pesos and dollars. Enter the amount and the result will update in real-time. Use the toggle button to switch between entering dollars and getting pesos or entering pesos and getting dollars.

## Contribution

Contributions are welcome! If you would like to contribute to this project, please follow these steps:

1. **Fork the repository**.
2. **Create a branch** for your feature (`git checkout -b feature/new-feature`).
3. **Make your changes** and commit them (`git commit -m 'Add new feature'`).
4. **Push your changes** to your fork (`git push origin feature/new-feature`).
5. **Create a Pull Request** on GitHub.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
