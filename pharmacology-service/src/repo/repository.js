'use strict'

const repository = (db) => {

  const tractaments = require('../model/tractaments.model')
  const patients_db = require('../model/pacients.model')
  const meds_db     = require('../model/medicaments.model')

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


    if ( options.filters.Sexe !== undefined){

      let patient_filter = {}
      let patients = []

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
        patients_db.Pacients.aggregate([{$match: 
          _filters
        }, {$count: 'pacients'
        }
        ]).then(_matrix => {
          resolve(_matrix)
        })
      })
    }

    if ( options.filters.Codi_Medicament !== undefined){

      let meds_filter = {}
      let meds = []

      for (let m in options.filters.Codi_Medicament){
        let aux = {}
        aux['Codi_Medicament'] = options.filters.Codi_Medicament[m]
        meds.push(aux)
        console.log(meds)
      }

      meds_filter = {
        $or: meds
       }

       let _filterArray = []
      _filterArray.push(meds_filter)
      let _filters = { $and: _filterArray}
       
      return new Promise((resolve, reject) => {
        meds_db.Medicament.aggregate([{$match: 
          _filters
        }
        ]).then(_matrix => {
          resolve(_matrix)
        })
      })
    }

    

    if ( options.filters.totalsCount !== undefined){
       
      return new Promise((resolve, reject) => {
        tractaments.aggregate(
          [{
            $group: {
                _id: null,
                sumPacient: {
                    $sum: '$Aportacion_cliente'
                },
                sumLIQ: {
                    $sum: '$LIQ'
                },
                sumRec: {
                    $sum: '$Rec'
                }
            }
        }]
        ).then(_matrix => {
          resolve(_matrix)
        })
      })
    }

    if ( options.filters.totalReceipt !== undefined){

      return new Promise((resolve, reject) => {
        tractaments.aggregate(
          [{$match: {
            "Medicament.Codi_Medicament":options.filters.totalReceipt[0]
          }}, {$group: {
            _id: "$PF",
            sumRec:{$sum:'$Rec'},
          }}]
        ).then(_matrix => {
          resolve(_matrix)
        })
      })
    }

    if ( options.filters.countByComarca !== undefined){

      return new Promise((resolve, reject) => {
        tractaments.aggregate(
          [{$match: {
            "Medicament.Codi_Medicament": options.filters.countByComarca[0]
          }}, {$group: {
            _id: "$Codi_Comarca",
            count:{$sum:1}
          }}]
        ).then(_matrix => {
          resolve(_matrix)
        })
      })
    }

    if ( options.filters.avgAge !== undefined){
       
      return new Promise((resolve, reject) => {
        patients_db.Pacients.aggregate(
          [{$match: {
          }}, {$group: {
            _id: null,  
            avgEdad:{$avg:'$AnysEdat'}
          
            }}]
        ).then(_matrix => {
          resolve(_matrix)
        })
      })
    }

    if ( options.filters.SexeCount !== undefined){

      let patient_filter = {}
      let patients = []

      for (let m in options.filters.SexeCount){
        let aux = {}
        aux['Sexe'] = options.filters.SexeCount[m]
        patients.push(aux)
        console.log(patients)
      }
      console.log(patients)
      patient_filter = {
        $or: patients
       }

       let _filterArray = []
      _filterArray.push(patient_filter)
      let _filters = { $and: _filterArray}
       
      return new Promise((resolve, reject) => {
        patients_db.Pacients.aggregate([{$match: 
          _filters
        }, {
          $group: {
              _id: '$AnysEdat',
              count: {
                  $sum: 1
              }
      
          }
        }
        ]).then(_matrix => {
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