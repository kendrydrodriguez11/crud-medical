# ===== Base image =====
FROM python:3.11-slim

# ===== Environment variables =====
ENV APP_HOME=/app \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=America/Guayaquil

WORKDIR $APP_HOME

# ===== Install system dependencies =====
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    gcc \
    libgraphviz-dev \
    nano \
    pkg-config \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && ln -fs /usr/share/zoneinfo/America/Guayaquil /etc/localtime \
    && echo "America/Guayaquil" > /etc/timezone

ARG ENV_MODE=dev
ENV ENV_MODE=$ENV_MODE

# Copia los requirements primero para cache de Docker
COPY ./requirements/ /app/requirements/

# Instala dependencias de Python
RUN pip install --upgrade pip setuptools wheel && \
    if [ "$ENV_MODE" = "prod" ]; then \
        pip install --no-cache-dir -r /app/requirements/production.txt ; \
    else \
        pip install --no-cache-dir -r /app/requirements/develop.txt ; \
    fi

# ===== Copy start script and set permissions =====
COPY docker/django/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# ===== Copy project files =====
COPY . /app

# Crea directorios de media y static
RUN mkdir -p /app/staticfiles /app/media

EXPOSE 8000

# ===== CMD: run server based on environment =====
CMD if [ "$ENV_MODE" = "prod" ]; then \
        gunicorn --bind 0.0.0.0:8000 config.wsgi:application ; \
    else \
        /app/start.sh ; \
    fi
