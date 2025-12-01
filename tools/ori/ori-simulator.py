#!/usr/bin/env python3
"""
Minimal native messaging host with logging.

- Reads JSON messages from stdin (length-prefixed)
- Logs everything to ori-simulator.log and stderr
- Sends a simple echo-style JSON response back to the extension

This is a debugging harness: you can see exactly what the extension sends
and what the host replies.
"""

import sys
import json
import struct
import logging
from pathlib import Path

# -----------------------------------------------------------------------------
# Logging setup
# -----------------------------------------------------------------------------
# Project root is: [project root]/tools/ori-simulator/ori-simulator.py -> up two levels
PROJECT_ROOT = Path(__file__).resolve().parents[2]

# Ensure logs directory exists at [project root]/logs
LOG_DIR = PROJECT_ROOT / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

# Log file path is now [project root]/logs/ori-simulator.log
LOG_PATH = LOG_DIR / "ori-simulator.log"

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_PATH, encoding="utf-8"),
        logging.StreamHandler(sys.stderr),
    ],
)

logging.info("Native host starting. Log file: %s", LOG_PATH)


# -----------------------------------------------------------------------------
# Native messaging protocol helpers
# -----------------------------------------------------------------------------
def read_message():
    """Read a single message from stdin, or return None on EOF."""
    raw_length = sys.stdin.buffer.read(4)
    if len(raw_length) == 0:
        logging.info("No more data on stdin (EOF). Shutting down.")
        return None

    message_length = struct.unpack("<I", raw_length)[0]
    logging.debug("Incoming message length: %d", message_length)

    message_bytes = sys.stdin.buffer.read(message_length)
    if len(message_bytes) != message_length:
        logging.error(
            "Expected %d bytes, received %d bytes", message_length, len(message_bytes)
        )
        return None

    try:
        message = json.loads(message_bytes.decode("utf-8"))
        logging.info("Received message from extension: %s", message)
        return message
    except Exception as e:
        logging.exception("Failed to decode JSON message: %s", e)
        return None


def send_message(message):
    """Send a JSON message to stdout using the native messaging framing."""
    try:
        encoded = json.dumps(message).encode("utf-8")
    except Exception as e:
        logging.exception("Failed to encode JSON response: %s", e)
        return

    sys.stdout.buffer.write(struct.pack("<I", len(encoded)))
    sys.stdout.buffer.write(encoded)
    sys.stdout.buffer.flush()

    logging.info("Sent response to extension: %s", message)


# -----------------------------------------------------------------------------
# Main loop
# -----------------------------------------------------------------------------
def main():
    logging.info("Native host main loop started.")
    try:
        while True:
            msg = read_message()
            if msg is None:
                break

            # Here you can implement any logic you want.
            # For debugging, we echo back the message with some extra info.
            response = {
                "status": "ok",
                "note": "Echo from native host",
                "received": msg,
            }
            send_message(response)
    except Exception as e:
        logging.exception("Unhandled exception in main loop: %s", e)
    finally:
        logging.info("Native host exiting.")


if __name__ == "__main__":
    main()
