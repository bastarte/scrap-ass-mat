
# url = 'https://assmat.loire-atlantique.fr/jcms/parents/faire-une-recherche-d-assistante-maternelle-fr-r1_58176?idCommune=rp1_62646&codeInsee=44109&cities=44036&longitude=-1.56512&latitude=47.219901&cityName=Nantes&adresse=Passage+Louis+L%C3%A9vesque+44000+Nantes&distance=3000&month=1617200000000&age=1%7C17%7C2%7C3%7C10%7C15%7C16%7C19&branchesId=cra_67000&branchesId=cra_67001&branchesId=&nomassmat=&isSearch=Ok&hashKey=88&withDispo=false&withDispoFuture=true&withNonDispo=false&withDispoNonRenseigne=false'

# url = 'https://assmat.loire-atlantique.fr/jcms/parents/faire-une-recherche-d-assistante-maternelle-fr-r1_58176?idCommune=rp1_62646&codeInsee=44109&cities=44036&longitude=-1.56512&latitude=47.219901&cityName=Nantes&adresse=Passage+Louis+L%C3%A9vesque+44000+Nantes&distance=3000&month=1617200000000&age=1%7C17%7C2%7C3%7C10%7C15%7C16%7C19&branchesId=cra_67000&branchesId=cra_67001&branchesId=&nomassmat=&isSearch=Ok&hashKey=88&withDispo=true&withDispoFuture=false&withNonDispo=false&withDispoNonRenseigne=false'

def call(attributes = {start: 0})
  url = "https://assmat.loire-atlantique.fr/jcms/parents/faire-une-recherche-d-assistante-maternelle-fr-r1_58176?idCommune=rp1_62646&codeInsee=44109&cities=44036&longitude=-1.56512&latitude=47.219901&cityName=Nantes&adresse=Passage+Louis+L%C3%A9vesque+44000+Nantes&distance=3000&month=1617200000000&age=1%7C17%7C2%7C3%7C10%7C15%7C16%7C19&branchesId=cra_67000&branchesId=cra_67001&branchesId=&nomassmat=&isSearch=Ok&hashKey=88&withDispo=true&withDispoFuture=true&withNonDispo=false&withDispoNonRenseigne=false&start=#{attributes[:start]}"

  unless false # File.file?('document.html')
    html_file = open(url).read
    html_doc = Nokogiri::HTML(html_file)
    File.write('document.html', html_doc.search('.amcontainer'))
  end

  file = 'document.html'
  html_doc = Nokogiri::HTML(File.open(file), nil, 'utf-8')

  assmats = []
  html_doc.search('.amcontainer').each do |amcontainer|
    data1 = amcontainer.search('.row-fluid')[0]
    data2 = amcontainer.search('.row-fluid')[1]
    assmat = {}
    assmat[:name] = data1.at_css('h2').text.strip
    assmat[:last_update] = data1.at_css('p').text.strip[-10..-1]
    quartier = data1.at_css('.quartier')
    assmat[:area] = data1.at_css('.quartier') ? quartier.text.strip[11..-1].split(" ").join(" ") : 'quartier inconnu'
    assmat[:distance] = data1.text.strip.match(/à (?<dist>.{1,4}) km/)[:dist].gsub(',','.').to_f

    data2 = data2.text.split(" ").join(" ")
    contact_details = data2.match(/(?<address>.*) Tél portable:(?<cell>.*) Courriel (?<available>.*) En savoir plus/) || {} # empty hash if nil
    assmat[:address] = contact_details[:address] || "NC"
    assmat[:cell] = contact_details[:cell] || "NC"
    assmat[:available] = contact_details[:available] || "NC"

    assmats << assmat
  end
  assmats
end
