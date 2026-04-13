import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import { env } from '../config/env';

const BASE_URL = env.faceppBaseUrl;
const API_KEY = env.faceppApiKey;
const API_SECRET = env.faceppApiSecret;

function isConfigured(): boolean {
  return !!(API_KEY && API_SECRET);
}

/**
 * Detect faces in an image file and return face_tokens
 */
export async function detectFaces(imagePath: string): Promise<string[]> {
  if (!isConfigured()) return [];

  try {
    const form = new FormData();
    form.append('api_key', API_KEY);
    form.append('api_secret', API_SECRET);
    form.append('image_file', fs.createReadStream(imagePath));

    const res = await axios.post(`${BASE_URL}/facepp/v3/detect`, form, {
      headers: form.getHeaders(),
      timeout: 15000,
    });

    const faces: { face_token: string }[] = res.data.faces || [];
    return faces.map((f) => f.face_token);
  } catch (err: any) {
    console.error('[Face++] detect error:', err.response?.data || err.message);
    return [];
  }
}

/**
 * Compare two faces — returns confidence score (0-100)
 */
export async function compareFaces(
  faceToken1: string,
  faceToken2: string
): Promise<number> {
  if (!isConfigured()) return 0;

  try {
    const form = new FormData();
    form.append('api_key', API_KEY);
    form.append('api_secret', API_SECRET);
    form.append('face_token1', faceToken1);
    form.append('face_token2', faceToken2);

    const res = await axios.post(`${BASE_URL}/facepp/v3/compare`, form, {
      headers: form.getHeaders(),
      timeout: 10000,
    });

    return res.data.confidence || 0;
  } catch (err: any) {
    console.error('[Face++] compare error:', err.response?.data || err.message);
    return 0;
  }
}

/**
 * Search for matching faces in event photos.
 * Takes a selfie image, detects faces, then compares against all face_tokens in the event.
 * Returns photo IDs sorted by highest confidence.
 */
export async function searchFaceInEvent(
  selfiePath: string,
  eventFaceTokens: { photoId: string; faceToken: string }[]
): Promise<{ photoId: string; confidence: number }[]> {
  if (!isConfigured() || eventFaceTokens.length === 0) return [];

  // Detect face in selfie
  const selfieTokens = await detectFaces(selfiePath);
  if (selfieTokens.length === 0) return [];

  const selfieToken = selfieTokens[0]; // Use the first (primary) face

  // Compare against all event face tokens (batch with concurrency limit)
  const CONCURRENCY = 5;
  const results: { photoId: string; confidence: number }[] = [];

  for (let i = 0; i < eventFaceTokens.length; i += CONCURRENCY) {
    const batch = eventFaceTokens.slice(i, i + CONCURRENCY);
    const batchResults = await Promise.all(
      batch.map(async ({ photoId, faceToken }) => {
        const confidence = await compareFaces(selfieToken, faceToken);
        return { photoId, confidence };
      })
    );
    results.push(...batchResults);
  }

  // Filter by threshold and sort by confidence descending
  const THRESHOLD = 70;
  return results
    .filter((r) => r.confidence >= THRESHOLD)
    .sort((a, b) => b.confidence - a.confidence);
}
