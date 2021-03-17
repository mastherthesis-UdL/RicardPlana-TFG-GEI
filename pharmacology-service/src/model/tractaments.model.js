const mongoose = require('mongoose')

const pacients = require('./pacients.model')
const medicament = require('./medicaments.model')
const metges = require('./metges.model')

let  TractamentsSchema = new mongoose.Schema({
  'Pacient': {type: pacients.PacientsSchema},
  'Medicament': {type: medicament.MedicamentSchema},
  'Metge': {type: metges.MetgesSchema},
  'LIQ': {type: Number},
  'Rec': {type: Number},
  'ENV': {type: Number},
  'Aportacion_cliente': {type: Number},
  'Any': {type: Number}
}, {timestamps: false})

const Tractaments = mongoose.model('Tractaments', TractamentsSchema, 'tractaments')
module.exports = Tractaments