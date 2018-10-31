from selenium import webdriver
import time
import csv
from datetime import datetime
from datetime import date
import re

url = 'https://finance.yahoo.com/quote/^DJI/history?period1=1357016400&period2=1540699200&interval=1d&filter=history&frequency=1d'

csv_file = open('dow_jones.csv', 'w', encoding='utf-8')
writer = csv.writer(csv_file)

dj_dict = {}
dj_dict['coin'] = 'coin'
dj_dict['data'] = 'data'
dj_dict['open_value'] = 'open_value'
dj_dict['high_value'] = 'high_value'
dj_dict['low_value'] = 'low_value'
dj_dict['close_value'] = 'close_value'
dj_dict['adj_close'] = 'adj_close'
dj_dict['volume'] = 'volume'
writer.writerow(dj_dict.values())

driver = webdriver.Chrome()
driver.get(url)

last_height = driver.execute_script("return document.body.scrollHeight")
print(last_height)

i=0
while i<100:
	
	driver.execute_script("window.scrollTo(0, window.scrollY + 650)")
	last_height = driver.execute_script("return document.body.scrollHeight")
	print(i)
	i=i+1

rows = driver.find_elements_by_xpath('//table/tbody/tr')
print(len(rows))
print("=*=*="*50)

for row in rows:

	dj_dict = {}

	coin = 'Dow Jones'
	data = row.find_element_by_xpath('td[1]/span').text
	print(data)
	open_value = row.find_element_by_xpath('td[2]/span').text
	high_value = row.find_element_by_xpath('td[3]/span').text
	low_value = row.find_element_by_xpath('td[4]/span').text
	close_value = row.find_element_by_xpath('td[5]/span').text
	adj_close = row.find_element_by_xpath('td[6]/span').text
	volume = row.find_element_by_xpath('td[7]/span').text

	dj_dict['coin'] = coin
	dj_dict['data'] = data
	dj_dict['open_value'] = open_value
	dj_dict['high_value'] = high_value
	dj_dict['low_value'] = low_value
	dj_dict['close_value'] = close_value
	dj_dict['adj_close'] = adj_close
	dj_dict['volume'] = volume
	writer.writerow(dj_dict.values())

driver.close()

csv_file.close()


