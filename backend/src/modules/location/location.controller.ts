import { Request, Response } from 'express';

export const locationController = {
  async search(req: Request, res: Response) {
    try {
      const { q } = req.query;
      if (!q || typeof q !== 'string') {
        res.status(400).json({ error: 'Query parameter "q" is required' });
        return;
      }

      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?` +
        `q=${encodeURIComponent(q)}&format=json&limit=10&addressdetails=1`,
        {
          headers: {
            'User-Agent': 'OurMomentApp/1.0',
            'Accept-Language': 'en',
          },
        }
      );

      if (!response.ok) {
        res.status(502).json({ error: 'Location service unavailable' });
        return;
      }

      const data = await response.json() as any[];
      const results = data.map((item: any) => ({
        placeId: item.place_id?.toString(),
        displayName: item.display_name,
        latitude: parseFloat(item.lat),
        longitude: parseFloat(item.lon),
        type: item.type,
      }));

      res.json(results);
    } catch {
      res.status(500).json({ error: 'Location search failed' });
    }
  },

  async reverseGeocode(req: Request, res: Response) {
    try {
      const { lat, lng } = req.query;
      if (!lat || !lng) {
        res.status(400).json({ error: 'Parameters "lat" and "lng" are required' });
        return;
      }

      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?` +
        `lat=${encodeURIComponent(lat as string)}&lon=${encodeURIComponent(lng as string)}&format=json`,
        {
          headers: {
            'User-Agent': 'OurMomentApp/1.0',
            'Accept-Language': 'en',
          },
        }
      );

      if (!response.ok) {
        res.status(502).json({ error: 'Geocoding service unavailable' });
        return;
      }

      const data = await response.json() as Record<string, any>;
      res.json({
        placeId: data.place_id?.toString(),
        displayName: data.display_name,
        latitude: parseFloat(data.lat),
        longitude: parseFloat(data.lon),
      });
    } catch {
      res.status(500).json({ error: 'Reverse geocoding failed' });
    }
  },
};
