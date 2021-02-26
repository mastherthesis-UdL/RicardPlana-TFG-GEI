const mongoose = require('mongoose')

let  PacientsSchema = new mongoose.Schema({
  'Identificador': {type: String},
  'Actiu/Pensionista': {type: String},
  'Titular/Beneficiari': {type: String},
  'Edat': {type: Int32},
  'AnysEdat': {type: Int32},
  'Sexe': {type: Int32},
  'Any': {type: Int32}
}, {timestamps: false})

const Pacients = mongoose.model('Pacients', PacientsSchema, 'patients')
module.exports = {Pacients, PacientsSchema}