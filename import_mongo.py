import sys
import logging
import logging.handlers

from pymongo import MongoClient, InsertOne
from pymongo.errors import BulkWriteError
from datetime import date

MONGO_HOST = "192.168.101.98"
MONGO_PORT = 27017

mongo_masterDB = MongoClient(MONGO_HOST, MONGO_PORT)
mongoM_masterCOLL = mongo_masterDB.samples

log_name = filename = str(date.today().strftime('%b-%d-%Y')) + '.log'

logging.basicConfig(filename=log_name,
                    filemode='a',
                    format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                    datefmt='%H:%M:%S',
                    level=logging.DEBUG)

logger = logging.getLogger(log_name)


def insert_registers():
    patients = []
    drugs = []
    doctors = []
    tractaments = []
    try:
        with open('Test.txt') as csvfile:
            for line in csvfile:
                spplited_line = line.split(";")

                patients.append(add_patient(spplited_line))
                drugs.append(add_drugs(spplited_line))
                doctors.append(add_doctors(spplited_line))
                tractaments.append(add_tractament(spplited_line))

        insert_patients(patients)
        insert_drugs(drugs)
        insert_doctors(doctors)
        insert_tractaments(tractaments)

    except Exception as e:
        logger.error(e)
        sys.exit()


def add_tractament(line):
    return InsertOne({'Rec': line[13],
                      'ENV': line[14],
                      'Aportacion_cliente': line[16],
                      'LIQ': line[17],
                      'Pacient': {'Identificador': line[1],
                                  'Actiu/Pensionista': line[2][1:-1],
                                  'Titular/Beneficiari': line[3][1:-1],
                                  'Edat': line[4],
                                  'AnysEdat': line[5][1:-1],
                                  'Sexe': line[6][1:-1], },
                      'Medicament': {'Codi_Medicament': line[10],
                                     'Nom_Medicament': line[11][1:-1],
                                     'PVP': line[14],
                                     'GT': line[12][1:-1]
                                     },
                      'Metge': {'NumColegiat': line[9]}
                      })


def insert_tractaments(tractaments):
    try:
        mongoM_masterCOLL.tractaments.bulk_write(tractaments, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_patients(patients):
    try:
        mongoM_masterCOLL.pacients.create_index('Identificador', unique=True)
        mongoM_masterCOLL.pacients.bulk_write(patients, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_drugs(drugs):
    try:
        mongoM_masterCOLL.medicament.create_index('Codi_Medicament', unique=True)
        mongoM_masterCOLL.medicament.bulk_write(drugs, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_doctors(doctors):
    try:
        mongoM_masterCOLL.metges.create_index('NumColegiat', unique=True)
        mongoM_masterCOLL.metges.bulk_write(doctors, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def add_doctors(line):
    return InsertOne({'NumColegiat': line[9],
                      ##'Nom': line[18],
                      ##'Codi_ABS': line[19]
                      })


def add_drugs(line):
    return InsertOne({'Codi_Medicament': line[10],
                      'Nom_Medicament': line[11][1:-1],
                      'PVP': line[14],
                      'GT': line[12][1:-1]
                      })


def add_patient(line):
    return InsertOne({'Identificador': line[1],
                      'Actiu/Pensionista': line[2][1:-1],
                      'Titular/Beneficiari': line[3][1:-1],
                      'Edat': line[4],
                      'AnysEdat': line[5][1:-1],
                      'Sexe': line[6][1:-1],
                      })


if __name__ == '__main__':
    insert_registers()
