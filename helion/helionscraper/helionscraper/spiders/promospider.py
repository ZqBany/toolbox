# Env preparation (linux/mac):
# sudo apt install -y python3-venv
# cd helion
# python3 -m venv venv
# source venv/bin/activate
# apt-get install python3-pip
# sudo pip3 install scrapy
#
# Usage:
# scrapy crawl promospider -o scraped_books.csv

import scrapy
import json
import re

from datetime import datetime
from helionscraper.items import HelionBook
from helionscraper.items import HelionBookLoader

class PromospiderSpider(scrapy.Spider):
    name = "promospider"
    allowed_domains = ["helion.pl", "www.goodreads.com"]
    start_urls = ["https://helion.pl/promocja-2za1/22"]

    def parse(self, response):
        book_list = response.css('.book-list-inner .list > li.classPresale')
        
        for book in book_list:
            book_item_loader = HelionBookLoader(item=HelionBook(), selector=book)
            book_item_loader.add_css('title', 'a.full-title-tooltip::text')
            book_item_loader.add_css('author', 'p.author a::text')
            book_item_loader.add_css('price', 'span[itemprop="price"]::text')
            book_item_loader.add_css('lowest_price', 'div.min-price::text')
            book_item_loader.add_css('url', 'a.show-short-desc::attr(href)')
            book_item = book_item_loader.load_item()
            yield response.follow(book_item['url'], callback=self.parse_details, meta={'book_item': book_item})
        
        next_page = response.css('[rel="next"] ::attr(href)').get()

        if next_page is not None:
            next_page_url = next_page
            yield response.follow(next_page_url, callback=self.parse)
            
    def parse_details(self, response):
        book_item = response.meta.get('book_item')
        if response.status >= 300:
            yield book_item
        details_css = response.css('.details-box.menu-section-item dt:contains("Tytuł oryginału") + dd a')
        if details_css:
            book_item['amazon_url'] = details_css.attrib['href']
            book_item['title_original'] = details_css.css("::text").get()
            asin = re.search("/ASIN/([0-9]+)/", book_item['amazon_url'])
            if asin is not None:
                book_item['amazon_asin'] = asin[1]
                book_item['goodread_url'] = "https://www.goodreads.com/book/isbn/" + book_item['amazon_asin']
                yield response.follow(book_item['goodread_url'], callback=self.parse_goodreads, meta={'book_item': book_item})
            else:
                yield book_item
        else:
            yield book_item
                        
    def parse_goodreads(self, response):
        book_item = response.meta.get('book_item')
        if response.status >= 300:
            yield book_item
        date_txt = response.css('.FeaturedDetails p[data-testid="publicationInfo"]::text').get()
        date_raw = re.split("published", date_txt, flags=re.IGNORECASE)[-1].strip()
        book_item['goodread_publication_date'] = datetime.strptime(date_raw, "%B %d, %Y").strftime("%d-%m-%Y")
        goodreads_json = response.css('script[type="application/ld+json"]::text').get()
        if goodreads_json:
            try:
                goodreads_json_obj = json.loads(goodreads_json)
                book_item['goodread_name'] = goodreads_json_obj['name']
                book_item['goodread_isbn'] = goodreads_json_obj['isbn']
                ratings = goodreads_json_obj['aggregateRating']
                book_item['goodread_rating'] = ratings['ratingValue']
                book_item['goodread_rating_count'] = ratings['ratingCount']
            except Exception as ex:
                print('Exception:', ex)
                return
        yield book_item

class ExtractExtraDataPipeline:
    def process_item(self, item, spider):
        adapter = ItemAdapter(item)

        if adapter.get('url'):
            details_page = fetch(adapter.get('url'))
            
            return item
        else:
            # drop item if no price
            raise DropItem(f"Missing url in {item}")