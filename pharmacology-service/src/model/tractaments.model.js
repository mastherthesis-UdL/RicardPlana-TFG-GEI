const mongoose = require('mongoose')

const pacients = require('./pacients.model')
const medicament = require('./medicaments.model')

let  TractamentsSchema = new mongoose.Schema({
  Pacient: {type: pacients.PacientsSchema},
  Medicament: {type: medicament.MedicamentSchema},
  Metge: {type: mongoose.Schema.Types.ObjectId},
  LIQ: {type: Double},
  Rec: {type: Int32},
  ENV: {type: Int32},
  Aportacion_cliente: {type: Double},
}, {timestamps: false})

const Tractaments = mongoose.model('Tractaments', TractamentsSchema, 'treatments')
module.exports = Tractaments