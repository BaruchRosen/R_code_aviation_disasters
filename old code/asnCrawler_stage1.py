import pandas as pd
from bs4 import BeautifulSoup
import requests
import random
import time
from datetime import datetime

accident_strings = []

headers = {"user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36"}


def get_pages_per_year(year_url, headers):
    # time_delay = (random.randrange(0, 1))
    # time.sleep(time_delay)
    req = requests.get(year_url, headers=headers)
    soup = BeautifulSoup(req.content, "html.parser")
    pagenumbers = soup.find_all("div", {"class": "pagenumbers"})
    links_num = len(str(pagenumbers).split('<a '))
    return links_num

def get_relevant_accidents_urls(full_url, headers, minimum_fat=50):
    # time_delay = (random.randrange(1, 2))
    # time.sleep(time_delay)
    req = requests.get(full_url, headers=headers)
    soup = BeautifulSoup(req.content, "html.parser")
    tables = soup.find_all('table')
    links = tables[0].select('a')
    urls = [link['href'] for link in links]
    disasters_table = tables[0]
    heads = []
    rows_fat = []
    rows_dates = []
    for i, row in enumerate(disasters_table.find_all('tr')):
        if i == 0:
            pass
        else:
            rows_fat.append([el.text.strip() for el in row.find_all('td')][4])
            rows_dates.append([el.text.strip() for el in row.find_all('td')][0])

    for i in range(len(rows_fat)):
        numbers = rows_fat[i].rstrip().split('+')
        int_numbers = [int(num) for num in numbers if num!='']
        rows_fat[i] = sum(int_numbers)
    url_list = []
    dates_list = []
    for i in range(len(rows_fat)):
        if rows_fat[i] >= minimum_fat:
            url_list.append(urls[i])
            dates_list.append(rows_dates[i])

    return url_list, dates_list

def get_accident(full_url, headers):
    req = requests.get(full_url, headers=headers)
    soup = BeautifulSoup(req.content, "html.parser")
    tables = soup.find_all('table')
    disaster_table = tables[0]
    heads = []
    rows = []
    for i, row in enumerate(disaster_table.find_all('tr')):
        if i == 0:
            headers = [el.text.strip() for el in row.find_all('th')]
        else:
            rows.append([el.text.strip() for el in row.find_all('td')])

    full_accident_text_csv = ''
    for row in rows:  #
        # row = ''
        full_accident_text_csv += row[0].split(':')[0] + ','
        full_accident_text_csv += row[1] + ','
    return full_accident_text_csv.replace('\n', ' ,')

minyear = 1993
maxYear = 2025
years = [*range(minyear,maxYear,1)]

start_time = time.time()
for year in years:
    # print('scan year' + str(year))
    year_text = str(year)
    year_url = 'https://asn.flightsafety.org/database/year/' + year_text
    number_for_year = get_pages_per_year(year_url, headers)
    pageNumbers = [*range(1,number_for_year+1,1)]
    for page in pageNumbers:
        # print('scan page' + str(page))
        page_url = year_url + '/' + str(page)
        accident_urls, accident_dates = get_relevant_accidents_urls(page_url, headers,minimum_fat=50)
        for i, accident in enumerate(accident_urls):
            accident_url = 'https://asn.flightsafety.org' + accident
            accident_string = get_accident(accident_url, headers)
            date_obj = datetime.strptime(accident_dates[i], "%d %b %Y")
            formatted_date = f"{date_obj.day}/{date_obj.month}/{date_obj.year}"
            print(formatted_date)
            accident_strings.append(formatted_date + ',' + accident_string)

with open('accidentDB ' + str(minyear) + ' - '+ str(maxYear-1) + '.csv', 'w') as f:
    for line in accident_strings:
        f.write(f"{line}\n")
end_time = time.time()

elapsed_time = end_time - start_time
print("Elapsed time: ", elapsed_time) 
# 436.3 seconds of running