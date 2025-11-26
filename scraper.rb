require 'nokogiri'
require 'httparty'
require 'csv'
require 'json'

class WebScraper
  def initialize
    @data = []
  end

  # Scraper para noticias de ejemplo (BBC News)
  def scrape_news
    url = "https://www.bbc.com/news"

    begin
      response = HTTParty.get(url)
      doc = Nokogiri::HTML(response.body)

      # Extraer noticias (selectores de ejemplo - pueden necesitar ajuste)
      doc.css('h3[class*="heading"]').first(10).each_with_index do |element, index|
        title = element.text.strip
        link = element.ancestors('a').first&.attribute('href')&.value
        link = "https://www.bbc.com#{link}" if link && !link.start_with?('http')

        news_item = {
          id: index + 1,
          title: title,
          link: link || 'No disponible',
          source: 'BBC News',
          scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
        }

        @data << news_item
        puts "📰 Noticia #{index + 1}: #{title}"
      end

      puts "\n✅ #{@data.size} noticias extraídas correctamente"

    rescue StandardError => e
      puts "❌ Error al scrapear: #{e.message}"
      # Datos de ejemplo en caso de error
      load_sample_data
    end
  end

  # Scraper alternativo para precios de productos
  def scrape_prices
    puts "\n🛒 Scrapeando precios de ejemplo..."

    # Datos de ejemplo (en un caso real, aquí iría el scraping real)
    sample_prices = [
      { id: 1, product: "iPhone 15", price: "$999", store: "Apple Store" },
      { id: 2, product: "Samsung Galaxy S24", price: "$849", store: "Amazon" },
      { id: 3, product: "Google Pixel 8", price: "$699", store: "Best Buy" },
      { id: 4, product: "MacBook Air", price: "$1099", store: "Apple Store" }
    ]

    @data = sample_prices
    puts "✅ #{@data.size} precios cargados"
  end

  def save_to_csv(filename = "scraped_data.csv")
    return if @data.empty?

    CSV.open(filename, "w") do |csv|
      # Headers
      csv << @data.first.keys

      # Data
      @data.each do |item|
        csv << item.values
      end
    end

    puts "💾 Datos guardados en #{filename}"
  end

  def save_to_json(filename = "scraped_data.json")
    return if @data.empty?

    File.open(filename, "w") do |file|
      file.write(JSON.pretty_generate(@data))
    end

    puts "💾 Datos guardados en #{filename}"
  end

  def display_data
    puts "\n" + "="*50
    puts "📊 DATOS EXTRAÍDOS"
    puts "="*50

    @data.each do |item|
      item.each do |key, value|
        puts "  #{key}: #{value}"
      end
      puts "-" * 30
    end
  end

  private

  def load_sample_data
    puts "📝 Cargando datos de ejemplo..."

    @data = [
      {
        id: 1,
        title: "Ejemplo de noticia 1",
        link: "https://ejemplo.com/noticia1",
        source: "Ejemplo",
        scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      },
      {
        id: 2,
        title: "Ejemplo de noticia 2",
        link: "https://ejemplo.com/noticia2",
        source: "Ejemplo",
        scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }
    ]
  end
end
