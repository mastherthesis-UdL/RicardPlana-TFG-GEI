const dbSettings = {
  db_dialect: process.env.DB_DIALECT || 'mongo',
  db_host: process.env.DB_HOST       || '192.168.101.98',
  db_port: process.env.DB_PORT || '27017',
  db_name: process.env.DB_NAME || 'samples',
  db_user: process.env.DB_USER || 'manager',
  db_password: process.env.DB_PASSWORD   || '9tY6xsWsQsxdV98'
}

const serverSettings = {
  port: process.env.PORT || 3000,
  ssl: require('./ssl')
}

module.exports = Object.assign({}, { dbSettings, serverSettings })
