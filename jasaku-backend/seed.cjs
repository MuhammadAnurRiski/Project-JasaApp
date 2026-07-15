const { Pool } = require('pg');
const crypto = require('crypto');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

function uid() { return crypto.randomUUID(); }

const PASS_HASH = '$2b$10$MF5btQmZNzPWDyHIMO/ZN.9z.fmsxBXYu.dirWrmhxPD6h7lDCCcK';

const SVC = {
  mcb:        '284db2ef-9824-4bfd-90e3-f88675d3811b',
  stopkontak: 'f7fe454c-82e8-4b22-b078-4d22317c10a7',
  keramik:    'ff0d4fae-6c4e-4fac-b86f-572b31a787f6',
  cat:        'ff4a47d0-fa7e-4e21-9ac1-ea296316fd12',
  plafon:     'a4654dc6-6721-4c1a-8cfd-cc8039df4d8b',
};

const PRICING = {
  kelistrikan:  '7794c0dc-3865-42d5-a75a-5ca4bdfda457',
  bangunan:     '439446ff-9ec8-4aec-97c3-c12afb677855',
};

const EXISTING_PROVIDERS = {
  ahmad:  { pp: 'a48ef3da-8433-4b1e-92a6-5574d7557877', user: 'c4d8d178-9639-4f27-a00f-e2c7ddcedcc9' },
  budi:   { pp: 'f7782e67-c3cd-4dc0-89ec-9505f64a7dd9', user: '27c7c8da-3d8a-45f9-9b39-70b1d1cf2470' },
  kusuma: { pp: '40dc3647-ef73-408b-be71-3470f10431ae', user: '132bfa74-30a7-4e8f-bc24-ece262a9b4e2' },
  riski1: { pp: 'c774483c-6363-44c4-803f-1d503c5c4d10', user: '0c9dfbd3-a33f-4243-87fa-47a2ce924bab' },
  riski2: { pp: 'd7070049-b247-47b5-890b-7cfe62da29f9', user: 'e437dffc-b967-41f9-99cb-93ed35e35b07' },
  rifan:  { pp: 'ad0cb88d-501e-46b5-a84a-b7af35e402f4', user: '9fb54f81-aae5-4acf-9165-19adfc28ebce' },
};

const NEW_PROVIDERS = [
  { name: 'Surya Pratama',      svc: 'mcb',        pricingCat: 'kelistrikan', price: 350000 },
  { name: 'Dedi Kurniawan',     svc: 'mcb',        pricingCat: 'kelistrikan', price: 300000 },
  { name: 'Hendra Wijaya',      svc: 'stopkontak', pricingCat: 'kelistrikan', price: 280000 },
  { name: 'Rizki Firmansyah',   svc: 'stopkontak', pricingCat: 'kelistrikan', price: 250000 },
  { name: 'Aditya Nugraha',     svc: 'stopkontak', pricingCat: 'kelistrikan', price: 300000 },
  { name: 'Fajar Ramadhan',     svc: 'keramik',    pricingCat: 'bangunan',    price: 400000 },
  { name: 'Yoga Purnama',       svc: 'keramik',    pricingCat: 'bangunan',    price: 350000 },
  { name: 'Dimas Saputra',      svc: 'cat',        pricingCat: 'bangunan',    price: 250000 },
  { name: 'Rian Putra',         svc: 'cat',        pricingCat: 'bangunan',    price: 300000 },
  { name: 'Aldi Mahendra',      svc: 'cat',        pricingCat: 'bangunan',    price: 280000 },
  { name: 'Toni Setiawan',      svc: 'plafon',     pricingCat: 'bangunan',    price: 400000 },
  { name: 'Bayu Prasetyo',      svc: 'plafon',     pricingCat: 'bangunan',    price: 380000 },
  { name: 'Arif Rahman',        svc: 'plafon',     pricingCat: 'bangunan',    price: 350000 },
  { name: 'Ilham Hidayat',      svc: 'plafon',     pricingCat: 'bangunan',    price: 420000 },
];

const NEW_CUSTOMERS = [
  'Siti Nurhaliza',
  'Rina Wati',
  'Dewi Sartika',
  'Putri Anggraini',
  'Eka Wulandari',
  'Rahmat Hidayat',
  'Firmansyah Putra',
  'Hendra Saputra',
  'Joko Widodo',
  'Kartika Sari',
];

