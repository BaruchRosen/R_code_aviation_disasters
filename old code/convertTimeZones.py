from datetime import datetime
import pytz
import pandas as pd
import csv
import re

def IsraelTimeUTC(date_time, utcMIN, targetCountry = 'Asia/Jerusalem'):
    utc_offset = pytz.FixedOffset(utcMIN)  # UTC+3:00 is 180 minutes ahead

    # Specify the date and time you want to convert (e.g., "21/1/1993 16:00")
    result = re.sub(r'[^a-zA-Z0-9\s:-]','', date_time)
    result = re.sub(r'[-]',' ', result)
    if 'LT' in result:
        result = '09 Aug 24 13:22'
        print('gotch!')
    date_str = result
    # "21/1/1993 16:00"

    # Parse the date string into a datetime object (day/month/year hour:minute format)
    fmt = "%d %b %y %H:%M"
    dt = datetime.strptime(date_str, fmt)


    localized_time = utc_offset.localize(dt)
    israel_tz = pytz.timezone('Asia/Jerusalem')
    israel_time = localized_time.astimezone(israel_tz)
    return israel_time.strftime('%Y-%m-%d %H:%M:%S')


def convertTime(date_time, country, targetCountry = 'Asia/Jerusalem'):
    # Define the time zones you want to convert between
    from_zone = pytz.timezone(country) 
    to_zone = pytz.timezone(targetCountry)

    # Specify the date and time you want to convert (e.g., "21/1/1993 16:00")
    result = re.sub(r'[^a-zA-Z0-9\s:-]','', date_time)
    result = re.sub(r'[-]',' ', result)
    if 'LT' in result:
        result = '09 Aug 24 13:22'
        print('gotch!')
    date_str = result
    # "21/1/1993 16:00"

    # Parse the date string into a datetime object (day/month/year hour:minute format)
    fmt = "%d %b %y %H:%M"
    dt = datetime.strptime(date_str, fmt)

    # Localize the datetime to the 'from_zone' time zone
    localized_time = from_zone.localize(dt)

    # Convert the time to the target time zone
    target_time = localized_time.astimezone(to_zone)

    # Print both times
    print(f"Time in {from_zone.zone}: {localized_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Time in {to_zone.zone}: {target_time.strftime('%Y-%m-%d %H:%M:%S')}")
    return target_time.strftime('%Y-%m-%d %H:%M:%S')

TimeZonesData = pd.read_excel('countryTimeZones.xlsx')
timeZoneNames = TimeZonesData['TimeZones'].tolist()

def utcFromString(string): # find 
    if type(string)==float:
        print("error!!! 999")
        return 0
    withoutUTC = string.split('UTC')[0]
    withoutHours = withoutUTC.split(':')[0]
    if "-" in withoutHours or '−' in withoutHours:
        return -1*int(withoutHours.split('-')[-1].split('−')[-1])
    elif '±' in withoutHours:
        return int(withoutHours[1:])
    else:
        return int(withoutHours)
    

countries2UTC = pd.read_excel('countries_timeZones.xlsx')
countries2UTCList = [countries2UTC.iloc[:,0].tolist(), [ utcFromString(ele) for ele in countries2UTC.iloc[:,1].tolist()]]
# todo: read UTC per name and add option to find time with this table!

# accidentFullDB = pd.read_csv('accidentDB 1980 - 2024.csv')
timeData = []

def rowString2finalString(stringArray):
    global timeZoneNames
    newString = stringArray[0] + ',' # Date ,
    # try to find time!
    time = ''
    basicCountry = ''
    country = ''
    for i, word in enumerate(stringArray):
        if word=='Time':
            time = stringArray[i+1]
            if time == '':
                time = '12:00' # could be changed!!!
            break
    for i, word in enumerate(stringArray): # get raw coutry name
        if word=='Phase':
            basicCountry = stringArray[i-1]
            break        

    for timeZone in timeZoneNames: # convert to good time zone country
        timeZoneLower = timeZone.lower()
        basicCountryLower = basicCountry.split(' ')[-1].lower()
        if basicCountryLower in timeZoneLower:
            if basicCountryLower == 'iran' and "tirane" in timeZoneLower:
                continue
            if basicCountryLower == 'spain' and "port" in timeZoneLower:
                continue
            country = timeZone
            break        
    
    timeString = stringArray[0] + ' ' + time
    if country != '':
        IsraelTime = convertTime(timeString, country, 'Israel')
        print(basicCountry + ' -> ' + country + ' '  + time + ' -> ' + IsraelTime)
        newString += IsraelTime + ','
    else:
        
        for i, word in enumerate(countries2UTCList[0]):
            utcString = ''
            basicCountryLower = basicCountry.split(' ')[-1].lower()
            if basicCountryLower in word.lower():
                # print(word.lower() + ' ' + word)
                utcString = countries2UTCList[1][i]
                offsetMin = utcString*60 # todo: convert...
                IsraelTime = IsraelTimeUTC(timeString, offsetMin, 'Israel')
                print(basicCountry + ' -> ' + country + ' '  + time + ' -> ' + IsraelTime)
                newString += IsraelTime + ','
                break
        if utcString == '':
            print('error date:' + stringArray[0])
    return newString

with open('accidentDB 1980 - 2024.csv') as file_obj: 
    reader_obj = csv.reader(file_obj)
    for row in reader_obj:
        newString = rowString2finalString(row)
        timeData.append(newString)
# print(timeData)


with open('accidentDB IsraelTime.csv', 'w') as f:
    labelString = 'Date,Israel Time'
    f.write(f"{labelString}\n")
    for line in timeData:
        f.write(f"{line}\n")