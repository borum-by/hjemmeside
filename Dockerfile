FROM python:3.11-slim

# Install git and wget
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Hugo extended version
RUN wget -O hugo.deb https://github.com/gohugoio/hugo/releases/download/v0.131.0/hugo_extended_0.131.0_linux-amd64.deb && \
    dpkg -i hugo.deb && \
    rm hugo.deb

RUN pip install flask

WORKDIR /app
COPY webhook-listener.py .
COPY build.sh .
RUN chmod +x build.sh

CMD ["python", "webhook-listener.py"]