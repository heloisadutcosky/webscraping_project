from selenium import webdriver
import time
import csv
from datetime import datetime
from datetime import date
import re

coins_list = ['bitcoin', 'ethereum', 'altcoin', 'blockchain', 'bitcoin-scams', 'bitcoin-regulation', 'litecoin', 'ripple', 'monero']

csv_file = open('cointelegraph.csv', 'w', encoding='utf-8')
writer = csv.writer(csv_file)

news_dict = {}
news_dict['coin'] = 'coin'
news_dict['head'] = 'head'
news_dict['news_date'] = 'news_date'
news_dict['resumo'] = 'resumo'
news_dict['author'] = 'author'
news_dict['views'] = 'views'
news_dict['comments'] = 'comments'
writer.writerow(news_dict.values())

for coin in coins_list:

	url = 'https://cointelegraph.com/tags/' + coin

	driver = webdriver.Chrome()
	driver.get(url)
	time.sleep(10)

	loadmore = driver.find_elements_by_xpath('//div[@class="row paging nav"]//a[@href="javascript:void(0)"]')
	try:
		loadmore = loadmore[0]
	except:
		loadmore

	i=0
	last_height = driver.execute_script("return document.body.scrollHeight")
	while i<500:
		try:
			driver.execute_script("arguments[0].click();", loadmore)
			print(i)

		except:
			break

		i = i+1

	news = driver.find_elements_by_xpath('//div[@id="recent"]/div[@class="row result"]')
	print(len(news))
	print("=*=*="*50)

	for new in news:

		news_dict = {}

		head = new.find_elements_by_xpath('./figure[@class="col-sm-8"]/h2/a')
		head = head[0].text
		head = str(head)
		print("="*50)
		print(head)
		
		news_date = new.find_elements_by_xpath('.//span[@class="date"]')
		news_date = news_date[0].text
		try:
			news_date = datetime.strptime(news_date, '%b %d, %Y')
			news_date = datetime.date(news_date)
			print(news_date)
		except:
			print(news_date)
			news_date = date.today()
			print(news_date)

		
		resumo = new.find_elements_by_xpath('.//p[@class="text"]/a')
		resumo = resumo[0].text
		resumo = str(resumo)
		
		author = new.find_elements_by_xpath('.//span[@class="author"]/span/a')
		author = author[0].text
		print(author)
		
		views = new.find_elements_by_xpath('./figure[@class="col-sm-8"]/div[2]//span[1]')
		try:
			views = views[0].text
			views = int(views.strip())
			print(views)
		except:
			views = new.find_elements_by_xpath('.//div[@class="stats"]/span[1]')
			try:
				views = views[0].text
				views = int(views.strip())
				print(views)
			except:
				views = ""
				print("ERRO views")
				print("-*-*-*-"*50)
		

		comments = new.find_elements_by_xpath('./figure[@class="col-sm-8"]/div[2]/span[2]')
		try:
			comments = comments[0].text
			comments = int(comments.strip())
			print(comments)
		except:
			try:
				comments = new.find_elements_by_xpath('./figure[@class="col-sm-8"]/div[2]/span[3]')
				comments = comments[0].text
				comments = int(comments.strip())
				print(comments)
			except:
				try:
					comments = new.find_elements_by_xpath('.//div[@class="stats"]/span[3]')
					comments = comments[0].text
					comments = int(comments.strip())
					print(comments)
				except:
					comments = 0
					print("ERRO comments")

		news_dict['coin'] = coin
		news_dict['head'] = head
		news_dict['news_date'] = news_date
		news_dict['resumo'] = resumo
		news_dict['author'] = author
		news_dict['views'] = views
		news_dict['comments'] = comments
		writer.writerow(news_dict.values())

	driver.close()

csv_file.close()


