# Use the official Flutter Docker image
FROM cirrusci/flutter:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the Flutter project files into the container
COPY . .

# Enable Flutter in a headless environment
RUN flutter config --no-analytics

# Get project dependencies
RUN flutter pub get

# Build the release APK
RUN flutter build apk --release

# The APK will be in build/app/outputs/flutter-apk/
CMD ["ls", "-l", "build/app/outputs/flutter-apk/"]
