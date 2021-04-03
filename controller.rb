class Controller
  def import_from_web
    page = 0
    all_assmats = []
    scrapper = ScrapperService.new
    loop do
      attributes = { start: page * 10 }
      page += 1
      assmats = scrapper.call(attributes)
      assmats.last == all_assmats.last ? break : all_assmats += assmats
    end
    save_csv(all_assmats)
  end

  private

  def save_csv(assmats)
    CSV.open("data.csv", "wb") do |csv|
      csv << assmats.first.keys # adds the attributes name on the first line
      assmats.each do |hash|
        csv << hash.values
      end
    end
  end
end
