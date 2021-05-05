'use strict'

const repository = (db) => {

  const tractaments = require('../model/tractaments.model')
  const patients_db = require('../model/pacients.model')

  const getTractaments= (options) => {
    
    let medicaments_filter = {}
    let medicaments = []
    if ( options.filters.medicaments !== undefined){

         for (let m in options.filters.medicaments){
            let aux = {}
            aux['Medicament.Codi_Medicament'] = options.filters.medicaments[m]
            medicaments.push(aux)
         }

         medicaments_filter = {
           $or: medicaments
       }     
    }


    let gt_filter = {}
    let gt = []
    if ( options.filters.GT !== undefined){

         for (let m in options.filters.GT){
            let aux = {}
            aux['Medicament.GT'] = options.filters.GT[m]
            gt.push(aux)
         }

         gt_filter = {
           $or: gt
       }
    }

    let pacients_filter = {}
    let pacients = []
    if ( options.filters.pacients !== undefined){

         for (let m in options.filters.pacients){
            let aux = {}
            aux['Pacient.Identificador'] = options.filters.pacients[m]
            pacients.push(aux)
         }

         pacients_filter = {
           $or: pacients
       }
    }


    let  fields_filter = []
    if (options.filters.fields !== undefined){
      fields_filter = options.filters.fields
    }

    //console.log(fields_filter)

    let patient_filter = {}
    let patients = []
    if ( options.filters.Sexe !== undefined){

         for (let m in options.filters.Sexe){
            let aux = {}
            aux['Sexe'] = options.filters.Sexe[m]
            patients.push(aux)
            console.log(patients)
         }

         patient_filter = {
           $or: patients
       }

       let _filterArray = []
      _filterArray.push(patient_filter)
      let _filters = { $and: _filterArray}
       
      return new Promise((resolve, reject) => {
        patients_db.Pacients.find(
          _filters
        ).select(fields_filter).then(_matrix => {
          resolve(_matrix)
        })
      })

      

    }


    let _filterArray = []
    _filterArray.push(medicaments_filter)
    _filterArray.push(pacients_filter)
    _filterArray.push(gt_filter)
    let _filters = { $and: _filterArray}

    console.log(_filters)

    return new Promise((resolve, reject) => {
      tractaments.aggregate([{$match: 
        _filters
      }, {$lookup: {
      
       from: 'medicament',   
       localField: 'Medicament.Codi_Medicament',    
       foreignField: 'Codi_Medicament',   
       as: 'Medicament'
      
      }}, {$unwind: {
        path: "$Medicament"
      }}]).then(_matrix => {
        resolve(_matrix)
      })
    })
  }

  const disconnect = () => {
    db.close()
  }

  return Object.create({
    getTractaments,
    disconnect
  })
}

const connect = (connection) => {
  return new Promise((resolve, reject) => {
    if (!connection) {
      reject(new Error('connection db not supplied!'))
    }
    resolve(repository(connection))
  })
}

module.exports = Object.assign({}, {connect})