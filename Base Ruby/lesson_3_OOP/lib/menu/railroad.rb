class RailRoad
  def initialize
    @stations = []
    @trains = []
    @wagons = []
    @routes = []
    puts WELOCOME
  end

  def start
    loop do
      system('clear')
      puts MENU[:main]
      puts '0 - Выйти из программы.'
      choice = gets.chomp
      break if choice == '0'
      next_menu(choice)
    end
  end

  private
  
  def next_menu(choice)
    case choice
    when '1' then create_menu
    when '2' then route_menu
    when '3' then train_menu 
    when '4' then puts_all
    end
  end

  def puts_all
    system('clear')
    puts 'Список поездов:'
    @trains.each { |train| show_train(train) }
    puts "\nСписок станций:"
    @stations.each do |item| 
      puts "- #{item.name} : Список ожидающих поездов: 
      Грузовые:" 
      item.list_train_by_type('cargo')
      puts '  Пассажирские:'
      item.list_train_by_type('passenger')
    end  
    puts 'Список маршрутов:'
    @routes.each_with_index do |route, index| 
      print "\n#{index} - "
      route.puts_stations
     end     
    puts "\nСписок вагонов:"
    @wagons.each { |item| puts "- #{item} : #{item.belongs_to}" }
    puts 'Нажмите Enter'
    wait = gets
  end

  def create_menu
    system('clear')
    puts MENU[:create]
    choice = gets.chomp
    case choice
    when '1' then create_station
    when '2' then create_train
    when '3' then create_route 
    when '4' then create_wagon
    when '5' then create_all
    end
  end

  def route_menu
    system('clear')
    return error 'Создайте маршрут' if @routes.size.zero?
    
    puts MENU[:route]
    choice = gets.chomp    
    @routes.each_with_index do |route, i|
      print "#{i} - "; route.puts_stations
    end

    puts "\nВыберите маршрут"
    route = gets.chomp.to_i
    return error 'Маршрут не выбран' unless (@routes[route] || !route.zero?)
    
    case choice
    when '1' then add_station_route(@routes[route])
    when '2' then rm_station_route(@routes[route])
    end
  end

  def add_station_route(route)
    stations = @stations - route.stations
    return error 'Создайте станцию' if stations.size.zero?
  
    stations.each_with_index do |station, i|
      puts "#{i} - #{station.name}"
    end

    puts 'Выберите станцию'
    station = gets.chomp.to_i
    route.add_station(stations[station])
  end

  def rm_station_route(route)
    return error 'У маршрута не может быть меньше 2х станций' if route.stations.size == 2
    
    route.stations.each_with_index do |station, i|
      puts "\n#{i} - #{station.name}"
    end
    puts 'Выберите станцию'
    station = gets.chomp.to_i
    route.rm_staion(route.stations[station])
  end

  def train_menu
    system('clear')
    return error 'Создайте поезд' if @trains.size.zero?

    puts MENU[:train]
    choice = gets.chomp
    @trains.each_with_index do |train, i|
      puts "#{i} - #{train.number}:#{train.type}"
    end
    puts 'Выберите поезд'
    train = gets.chomp.to_i
    case choice
    when '1' then assign_route_train(@trains[train])
    when '2' then hook_wagon(@trains[train])
    when '3' then unhook_wagon(@trains[train])
    when '4' then move(@trains[train]) 
    end
  end

  def assign_route_train(train)
    return error 'Создайте маршрут' if @routes.size.zero?
   
    puts 'Выберите порядковый номер маршрута'
    @routes.each_with_index { |route, i| puts "#{i+1} - #{route}" }
    route = gets.chomp.to_i
    return error 'Выбор некорректен' unless (@routes[route - 1] || route.zero?)

    train.add_route(@routes[route - 1])
  end

  def move(train)
    return error 'У поезда нет маршрута' if train.route.nil?
    
    puts "Куда едим? \n  1 - Вперед\n  2 - Назад"
    dir = gets.chomp.to_i
    train.move_forward if dir == 1
    train.move_back if dir == 2
  end

  def hook_wagon(train)
    return error 'Создайте вагон' if @wagons.size.zero?
    
    wagons = @wagons.select do |wagon| 
      wagon.type == train.type && wagon.belongs_to.nil?
    end    
    wagons.each_with_index do |wagon, i|     
        puts "#{i} - #{wagon} : #{wagon.type}"
    end
    puts 'Выберите порядковый номер вагона'
    wagon = gets.chomp.to_i
    return error 'Выбор некорректен' unless wagons[wagon]

    train.hook_wagon(wagons[wagon])
  end

  def unhook_wagon(train)
    return error 'Не чего отцеплять' if train.wagons.size.zero?

    puts 'Выберите порядковый номер вагона'
    train.wagons.each_with_index do |wagon, i|
      puts "#{i} - #{wagon} : #{wagon.type}"
    end
    wagon = gets.chomp.to_i
    return error 'Выбор некорректен' unless train.wagons[wagon]
    
    train.unhook_wagon(train.wagons[wagon])
  end

  def create_station
    puts 'Название станции'
    name = gets.chomp
    return error 'Станция должна иметь название' if name == ''

    @stations << Station.new(name)
  end

  def create_train
    puts MENU[:type]
    type = gets.chomp.to_i
    return unless [1, 2].include?(type)

    begin
      puts "Введите номер поезда\n 
      Формат номера \"777-77\" (Номер может состоять из букв и цифр)"
      name = gets.chomp
      @trains << PassengerTrain.new(name) if type == 1
      @trains << CargoTrain.new(name) if type == 2
      puts "Создан поезд #{@trains[-1].number}"
    rescue => exception
      puts exception
      retry      
    end    
  end

  def create_route    
    return error 'Создайте 2 станции' if @stations.size < 2
    
    @stations.each_with_index { |station, i| puts "#{i} - #{station.name}" }
    puts 'Выберите начальную станцию'
    start = gets.chomp.to_i    
    puts 'Выберите конечную станцию'
    finish = gets.chomp.to_i

    if ((0...@stations.size).include?(finish) && (0...@stations.size).include?(start))
      if Station.all[start] == Station.all[finish]
        puts 'Нельзя создать маршрут с 1 станцией'
        enter = gets
        return
      end
      @routes << Route.new(Station.all[start], Station.all[finish])
    else
      puts 'Выбор станций не корректен'
      enter = gets
      return
    end    
  end

  def create_wagon
    puts MENU[:type]
    type = gets.chomp.to_i
    @wagons << PassengerWagon.new if type == 1 
    @wagons << CargoTrain.new if type == 2
  end

  def create_all
    @wagons << Wagon.new('passenger')
    @wagons << Wagon.new('cargo')
    @trains << Train.new('Train 0001', 'passenger')
    @trains << Train.new('Train 0002', 'cargo')
    @stations << Station.new('Трансильвания')
    @stations << Station.new('Пенсильвания')
    @routes << Route.new(@stations[0], @stations[1])
  end

  def show_train(train)  
    puts "\n#{train.type}: #{train.number}"
    count = train.wagons.size
    puts "Кол-во вагонов: #{count}" 
    puts WAGONS[count]   
  end

  def error(message)
    puts message
    enter = gets    
  end
end
