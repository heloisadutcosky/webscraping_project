from scrapy import Spider, Request
from crypto.items import CryptoItem
import re
from datetime import datetime

class CryptoSpider(Spider):
	name = 'crypto_spider'
	allowed_urls = ['https://coinmarketcap.com/']
	start_urls = ['https://coinmarketcap.com/all/views/all']


	def parse(self, response):
		rows_main = response.xpath('//*[@id="currencies-all"]/tbody/tr')

		for row in rows_main:
			name = row.xpath('./td[2]//a[@class = "currency-name-container link-secondary"]/text()').extract_first()
			print(name)
			symbol = row.xpath('./td[3]/text()').extract_first()
			print(symbol)
			circulating_supply = row.xpath('./td[6]//span/text()').extract_first()
			circulating_supply = int(circulating_supply.replace(',',''))
			print(circulating_supply)

			print('='*50)

			url = row.xpath('./td[2]//a[@class = "link-secondary"]/@href').extract_first()

			result_url = 'https://coinmarketcap.com{}historical-data/?start=20130428&end=20181020'.format(url)

			yield Request(url=result_url, meta={'name': name, 'symbol': symbol},
				callback=self.parse_result_page)

	def parse_result_page(self, response):

		name = response.meta['name']
		symbol = response.meta['symbol']

		rows_crypto = response.xpath('//*[@id="historical-data"]//table/tbody/tr')

		for row_crypto in rows_crypto:
			date = row_crypto.xpath('./td[1]/text()').extract_first()
			date = datetime.strptime(date, '%b %d, %Y')
			date = datetime.date(date)
			print(date)
			open_value = row_crypto.xpath('./td[2]/text()').extract_first()
			print(open_value)
			high_value = row_crypto.xpath('./td[3]/text()').extract_first()
			print(high_value)
			low_value = row_crypto.xpath('./td[4]/text()').extract_first()
			print(low_value)
			close_value = row_crypto.xpath('./td[5]/text()').extract_first()
			print(close_value)
			volume = row_crypto.xpath('./td[6]/text()').extract_first()
			volume = int(volume.replace(',',''))
			print(volume)
			market_cap = row_crypto.xpath('./td[7]/text()').extract_first()
			market_cap = int(market_cap.replace(',',''))
			print(market_cap)

			print('*'*50)


			item = CryptoItem()
			item['name'] = name
			item['symbol'] = symbol
			item['date'] = date
			item['open_value'] = open_value
			item['high_value'] = high_value
			item['low_value'] = low_value
			item['close_value'] = close_value
			item['volume'] = volume
			item['market_cap'] = market_cap
			yield item


			
			
