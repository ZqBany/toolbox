# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy
from itemloaders.processors import TakeFirst, MapCompose
from scrapy.loader import ItemLoader

class HelionBook(scrapy.Item):
   title = scrapy.Field()
   author = scrapy.Field()
   goodread_publication_date = scrapy.Field()
   goodread_rating = scrapy.Field()
   goodread_rating_count = scrapy.Field()
   title_original = scrapy.Field()
   amazon_url = scrapy.Field()
   goodread_url = scrapy.Field()
   url = scrapy.Field()
   amazon_asin = scrapy.Field()
   price = scrapy.Field()
   lowest_price = scrapy.Field()
   goodread_name = scrapy.Field()
   goodread_isbn = scrapy.Field()
   
   
class HelionBookLoader(ItemLoader):

    default_output_processor = TakeFirst()
    price_in = MapCompose(lambda x: x.split("zł")[0].strip())
    lowest_price_in = MapCompose(lambda x: x.strip().split("zł")[0].removeprefix("(").strip())
    url_in = MapCompose(lambda x: 'https:' + x )