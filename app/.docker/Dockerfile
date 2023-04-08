FROM python:3.11-slim as python_builder
WORKDIR /app
RUN apt update && apt install -y make
COPY ../pyproject.toml ../poetry.lock ./
RUN pip install poetry \
    && poetry config virtualenvs.create false \
    && poetry install


FROM python_builder as python_runner
COPY ../ .
WORKDIR /app/src
EXPOSE 8501

ENTRYPOINT ["streamlit", "run", "main.py"]
