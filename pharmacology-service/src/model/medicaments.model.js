const mongoose = require('mongoose')

let  MedicamentSchema = new mongoose.Schema({
  'Codi_Medicament': {type: String},
  'Nom_Medicament': {type: String},
  'PVP': {type: String},
  'GT': {type: String},
  'Any': {type: Int32},
  'Codi_ATC5': {type: String},
  'Nom_ATC5': {type: String},
  'Codi_ATC7': {type: String},
  'Nom_ATC7': {type: String},
  'Numero_Principi_Actiu(PA)': {type: Int32},
  'Nom_PA': {type: String},
  'Quantitat_PA': {type: Int32},
  'Unitats': {type: Int32},
  'DDD': {type: Int32},
  'DDD_msc': {type: Int32},
  'Numero_DDD_msc': {type: Int32},
  'Numero_DDD_calcular': {type: Int32},
  'Unitats_DDD': {type: String},
  
}, {timestamps: false})

const Medicament = mongoose.model('Medicament', MedicamentSchema, 'drugs')
module.exports = {Medicament, MedicamentSchema}