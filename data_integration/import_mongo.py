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

dictionary_abs_comarca = {
	'TÀRREG': 'Urgell',
	'ABS CERDANYA': 'Cerdanya',
	'ABS LLEIDA RURAL SUD': 'Segrià',
	'PONTS': 'Noguera',
	'ABS LA GRANADELLA': 'Segrià',
	'ABS ARAN': "Val d'Aran",
	'LA POBLA DE SEGUR': 'Pallars Jussà',
	'AGRAMUNT': 'Urgell',
	'PALLARS SOBIRÀ': 'Pallars Sobirà',
	'CAPPONT': 'Segrià',
	'EIXAMPLE': 'Segrià',
	'BELLPUIG': 'Urgell',
	"LA SEU D'URGELL": 'Alt Urgell',
	'SERÒS': 'Segrià',
	'ARTESA DE SEGRE': 'Noguera',
	"PLA D'URGELL": "Pla d'Urgell",
	'TÀRREGA': 'Urgell',
	'ALFARRÀS/ALMENAR': 'Segrià',
	'RONDA': 'Segrià',
	'BALAFIA': 'Segrià',
	'ALTA RIBAGORÇA': 'Alta Ribagorça',
	'BALAGUER': 'Noguera',
	'CERVERA': 'Segarra',
	'ALT URGELL-SUD': 'Alt Urgell',
	'ALCARRÀS': 'Segrià',
	'CS FERRAN': 'Segrià',
	'CENTRE SANTA MARIA': 'Segrià',
	'TREMP': 'Pallars Jussà',
	'ABS ALMACELLES': 'Segrià',
	'BORDETA': 'Segrià',
	'LLEIDA RURAL NORD': 'Segrià',
	'ABS BORGES BLANQUES': 'Garrigues',
	'':''
}

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
    return InsertOne({FIELDS[4]: parsed_treatmens[0], # Rec
                      FIELDS[5]: parsed_treatmens[1], # ENV
                      FIELDS[6]: parsed_treatmens[2], # Aportacion_cliente
                      FIELDS[7]: parsed_treatmens[3], # LIQ
                      FIELDS[0]: {FIELDS[8]: parsed_patients[0],    # Pacient_Identificador
                                  FIELDS[9]: parsed_patients[1],    # Pacient_Actiu/Pensionista
                                  FIELDS[10]: parsed_patients[2],   # Pacient_Titular/Beneficiari
                                  FIELDS[11]: parsed_patients[3],   # Pacient_Edat
                                  FIELDS[12]: parsed_patients[4],   # Pacient_AnysEdat
                                  FIELDS[13]: parsed_patients[5]},  # Pacient_Sexe
                      FIELDS[1]: {FIELDS[14]: parsed_drugs[0],      # Medicament_Codi_Medicament
                                  FIELDS[15]: parsed_drugs[1],      # Medicament_Nom_Medicament
                                  FIELDS[16]: parsed_drugs[2],      # Medicament_PVP
                                  FIELDS[17]: parsed_drugs[3]       # Medicament_GT
                                  },
                      FIELDS[2]: {FIELDS[18]: line[9]},             # Metge_NumColegiat
                      FIELDS[19]: year,                             # Any
                      FIELDS[22]: parsed_treatmens[4],              # ABS
                      FIELDS[23]: parsed_treatmens[5],              # PF
                      FIELDS[24]: parsed_treatmens[6]               # Codi_Comarca
                      })


def parse_fields():
    with open(FIELDS_FILE, encoding="utf-8") as csvfile:
        for line in csvfile:
            FIELDS.append(line.split(";")[0])
            DESCRIPTIONS.append(line.split(";")[1][:-1])

def parse_treatment(line):
    newline = []

    # Rec
    try:
        newline.append(int(line[13].split(",")[0]))
    except ValueError as e:
        logger.info(e.details)
        newline.append(int(0))
    # ENV
    try:
        newline.append(int(line[14].split(",")[0]))
    except ValueError as e:
        logger.info(e.details)
        newline.append(int(0))
    # Aportacion_cliente
    try:
        newline.append(float(line[16].replace(",", ".")))
    except ValueError as e:
        logger.info(e.details)
        newline.append(float(0))
    # LIQ
    try:
        newline.append(float(line[17].replace(",", ".")))
    except ValueError as e:
        logger.info(e.details)
        newline.append(float(0))
    # ABS
    try:
        newline.append(line[19][1:-2])
    except ValueError as e:
        logger.info(e.details)
        newline.append("")
    # PF
    try:
        newline.append(line[0][-2:])
    except ValueError as e:
        logger.info(e.details)
        newline.append("")
    # Codi_Comarca
    try:
        newline.append(dictionary_abs_comarca[line[19][1:-2]])
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
    return InsertOne({FIELDS[18]: line[9], # NumColegiat
                      # 'Nom': line[18],
                      # 'Codi_ABS': line[19]
                      })


def add_drugs(line, year):
    parsed_line = parse_drugs(line)
    return InsertOne({FIELDS[14]: parsed_line[0], # Codi_Medicament
                      FIELDS[15]: parsed_line[1], # Nom_Medicament
                      FIELDS[16]: parsed_line[2], # PVP
                      FIELDS[17]: parsed_line[3], # GT
                      FIELDS[19]: year            # Any
                      })


def add_patient(line, year):
    parsed_line = parse_patient(line)
    return InsertOne({FIELDS[8]: parsed_line[0],    # Identificador
                      FIELDS[9]: parsed_line[1],    # Actiu/Pensionista
                      FIELDS[10]: parsed_line[2],   # Titular/Beneficiari
                      FIELDS[11]: parsed_line[3],   # Edat
                      FIELDS[12]: parsed_line[4],   # AnysEdat
                      FIELDS[13]: parsed_line[5],   # Sexe
                      FIELDS[19]: year              # Any
                      })


def parse_patient(line):
    newline = []
    try:
        # Identificador
        newline.append(line[1])
        # Actiu/Pensionista
        newline.append(line[2].replace('"', ''))
        # Titular/Beneficiari
        newline.append(line[3].replace('"', ''))
        # Edat
        try:
            newline.append(int(line[4]))
        except ValueError as e:
            logger.info(e)
            newline.append(int(0))
        #AnysEdat
        try:
            newline.append(int(float(line[5].replace(",", "."))))
        except ValueError as e:
            logger.info(e)
            newline.append(int(0))
        #Sexe
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
        # Codi_Medicament
        newline.append(line[10])
        # Nom_Medicament
        newline.append(line[11].replace('"', ''))
        # PVP
        try:
            newline.append(float(line[14].replace(",", ".")))
        except ValueError as e:
            logger.info(e)
            newline.append(float(0))
        #GT
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
