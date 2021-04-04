class ScrapperService
  PREFIX = 'https://assmat.loire-atlantique.fr/'.freeze

  def call(attributes = {start: 0})
    @url = "https://assmat.loire-atlantique.fr/jcms/parents/faire-une-recherche-d-assistante-maternelle-fr-r1_58176?idCommune=rp1_62646&codeInsee=44109&cities=44036&longitude=-1.56512&latitude=47.219901&cityName=Nantes&adresse=Passage+Louis+L%C3%A9vesque+44000+Nantes&distance=3000&month=1617200000000&age=1%7C17%7C2%7C3%7C10%7C15%7C16%7C19&branchesId=cra_67000&branchesId=cra_67001&branchesId=&nomassmat=&isSearch=Ok&hashKey=88&withDispo=true&withDispoFuture=true&withNonDispo=false&withDispoNonRenseigne=false&start=#{attributes[:start]}"

    store_locally

    html_file = File.open('document.html')
    html_doc  = Nokogiri::HTML(html_file, nil, 'utf-8')

    assmats = []
    html_doc.search('.amcontainer').each do |amcontainer|
      data1   = amcontainer.search('.row-fluid')[0]
      data2   = amcontainer.search('.row-fluid')[1]
      @assmat = {}

      parse_data1(data1)
      parse_data2(data2)
      parse_subpage(@assmat[:url])

      assmats << @assmat
    end
    assmats
  end

  private

  def store_locally
    # store_in_file
    # unless File.file?('document.html') # tries to get page locally
    unless false # forces to get page from the web
      html_file = URI.parse(@url).open.read
      html_doc  = Nokogiri::HTML(html_file)
      File.write('document.html', html_doc.search('.amcontainer'))
    end
  end

  def parse_data1(data1)
    @assmat[:name]        = data1.at_css('h2').text.strip
    @assmat[:last_update] = data1.at_css('p').text.strip[-10..-1]
    quartier              = data1.at_css('.quartier')
    @assmat[:area]        = quartier ? quartier.text.strip[11..-1].split(' ').join(' ') : 'quartier inconnu'
    @assmat[:distance]    = data1.text.strip.match(/à (?<dist>.{1,4}) km/)[:dist].gsub(',', '.').to_f
  end

  def parse_data2(data2)
    # regexp1 = /(?<address>.*) Tél portable: (?<cell>.*) Courriel (?<available>.*) En savoir plus/
    regexp2         = /((?<address>.*) (Tél fixe : (?<land>(\d)+)) Tél portable: (?<cell>.*) Courriel (?<available>.*) En savoir plus|(?<address>.+) Tél portable: (?<cell>.+) Courriel (?<available>.*) En savoir plus)/
    data2_text      = data2.text.split(' ').join(' ')
    contact_details = data2_text.match(regexp2) || {} # empty hash if nil
    @assmat[:address]   = contact_details[:address] || 'NC'
    @assmat[:land]      = contact_details[:land] || 'NC'
    @assmat[:cell]      = contact_details[:cell] || 'NC'
    @assmat[:available] = contact_details[:available] || 'NC'
    # pp @assmat

    @assmat[:url] = "#{PREFIX}#{data2.search('.wysiwyg a').attribute('href').value}"
  end

  def parse_subpage(url)
    html_file = URI.parse(url).open.read

    li = Nokogiri::HTML(html_file).css('.listeDispos li')
    line = 1
    li.each_with_index do |dispo, index|
      next unless (index % 3).zero? # after each li with data, there are 2 lis with nothing interesting

      # get availability details
      cr_dispo        = dispo.at_css('p.crDispos') ? dispo.at_css('p.crDispos').text.strip : 'NC'
      precision_dispo = dispo.at_css('div.precisionDispo p') ? dispo.at_css('div.precisionDispo p').text.strip.gsub(',', '-') : 'Pas de précision'

      # get the full calendar, which is a big table of avail/not available timeslots.
      creneau_dispo = '|'
      dispo.search('tr td img').each_with_index do |creneau, index_creneau|
        if index_creneau.even?
          creneau['class'] == 'creneauNonDispo' ? creneau_dispo << '-' : creneau_dispo << 'X'
        end
        creneau_dispo << '|' if (creneau_dispo.size % 8).zero?
      end

      # store availability details with a dynamic key name
      storage_loc           = "dispos#{line}".to_sym
      @assmat[storage_loc]  = "#{cr_dispo}***#{precision_dispo}***#{creneau_dispo}"
      line += 1
    end
  end
end
