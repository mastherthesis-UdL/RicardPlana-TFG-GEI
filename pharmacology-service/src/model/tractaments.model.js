const mongoose = require('mongoose')

const pacients = require('./pacients.model')
const medicament = require('./medicaments.model')

let  TractamentsSchema = new mongoose.Schema({
  Pacient: {type: pacients.PacientsSchema},
  Medicament: {type: medicament.MedicamentSchema},
  Metge: {type: mongoose.Schema.Types.ObjectId},
  LIQ: {type: String},
  Rec: {type: String},
  ENV: {type: String},
  Aportacion_cliente: {type: String},
}, {timestamps: false})

const Tractaments = mongoose.model('Tractaments', TractamentsSchema, 'tractaments')
module.exports = Tractaments