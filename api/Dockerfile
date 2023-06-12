# Use the official Python base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file to the working directory
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask app code to the working directory
COPY api.py .

# Expose the port that the Flask app listens on
EXPOSE 5000

# Set the entrypoint command to run the Flask app
CMD ["python", "api.py"]