const ADDRESSES = [
  'Jl. P. Antasari No. 45',
  'Jl. A. Yani No. 120',
  'Jl. S. Parman No. 33',
  'Jl. Jend. Sudirman No. 88',
  'Jl. Lambung Mangkurat No. 15',
  'Jl. Pramuka No. 67',
  'Jl. Martadinata No. 22',
  'Jl. Veteran No. 50',
  'Jl. Pahlawan No. 10',
  'Jl. Merdeka No. 78',
];

const REVIEWS_5 = [
  'Hasil kerjanya sangat rapi dan sesuai ekspektasi. Mitra datang tepat waktu dan sangat profesional.',
  'Pekerjaan selesai dengan baik. Komunikasi lancar, harga sesuai, dan hasilnya memuaskan.',
  'Sangat puas dengan hasilnya. Kerapihan dan ketelitian luar biasa. Pasti akan pakai lagi.',
  'Mitra sangat helpfull dan pekerjaannya cepat selesai. Kualitas bahan juga bagus.',
  'Luar biasa! Hasilnya lebih bagus dari yang dibayangkan. Sangat recommended.',
  'Tukangnya jago, hasilnya rapi banget. Datang pagi dan langsung kerja. Puas sekali.',
  'Kualitas kerja bintang 5. Bersih, rapi, dan sesuai waktu yang dijanjikan.',
];

const REVIEWS_4 = [
  'Secara keseluruhan bagus. Cuma ada sedikit keterlambatan di awal, tapi hasilnya memuaskan.',
  'Hasil kerja rapi, cuma pengerjaannya agak lama dari estimasi. Tapi tetep oke.',
  'Puas dengan hasilnya. Mitra ramah dan hasil kerja bagus, cuma perlu koordinasi lebih.',
  'Hasil cat bagus dan rapi. Sedikit noda di area sekitar tapi overall puas.',
  'Kerjaan rapi, cuma komunikasi bisa lebih baik lagi. Tapi hasil akhir memuaskan.',
  'Bahan yang dipakai bagus, pengerjaan juga rapi. Hanya saja agak molor setengah hari.',
  'Overall memuaskan. Hasil kerja bagus, tapi perlu dipastikan timeline-nya lebih ketat.',
];

const REVIEWS_3 = [
  'Lumayan. Hasilnya standar, tidak terlalu rapi tapi masih bisa diterima.',
  'Agak kecewa dengan ketepatan waktu. Tapi kualitas kerja masih oke.',
  'Hasilnya biasa saja. Harga sesuai dengan kualitas yang didapat.',
];

const REVIEW_POOL = [
  { r: 5, texts: REVIEWS_5 },
  { r: 4, texts: REVIEWS_4 },
  { r: 3, texts: REVIEWS_3 },
];

function pickReview() {
  const w = Math.random();
  const tier = w < 0.5 ? 0 : w < 0.85 ? 1 : 2;
  const pool = REVIEW_POOL[tier];
  const text = pool.texts[Math.floor(Math.random() * pool.texts.length)];
  return { rating: pool.r, review: text };
}

function rndBetween(min, max) { return min + Math.random() * (max - min); }
function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }

function rndDate(startStr, endStr) {
  const start = new Date(startStr).getTime();
  const end = new Date(endStr).getTime();
  return new Date(start + Math.random() * (end - start));
}

function fmtDate(d) { return d.toISOString().split('T')[0]; }
function fmtTs(d) { return d.toISOString().replace('T', ' ').replace('Z', ''); }

const STREET_NO = () => Math.floor(Math.random() * 200) + 1;

const BANJARMASIN_ADDRESSES = [
  'Banjarmasin Tengah', 'Banjarmasin Selatan', 'Banjarmasin Timur',
  'Banjarmasin Barat', 'Banjarmasin Utara',
];

function rndLocation() {
  const lat = rndBetween(-3.36, -3.28);
  const lng = rndBetween(114.55, 114.63);
  return { lat, lng, addr: `Jl. ${pick(['P. Antasari', 'A. Yani', 'S. Parman', 'Sudirman', 'Lambung Mangkurat', 'Pramuka', 'Martadinata', 'Veteran', 'Pahlawan', 'Merdeka'])} No. ${STREET_NO()}, ${pick(BANJARMASIN_ADDRESSES)}, Banjarmasin` };
}

const PAYMENT_METHODS = ['bank_transfer', 'e_wallet', 'qris', 'cash'];

