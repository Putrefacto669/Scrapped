require 'nokogiri'
require 'httparty'
require 'csv'
require 'json'

class TitleScraper
  HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
  }

  def self.scrape_titles_from_url(url, include_paragraphs: false)
    begin
      response = HTTParty.get(url, headers: HEADERS, timeout: 10)

      unless response.success?
        puts "⚠️  Error HTTP: #{response.code} para #{url}"
        return []
      end

      doc = Nokogiri::HTML(response.body)
      titles = []

      # Extraer títulos h1-h6
      (1..6).each do |level|
        doc.css("h#{level}").each do |title|
          next if title.text.strip.empty?

          titles << {
            id: titles.size + 1,
            tag: "h#{level}",
            level: level,
            content: title.text.strip,
            url: url,
            character_count: title.text.strip.length,
            words_count: title.text.strip.split.length
          }
        end
      end

      # Opcional: incluir párrafos
      if include_paragraphs
        doc.css('p').each do |paragraph|
          text = paragraph.text.strip
          next if text.empty? || text.length < 10

          titles << {
            id: titles.size + 1,
            tag: "p",
            level: 0,
            content: text[0..100] + "...", # Primeros 100 caracteres
            url: url,
            character_count: text.length,
            words_count: text.split.length
          }
        end
      end

      puts "✅ #{titles.size} elementos encontrados en #{url}"
      return titles

    rescue HTTParty::Error => e
      puts "❌ Error de conexión con #{url}: #{e.message}"
    rescue StandardError => e
      puts "❌ Error inesperado con #{url}: #{e.message}"
    end

    return []
  end

  def self.scrape_multiple_urls(urls, delay: 1, include_paragraphs: false)
    all_titles = []

    urls.each_with_index do |url, index|
      puts "\n📊 [#{index + 1}/#{urls.size}] Scrapeando: #{url}"

      titles = scrape_titles_from_url(url, include_paragraphs: include_paragraphs)
      all_titles.concat(titles)

      # Delay para no sobrecargar el servidor
      sleep(delay) unless index == urls.size - 1
    end

    all_titles
  end

  def self.analyze_titles(titles)
    analysis = {
      total_titles: titles.size,
      by_tag: Hash.new(0),
      by_level: Hash.new(0),
      total_characters: 0,
      total_words: 0,
      urls_scraped: titles.map { |t| t[:url] }.uniq
    }

    titles.each do |title|
      analysis[:by_tag][title[:tag]] += 1
      analysis[:by_level][title[:level]] += 1 if title[:level] > 0
      analysis[:total_characters] += title[:character_count]
      analysis[:total_words] += title[:words_count]
    end

    analysis
  end

  def self.save_to_csv(titles, filename = "titles_analysis.csv")
    return if titles.empty?

    CSV.open(filename, "w", write_headers: true, headers: ["ID", "Tag", "Level", "Content", "URL", "Chars", "Words"]) do |csv|
      titles.each do |title|
        csv << [
          title[:id],
          title[:tag],
          title[:level],
          title[:content],
          title[:url],
          title[:character_count],
          title[:words_count]
        ]
      end
    end

    puts "💾 CSV guardado: #{filename} (#{titles.size} registros)"
  end

  def self.save_to_json(titles, filename = "titles_analysis.json")
    return if titles.empty?

    data = {
      metadata: {
        generated_at: Time.now.iso8601,
        total_records: titles.size,
        analysis: analyze_titles(titles)
      },
      titles: titles
    }

    File.write(filename, JSON.pretty_generate(data))
    puts "💾 JSON guardado: #{filename}"
  end

  def self.print_analysis(titles)
    analysis = analyze_titles(titles)

    puts "\n" + "="*60
    puts "📈 ANÁLISIS DE RESULTADOS"
    puts "="*60
    puts "Total de elementos: #{analysis[:total_titles]}"
    puts "URLs analizadas: #{analysis[:urls_scraped].join(', ')}"
    puts "Total caracteres: #{analysis[:total_characters]}"
    puts "Total palabras: #{analysis[:total_words]}"

    puts "\n📊 Distribución por etiquetas:"
    analysis[:by_tag].each do |tag, count|
      puts "  #{tag}: #{count} (#{(count.to_f/analysis[:total_titles]*100).round(1)}%)"
    end

    puts "\n🏷️  Distribución por niveles de título:"
    analysis[:by_level].each do |level, count|
      puts "  h#{level}: #{count} elementos"
    end
  end
end

# 🚀 INTERFAZ DE USUARIO MEJORADA
if __FILE__ == $0
  puts "🌐 SCRAPER AVANZADO DE TÍTULOS"
  puts "=" * 40

  # URLs por defecto o personalizadas
  default_urls = [
    "https://www.ruby-lang.org",
    "https://rubyonrails.org",
    "https://github.com"
  ]

  print "¿Usar URLs por defecto? (s/n): "
  use_default = gets.chomp.downcase == 's'

  urls = if use_default
           default_urls
         else
           puts "Introduce las URLs (una por línea, línea vacía para terminar):"
           user_urls = []
           while (url = gets.chomp) != ""
             user_urls << url
           end
           user_urls
         end

  print "¿Incluir párrafos? (s/n): "
  include_paragraphs = gets.chomp.downcase == 's'

  print "Delay entre requests (segundos): "
  delay = gets.chomp.to_f

  # Ejecutar scraping
  titles = TitleScraper.scrape_multiple_urls(
    urls,
    delay: delay,
    include_paragraphs: include_paragraphs
  )

  # Mostrar análisis
  TitleScraper.print_analysis(titles)

  # Guardar resultados
  if titles.any?
    TitleScraper.save_to_csv(titles, "titles_detailed.csv")
    TitleScraper.save_to_json(titles, "titles_detailed.json")

    puts "\n🎯 Ejemplos de títulos encontrados:"
    titles.first(3).each do |title|
      puts "  [#{title[:tag]}] #{title[:content][0..50]}..."
    end
  else
    puts "❌ No se encontraron títulos"
  end
end
