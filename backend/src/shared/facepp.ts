import axios from 'axios';
import FormData from 'form-data';
import fs from 'fs';
import sharp from 'sharp';
import { env } from '../config/env';

const BASE_URL = env.faceppBaseUrl;
const API_KEY = env.faceppApiKey;
const API_SECRET = env.faceppApiSecret;
const MAX_FILE_SIZE = 2 * 1024 * 1024; // 2MB Face++ limit

function isConfigured(): boolean {
  return !!(API_KEY && API_SECRET);
}

// Queue to ensure only 1 Face++ API call at a time (free tier limit)
let queue: Promise<any> = Promise.resolve();
function enqueue<T>(fn: () => Promise<T>): Promise<T> {
  const task = queue.then(() => fn(), () => fn());
  queue = task.catch(() => {}); // prevent chain break
  return task;
}

/**
 * Compress image to fit Face++ 2MB limit. Returns path to compressed file.
 */
async function compressForFacepp(imagePath: string): Promise<string> {
  const stat = fs.statSync(imagePath);
  if (stat.size <= MAX_FILE_SIZE) return imagePath;

  const compressed = imagePath + '.facepp.jpg';
  await sharp(imagePath)
    .resize(1024, 1024, { fit: 'inside', withoutEnlargement: true })
    .jpeg({ quality: 80 })
    .toFile(compressed);

  return compressed;
}

/**
 * Detect faces in an image file and return face_tokens
 */
export async function detectFaces(imagePath: string): Promise<string[]> {
  if (!isConfigured()) return [];

  return enqueue(async () => {
    let compressed: string | null = null;
    try {
      compressed = await compressForFacepp(imagePath);
      const form = new FormData();
      form.append('api_key', API_KEY);
      form.append('api_secret', API_SECRET);
      form.append('image_file', fs.createReadStream(compressed));

      const res = await axios.post(`${BASE_URL}/facepp/v3/detect`, form, {
        headers: form.getHeaders(),
        timeout: 15000,
      });

      const faces: { face_token: string }[] = res.data.faces || [];
      return faces.map((f) => f.face_token);
    } catch (err: any) {
      console.error('[Face++] detect error:', err.response?.data || err.message);
      return [];
    } finally {
      if (compressed && compressed !== imagePath) try { fs.unlinkSync(compressed); } catch (_) {}
    }
  });
}

/**
 * Create or get a FaceSet for an event.
 * Uses outer_id = eventId. Cached to avoid redundant API calls.
 */
const knownFaceSets = new Set<string>();

export async function ensureFaceSet(eventId: string): Promise<void> {
  if (!isConfigured()) return;
  if (knownFaceSets.has(eventId)) return;

  return enqueue(async () => {
    if (knownFaceSets.has(eventId)) return; // double-check after queue wait
    try {
      const form = new FormData();
      form.append('api_key', API_KEY);
      form.append('api_secret', API_SECRET);
      form.append('outer_id', eventId);
      form.append('force_merge', '1');

      await axios.post(`${BASE_URL}/facepp/v3/faceset/create`, form, {
        headers: form.getHeaders(),
        timeout: 10000,
      });
      knownFaceSets.add(eventId);
    } catch (err: any) {
      const msg = err.response?.data?.error_message || '';
      if (msg.includes('FACESET_EXIST')) {
        knownFaceSets.add(eventId); // already exists, cache it
      } else {
        console.error('[Face++] ensureFaceSet error:', err.response?.data || err.message);
      }
    }
  });
}

/**
 * Add face_tokens to an event's FaceSet (max 5 per call).
 */
export async function addFacesToSet(eventId: string, faceTokens: string[]): Promise<void> {
  if (!isConfigured() || faceTokens.length === 0) return;

  // Face++ allows max 5 face_tokens per addface call
  for (let i = 0; i < faceTokens.length; i += 5) {
    const batch = faceTokens.slice(i, i + 5);
    await enqueue(async () => {
      try {
        const form = new FormData();
        form.append('api_key', API_KEY);
        form.append('api_secret', API_SECRET);
        form.append('outer_id', eventId);
        form.append('face_tokens', batch.join(','));

        await axios.post(`${BASE_URL}/facepp/v3/faceset/addface`, form, {
          headers: form.getHeaders(),
          timeout: 10000,
        });
      } catch (err: any) {
        console.error('[Face++] addFacesToSet error:', err.response?.data || err.message);
      }
    });
  }
}

/**
 * Remove face_tokens from an event's FaceSet.
 */
export async function removeFacesFromSet(eventId: string, faceTokens: string[]): Promise<void> {
  if (!isConfigured() || faceTokens.length === 0) return;

  for (let i = 0; i < faceTokens.length; i += 5) {
    const batch = faceTokens.slice(i, i + 5);
    await enqueue(async () => {
      try {
        const form = new FormData();
        form.append('api_key', API_KEY);
        form.append('api_secret', API_SECRET);
        form.append('outer_id', eventId);
        form.append('face_tokens', batch.join(','));

        await axios.post(`${BASE_URL}/facepp/v3/faceset/removeface`, form, {
          headers: form.getHeaders(),
          timeout: 10000,
        });
      } catch (err: any) {
        console.error('[Face++] removeFacesFromSet error:', err.response?.data || err.message);
      }
    });
  }
}

/**
 * Search for a face in an event's FaceSet using Face++ Search API.
 * Returns matching face_tokens with confidence scores (single API call).
 */
export async function searchFaceInFaceSet(
  selfiePath: string,
  eventId: string
): Promise<{ faceToken: string; confidence: number }[]> {
  if (!isConfigured()) return [];

  return enqueue(async () => {
    let compressed: string | null = null;
    try {
      compressed = await compressForFacepp(selfiePath);
      const form = new FormData();
      form.append('api_key', API_KEY);
      form.append('api_secret', API_SECRET);
      form.append('image_file', fs.createReadStream(compressed));
      form.append('outer_id', eventId);
      form.append('return_result_count', '5');

      const res = await axios.post(`${BASE_URL}/facepp/v3/search`, form, {
        headers: form.getHeaders(),
        timeout: 15000,
      });

      const results: { face_token: string; confidence: number }[] = res.data.results || [];
      const thresholds = res.data.thresholds || {};
      // Use 1e-3 threshold (0.1% error rate) as minimum confidence
      const minConfidence = thresholds['1e-3'] || 60;

      return results
        .filter((r) => r.confidence >= minConfidence)
        .map((r) => ({ faceToken: r.face_token, confidence: r.confidence }));
    } catch (err: any) {
      const errorMsg = err.response?.data?.error_message || '';
      // EMPTY_FACESET means no faces in the set yet
      if (errorMsg === 'EMPTY_FACESET') return [];
      console.error('[Face++] search error:', err.response?.data || err.message);
      return [];
    } finally {
      if (compressed && compressed !== selfiePath) try { fs.unlinkSync(compressed); } catch (_) {}
    }
  });
}
