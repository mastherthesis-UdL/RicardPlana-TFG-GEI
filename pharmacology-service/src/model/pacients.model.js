const mongoose = require('mongoose')

let  PacientsSchema = new mongoose.Schema({
  'Identificador': {type: String},
  'Actiu/Pensionista': {type: String},
  'Titular/Beneficiari': {type: String},
  'Edat': {type: String},
  'AnysEdat': {type: String},
  'Sexe': {type: String}
}, {timestamps: false})

const Pacients = mongoose.model('Pacients', PacientsSchema, 'pacients')
module.exports = {Pacients, PacientsSchema}