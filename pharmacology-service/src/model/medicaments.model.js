const mongoose = require('mongoose')

let  MedicamentSchema = new mongoose.Schema({
  'Codi_Medicament': {type: String},
  'Nom_Medicament': {type: String},
  'PVP': {type: Number},
  'GT': {type: String},
  'Any': {type: Number}
}, {timestamps: false})

const Medicament = mongoose.model('Medicament', MedicamentSchema, 'medicament')
module.exports = {Medicament, MedicamentSchema}