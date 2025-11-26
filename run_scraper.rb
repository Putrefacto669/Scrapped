require 'nokogiri'
require 'httparty'
require 'csv'
require 'json'

class WebScraper
  def initialize
    @data = []
  end

  def scrape_news
    puts "📰 Scrapeando noticias de ejemplo..."

    # Datos de ejemplo (evitamos problemas de conexión)
    sample_news = [
      {
        id: 1,
        title: "Ruby 3.2 libera nuevas características de performance",
        link: "https://www.ruby-lang.org/news",
        source: "Ruby News",
        scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      },
      {
        id: 2,
        title: "Rails 7 introduce nuevas herramientas de desarrollo",
        link: "https://rubyonrails.org/news",
        source: "Rails News",
        scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      },
      {
        id: 3,
        title: "GitHub Copilot ahora soporta Ruby y Rails",
        link: "https://github.com/features/copilot",
        source: "GitHub News",
        scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }
    ]

    @data = sample_news
    puts "✅ #{@data.size} noticias cargadas"
  end

  def scrape_real_website
    puts "🌐 Intentando scrapear sitio web real..."

    begin
      # Un sitio simple y confiable
      url = "https://www.wikipedia.org/"
      response = HTTParty.get(url, timeout: 10)

      if response.success?
        doc = Nokogiri::HTML(response.body)
        titles = doc.css('h1, h2, h3')

        titles.each_with_index do |title, index|
          @data << {
            id: index + 1,
            title: title.text.strip,
            tag: title.name,
            source: "https.org",
            scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          }
        end

        puts "✅ #{titles.size} elementos encontrados"
      else
        puts "❌ Error en la respuesta HTTP"
        load_sample_data
      end

    rescue StandardError => e
      puts "❌ Error al conectar: #{e.message}"
      load_sample_data
    end
  end

  def save_to_csv(filename = "scraped_data.csv")
    return if @data.empty?

    CSV.open(filename, "w") do |csv|
      csv << @data.first.keys
      @data.each { |item| csv << item.values }
    end

    puts "💾 Datos guardados en #{filename}"
  end

  def save_to_json(filename = "scraped_data.json")
    return if @data.empty?

    File.write(filename, JSON.pretty_generate(@data))
    puts "💾 Datos guardados en #{filename}"
  end

  def display_data
    if @data.empty?
      puts "📭 No hay datos para mostrar"
      return
    end

    puts "\n" + "="*50
    puts "📊 DATOS EXTRAÍDOS (#{@data.size} registros)"
    puts "="*50

    @data.each do |item|
      item.each { |key, value| puts "  #{key}: #{value}" }
      puts "-" * 30
    end
  end

  def clear_data
    @data.clear
    puts "🗑️  Datos limpiados"
  end

  private

  def load_sample_data
    puts "📝 Cargando datos de ejemplo..."

    @data = [
      {
        id: 1,
        title: "Ejemplo de noticia 1 - Aprendiendo Ruby",
        link: "https://ejemplo.com/noticia1",
        source: "Ejemplo",
        scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      },
      {
        id: 2,
        title: "Ejemplo de noticia 2 - Web Scraping con Nokogiri",
        link: "https://ejemplo.com/noticia2",
        source: "Ejemplo",
        scraped_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }
    ]
  end
end

# 🚀 INTERFAZ MEJORADA - MÁS ROBUSTA
def main
  scraper = WebScraper.new

  puts "🌐 WEB SCRAPER CON RUBY"
  puts "=" * 40

  begin
    loop do
      puts "\n¿Qué quieres hacer?"
      puts "1. 📰 Scrapear noticias de ejemplo"
      puts "2. 🌐 Scrapear sitio web real (httpbin.org)"
      puts "3. 👀 Ver datos actuales"
      puts "4. 💾 Guardar a CSV"
      puts "5. 💾 Guardar a JSON"
      puts "6. 🗑️  Limpiar datos"
      puts "7. 🚪 Salir"
      print "\nSelecciona una opción (1-7): "

      # Manejo más robusto de la entrada
      input = gets
      break if input.nil? # Si se cierra la entrada

      option = input.chomp.to_i

      case option
      when 1
        scraper.scrape_news
      when 2
        scraper.scrape_real_website
      when 3
        scraper.display_data
      when 4
        scraper.save_to_csv
      when 5
        scraper.save_to_json
      when 6
        scraper.clear_data
      when 7
        puts "👋 ¡Hasta luego!"
        break
      else
        puts "❌ Opción no válida. Por favor usa 1-7."
      end
    end
  rescue Interrupt
    puts "\n\n⏹️  Programa interrumpido por el usuario"
  rescue StandardError => e
    puts "❌ Error inesperado: #{e.message}"
  end
end

# Ejecutar el programa
if __FILE__ == $0
  main
end
