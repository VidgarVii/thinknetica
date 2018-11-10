class Adapter
  def initialize
    @stations = []
    @trains = { pass: [], cargo: [] }
    @wagon = { pass: [], cargo: [] }
    @routes = []
  end
  
  def mk_station(name = "State #{rand(100)}")    
    @stations << Station.new(name)
  end

  def mk_train(type, number = "Train #{rand(100)}")
    @trains[:cargo] << CargoTrain.new(number) if type == 'cargo'
    @trains[:pass] << PassengerTrain.new(number) if type == 'pass'
  end
  
  def mk_route(st1, st2)
    return puts 'Создайте как минимум 2 станции' if @stations.size < 2
    @routes << Route.new(st1, st2)
  end
  
  def mk_wagon(type)
    @wagon[:cargo] << CargoWagon.new if type == 'cargo'
    @wagon[:pass] << PassengerWagon.new if type == 'pass'    
  end
  
  def add_state_to_route(state, route = 0)
    @routes[route].add_station(state)
  end

  def rm_state_from_route(state, route = 0)
    @routes[route].rm_staion(state)
  end
  
  def assign_route(train, route = 0)
    train.add_route(route)
  end
  
  def hook_wagon(train, count = 1)    
  end

  def unhook_wagon(train, count = 1)    
  end

  def move(train, direction)
    train.move_forward if direction == 'forward'
    train.move_back if direction == 'backward'
  end

  def puts_all
    puts 'Список поездов:'
    puts @trains
    puts 'Список станций:'
    puts @stations
    puts 'Список маршрутов:'
    puts @routes
    puts 'Список вагонов:'
    puts @wagon
  end
  
  private

end