
# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Install system dependencies required for runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Install your package from PyPI
RUN pip install --no-cache-dir pymemgpt

# Copy the rest of your application's code (if needed)
# COPY . .

# The command to run your application
# Assuming memgpt is the command installed by your package
CMD ["memgpt"]
