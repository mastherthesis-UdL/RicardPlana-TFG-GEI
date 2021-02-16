import sys
import logging.handlers

from pymongo import MongoClient, InsertOne
from pymongo.errors import BulkWriteError
from datetime import date


MONGO_HOST = "127.0.0.1"
MONGO_PORT = 27017
NUMBER_INSERTS = 50000
FIELDS = []
FIELDS_FILE = 'database_fields.csv'

log_name = str(date.today().strftime('%b-%d-%Y')) + '.log'

logging.basicConfig(filename=log_name,
                    filemode='a',
                    format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                    datefmt='%H:%M:%S',
                    level=logging.DEBUG)

logger = logging.getLogger(log_name)


def insert_registers(args):
    year = int(args[1].split("/")[-1].split("_")[1].split(".")[0])
    filename = args[1]

    if len(args) == 4:
        mongo_masterDB = MongoClient(args[2], int(args[3]))
    else:
        mongo_masterDB = MongoClient(MONGO_HOST, MONGO_PORT)

    mongoM_masterCOLL = mongo_masterDB.samples2

    patients = []
    drugs = []
    doctors = []
    tractaments = []
    count = 0

    try:
        with open(args[1], encoding="utf-8") as csvfile:
            for line in csvfile:
                spplited_line = line.split(";")

                if count == NUMBER_INSERTS:
                    count = 0
                    insert_patients(patients, mongoM_masterCOLL)
                    insert_drugs(drugs, mongoM_masterCOLL)
                    insert_doctors(doctors, mongoM_masterCOLL)
                    insert_tractaments(tractaments, mongoM_masterCOLL)

                    patients = []
                    drugs = []
                    doctors = []
                    tractaments = []

                patients.append(add_patient(spplited_line, year))
                drugs.append(add_drugs(spplited_line, year))
                doctors.append(add_doctors(spplited_line))
                tractaments.append(add_tractament(spplited_line, year))

                count += 1

        insert_patients(patients, mongoM_masterCOLL)
        insert_drugs(drugs, mongoM_masterCOLL)
        insert_doctors(doctors, mongoM_masterCOLL)
        insert_tractaments(tractaments, mongoM_masterCOLL)
        insert_filename(filename, mongoM_masterCOLL,year)
        
    except Exception as e:
        logger.error(e)
        sys.exit()

def insert_filename(filename, mongo, year):
    try:
        mongo.fitxers.insert_one({FIELDS[20]: filename,
                                  FIELDS[19] : year,
                                  FIELD[21]: datetime.now().strftime("%d/%m/%Y %H:%M:%S")
                                  })

    except BulkWriteError as bwe:
        logger.info(bwe.details)

def add_tractament(line, year):
    return InsertOne({FIELDS[4]: int(line[13].split(",")[0]),
                      FIELDS[5]: int(line[14].split(",")[0]),
                      FIELDS[6]: float(line[16].replace(",",".")),
                      FIELDS[7]: float(line[17].replace(",",".")),
                      FIELDS[0]: {FIELDS[8]: int(line[1]),
                                  FIELDS[9]: line[2][1:-1],
                                  FIELDS[10]: line[3][1:-1],
                                  FIELDS[11]: int(line[4]),
                                  FIELDS[12]: int(float(line[5].replace(",","."))),
                                  FIELDS[13]: int(line[6][1:-1]) },
                      FIELDS[1]: {FIELDS[14]: int(line[10]),
                                     FIELDS[15]: line[11][1:-1],
                                     FIELDS[16]: float(line[14].replace(",",".")),
                                     FIELDS[17]: line[12][1:-1]
                                     },
                      FIELDS[2]: {FIELDS[18]: line[9]},
                      FIELDS[19]: year
                      })

def parse_fields():
    with open(FIELDS_FILE, encoding="utf-8") as csvfile:
            for line in csvfile:
                FIELDS.append(line.split(";")[0])
    

def insert_tractaments(tractaments, mongo):
    try:
        mongo.tractaments.create_index(FIELDS[1]+'.'+FIELDS[14], unique=False)
        mongo.tractaments.create_index(FIELDS[0]+'.'+FIELDS[8], unique=False)
        mongo.tractaments.bulk_write(tractaments, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_patients(patients, mongo):
    try:
        mongo.pacients.create_index(FIELDS[8], unique=True)
        mongo.pacients.bulk_write(patients, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_drugs(drugs, mongo):
    try:
        mongo.medicament.create_index(FIELDS[14], unique=True)
        mongo.medicament.create_index(FIELDS[17], unique=True)
        mongo.medicament.bulk_write(drugs, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_doctors(doctors, mongo):
    try:
        mongo.metges.create_index(FIELDS[18], unique=True)
        mongo.metges.bulk_write(doctors, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def add_doctors(line):
    return InsertOne({FIELDS[18]: line[9],
                      # 'Nom': line[18],
                      # 'Codi_ABS': line[19]
                      })


def add_drugs(line, year):
    return InsertOne({FIELDS[14]: int(line[10]),
                      FIELDS[15]: line[11][1:-1],
                      FIELDS[16]: float(line[14].replace(",",".")),
                      FIELDS[17]: line[12][1:-1],
                      FIELDS[19]: year
                      })


def add_patient(line, year):
    return InsertOne({FIELDS[8]: int(line[1]),
                      FIELDS[9]: line[2][1:-1],
                      FIELDS[10]: line[3][1:-1],
                      FIELDS[11]: int(line[4]),
                      FIELDS[12]: int(float(line[5].replace(",","."))),
                      FIELDS[13]: int(line[6][1:-1]),
                      FIELDS[19]: year
                      })


if __name__ == '__main__':
    
    if len(sys.argv) >= 2:
        parse_fields()
        insert_registers(sys.argv)
    else:
        print("WRONG SINTAX - it must match: python3 import_mongo {CSVFILE} [MONGO_IP MONGO_PORT]")