async function main() {
  const client = await pool.connect();
  let counts = { users: 0, profiles: 0, services: 0, prices: 0, locations: 0, payouts: 0, orders: 0, items: 0, olocs: 0, payments: 0, schedules: 0, reviews: 0 };

  try {
    await client.query('BEGIN');

    // ─── STEP 1: Create 10 new customer users ───
    const customerIds = []; // { userId, profileId }
    for (let i = 0; i < NEW_CUSTOMERS.length; i++) {
      const name = NEW_CUSTOMERS[i];
      const userId = uid();
      const profileId = uid();
      const email = `customer${String(i + 11).padStart(2, '0')}@seed.com`;
      const phone = `0812${String(90000000 + i * 1111111).slice(0, 8)}`;

      await client.query(
        `INSERT INTO users (id, role_id, email, phone, password_hash, is_phone_verified, status)
         VALUES ($1, 1, $2, $3, $4, true, 'active')`,
        [userId, email, phone, PASS_HASH]
      );

      await client.query(
        `INSERT INTO profiles_customer (id, user_id, full_name, nickname, gender, address)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [profileId, userId, name, name.split(' ')[0], i % 2 === 0 ? 'female' : 'male', `${pick(ADDRESSES)}, Banjarmasin`]
      );

      customerIds.push({ userId, profileId });
      counts.users++;
      counts.profiles++;
    }
    console.log(`Created ${customerIds.length} customers`);

    // ─── STEP 2: Create 14 new provider accounts ───
    const providerIds = []; // { ppId, userId, svcKey, price }
    for (let i = 0; i < NEW_PROVIDERS.length; i++) {
      const np = NEW_PROVIDERS[i];
      const userId = uid();
      const ppId = uid();
      const loc = uid();
      const email = `mitra${String(i + 1).padStart(2, '0')}@seed.com`;
      const phone = `0823${String(50000000 + i * 7142857).slice(0, 8)}`;
      const locData = rndLocation();

      // user
      await client.query(
        `INSERT INTO users (id, role_id, email, phone, password_hash, is_phone_verified, status)
         VALUES ($1, 2, $2, $3, $4, true, 'active')`,
        [userId, email, phone, PASS_HASH]
      );

      // provider profile
      await client.query(
        `INSERT INTO provider_profiles (id, user_id, full_name, nickname, gender, phone, address, domicile,
          is_verified, verification_status, onboarding_completed, is_active, rating, total_jobs, total_reviews, service_available)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, true, 'verified', true, true, 0, 0, 0, true)`,
        [ppId, userId, np.name, np.name.split(' ')[0], i % 3 === 0 ? 'male' : i % 3 === 1 ? 'female' : 'male',
         phone, locData.addr, 'Banjarmasin']
      );

      // provider location (PostGIS)
      await client.query(
        `INSERT INTO provider_locations (id, provider_id, address, location)
         VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326))`,
        [loc, userId, locData.addr, locData.lng, locData.lat]
      );

      // provider service
      const psId = uid();
      await client.query(
        `INSERT INTO provider_services (id, provider_id, service_id) VALUES ($1, $2, $3)`,
        [psId, ppId, SVC[np.svc]]
      );

      // provider service price
      const ptId = PRICING[np.pricingCat];
      const priceVariance = np.price + Math.floor(rndBetween(-30000, 30000));
      const finalPrice = Math.max(150000, priceVariance);
      await client.query(
        `INSERT INTO provider_service_prices (id, provider_service_id, pricing_type_id, price, unit)
         VALUES ($1, $2, $3, $4, 'hari')`,
        [uid(), psId, ptId, finalPrice]
      );

      // provider payout method
      const pmType = pick(['bank', 'ewallet']);
      const pmName = pick(['BCA', 'Mandiri', 'BRI', 'BNI']);
      const pmNumber = String(Math.floor(Math.random() * 9000000000) + 1000000000);
      await client.query(
        `INSERT INTO provider_payout_methods (id, provider_id, type, provider_name, account_number, account_name)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [uid(), userId, pmType === 'bank' ? 'bank' : 'ewallet', np.name, pmNumber, np.name]
      );

      providerIds.push({ ppId, userId, svcKey: np.svc, price: finalPrice });
      counts.users++;
      counts.profiles++;
      counts.locations++;
      counts.services++;
      counts.prices++;
      counts.payouts++;
    }
    console.log(`Created ${providerIds.length} providers`);

    // ─── STEP 3: Fix existing providers without prices, locations, payouts ───

    // Budi: needs prices for MCB + Stopkontak, location, payout
    {
      const budi = EXISTING_PROVIDERS.budi;
      const psRows = await client.query(
        `SELECT id, service_id FROM provider_services WHERE provider_id = $1`, [budi.pp]
      );
      for (const ps of psRows.rows) {
        const ptId = ps.service_id === SVC.mcb ? PRICING.kelistrikan : PRICING.kelistrikan;
        const price = ps.service_id === SVC.mcb ? 280000 : 220000;
        await client.query(
          `INSERT INTO provider_service_prices (id, provider_service_id, pricing_type_id, price, unit)
           VALUES ($1, $2, $3, $4, 'hari')
           ON CONFLICT DO NOTHING`,
          [uid(), ps.id, ptId, price]
        );
        counts.prices++;
      }
      const loc = rndLocation();
      await client.query(
        `INSERT INTO provider_locations (id, provider_id, address, location)
         VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326))
         ON CONFLICT (provider_id) DO NOTHING`,
        [uid(), budi.user, loc.addr, loc.lng, loc.lat]
      );
      await client.query(
        `INSERT INTO provider_payout_methods (id, provider_id, type, provider_name, account_number, account_name)
         VALUES ($1, $2, 'bank', 'Budi', $3, 'Budi')
         ON CONFLICT DO NOTHING`,
        [uid(), budi.user, String(Math.floor(Math.random() * 9000000000) + 1000000000)]
      );
      counts.locations++;
      counts.payouts++;
    }

    // Kusuma: needs price for Cat Dinding, location, payout
    {
      const kus = EXISTING_PROVIDERS.kusuma;
      const psRows = await client.query(
        `SELECT id FROM provider_services WHERE provider_id = $1 AND service_id = $2`,
        [kus.pp, SVC.cat]
      );
      if (psRows.rows.length > 0) {
        await client.query(
          `INSERT INTO provider_service_prices (id, provider_service_id, pricing_type_id, price, unit)
           VALUES ($1, $2, $3, $4, 'hari') ON CONFLICT DO NOTHING`,
          [uid(), psRows.rows[0].id, PRICING.bangunan, 270000]
        );
        counts.prices++;
      }
      const loc = rndLocation();
      await client.query(
        `INSERT INTO provider_locations (id, provider_id, address, location)
         VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326))
         ON CONFLICT (provider_id) DO NOTHING`,
        [uid(), kus.user, loc.addr, loc.lng, loc.lat]
      );
      await client.query(
        `INSERT INTO provider_payout_methods (id, provider_id, type, provider_name, account_number, account_name)
         VALUES ($1, $2, 'ewallet', 'Kusuma wijaya', $3, 'Kusuma wijaya')
         ON CONFLICT DO NOTHING`,
        [uid(), kus.user, `0897${String(Math.floor(Math.random() * 90000000) + 10000000)}`]
      );
      counts.locations++;
      counts.payouts++;
    }

    // Rifan: needs price for MCB, location, payout
    {
      const rifan = EXISTING_PROVIDERS.rifan;
      const psRows = await client.query(
        `SELECT id FROM provider_services WHERE provider_id = $1 AND service_id = $2`,
        [rifan.pp, SVC.mcb]
      );
      if (psRows.rows.length > 0) {
        await client.query(
          `INSERT INTO provider_service_prices (id, provider_service_id, pricing_type_id, price, unit)
           VALUES ($1, $2, $3, $4, 'hari') ON CONFLICT DO NOTHING`,
          [uid(), psRows.rows[0].id, PRICING.kelistrikan, 320000]
        );
        counts.prices++;
      }
      const loc = rndLocation();
      await client.query(
        `INSERT INTO provider_locations (id, provider_id, address, location)
         VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326))
         ON CONFLICT (provider_id) DO NOTHING`,
        [uid(), rifan.user, loc.addr, loc.lng, loc.lat]
      );
      await client.query(
        `INSERT INTO provider_payout_methods (id, provider_id, type, provider_name, account_number, account_name)
         VALUES ($1, $2, 'bank', 'Rifan', $3, 'Rifan Ardian Rahmansyah')
         ON CONFLICT DO NOTHING`,
        [uid(), rifan.user, String(Math.floor(Math.random() * 9000000000) + 1000000000)]
      );
      counts.locations++;
      counts.payouts++;
    }

    // Riski1 & Riski2: add locations if missing
    for (const [key, data] of Object.entries({ riski1: EXISTING_PROVIDERS.riski1, riski2: EXISTING_PROVIDERS.riski2 })) {
      const existing = await client.query(`SELECT 1 FROM provider_locations WHERE provider_id = $1`, [data.user]);
      if (existing.rows.length === 0) {
        const loc = rndLocation();
        await client.query(
          `INSERT INTO provider_locations (id, provider_id, address, location)
           VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326))`,
          [uid(), data.user, loc.addr, loc.lng, loc.lat]
        );
        counts.locations++;
      }
    }

    // Also add Ahmad's location if missing
    {
      const existing = await client.query(`SELECT 1 FROM provider_locations WHERE provider_id = $1`, [EXISTING_PROVIDERS.ahmad.user]);
      if (existing.rows.length === 0) {
        const loc = rndLocation();
        await client.query(
          `INSERT INTO provider_locations (id, provider_id, address, location)
           VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326))`,
          [uid(), EXISTING_PROVIDERS.ahmad.user, loc.addr, loc.lng, loc.lat]
        );
        counts.locations++;
      }
    }

    console.log('Fixed existing providers (prices, locations, payouts)');

    // ─── STEP 4: Create orders + reviews for ALL providers ───

    // Build full provider list: existing (with their services) + new
    const allProviders = [];

    // Existing providers and their services
    {
      const rows = await client.query(
        `SELECT ps.id as ps_id, ps.provider_id as pp_id, ps.service_id,
                pp.user_id, pp.full_name,
                psp.price, psp.unit
         FROM provider_services ps
         JOIN provider_profiles pp ON ps.provider_id = pp.id
         LEFT JOIN provider_service_prices psp ON psp.provider_service_id = ps.id`
      );
      for (const r of rows.rows) {
        allProviders.push({
          ppId: r.pp_id,
          userId: r.user_id,
          serviceId: r.service_id,
          price: r.price ? Number(r.price) : 250000,
          name: r.full_name,
        });
      }
    }

    // New providers
    for (const np of providerIds) {
      allProviders.push({
        ppId: np.ppId,
        userId: np.userId,
        serviceId: SVC[np.svcKey],
        price: np.price,
        name: NEW_PROVIDERS.find(p => p.svc === np.svcKey && Math.abs(p.price - np.price) < 50000)?.name || 'Unknown',
      });
    }

    // Deduplicate: 5 orders per UNIQUE provider (not per provider-service)
    const seenProviders = new Map();
    for (const prov of allProviders) {
      if (!seenProviders.has(prov.ppId)) {
        seenProviders.set(prov.ppId, prov);
      }
    }
    const uniqueProviders = Array.from(seenProviders.values());
    console.log(`Unique providers: ${uniqueProviders.length}, creating 5 orders each = ${uniqueProviders.length * 5} orders`);

    // Batch all data first, then insert
    const batchOrders = [];
    const batchItems = [];
    const batchOLocs = [];
    const batchPayments = [];
    const batchSchedules = [];
    const batchReviews = [];
    let orderNum = 0;

    for (const prov of uniqueProviders) {
      const pricingType = Object.values(SVC).indexOf(prov.serviceId) < 3 ? PRICING.kelistrikan : PRICING.bangunan;
      const usedDates = new Set();

      for (let j = 0; j < 5; j++) {
        const cust = customerIds[orderNum % customerIds.length];
        const orderId = uid();
        let workDate = rndDate('2026-06-01', '2026-07-15');
        let dateStr = fmtDate(workDate);
        let tries = 0;
        while (usedDates.has(dateStr) && tries < 30) {
          workDate = rndDate('2026-06-01', '2026-07-15');
          dateStr = fmtDate(workDate);
          tries++;
        }
        usedDates.add(dateStr);

        const totalPrice = prov.price + Math.floor(rndBetween(-20000, 20000));
        const platformFee = Math.round(totalPrice * 0.05);
        const custLoc = rndLocation();
        const payMethod = pick(PAYMENT_METHODS);
        const createdAt = new Date(workDate.getTime() + rndBetween(-86400000 * 3, 86400000));
        const { rating, review: reviewText } = pickReview();

        batchOrders.push(`('${orderId}','${cust.profileId}','${prov.ppId}','completed',${totalPrice},${platformFee},'${dateStr}','${fmtTs(createdAt)}',true,'manual')`);
        batchItems.push(`('${uid()}','${orderId}','${prov.serviceId}','${pricingType}',1,${totalPrice},${totalPrice})`);
        batchOLocs.push(`('${uid()}','${orderId}','${custLoc.addr.replace(/'/g, "''")}',ST_SetSRID(ST_MakePoint(${custLoc.lng},${custLoc.lat}),4326))`);
        batchPayments.push(`('${uid()}','${orderId}','${payMethod}','paid',${totalPrice},'${fmtTs(createdAt)}')`);
        batchSchedules.push(`('${uid()}','${prov.ppId}','${dateStr}',true,'${orderId}')`);
        batchReviews.push(`('${uid()}','${orderId}','${cust.userId}','${prov.userId}',${rating},'${reviewText.replace(/'/g, "''")}')`);

        orderNum++;
      }
    }

    // Insert in batches of 50
    const BATCH = 50;
    for (let i = 0; i < batchOrders.length; i += BATCH) {
      const chunk = batchOrders.slice(i, i + BATCH);
      await client.query(`INSERT INTO orders (id,customer_id,provider_id,status,total_price,platform_fee,work_date,created_at,payout_confirmed,assignment_type) VALUES ${chunk.join(',')}`);
    }
    counts.orders = batchOrders.length;
    console.log(`Inserted ${counts.orders} orders`);

    for (let i = 0; i < batchItems.length; i += BATCH) {
      const chunk = batchItems.slice(i, i + BATCH);
      await client.query(`INSERT INTO order_items (id,order_id,service_id,pricing_type_id,quantity,price,subtotal) VALUES ${chunk.join(',')}`);
    }
    counts.items = batchItems.length;

    for (let i = 0; i < batchOLocs.length; i += BATCH) {
      const chunk = batchOLocs.slice(i, i + BATCH);
      await client.query(`INSERT INTO order_locations (id,order_id,address,location) VALUES ${chunk.join(',')}`);
    }
    counts.olocs = batchOLocs.length;

    for (let i = 0; i < batchPayments.length; i += BATCH) {
      const chunk = batchPayments.slice(i, i + BATCH);
      await client.query(`INSERT INTO payments (id,order_id,method,status,amount,paid_at) VALUES ${chunk.join(',')}`);
    }
    counts.payments = batchPayments.length;

    for (let i = 0; i < batchSchedules.length; i += BATCH) {
      const chunk = batchSchedules.slice(i, i + BATCH);
      await client.query(`INSERT INTO provider_schedules (id,provider_id,work_date,is_booked,order_id) VALUES ${chunk.join(',')} ON CONFLICT (provider_id,work_date) DO NOTHING`);
    }
    counts.schedules = batchSchedules.length;

    for (let i = 0; i < batchReviews.length; i += BATCH) {
      const chunk = batchReviews.slice(i, i + BATCH);
      await client.query(`INSERT INTO reviews (id,order_id,customer_id,provider_id,rating,review) VALUES ${chunk.join(',')}`);
    }
    counts.reviews = batchReviews.length;

    console.log(`Created ${orderNum} orders with reviews (batch inserted)`);

    // ─── STEP 5: Update provider_profiles aggregates ───
    await client.query(`
      UPDATE provider_profiles pp SET
        rating = COALESCE(sub.avg_rating, 0),
        total_jobs = COALESCE(sub.cnt, 0),
        total_reviews = COALESCE(sub.cnt, 0)
      FROM (
        SELECT provider_id,
               ROUND(AVG(rating)::numeric, 1) as avg_rating,
               COUNT(*) as cnt
        FROM reviews
        GROUP BY provider_id
      ) sub
      WHERE pp.user_id = sub.provider_id
    `);
    console.log('Updated provider_profiles aggregates');

    await client.query('COMMIT');

    console.log('\n=== SEED COMPLETE ===');
    console.log('New users:           ', counts.users);
    console.log('Customer profiles:   ', counts.profiles);
    console.log('Provider locations:  ', counts.locations);
    console.log('Provider prices:     ', counts.prices);
    console.log('Provider payouts:    ', counts.payouts);
    console.log('Orders:              ', counts.orders);
    console.log('Order items:         ', counts.items);
    console.log('Order locations:     ', counts.olocs);
    console.log('Payments:            ', counts.payments);
    console.log('Schedules:           ', counts.schedules);
    console.log('Reviews:             ', counts.reviews);

  } catch (e) {
    await client.query('ROLLBACK');
    console.error('ROLLBACK:', e.message);
    throw e;
  } finally {
    client.release();
  }
  await pool.end();
}

main().catch(e => { console.error(e); process.exit(1); });
