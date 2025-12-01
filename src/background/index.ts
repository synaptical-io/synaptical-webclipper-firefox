import { sendToOri } from './nativeMessaging';

console.log('[background] Synaptical WebClipper background worker started');

browser.runtime.onInstalled.addListener((details) => {
  console.log('[background] onInstalled:', details.reason);
});

/**
 * Handle messages from UI / content scripts and forward selected ones to Ori.
 *
 * Convention:
 *   { type: "ori:request", action: string, payload?: unknown }
 */
browser.runtime.onMessage.addListener((message, sender) => {
  if (!message || typeof message !== 'object') {
    return;
  }

  if (message.type === 'ori:request') {
    const action = typeof message.action === 'string' ? message.action : 'unknown';

    // Returning a Promise is fine; the sender can await browser.runtime.sendMessage.
    return sendToOri({
      type: action,
      payload: message.payload,
    });
  }

  // Other message types can be handled here later.
});
