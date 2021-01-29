import sys
import logging.handlers

from pymongo import MongoClient, InsertOne
from pymongo.errors import BulkWriteError
from datetime import date

MONGO_HOST = "127.0.0.1"
MONGO_PORT = 27017
NUMBER_INSERTS = 50000

log_name = filename = str(date.today().strftime('%b-%d-%Y')) + '.log'

logging.basicConfig(filename=log_name,
                    filemode='a',
                    format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                    datefmt='%H:%M:%S',
                    level=logging.DEBUG)

logger = logging.getLogger(log_name)


def insert_registers(args):
    if len(args) == 4:
        mongo_masterDB = MongoClient(args[2], int(args[3]))
    else:
        mongo_masterDB = MongoClient(MONGO_HOST, MONGO_PORT)

    mongoM_masterCOLL = mongo_masterDB.samplesTEST

    patients = []
    drugs = []
    doctors = []
    tractaments = []
    count = 0

    try:
        with open(args[1]) as csvfile:
            for line in csvfile:
                spplited_line = line.split(";")

                if count == NUMBER_INSERTS:
                    print("ONEJUMP")
                    count = 0
                    insert_patients(patients, mongoM_masterCOLL)
                    insert_drugs(drugs, mongoM_masterCOLL)
                    insert_doctors(doctors, mongoM_masterCOLL)
                    insert_tractaments(tractaments, mongoM_masterCOLL)

                    patients = []
                    drugs = []
                    doctors = []
                    tractaments = []

                patients.append(add_patient(spplited_line))
                drugs.append(add_drugs(spplited_line))
                doctors.append(add_doctors(spplited_line))
                tractaments.append(add_tractament(spplited_line))

                count += 1

        insert_patients(patients, mongoM_masterCOLL)
        insert_drugs(drugs, mongoM_masterCOLL)
        insert_doctors(doctors, mongoM_masterCOLL)
        insert_tractaments(tractaments, mongoM_masterCOLL)

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


def insert_tractaments(tractaments, mongo):
    try:
        mongo.tractaments.bulk_write(tractaments, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_patients(patients, mongo):
    try:
        mongo.pacients.create_index('Identificador', unique=True)
        mongo.pacients.bulk_write(patients, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_drugs(drugs, mongo):
    try:
        mongo.medicament.create_index('Codi_Medicament', unique=True)
        mongo.medicament.bulk_write(drugs, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_doctors(doctors, mongo):
    try:
        mongo.metges.create_index('NumColegiat', unique=True)
        mongo.metges.bulk_write(doctors, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def add_doctors(line):
    return InsertOne({'NumColegiat': line[9],
                      # 'Nom': line[18],
                      # 'Codi_ABS': line[19]
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
    if len(sys.argv) >= 2:
        insert_registers(sys.argv)
    else:
        print("WRONG SINTAX - it must match: python3 import_mongo {CSVFILE} [MONGO_IP MONGO_PORT]")
