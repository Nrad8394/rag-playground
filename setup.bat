@echo off
REM RAGFlow Setup Script for Windows

echo Setting up RAGFlow environment...

REM Create necessary directories
if not exist "conf" mkdir conf
if not exist "data" mkdir data

echo.
echo Windows environment detected
echo Using Docker networking - no hosts file modification needed
echo.
echo Setup complete! You can now run: docker-compose up -d
echo.
echo Note: If you encounter issues, ensure Docker Desktop is running
echo and has sufficient resources (4+ CPU cores, 16+ GB RAM)

pause
