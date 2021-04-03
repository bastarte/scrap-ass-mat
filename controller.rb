class Controller

  def import_from_web
    assmats = (1..10).to_a
    page = 0
    all_assmats = []
    while assmats.length == 10
      attributes = { start: page * 10 }
      page += 1
      assmats = call(attributes)
      pp assmats
      all_assmats += assmats
    end
    save_CSV(all_assmats)
  end

  private

  def save_CSV(assmats)
    pp assmats
    CSV.open("data.csv", "wb") do |csv|
      csv << assmats.first.keys # adds the attributes name on the first line
      assmats.each do |hash|
        csv << hash.values
      end
    end
  end
end
