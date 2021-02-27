const mongoose = require('mongoose')

let  PacientsSchema = new mongoose.Schema({
  'Identificador': {type: String},
  'Actiu/Pensionista': {type: String},
  'Titular/Beneficiari': {type: String},
  'Edat': {type: Number},
  'AnysEdat': {type: Number},
  'Sexe': {type: Number},
  'Any': {type: Number}
}, {timestamps: false})

const Pacients = mongoose.model('Pacients', PacientsSchema, 'pacients')
module.exports = {Pacients, PacientsSchema}