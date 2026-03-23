FROM python:3.12-slim

ENV PYTHONPATH=/app

WORKDIR /app

RUN pip install uv

COPY . .

RUN uv sync

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
