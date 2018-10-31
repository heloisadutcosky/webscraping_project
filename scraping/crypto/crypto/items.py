# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class CryptoItem(scrapy.Item):
	name = scrapy.Field()
	symbol = scrapy.Field()
	date = scrapy.Field()
	open_value = scrapy.Field()
	high_value = scrapy.Field()
	low_value = scrapy.Field()
	close_value = scrapy.Field()
	volume = scrapy.Field()
	market_cap = scrapy.Field()

