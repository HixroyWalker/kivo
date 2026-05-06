'use strict';

const express = require('express');
const helmet  = require('helmet');
const cors    = require('cors');

const app  = express();
const PORT = process.env.PORT || 8080;

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(helmet());
app.use(cors());
app.use(express.json());

// ── Health check (required by Cloud Run & the Dockerfile HEALTHCHECK) ─────────
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok', service: 'kivo-backend' });
});

// ── Root ──────────────────────────────────────────────────────────────────────
app.get('/', (_req, res) => {
  res.json({ service: 'KiVo Global API', version: '1.0.0' });
});

// ── Shipping fee calculation ──────────────────────────────────────────────────
// POST /api/shipping
// Body: { cartSubtotal: number, isUnlimitedMember: boolean, customMerchantFee?: number }
app.post('/api/shipping', (req, res) => {
  const { cartSubtotal, isUnlimitedMember, customMerchantFee } = req.body;

  if (typeof cartSubtotal !== 'number') {
    return res.status(400).json({ error: 'cartSubtotal must be a number' });
  }

  const FREE_THRESHOLD       = 150.0;
  const DISCOUNTED_THRESHOLD = 100.0;
  const DISCOUNT_MULTIPLIER  = 0.5;
  const DEFAULT_MERCHANT_FEE = 5.99;

  let fee = 0;

  if (!isUnlimitedMember) {
    if (cartSubtotal < FREE_THRESHOLD) {
      const base = typeof customMerchantFee === 'number'
        ? customMerchantFee
        : DEFAULT_MERCHANT_FEE;
      fee = cartSubtotal >= DISCOUNTED_THRESHOLD
        ? base * DISCOUNT_MULTIPLIER
        : base;
    }
  }

  res.json({ shippingFee: fee });
});

// ── TRN verification stub ─────────────────────────────────────────────────────
// POST /api/verify-trn
// Body: { trn: string }
app.post('/api/verify-trn', (req, res) => {
  const { trn } = req.body;

  if (!trn || typeof trn !== 'string') {
    return res.status(400).json({ error: 'trn must be a non-empty string' });
  }

  if (!/^[A-Z0-9]{8,15}$/.test(trn)) {
    return res.status(422).json({
      trn,
      verified: false,
      message: 'Invalid TRN format — must be 8-15 uppercase alphanumeric characters',
    });
  }

  // TODO: replace with live Government of Jamaica API endpoint
  res.json({
    trn,
    verified: true,
    entity:      'Santa Cruz Business Entity',
    verifiedAt:  new Date().toISOString(),
    validUntil:  new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(),
  });
});

// ── 404 catch-all ─────────────────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// ── Start ─────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`KiVo backend listening on port ${PORT}`);
});

module.exports = app; // exported for testing
