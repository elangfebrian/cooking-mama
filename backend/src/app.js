const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const fs = require('fs');
const path = require('path');
const YAML = require('yaml');
const swaggerUi = require('swagger-ui-express');

const env = require('./config/env');
const routes = require('./routes');
const { UPLOAD_DIR } = require('./middleware/upload');
const { notFound, errorHandler } = require('./middleware/errorHandler');

const app = express();

app.set('trust proxy', 1);
// crossOriginResourcePolicy: foto di /uploads harus bisa dimuat oleh Flutter Web (origin berbeda)
app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors({
  origin: env.corsOrigin === '*' ? true : env.corsOrigin.split(',').map((s) => s.trim()),
  allowedHeaders: ['Content-Type', 'Authorization'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
}));
if (env.nodeEnv !== 'test') app.use(morgan(env.nodeEnv === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '1mb' }));

app.use('/uploads', express.static(UPLOAD_DIR, { maxAge: '7d' }));

// Dokumentasi API (Swagger UI) di /docs
const spec = YAML.parse(fs.readFileSync(path.join(__dirname, 'docs', 'openapi.yaml'), 'utf8'));
app.use('/docs', swaggerUi.serve, swaggerUi.setup(spec, { customSiteTitle: 'Cooking Mama API' }));

app.get('/', (_req, res) => res.json({ name: 'Cooking Mama API', docs: '/docs', health: '/api/health' }));
app.use('/api', routes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
