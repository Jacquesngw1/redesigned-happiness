import json
import os
from typing import Any, Dict

import httpx

QWEN_URL = os.getenv(
    "QWEN_BASE_URL", "https://dashscope.aliyuncs.com/compatible-mode/v1"
)
DEEPSEEK_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com/v1")
QWEN_KEY = os.getenv("QWEN_API_KEY")
DEEPSEEK_KEY = os.getenv("DEEPSEEK_API_KEY")


def route_ai_task(payload: Dict[str, Any]) -> Dict[str, Any]:
    tokens = payload.get("tokens", 0)
    entities = len(payload.get("entities", []))
    is_english = payload.get("is_english", True)

    if (
        tokens > 8000
        or entities > 75
        or not is_english
        or payload.get("qwen_retry_count", 0) >= 2
    ):
        return call_deepseek(payload)
    return call_qwen(payload)


def call_qwen(payload: Dict[str, Any]) -> Dict[str, Any]:
    headers = {
        "Authorization": f"Bearer {QWEN_KEY}",
        "Content-Type": "application/json",
    }
    body = {
        "model": "qwen-plus",
        "messages": [
            {"role": "system", "content": payload["system_prompt"]},
            {"role": "user", "content": payload["user_prompt"]},
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.2,
    }
    with httpx.Client() as client:
        resp = client.post(
            f"{QWEN_URL}/chat/completions", json=body, headers=headers
        )
        resp.raise_for_status()
        return json.loads(resp.json()["choices"][0]["message"]["content"])


def call_deepseek(payload: Dict[str, Any]) -> Dict[str, Any]:
    headers = {
        "Authorization": f"Bearer {DEEPSEEK_KEY}",
        "Content-Type": "application/json",
    }
    body = {
        "model": "deepseek-chat",
        "messages": [
            {"role": "system", "content": payload["system_prompt"]},
            {"role": "user", "content": payload["user_prompt"]},
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.1,
    }
    with httpx.Client() as client:
        resp = client.post(
            f"{DEEPSEEK_URL}/chat/completions", json=body, headers=headers
        )
        resp.raise_for_status()
        return json.loads(resp.json()["choices"][0]["message"]["content"])
