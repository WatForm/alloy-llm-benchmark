#!/usr/bin/env python3
"""Call one configured LLM for a prompt file."""

from __future__ import annotations

import argparse
import importlib
import json
from pathlib import Path
import random
import re
import sys
import time
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlencode
from urllib.request import Request, urlopen


# Add benchmark model aliases here. The command line accepts only these aliases.
MODEL_CONFIGS = {
    # OpenAI GPT-5.6 supports: none, low, medium, high, xhigh, max.
    # GPT-4o mini does not expose a reasoning-effort control.
    "gpt-5-6-sol": {
        "provider": "openai",
        "api_model": "gpt-5.6-sol",
        "reasoning_effort": "high",
    },
    "gpt-5-6-terra": {
        "provider": "openai",
        "api_model": "gpt-5.6-terra",
        "reasoning_effort": "high",
    },
    "gpt-5-6-luna": {
        "provider": "openai",
        "api_model": "gpt-5.6-luna",
        "reasoning_effort": "medium",
    },
    "gpt-4o-mini": {
        "provider": "openai",
        "api_model": "gpt-4o-mini",
    },

    # Gemini 3.1 Pro supports: low, medium, high.
    # Gemini 3.6 Flash supports: minimal, low, medium, high.
    "gemini-pro": {
        "provider": "gemini",
        "api_model": "gemini-3.1-pro-preview",
        "thinking_level": "high",
        "max_output_tokens": 16384,
    },
    "gemini-flash": {
        "provider": "gemini",
        "api_model": "gemini-3.6-flash",
        "thinking_level": "medium",
        "max_output_tokens": 16384,
    },

    # Claude Opus 5 and Sonnet 5 use adaptive thinking plus effort.
    # Opus 5 supports: low, medium, high, xhigh, max.
    # Sonnet 5 supports: low, medium, high, xhigh, max.
    # For xhigh/max, consider raising max_tokens to 64000 or more.
    "claude-opus-5": {
        "provider": "anthropic",
        "api_model": "claude-opus-5",
        "thinking_type": "adaptive",
        "effort": "max",
        "max_tokens": 64000,
    },
    "claude-sonnet": {
        "provider": "anthropic",
        "api_model": "claude-sonnet-5",
        "thinking_type": "adaptive",
        "effort": "high",
        "max_tokens": 16384,
    },

    # Claude Haiku 4.5 does not support named effort levels. It uses manual
    # extended thinking with a token budget. The budget must be >= 1024 and
    # less than max_tokens.
    "claude-haiku": {
        "provider": "anthropic",
        "api_model": "claude-haiku-4-5-20251001",
        "thinking_type": "enabled",
        "thinking_budget_tokens": 8192,
        "max_tokens": 16384,
    },
}

PROVIDER_KEY_FILES = {
    "openai": "openai_key",
    "anthropic": "anthropic_key",
    "gemini": "gemini_key",
}

MAX_API_ATTEMPTS = 8
RETRY_BASE_DELAY_SECONDS = 1.0
RETRY_MAX_DELAY_SECONDS = 20.0
API_TIMEOUT_SECONDS = 600.0


def extract_retry_seconds(error: Exception) -> float | None:
    match = re.search(
        r"try again in\s*([0-9]+(?:\.[0-9]+)?)s",
        str(error),
        re.IGNORECASE,
    )
    return float(match.group(1)) if match else None


def call_with_retries(provider: str, call_func) -> str:
    for attempt in range(1, MAX_API_ATTEMPTS + 1):
        try:
            return call_func()
        except Exception as error:
            if attempt >= MAX_API_ATTEMPTS:
                raise

            hinted_wait = extract_retry_seconds(error)
            backoff_wait = min(
                RETRY_MAX_DELAY_SECONDS,
                RETRY_BASE_DELAY_SECONDS * (2 ** (attempt - 1)),
            )
            wait_seconds = (
                max(hinted_wait or 0.0, backoff_wait)
                + random.uniform(0.0, 0.4)
            )

            print(
                f"{provider} call failed on attempt "
                f"{attempt}/{MAX_API_ATTEMPTS}: {error}. "
                f"Retrying in {wait_seconds:.2f}s...",
                file=sys.stderr,
                flush=True,
            )
            time.sleep(wait_seconds)

    raise RuntimeError("unreachable")


def get_api_key(provider: str) -> str:
    key_path = (
        Path(__file__).resolve().parent.parent
        / "secret"
        / PROVIDER_KEY_FILES[provider]
    )

    if not key_path.exists():
        raise RuntimeError(
            f"missing {provider} API key: create "
            f"{key_path.relative_to(key_path.parent.parent)}"
        )

    key = key_path.read_text(encoding="utf-8").strip()
    if not key:
        raise RuntimeError(
            f"{key_path.relative_to(key_path.parent.parent)} is empty"
        )

    return key


def post_json(
    url: str,
    headers: dict[str, str],
    payload: dict,
) -> dict:
    request = Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            **headers,
        },
        method="POST",
    )

    try:
        with urlopen(
            request,
            timeout=API_TIMEOUT_SECONDS,
        ) as response:
            response_body = response.read().decode("utf-8")
    except HTTPError as error:
        error_body = error.read().decode(
            "utf-8",
            errors="replace",
        )
        raise RuntimeError(
            f"HTTP {error.code}: {error_body}"
        ) from error
    except URLError as error:
        raise RuntimeError(str(error)) from error

    return json.loads(response_body)


