import sys
import logging.handlers


from pymongo import MongoClient, InsertOne
from pymongo.errors import BulkWriteError
from datetime import date, datetime


MONGO_HOST = "127.0.0.1"
MONGO_PORT = 27017
NUMBER_INSERTS = 50000
FIELDS = []
FIELDS_FILE = 'database_fields.csv'
DESCRIPTIONS = []

log_name = str(date.today().strftime('%b-%d-%Y')) + '.log'

logging.basicConfig(filename=log_name,
                    filemode='a',
                    format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                    datefmt='%H:%M:%S',
                    level=logging.DEBUG)

logger = logging.getLogger(log_name)


def insert_registers(args):
    year = int(args[1].split("/")[-1].split("_")[-1].split(".")[0])
    filename = args[1].split("/")[-1]
    if len(args) == 4:
        mongo_masterDB = MongoClient(args[2], int(args[3]))
    else:
        mongo_masterDB = MongoClient(MONGO_HOST, MONGO_PORT)

    mongoM_masterCOLL = mongo_masterDB.samples

    patients = []
    drugs = []
    doctors = []
    treatments = []
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
                    insert_treatments(treatments, mongoM_masterCOLL)

                    patients = []
                    drugs = []
                    doctors = []
                    treatments = []

                patients.append(add_patient(spplited_line, year))
                drugs.append(add_drugs(spplited_line, year))
                doctors.append(add_doctors(spplited_line))
                treatments.append(add_treatments(spplited_line, year))

                count += 1

        insert_patients(patients, mongoM_masterCOLL)
        insert_drugs(drugs, mongoM_masterCOLL)
        insert_doctors(doctors, mongoM_masterCOLL)
        insert_treatments(treatments, mongoM_masterCOLL)
        insert_filename(filename, mongoM_masterCOLL, year)
        insert_fields(mongoM_masterCOLL)

    except Exception as e:
        logger.error(e)
        sys.exit()


def insert_fields(mongo):
    record = []
    try:
        for x in range(len(FIELDS)):
            record.append(InsertOne({'Field': FIELDS[x],
                                     'Description': DESCRIPTIONS[x],
                                     }))
        mongo.descripcions.bulk_write(record, ordered=False)

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def insert_filename(filename, mongo, year):
    try:
        mongo.fitxers.insert_one({FIELDS[20]: filename,
                                FIELDS[19]: year,
                                FIELDS[21]: str(datetime.now())
                                })

    except BulkWriteError as bwe:
        logger.info(bwe.details)


def add_treatments(line, year):
    parsed_patients = parse_patient(line)
    parsed_drugs = parse_drugs(line)
    parsed_treatmens = parse_treatment(line)
    return InsertOne({FIELDS[4]: parsed_treatmens[0],
                      FIELDS[5]: parsed_treatmens[1],
                      FIELDS[6]: parsed_treatmens[2],
                      FIELDS[7]: parsed_treatmens[3],
                      FIELDS[0]: {FIELDS[8]: parsed_patients[0],
                                  FIELDS[9]: parsed_patients[1],
                                  FIELDS[10]: parsed_patients[2],
                                  FIELDS[11]: parsed_patients[3],
                                  FIELDS[12]: parsed_patients[4],
                                  FIELDS[13]: parsed_patients[5]},
                      FIELDS[1]: {FIELDS[14]: parsed_drugs[0],
                                  FIELDS[15]: parsed_drugs[1],
                                  FIELDS[16]: parsed_drugs[2],
                                  FIELDS[17]: parsed_drugs[3]
                                  },
                      FIELDS[2]: {FIELDS[18]: line[9]},
                      FIELDS[19]: year,
                      FIELDS[22]: parsed_treatmens[4]
                      })


def parse_fields():
    with open(FIELDS_FILE, encoding="utf-8") as csvfile:
        for line in csvfile:
            FIELDS.append(line.split(";")[0])
            DESCRIPTIONS.append(line.split(";")[1][:-1])

def parse_treatment(line):
    newline = []

    try:
        newline.append(int(line[13].split(",")[0]))
    except ValueError as e:
        logger.info(e.details)
        newline.append(int(0))

    try:
        newline.append(int(line[14].split(",")[0]))
    except ValueError as e:
        logger.info(e.details)
        newline.append(int(0))

    try:
        newline.append(float(line[16].replace(",", ".")))
    except ValueError as e:
        logger.info(e.details)
        newline.append(float(0))

    try:
        newline.append(float(line[17].replace(",", ".")))
    except ValueError as e:
        logger.info(e.details)
        newline.append(float(0))
    try:
        newline.append(line[19][1:-2])
    except ValueError as e:
        logger.info(e.details)
        newline.append("")

        

    return newline


def insert_treatments(treatments, mongo):
    try:
        mongo.tractaments.create_index(FIELDS[1]+'.'+FIELDS[14], unique=False)
        mongo.tractaments.create_index(FIELDS[0]+'.'+FIELDS[8], unique=False)
        mongo.tractaments.bulk_write(treatments, ordered=False)

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
        mongo.medicament.create_index(FIELDS[17], unique=False)
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
    parsed_line = parse_drugs(line)
    return InsertOne({FIELDS[14]: parsed_line[0],
                      FIELDS[15]: parsed_line[1],
                      FIELDS[16]: parsed_line[2],
                      FIELDS[17]: parsed_line[3],
                      FIELDS[19]: year
                      })


def add_patient(line, year):
    parsed_line = parse_patient(line)
    return InsertOne({FIELDS[8]: parsed_line[0],
                      FIELDS[9]: parsed_line[1],
                      FIELDS[10]: parsed_line[2],
                      FIELDS[11]: parsed_line[3],
                      FIELDS[12]: parsed_line[4],
                      FIELDS[13]: parsed_line[5],
                      FIELDS[19]: year
                      })


def parse_patient(line):
    newline = []
    try:
        newline.append(line[1])
        newline.append(line[2].replace('"', ''))
        newline.append(line[3].replace('"', ''))
        try:
            newline.append(int(line[4]))
        except ValueError as e:
            logger.info(e)
            newline.append(int(0))
        try:
            newline.append(int(float(line[5].replace(",", "."))))
        except ValueError as e:
            logger.info(e)
            newline.append(int(0))
        try:
            newline.append(int(line[6][1:-1]))
        except ValueError as e:
            logger.info(e)
            newline.append(int(0))
        return newline
    except ValueError as e:
        logger.info(e)


def parse_drugs(line):
    newline = []
    try:
        newline.append(line[10])
        newline.append(line[11].replace('"', ''))
        try:
            newline.append(float(line[14].replace(",", ".")))
        except ValueError as e:
            logger.info(e)
            newline.append(float(0))
        newline.append(line[12][1:-1])
        return newline
    except ValueError as e:
        logger.info(e)


if __name__ == '__main__':

    if len(sys.argv) >= 2:
        parse_fields()
        insert_registers(sys.argv)
    else:
        print(
            "WRONG SINTAX - it must match: python3 import_mongo {CSVFILE} [MONGO_IP MONGO_PORT]")
