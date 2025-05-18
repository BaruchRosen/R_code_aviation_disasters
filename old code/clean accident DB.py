import csv 
import convertTimeZones as conv


def getElementAfterWord(element, array):
    for i,ele in enumerate(array):
        if ele == element:
            break
    return array[i+1]

def getElement(element, array): # tring to find 'Date' which isnt there... - fix
    for i,ele in enumerate(array):
        if ele == element:
            break
    return array[i+1]

def rowString2finalString(stringArray):
    newString = stringArray[0] # 08/02/1993,
    time = ''
    if getElementAfterWord("Time",stringArray) != '':        
        time = getElementAfterWord("Time",stringArray)  # 14:16
        newString += ',' + time
    else:
        time = '12:00'
        newString += ',' + time
    newString += ',' + getElementAfterWord("Fatalities",stringArray).split('/')[0].split(':')[1]  # Fatalities: 131 / Occupants: 131
    basic_country = ''
    for i, word in enumerate(stringArray): # get raw coutry name
        if word=='Phase':
            basicCountry = stringArray[i-1]
            break      
    
    newString += ',' + conv.convertTime_2(basicCountry, stringArray[0], time) 

    # for col in ['Time', 'Fatalities']:
    #     newString += ',' + getElement(col, stringArray)
    # israelDate =  ',' + 'IsraelDate'
    # israelTime = ',' + 'IsraelTime'
    # newString += israelDate + israelTime
    return newString


columnNames = ['Date', 'Time', 'Fatalities'] # , 'IsraelDate', 'IsraelTime'
newData = []

original_file = conv.choose_file('accidentDB 1993 - 2024.csv')
with open(original_file) as file_obj: 
    reader_obj = csv.reader(file_obj) 
    for row in reader_obj: 
        newString = rowString2finalString(row)
        newData.append(newString)

accident_file = original_file.split('accidentDB 1993 - 2024.csv')[0]
accident_file += 'accidentDB res.csv'

with open(accident_file, 'w') as f:
    labelString = 'Date,Time,Fatalities,IsraelDate,IsraelTime'
    f.write(f"{labelString}\n")
    for line in newData:
        f.write(f"{line}\n")