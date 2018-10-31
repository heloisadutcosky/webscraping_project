from scrapy import Spider, Request
from reddit_coins.items import RedditCoinsItem
import re
import numpy as np
from datetime import datetime


class RedditCoinsSpider(Spider):
	name = 'reddit_coins_spider'
	allowed_urls = ['https://www.reddit.com/']
	start_urls = ['https://www.reddit.com/r/CryptoCurrency/wiki/directory']



# Getting the list of cryptocoins that have subreddit
	def parse(self, response):
		coins = response.xpath('//ul//a[@rel="nofollow"]/text()').extract()
		coin_urls = response.xpath('//ul//a[@rel="nofollow"]/@href').extract()

		coins = coins[:coins.index('ZeroCoin')+1]
		coin_urls = coin_urls[:coins.index('ZeroCoin')+1]

		print(coins[0])
		print(coin_urls[0])
		print('*'*50)

		moderators_urls = ['https://old.reddit.com{}/about/moderators/'.format(x) for x in coin_urls]
		old_urls = ['https://old.reddit.com{}/top/?sort=top&t=all'.format(x) for x in coin_urls]

		print(moderators_urls[0])
		print(old_urls[0])
		print('*'*50)

		for moderators_url in moderators_urls:
			i = moderators_urls.index(moderators_url)
			yield Request(url=moderators_url, meta={'coin': coins[i], 'old_url': old_urls[i]},
				callback=self.parse_moderators)


# Getting the moderators list for each one of the coins subreddits
	def parse_moderators(self, response):

		coin = response.meta['coin']
		old_url = response.meta['old_url']

		print(coin)
		print(old_url)
		print('='*50)

		moderators = response.xpath('//span[@class="user"]/a/text()').extract()

		yield Request(url=old_url, meta={'coin': coin, 'moderators': moderators},
			callback=self.parse_old_url)


# Getting all the topics posted from the coins subreddits 
	def parse_old_url(self, response):

		coin = response.meta['coin']
		moderators = response.meta['moderators']

		subscribers = response.xpath('//span[@class="number"]/text()').extract()[0]

		news = response.xpath('//div[@id="siteTable"]/div')
		news = list(map(lambda i: news[i], np.arange(0,len(news),2)))

		new_url = response.xpath('//span[@class="next-button"]/a/@href').extract_first()

		for new in news:
			print(coin)
			print(new_url)
			print('='*50)

			head = new.xpath('.//p[@class="title"]/a/text()').extract_first()
			news_date = new.xpath('.//p/time/@datetime').extract_first()
			fonte = new.xpath('./@data-domain').extract_first() 
			user = new.xpath('./@data-author').extract_first()
			comments = new.xpath('./@data-comments-count').extract_first() 
			rank = new.xpath('./@data-rank').extract_first()
			score = new.xpath('./@data-score').extract_first()
			moderator = user in moderators

			user_url = new.xpath('.//p[@class="tagline "]/a/@href').extract_first()

			print(head)
			print(user_url)
			print('=*=-*'*50)

			try:
				yield Request(url=user_url, meta={'coin': coin, 'subscribers': subscribers,'head': head,
				'news_date': news_date, 'fonte': fonte, 'user': user, 'comments': comments, 'rank': rank, 'score': score, 
				'moderator': moderator}, callback=self.parse_user)

			except:
				try:
					print(new_url)
					print('=*=-*'*50) 
					yield Request(url=new_url, meta={'coin': coin, 'moderators': moderators}, callback=self.parse_old_url)
				except:
					continue

# Getting information on each of the user who posted the topics
	def parse_user(self, response):

		coin = response.meta['coin']
		subscribers = response.meta['subscribers']

		try:
			subscribers = int(subscribers.replace(",", ""))
		except:
			print(subscribers)
		
		head = response.meta['head']
		news_date = response.meta['news_date']
		try:
			news_date = datetime.strptime(news_date, '%Y-%m-%dT%H:%M:%S+00:00')
			news_date = datetime.date(news_date)
		except:
			print(news_date)


		fonte = response.meta['fonte']
		user = response.meta['user']
		comments = response.meta['comments']
		
		try:
			comments = int(comments.replace(",", ""))
		except:
			print(comments)

		rank = response.meta['rank']
		score = response.meta['score']
		moderator = response.meta['moderator']

		post_karma = response.xpath('//span[@class="karma"]/text()').extract_first()
		try:
			post_karma = int(post_karma.replace(",", ""))
		except:
			post_karma = response.xpath('//div[@class="ProfileSidebar__counterInfo"]/text()').extract_first()
			try:
				post_karma = re.findall('\d+', post_karma)
				post_karma = int(post_karma[0])
			except:
				print(post_karma)

		comment_karma = response.xpath('//span[@class="karma comment-karma"]/text()').extract_first()
		try:
			comment_karma = int(comment_karma.replace(",", ""))
		except:
			comment_karma = response.xpath('//div[@class="ProfileSidebar__counterInfo"]/text()').extract()[1]
			try:
				comment_karma = re.findall('\d+', comment_karma)
				comment_karma = int(comment_karma[0])
			except:
				print(comment_karma)


		item = RedditCoinsItem()
		item['coin'] = coin
		item['subscribers'] = subscribers
		item['head'] = head
		item['news_date'] = news_date
		item['fonte'] = fonte
		item['user'] = user
		item['comments'] = comments
		item['rank'] = rank
		item['score'] = score
		item['moderator'] = moderator
		item['post_karma'] = post_karma
		item['comment_karma'] = comment_karma
			
		yield item


		



