const mongoose = require('mongoose')

let  MetgesSchema = new mongoose.Schema({
  'NumColegiat': {type: String}
}, {timestamps: false})

const Metges = mongoose.model('Metges', MetgesSchema, 'metges')
module.exports = {Metges, MetgesSchema}