import pandas as pd
import time
import datetime
from pandas import Timestamp
from tkinter import filedialog

def choose_file(message):
    filepath = filedialog.askopenfilename(
        title=message,
        filetypes=[("All files", "*.*"), ("Text files", "*.txt")]
    )
    return filepath

# get holidays
holydaysData = pd.read_excel(choose_file('holidays 1993-2024.xlsx'))
dates_after_holday = holydaysData['Day after holiday'].tolist()

# aero accidents
aeroDATA = pd.read_csv(choose_file("accidentDB complete.csv"))
accident_dates = aeroDATA['IsraelDate'].tolist()
# todo: add condition by time to pass the by one day if accident happend after 17:00!!!!!!!!
accident_dates = [datetime.datetime.strptime(date, "%d/%m/%Y") for date in accident_dates]

# market DATA
market = pd.read_excel(choose_file("TA125_full.xlsx"))
market_dates = market['Date'].tolist()
# add coulmn to indicate days after holiday
after_holiday = []
for date in market_dates:
    if date in dates_after_holday:
        after_holiday.append(1)
    else:
        after_holiday.append(0)

market['after_holiday'] = after_holiday

# add coulmn to indicate days of accidents
afterAccidentDays = []
for date in market_dates:
    if date in accident_dates:
        afterAccidentDays.append(1)
    elif date - datetime.timedelta(days=1) in accident_dates:
        afterAccidentDays.append(2)
    elif date - datetime.timedelta(days=2) in accident_dates:
        afterAccidentDays.append(3)
    else:
        afterAccidentDays.append(0)
market['afterAccidentDays'] = afterAccidentDays

market.to_csv('text.csv', index=False)