import sys
import pymongo
from pymongo import MongoClient, UpdateOne
from pymongo.errors import BulkWriteError


MONGO_HOST = "127.0.0.1"
MONGO_PORT = 27017
INSERTS = 50000


def check_file(_args):

    filename = _args[1]
    to_insert = []
    count = 0
    numerolinia = 0

    mongo_masterDB = MongoClient(MONGO_HOST, MONGO_PORT)
    mongoM_masterCOLL = mongo_masterDB.samples
    col = mongoM_masterCOLL["medicament"]
    try:
        with open(_args[1], encoding="latin-1") as csvfile:
            for line in csvfile:
                nLine = convert_line(line.split(";"))
                col.find_one_and_update(
                    {"Codi_Medicament": nLine[14]},
                    {"$set":
                        {"Codi_ATC5": nLine[0],
                        "Nom_ATC5": nLine[1],
                        "Codi_ATC7": nLine[2],
                        "Nom_ATC7": nLine[3],
                        "Numero_Principi_Actiu(PA)": nLine[4],
                        "Codi_PA": nLine[5],
                        "Nom_PA": nLine[6],
                        "Quantitat_PA": nLine[7],
                        "Unitats": nLine[8],
                        "DDD": nLine[9], 
                        "DDD_msc": nLine[10],
                        "Numero_DDD_msc": nLine[11], 
                        "Numero_DDD_calculat": nLine[12], 
                        "Unitats_DDD": nLine[13][1:-1],
                        #"GT": "",                      
                        }
                    }, upsert=True)
                
    except Exception as e:
        print(e)
        print(line)
        sys.exit()


def convert_line(_line):
    new_line = []

    new_line.append(_line[0][1:-1])
    new_line.append(_line[1][1:-1])
    new_line.append(_line[2][1:-1])
    new_line.append(_line[3][1:-1])
    try:
        new_line.append(int(float(_line[4])))
    except ValueError as e:
        new_line.append(int(0))

    new_line.append(_line[5][1:-1])
    new_line.append(_line[6][1:-1])

    try:
        new_line.append(int(float(_line[9].replace(",", "."))))
    except ValueError as e:
        new_line.append(int(0))

    try:
        new_line.append(int(float(_line[10].replace(",", "."))))
    except ValueError as e:
        new_line.append(int(0))

    try:
        new_line.append(int(float(_line[11].replace(",", "."))))
    except ValueError as e:
        new_line.append(int(0))

    try:
        new_line.append(int(float(_line[12].replace(",", "."))))
    except ValueError as e:
        new_line.append(int(0))

    try:
        new_line.append(int(float(_line[13].replace(",", "."))))
    except ValueError as e:
        new_line.append(int(0))

    try:
        new_line.append((int(float(_line[14].replace(",", ".")))))
    except ValueError as e:
        new_line.append(int(0))

    new_line.append(_line[15].replace("\n",""))
    new_line.append(_line[7].split(",")[0])
    #print(new_line)
    #print(new_line)
    return new_line

if __name__ == '__main__':

    if len(sys.argv) >= 2:
        check_file(sys.argv)
    else:
        print(
            "WRONG SINTAX - it must match: python3 import_drugs {CSVFILE}")
