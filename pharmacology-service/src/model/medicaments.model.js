const mongoose = require('mongoose')

let  MedicamentSchema = new mongoose.Schema({
  'Codi_Medicament': {type: String},
  'Nom_Medicament': {type: String},
  'PVP': {type: Number},
  'GT': {type: String},
  'Any': {type: Number},
  'Codi_ATC5': {type: String},
  'Nom_ATC5': {type: String},
  'Codi_ATC7': {type: String},
  'Numero_Principi_Actiu(PA)': {type: Number},
  'Codi_PA': {type: String},
  'Nom_PA': {type: String},
  'Quantitat_PA': {type: Number},
  'Unitats': {type: Number},
  'DDD': {type: Number},
  'DDD_msc': {type: Number},
  'Numero_DDD_msc': {type: Number},
  'Numero_DDD_calculat': {type: Number},
  'Unitats_DDD': {type: String}
}, {timestamps: false})

const Medicament = mongoose.model('Medicament', MedicamentSchema, 'medicament')
module.exports = {Medicament, MedicamentSchema}