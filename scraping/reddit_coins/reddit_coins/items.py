# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class RedditCoinsItem(scrapy.Item):
	# define the fields for your item here like:
	# name = scrapy.Field()
	coin = scrapy.Field()
	subscribers = scrapy.Field()
	head = scrapy.Field()
	news_date = scrapy.Field()
	fonte = scrapy.Field()
	user = scrapy.Field()
	comments = scrapy.Field()
	rank = scrapy.Field()
	score = scrapy.Field()
	moderator = scrapy.Field()
	post_karma = scrapy.Field()
	comment_karma = scrapy.Field()
	
