const ORI_HOST_NAME = 'com.synaptical.ori';

export interface OriRequest {
  type: string;
  payload?: unknown;
}

export interface OriResponse {
  ok: boolean;
  data?: unknown;
  error?: string;
}

export async function sendToOri(request: OriRequest): Promise<OriResponse> {
  const response = await browser.runtime.sendNativeMessage(ORI_HOST_NAME, request);
  return response as OriResponse;
}
