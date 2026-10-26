FROM python:3.13-slim

# Install git and wget
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Hugo extended version
RUN wget -O hugo.deb https://github.com/gohugoio/hugo/releases/download/v0.168.0/hugo_extended_0.168.0_linux-amd64.deb && \
    echo "b7cd5087c39bf5584e40180bd04fab0c6fb19f2913cd63121da8663e112a08db  hugo.deb" | sha256sum -c - && \
    dpkg -i hugo.deb && \
    rm hugo.deb

RUN pip install --no-cache-dir Flask==3.1.3 gunicorn==26.2.0 && \
    rm -rf /usr/local/lib/python3.13/ensurepip

WORKDIR /app
COPY webhook-listener.py .
COPY build.sh .
RUN chmod +x build.sh

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "webhook-listener:app"]
