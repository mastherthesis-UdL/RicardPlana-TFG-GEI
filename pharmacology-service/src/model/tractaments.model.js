const mongoose = require('mongoose')

const pacients = require('./pacients.model')
const medicament = require('./medicaments.model')

let  TractamentsSchema = new mongoose.Schema({
  'Pacient': {type: pacients.PacientsSchema},
  'Medicament': {type: medicament.MedicamentSchema},
  'Metge': {type: mongoose.Schema.Types.ObjectId},
  'LIQ': {type: Number},
  'Rec': {type: Number},
  'ENV': {type: Number},
  'Aportacion_cliente': {type: Number},
  'Year': {type: Number}
}, {timestamps: false})

const Tractaments = mongoose.model('Tractaments', TractamentsSchema, 'tractaments')
module.exports = Tractaments