def call_openai(
    prompt: str,
    config: dict,
    key: str,
) -> str:
    try:
        OpenAI = importlib.import_module("openai").OpenAI
    except ImportError as error:
        raise RuntimeError(
            "OpenAI models require the openai package. "
            "Run: pip install -U openai"
        ) from error

    client = OpenAI(api_key=key)

    request = {
        "model": config["api_model"],
        "input": prompt,
    }

    if "reasoning_effort" in config:
        request["reasoning"] = {
            "effort": config["reasoning_effort"],
        }

    response = client.responses.create(**request)

    text = (response.output_text or "").strip()
    if not text:
        raise RuntimeError(
            f"OpenAI response did not contain text: {response}"
        )

    return text


def call_anthropic(
    prompt: str,
    config: dict,
    key: str,
) -> str:
    payload = {
        "model": config["api_model"],
        "max_tokens": config["max_tokens"],
        "messages": [
            {
                "role": "user",
                "content": prompt,
            }
        ],
    }

    thinking_type = config.get("thinking_type")

    if thinking_type == "adaptive":
        payload["thinking"] = {
            "type": "adaptive",
        }

    elif thinking_type == "enabled":
        budget_tokens = config.get("thinking_budget_tokens")

        if not isinstance(budget_tokens, int):
            raise ValueError(
                "manual Anthropic thinking requires "
                "thinking_budget_tokens"
            )

        if budget_tokens < 1024:
            raise ValueError(
                "Anthropic thinking_budget_tokens must be "
                "at least 1024"
            )

        if budget_tokens >= config["max_tokens"]:
            raise ValueError(
                "Anthropic thinking_budget_tokens must be "
                "less than max_tokens"
            )

        payload["thinking"] = {
            "type": "enabled",
            "budget_tokens": budget_tokens,
        }

    elif thinking_type is not None:
        raise ValueError(
            f"unsupported Anthropic thinking_type: "
            f"{thinking_type}"
        )

    if "effort" in config:
        payload["output_config"] = {
            "effort": config["effort"],
        }

    response = post_json(
        "https://api.anthropic.com/v1/messages",
        {
            "x-api-key": key,
            "anthropic-version": "2023-06-01",
        },
        payload,
    )

    # Discard thinking blocks and retain only the final visible text.
    text = "".join(
        part.get("text", "")
        for part in response.get("content", [])
        if part.get("type") == "text"
    ).strip()

    if not text:
        raise RuntimeError(
            f"Anthropic response did not contain text: {response}"
        )

    return text


def call_gemini(
    prompt: str,
    config: dict,
    key: str,
) -> str:
    model_path = config["api_model"]

    if not model_path.startswith("models/"):
        model_path = f"models/{model_path}"

    url = (
        "https://generativelanguage.googleapis.com/v1beta/"
        f"{quote(model_path, safe='/')}:generateContent?"
        f"{urlencode({'key': key})}"
    )

    generation_config = {
        "maxOutputTokens": config["max_output_tokens"],
    }

    if "thinking_level" in config:
        generation_config["thinkingConfig"] = {
            "thinkingLevel": config["thinking_level"],
        }

    response = post_json(
        url,
        {},
        {
            "contents": [
                {
                    "role": "user",
                    "parts": [
                        {
                            "text": prompt,
                        }
                    ],
                }
            ],
            "generationConfig": generation_config,
        },
    )

    candidates = response.get("candidates", [])
    if not candidates:
        raise RuntimeError(
            f"Gemini response did not contain candidates: "
            f"{response}"
        )

    # Retain final answer text and ignore any returned thought parts.
    text = "".join(
        part.get("text", "")
        for part in candidates[0]
        .get("content", {})
        .get("parts", [])
        if not part.get("thought", False)
    ).strip()

    if not text:
        raise RuntimeError(
            f"Gemini response did not contain text: {response}"
        )

    return text


def call_model(
    prompt: str,
    config: dict,
    key: str,
) -> str:
    provider = config["provider"]

    if provider == "openai":
        return call_openai(prompt, config, key)

    if provider == "anthropic":
        return call_anthropic(prompt, config, key)

    if provider == "gemini":
        return call_gemini(prompt, config, key)

    raise ValueError(
        f"unsupported provider in model configuration: "
        f"{provider}"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__,
    )
    parser.add_argument(
        "input_file",
        type=Path,
    )
    parser.add_argument(
        "output_file",
        type=Path,
    )
    parser.add_argument(
        "--model",
        required=True,
        choices=sorted(MODEL_CONFIGS),
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    config = MODEL_CONFIGS[args.model]
    provider = config["provider"]

    try:
        prompt = args.input_file.read_text(
            encoding="utf-8",
        )
        key = get_api_key(provider)
    except (OSError, RuntimeError) as error:
        print(f"Error: {error}")
        return 1

    print(
        f"Calling {args.model} "
        f"({provider}: {config['api_model']}); "
        "this may take a while...",
        flush=True,
    )

    try:
        output_text = call_with_retries(
            provider,
            lambda: call_model(
                prompt,
                config,
                key,
            ),
        )
    except Exception as error:
        print(
            f"Error calling {args.model}: {error}"
        )
        return 1

    try:
        args.output_file.write_text(
            output_text,
            encoding="utf-8",
        )
    except OSError as error:
        print(
            f"Error writing {args.output_file}: {error}"
        )
        return 1

    print(
        f"Successfully wrote output to "
        f"{args.output_file}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())