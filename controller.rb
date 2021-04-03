class Controller
  def import_from_web
    data = call
    save_CSV(data)
  end
end
