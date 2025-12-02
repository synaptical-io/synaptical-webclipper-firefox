/**
 * Minimal background script that:
 * - connects to the Ori native host (ori-simulator.py)
 * - sends a test message
 * - logs all messages and lifecycle events
 */

const ORI_HOST_NAME = 'io.synaptical.ori.simulator';

let oriPort: browser.runtime.Port | null = null;

/**
 * Establish (or re-establish) a native messaging connection to Ori.
 */
function connectToOri(): void {
  if (oriPort) {
    console.debug('[Firefox WebClipper] connectToOri(): already connected, skipping.');
    return;
  }

  console.info('[Firefox WebClipper] Connecting to native host:', ORI_HOST_NAME);

  try {
    const port = browser.runtime.connectNative(ORI_HOST_NAME);
    oriPort = port;

    console.info('[Firefox WebClipper] Native port opened:', port.name);

    // Log incoming messages from the native host
    port.onMessage.addListener((msg: unknown) => {
      console.info('[Firefox WebClipper] Message from native host:', msg);
    });

    // Handle disconnects (e.g. host crashed or not found)
    port.onDisconnect.addListener(() => {
      const lastError = browser.runtime.lastError;
      if (lastError) {
        console.error('[Firefox WebClipper] Port disconnected with error:', lastError.message);
      } else {
        console.warn('[Firefox WebClipper] Port disconnected.');
      }
      oriPort = null;
    });

    // Send a simple test message so you see activity in ori-simulator.log
    sendToOri({
      kind: 'hello',
      from: 'extension-background',
      timestamp: Date.now(),
    });
  } catch (err) {
    console.error('[Firefox WebClipper] Failed to connect to native host:', err);
    oriPort = null;
  }
}

/**
 * Send a message to the Ori native host.
 * Safe to call even if the port is not yet connected.
 */
function sendToOri(payload: unknown): void {
  if (!oriPort) {
    console.warn('[Firefox WebClipper] sendToOri(): no active port, attempting to reconnect.');
    connectToOri();

    if (!oriPort) {
      console.error('[Firefox WebClipper] sendToOri(): still no port after reconnect, aborting.');
      return;
    }
  }

  try {
    console.info('[Firefox WebClipper] Sending message to native host:', payload);
    oriPort.postMessage(payload);
  } catch (err) {
    console.error('[Firefox WebClipper] Failed to post message:', err);
  }
}

/**
 * Optional: bridge messages from other parts of the extension.
 * For now, just log and forward anything with { target: "ori" }.
 */
browser.runtime.onMessage.addListener((message, sender) => {
  console.info('[Firefox WebClipper] runtime.onMessage from', sender.id, ':', message);

  if (message && typeof message === 'object' && (message as any).target === 'ori') {
    const payload = (message as any).payload ?? message;
    sendToOri(payload);
  }

  // No async response
  return false;
});

// Try to connect when the background service worker starts.
connectToOri();

// Also hook into typical lifecycle events, just in case Firefox fires them.
browser.runtime.onInstalled.addListener(() => {
  console.info('[Firefox WebClipper] runtime.onInstalled → ensuring native connection.');
  connectToOri();
});

browser.runtime.onStartup.addListener(() => {
  console.info('[Firefox WebClipper] runtime.onStartup → ensuring native connection.');
  connectToOri();
});
